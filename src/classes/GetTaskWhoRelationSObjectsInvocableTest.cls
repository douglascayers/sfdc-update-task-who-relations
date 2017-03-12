/**
 * Developed by Doug Ayers
 * github.com/douglascayers
 */
@isTest
private class GetTaskWhoRelationSObjectsInvocableTest {

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

        Task tsk = new Task(
            subject = 'Hello World'
        );

        insert tsk;

        // The TaskWhoRelation object is a view over the TaskRelation object filtered to just Contacts and Leads
        // Another nuance of the TaskWhoRelation object is that it seems to be populated asynchronously.
        // Since the data in that object may not be immediately available then our tests fail.
        // As workaround, we create our own in-memory list of TaskWhoRelations as if we had queried them.

        List<TaskRelation> relations = new List<TaskRelation>();

        relations.add( new TaskRelation(
            taskId = tsk.id,
            relationId = cont.id
        ));

        Test.startTest();

        GetTaskWhoRelationSObjectsInvocable.Request req = new GetTaskWhoRelationSObjectsInvocable.Request();
        req.relations = relations;

        List<GetTaskWhoRelationSObjectsInvocable.Request> requests = new GetTaskWhoRelationSObjectsInvocable.Request[] { req };

        List<GetTaskWhoRelationSObjectsInvocable.Response> responses = GetTaskWhoRelationSObjectsInvocable.execute( requests );

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

        Task tsk = new Task(
            subject = 'Hello World'
        );

        insert tsk;

        // The TaskWhoRelation object is a view over the TaskRelation object filtered to just Contacts and Leads
        // Another nuance of the TaskWhoRelation object is that it seems to be populated asynchronously.
        // Since the data in that object may not be immediately available then our tests fail.
        // As workaround, we create our own in-memory list of TaskWhoRelations as if we had queried them.

        List<TaskRelation> relations = new List<TaskRelation>();

        relations.add( new TaskRelation(
            taskId = tsk.id,
            relationId = ld.id
        ));

        Test.startTest();

        GetTaskWhoRelationSObjectsInvocable.Request req = new GetTaskWhoRelationSObjectsInvocable.Request();
        req.relations = relations;

        List<GetTaskWhoRelationSObjectsInvocable.Request> requests = new GetTaskWhoRelationSObjectsInvocable.Request[] { req };

        List<GetTaskWhoRelationSObjectsInvocable.Response> responses = GetTaskWhoRelationSObjectsInvocable.execute( requests );

        Test.stopTest();

        System.assertEquals( 1, responses.size() );
        System.assertEquals( null, responses[0].contacts );
        System.assertEquals( 1, responses[0].leads.size() );

    }

}