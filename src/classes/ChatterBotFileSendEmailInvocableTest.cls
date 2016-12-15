@isTest
private class ChatterBotFileSendEmailInvocableTest {

    @isTest
    static void test_send_email() {

        ContentVersion cv1 = new ContentVersion(
            title = 'Test Title',
            description = 'Test Description',
            pathOnClient = '/test.txt',
            versionData = Blob.valueOf( 'Hello World' )
        );

        insert cv1;

        ContentDocument cd = [ SELECT id FROM ContentDocument ];

        Chatter_Bot_File__c cbf = new Chatter_Bot_File__c(
            content_document_id__c = cd.id,
            active__c = true
        );

        insert cbf;

        ContentVersion cv2 = new ContentVersion(
            contentDocumentId = cd.id,
            title = 'Test Title 2',
            description = 'Test Description 2',
            pathOnClient = '/test2.txt',
            versionData = Blob.valueOf( 'Hello World 2' ),
            reasonForChange = 'test update'
        );

        insert cv2;

        Test.startTest();

        Chatter_Bot_File__c botFile = [ SELECT id, active__c, content_document_id__c, content_version_id__c, title__c, description__c, version_number__c, reason_for_change__c FROM Chatter_Bot_File__c ];

        ChatterBotFileSendEmailInvocable.Request req = new ChatterBotFileSendEmailInvocable.Request();
        req.chatterBotFile = botFile;
        req.attachFile = true;
        req.emailTemplateName = 'Chatter_Bot_File_Template';
        req.toAddresses = new List<String>{ UserInfo.getUserEmail() };
        req.ccAddresses = new List<String>{ UserInfo.getUserEmail() };
        req.bccAddresses = new List<String>{ UserInfo.getUserEmail() };

        ChatterBotFileSendEmailInvocable.execute( new ChatterBotFileSendEmailInvocable.Request[] { req } );

        Test.stopTest();

    }

}