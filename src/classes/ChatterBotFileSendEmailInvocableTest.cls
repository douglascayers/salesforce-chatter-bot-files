@isTest
private class ChatterBotFileSendEmailInvocableTest {

    @isTest
    static void test_send_email() {

        ContentVersion cv = new ContentVersion(
            title = 'Test Title',
            description = 'Test Description',
            pathOnClient = '/test.txt',
            versionData = Blob.valueOf( 'Hello World' ),
            reasonForChange = 'Test Reason'
        );

        insert cv;

        Chatter_Bot_File__c botFile = [ SELECT id, content_document_id__c, content_version_id__c, title__c, reason_for_change__c, version_number__c FROM Chatter_Bot_File__c ];

        Test.startTest();

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