@isTest
private class ChatterBotFileFollowersInvocableTest {

    @isTest
    static void test_get_emails() {

        ContentVersion cv = new ContentVersion(
            title = 'Test Title',
            description = 'Test Description',
            pathOnClient = '/test.txt',
            versionData = Blob.valueOf( 'Hello World' ),
            reasonForChange = 'Test Reason'
        );

        insert cv;

        ContentDocument cd = [ SELECT id FROM ContentDocument WHERE latestPublishedVersionId = :cv.id ];

        EntitySubscription follower = new EntitySubscription(
            parentId = cd.id,
            subscriberId = UserInfo.getUserId()
        );

        insert follower;

        Test.startTest();

        ChatterBotFileFollowersInvocable.Request req = new ChatterBotFileFollowersInvocable.Request();
        req.contentDocumentId = cd.id;

        List<ChatterBotFileFollowersInvocable.Response> responses = ChatterBotFileFollowersInvocable.execute( new ChatterBotFileFollowersInvocable.Request[] { req } );

        Test.stopTest();

        System.assertEquals( 1, responses.size() );
        System.assert( new Set<String>( responses[0].emailAddresses ).contains( UserInfo.getUserEmail() ) );

    }

}