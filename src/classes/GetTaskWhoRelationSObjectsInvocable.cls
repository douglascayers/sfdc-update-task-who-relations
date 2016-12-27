/**
 * Developed by Doug Ayers
 * github.com/douglascayers
 */
public class GetTaskWhoRelationSObjectsInvocable {

    @InvocableMethod(
        label = 'Get Contact/Lead SObject Collections'
        description = 'Separates TaskRelations into two lists: one of Contacts and one of Leads.'
    )
    public static List<Response> execute( List<Request> requests ) {

        String contactKeyPrefix = Contact.sObjectType.getDescribe().getKeyPrefix();
        String leadKeyPrefix = Lead.sObjectType.getDescribe().getKeyPrefix();

        List<Response> responses = new List<Response>();

        for ( Request req : requests ) {

            System.debug( req );

            Response res = new Response();
            res.contacts = new List<Contact>();
            res.leads = new List<Lead>();

            for ( TaskRelation relation : req.relations ) {

                String relationKeyPrefix = String.valueOf( relation.relationId ).left( 3 );

                if ( contactKeyPrefix == relationKeyPrefix ) {

                    res.contacts.add( new Contact( id = relation.relationId ) );

                } else if ( leadKeyPrefix == relationKeyPrefix ) {

                    res.leads.add( new Lead( id = relation.relationId ) );

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

    // ---------------------------------------------------

    public class Request {

        // Ideally, I wanted this to be list of TaskWhoRelation object
        // since that's pre-filtered to just Contacts and Leads
        // but that was impossible to unit test because that data
        // is inserted asynchronously by Salesforce and the sobject
        // fields were not writeable in apex.

        @InvocableVariable(
            label = 'Task Relations'
            description = 'SObject Collection of TaskRelation records.'
            required = true
        )
        public List<TaskRelation> relations;

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