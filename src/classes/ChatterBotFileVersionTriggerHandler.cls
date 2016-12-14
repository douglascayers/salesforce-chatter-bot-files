public with sharing class ChatterBotFileVersionTriggerHandler {

    public void createChatterBotFiles( List<ContentVersion> contentVersions ) {

        List<Chatter_Bot_File__c> files = new List<Chatter_Bot_File__c>();

        // Note that the content version records provided to us by the trigger
        // do not have their FileExtension field populated. If you need to know
        // that value then you must re-query for the ContentVersions here.
        // I have no idea why that is.

        for ( ContentVersion version : contentVersions ) {

            System.debug( version );

            files.add( new Chatter_Bot_File__c(
                content_document_id__c = version.contentDocumentId,
                title__c = version.title,
                description__c = version.description,
                version_number__c = version.versionNumber,
                reason_for_change__c = version.reasonForChange,
                file_type__c = version.fileType
            ));

        }

        Database.upsert( files, Chatter_Bot_File__c.Content_Document_ID__c );

    }

    public void deleteChatterBotFiles( List<ContentDocument> contentDocuments ) {

        Set<ID> contentDocumentIds = new Set<ID>();

        for ( ContentDocument document : contentDocuments ) {
            contentDocumentIds.add( document.id );
        }

        delete [ SELECT id FROM Chatter_Bot_File__c WHERE content_document_id__c IN :contentDocumentIds ];

    }

}