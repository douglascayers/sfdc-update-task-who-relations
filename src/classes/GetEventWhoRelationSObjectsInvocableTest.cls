/**
 * Developed by Doug Ayers
 * github.com/douglascayers
 */
@isTest
private class GetEventWhoRelationSObjectsInvocableTest {

    @isTest
    static void test_get_contacts() {

        Account acct = new Account(
            name = 'Salesforce'
        );

        insert acct;

        Contact cont = new Contact(
            accountId = acct.id,
            firstName = 'Marc',
            lastName = 'Benioff'
        );

        insert cont;

        Event evt = new Event(
            subject = 'Hello World',
            startDateTime = DateTime.now(),
            endDateTime = DateTime.now().addHours( 1 )
        );

        insert evt;

        // The EventWhoRelation object is a view over the EventRelation object filtered to just Contacts and Leads
        // Another nuance of the EventWhoRelation object is that it seems to be populated asynchronously.
        // Since the data in that object may not be immediately available then our tests fail.
        // As workaround, we create our own in-memory list of EventWhoRelations as if we had queried them.

        List<EventRelation> relations = new List<EventRelation>();

        relations.add( new EventRelation(
            eventId = evt.id,
            relationId = cont.id
        ));

        Test.startTest();

        GetEventWhoRelationSObjectsInvocable.Request req = new GetEventWhoRelationSObjectsInvocable.Request();
        req.relations = relations;

        List<GetEventWhoRelationSObjectsInvocable.Request> requests = new GetEventWhoRelationSObjectsInvocable.Request[] { req };

        List<GetEventWhoRelationSObjectsInvocable.Response> responses = GetEventWhoRelationSObjectsInvocable.execute( requests );

        Test.stopTest();

        System.assertEquals( 1, responses.size() );
        System.assertEquals( 1, responses[0].contacts.size() );
        System.assertEquals( null, responses[0].leads );

    }

    @isTest
    static void test_get_leads() {

        Lead ld = new Lead(
            company = 'Salesforce',
            firstName = 'Parker',
            lastName = 'Harris'
        );

        insert ld;

        Event evt = new Event(
            subject = 'Hello World',
            startDateTime = DateTime.now(),
            endDateTime = DateTime.now().addHours( 1 )
        );

        insert evt;

        // The EventWhoRelation object is a view over the EventRelation object filtered to just Contacts and Leads
        // Another nuance of the EventWhoRelation object is that it seems to be populated asynchronously.
        // Since the data in that object may not be immediately available then our tests fail.
        // As workaround, we create our own in-memory list of EventWhoRelations as if we had queried them.

        List<EventRelation> relations = new List<EventRelation>();

        relations.add( new EventRelation(
            eventId = evt.id,
            relationId = ld.id
        ));

        Test.startTest();

        GetEventWhoRelationSObjectsInvocable.Request req = new GetEventWhoRelationSObjectsInvocable.Request();
        req.relations = relations;

        List<GetEventWhoRelationSObjectsInvocable.Request> requests = new GetEventWhoRelationSObjectsInvocable.Request[] { req };

        List<GetEventWhoRelationSObjectsInvocable.Response> responses = GetEventWhoRelationSObjectsInvocable.execute( requests );

        Test.stopTest();

        System.assertEquals( 1, responses.size() );
        System.assertEquals( null, responses[0].contacts );
        System.assertEquals( 1, responses[0].leads.size() );

    }

}