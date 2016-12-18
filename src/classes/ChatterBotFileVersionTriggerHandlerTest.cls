@isTest
private class ChatterBotFileVersionTriggerHandlerTest {

    @isTest
    static void test_auto_create_chatter_bot_file() {

        Chatter_Bot_Files_Setting__c settings = Chatter_Bot_Files_Setting__c.getInstance();
        settings.auto_create_chatter_bot_file_records__c = true;
        upsert settings;

        Test.startTest();

        ContentVersion cv = new ContentVersion(
            title = 'Test Title',
            description = 'Test Description',
            pathOnClient = '/test.txt',
            versionData = Blob.valueOf( 'Hello World' )
        );

        insert cv;

        Test.stopTest();

        ContentDocument cd = [ SELECT id FROM ContentDocument ];

        System.assertEquals( 1, [ SELECT count() FROM Chatter_Bot_File__c WHERE content_document_id__c = :cd.id ] );

    }

    @isTest
    static void test_no_auto_create_chatter_bot_file() {

        Chatter_Bot_Files_Setting__c settings = Chatter_Bot_Files_Setting__c.getInstance();
        settings.auto_create_chatter_bot_file_records__c = false;
        upsert settings;

        Test.startTest();

        ContentVersion cv = new ContentVersion(
            title = 'Test Title',
            description = 'Test Description',
            pathOnClient = '/test.txt',
            versionData = Blob.valueOf( 'Hello World' )
        );

        insert cv;

        Test.stopTest();

        ContentDocument cd = [ SELECT id FROM ContentDocument ];

        System.assertEquals( 0, [ SELECT count() FROM Chatter_Bot_File__c WHERE content_document_id__c = :cd.id ] );

    }

    @isTest
    static void test_update_file() {

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

        Test.startTest();

        ContentVersion cv2 = new ContentVersion(
            contentDocumentId = cd.id,
            title = 'Test Title 2',
            description = 'Test Description 2',
            pathOnClient = '/test2.txt',
            versionData = Blob.valueOf( 'Hello World 2' ),
            reasonForChange = 'test update'
        );

        insert cv2;

        Test.stopTest();

        Chatter_Bot_File__c file = [ SELECT content_document_id__c, content_version_id__c, title__c, description__c, version_number__c, reason_for_change__c, file_type__c FROM Chatter_Bot_File__c ];
        ContentVersion cv = [ SELECT id, contentDocumentId, title, description, versionNumber, reasonForChange, fileType FROM ContentVersion WHERE id = :cv2.id ];

        System.assertEquals( cv.id, file.content_version_id__c );
        System.assertEquals( cv.contentDocumentId, file.content_document_id__c );
        System.assertEquals( cv.title, file.title__c );
        System.assertEquals( cv.description, file.description__c );
        System.assertEquals( cv.versionNumber, file.version_number__c );
        System.assertEquals( cv.reasonForChange, file.reason_for_change__c );
        System.assertEquals( cv.fileType, file.file_type__c );

    }

    @isTest
    static void test_delete_file() {

        ContentVersion cv1 = new ContentVersion(
            title = 'Test Title',
            description = 'Test Description',
            pathOnClient = '/test.txt',
            versionData = Blob.valueOf( 'Hello World' )
        );

        insert cv1;

        ContentDocument cd = [ SELECT id FROM ContentDocument ];

        Test.startTest();

        delete cd;

        Test.stopTest();

        System.assertEquals( 0, [ SELECT count() FROM Chatter_Bot_File__c ] );

    }

}