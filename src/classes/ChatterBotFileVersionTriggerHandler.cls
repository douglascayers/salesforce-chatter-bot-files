/**
 * At the time of this writing, Process Builder does not support
 * ContentDocument, ContentVersion, or ContentNote objects.
 *
 * As workaround we implemented a trigger that syncs record changes
 * to ContentVersion object to a custom object, Chatter_Bot_File__c.
 * Process Builder supports all custom objects so voila!
 *
 * You can vote for this to become standard feature here:
 * https://success.salesforce.com/ideaView?id=0873A000000E35YQAS
 */
public with sharing class ChatterBotFileVersionTriggerHandler {

    public void createChatterBotFiles( List<ContentVersion> contentVersions ) {

        // do any chatter bot files exist for these document ids?
        // if yes then we should update those records, else ignore

        Set<String> contentDocumentIds = new Set<String>();
        for ( ContentVersion version : contentVersions ) {
            contentDocumentIds.add( version.contentDocumentId );
            contentDocumentIds.add( String.valueOf( version.contentDocumentId ).left( 15 ) );
        }

        // content document id => chatter bot file
        Map<ID, Chatter_Bot_File__c> contentDocumentToChatterBotFileMap = new Map<ID, Chatter_Bot_File__c>();
        for ( Chatter_Bot_File__c chatterBotFile : [
            SELECT
                id, content_document_id__c
            FROM
                Chatter_Bot_File__c
            WHERE
                active__c = true
                AND
                content_document_id__c IN :contentDocumentIds
        ]) {
            contentDocumentToChatterBotFileMap.put( chatterBotFile.content_document_id__c, chatterBotFile );
        }

        // Note that the content version records provided to us by the trigger
        // do not have their FileExtension field populated. If you need to know
        // that value then you must re-query for the ContentVersions here.
        // I have no idea why that is.

        for ( ContentVersion version : contentVersions ) {

            System.debug( version );

            Chatter_Bot_File__c chatterBotFile = contentDocumentToChatterBotFileMap.get( version.contentDocumentId );

            if ( chatterBotFile != null ) {
                chatterBotFile.content_document_id__c = version.contentDocumentId;
                chatterBotFile.content_version_id__c = version.id;
                chatterBotFile.title__c = version.title;
                chatterBotFile.description__c = version.description;
                chatterBotFile.version_number__c = version.versionNumber;
                chatterBotFile.reason_for_change__c = version.reasonForChange;
                chatterBotFile.file_type__c = version.fileType;
            }

        }

        if ( contentDocumentToChatterBotFileMap.values().size() > 0 ) {
            update contentDocumentToChatterBotFileMap.values();
        }

    }

    public void deleteChatterBotFiles( List<ContentDocument> contentDocuments ) {

        Set<ID> contentDocumentIds = new Set<ID>();

        for ( ContentDocument document : contentDocuments ) {
            contentDocumentIds.add( document.id );
        }

        delete [ SELECT id FROM Chatter_Bot_File__c WHERE content_document_id__c IN :contentDocumentIds ];

    }

}