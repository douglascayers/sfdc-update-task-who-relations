/**
 * Developed by Doug Ayers
 * github.com/douglascayers
 */
public class GetEventWhoRelationSObjectsInvocable {

    @InvocableMethod(
        label = 'Get Contact/Lead SObject Collections'
        description = 'Separates EventRelations into two lists: one of Contacts and one of Leads.'
    )
    public static List<Response> execute( List<Request> requests ) {

        String contactKeyPrefix = Contact.sObjectType.getDescribe().getKeyPrefix();
        String leadKeyPrefix = Lead.sObjectType.getDescribe().getKeyPrefix();

        Set<ID> contactIds = new Set<ID>();
        Set<ID> leadIds = new Set<ID>();

        Map<ID, Contact> contactsMap = new Map<ID, Contact>();
        Map<ID, Lead> leadsMap = new Map<ID, Lead>();

        List<Response> responses = new List<Response>();

        for ( Request req : requests ) {

            for ( EventRelation relation : req.relations ) {

                String relationKeyPrefix = String.valueOf( relation.relationId ).left( 3 );

                if ( contactKeyPrefix == relationKeyPrefix ) {

                    contactIds.add( relation.relationId );

                } else if ( leadKeyPrefix == relationKeyPrefix ) {

                    leadIds.add( relation.relationId );

                }

            }

        }

        if ( contactIds.size() > 0 ) {

            List<String> contactFieldNames = getFieldNames( SObjectType.Contact.fieldSets.Task_Event_Who_Relation_Flow_Fields );

            String query = ' SELECT ' + String.join( contactFieldNames, ', ' ) + ' FROM Contact WHERE id IN :contactIds ';
            System.debug( 'contact query: ' + query );

            contactsMap = new Map<ID, Contact>( (List<Contact>) Database.query( query ) );

            // for efficiency, salesforce does not populate fields on sobjects when queried
            // if their values in the database is null. That's fine, I get it. But, this hurts us
            // when we try to reference these null fields we queried in Process Builder or Flow
            // because we get error "The flow failed to access the value for <some field> because it hasn't been set or assigned."
            // So, to force salesforce to acknowledge these null fields have been "set or assigned"
            // then if they are null then we'll perform a set here in the code.
            // We aren't changing the value from anything it wasn't already, but this causes Flow
            // to now "see" that the field is set or assigned and not blow up.
            for ( Contact record : contactsMap.values() ) {
                for ( String fieldName : contactFieldNames ) {
                    if ( record.get( fieldName ) == null ) {
                        record.put( fieldName, null ); // force acknowledgement of field being set
                    }
                }
            }

        }

        if ( leadIds.size() > 0 ) {

            List<String> leadFieldNames = getFieldNames( SObjectType.Lead.fieldSets.Task_Event_Who_Relation_Flow_Fields );

            String query = ' SELECT ' + String.join( leadFieldNames, ', ' ) + ' FROM Lead WHERE id IN :leadIds ';
            System.debug( 'lead query: ' + query );

            leadsMap = new Map<ID, Lead>( (List<Lead>) Database.query( query ) );

            // for efficiency, salesforce does not populate fields on sobjects when queried
            // if their values in the database is null. That's fine, I get it. But, this hurts us
            // when we try to reference these null fields we queried in Process Builder or Flow
            // because we get error "The flow failed to access the value for <some field> because it hasn't been set or assigned."
            // So, to force salesforce to acknowledge these null fields have been "set or assigned"
            // then if they are null then we'll perform a set here in the code.
            // We aren't changing the value from anything it wasn't already, but this causes Flow
            // to now "see" that the field is set or assigned and not blow up.
            for ( Lead record : leadsMap.values() ) {
                for ( String fieldName : leadFieldNames ) {
                    if ( record.get( fieldName ) == null ) {
                        record.put( fieldName, null ); // force acknowledgement of field being set
                    }
                }
            }

        }

        System.debug( 'contactsMap: ' + contactsMap );
        System.debug( 'leadsMap: ' + leadsMap );

        for ( Request req : requests ) {

            System.debug( req );

            Response res = new Response();
            res.contacts = new List<Contact>();
            res.leads = new List<Lead>();

            for ( EventRelation relation : req.relations ) {

                String relationKeyPrefix = String.valueOf( relation.relationId ).left( 3 );

                if ( contactKeyPrefix == relationKeyPrefix ) {

                    res.contacts.add( contactsMap.get( relation.relationId ) );

                } else if ( leadKeyPrefix == relationKeyPrefix ) {

                    res.leads.add( leadsMap.get( relation.relationId ) );

                }

            }

            // because Flow Decisions can't check for list size
            // but only if a list is null or not then if empty
            // we want to set to null the contact or lead list

            if ( res.contacts.isEmpty() ) {
                res.contacts = null;
            }

            if ( res.leads.isEmpty() ) {
                res.leads = null;
            }

            System.debug( res );

            responses.add( res );

        }

        return responses;
    }

    private static List<String> getFieldNames( FieldSet fs ) {

        List<String> fieldNames = new List<String>();

        for ( FieldSetMember fsm : fs.getFields() ) {
            fieldNames.add( fsm.getFieldPath() );
        }

        return fieldNames;
    }

    // ---------------------------------------------------

    public class Request {

        // Ideally, I wanted this to be list of EventWhoRelation object
        // since that's pre-filtered to just Contacts and Leads
        // but that was impossible to unit test because that data
        // is inserted asynchronously by Salesforce and the sobject
        // fields were not writeable in apex.

        @InvocableVariable(
            label = 'Event Relations'
            description = 'SObject Collection of EventRelation records.'
            required = true
        )
        public List<EventRelation> relations;

    }

    public class Response {

        @InvocableVariable(
            label = 'Contacts'
            description = 'SObject Collection of Contact records. If no contacts then will be null.'
        )
        public List<Contact> contacts;

        @InvocableVariable(
            label = 'Leads'
            description = 'SObject Collection of Lead records. If no leads then will be null.'
        )
        public List<Lead> leads;

    }

}