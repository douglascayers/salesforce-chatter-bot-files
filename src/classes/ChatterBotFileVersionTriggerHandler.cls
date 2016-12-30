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
 *
 * Note, 'without sharing' is used in this class.
 * Most users will not have sharing access to the Chatter_Bot_File__c object
 * but we want to ensure this trigger handler can update those records when any
 * user uploads a new file.
 * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_keywords_sharing.htm
 */
public without sharing class ChatterBotFileVersionTriggerHandler {

    public void createChatterBotFiles( List<ContentVersion> contentVersions ) {

        // do any chatter bot files exist for these document ids?
        // if yes then we should update those records, else ignore
        // unless custom setting says to auto create records anyways

        // When filtering on lookup fields, Salesforce has special
        // handling to treat 15 and 18 character IDs the same.
        // Since our query is on a text field and not an ID lookup field
        // then we have to handle both 15 and 18 character IDs as unique
        // values in our filter criteria.
        Set<String> contentDocumentIds = new Set<String>();
        for ( ContentVersion version : contentVersions ) {
            contentDocumentIds.add( version.contentDocumentId );
            contentDocumentIds.add( String.valueOf( version.contentDocumentId ).left( 15 ) );
        }

        // content document id => chatter bot file
        Map<ID, Chatter_Bot_File__c> contentDocumentToChatterBotFileMap = new Map<ID, Chatter_Bot_File__c>();
        for ( Chatter_Bot_File__c chatterBotFile : [
            SELECT
                id, content_document_id__c, active__c
            FROM
                Chatter_Bot_File__c
            WHERE
                content_document_id__c IN :contentDocumentIds
        ]) {
            contentDocumentToChatterBotFileMap.put( chatterBotFile.content_document_id__c, chatterBotFile );
        }

        Chatter_Bot_Files_Setting__c settings = Chatter_Bot_Files_Setting__c.getInstance();
        Boolean autoCreateChatterBotFiles = ( settings != null && settings.auto_create_chatter_bot_file_records__c );

        List<Chatter_Bot_File__c> chatterBotFilesToUpsert = new List<Chatter_Bot_File__c>();

        for ( ContentVersion version : contentVersions ) {

            System.debug( version );

            Chatter_Bot_File__c chatterBotFile = contentDocumentToChatterBotFileMap.get( version.contentDocumentId );

            if ( chatterBotFile == null ) {

                System.debug( 'No Chatter Bot File record matches content document id: ' + version.contentDocumentId );
                System.debug( 'Should auto create Chatter Bot File? ' + autoCreateChatterBotFiles + '. This option is controlled by Chatter_Bot_Files_Setting__c custom setting.' );

                if ( autoCreateChatterBotFiles ) {
                    chatterBotFile = new Chatter_Bot_File__c(
                        active__c = true
                    );
                }

            }

            if ( chatterBotFile != null && chatterBotFile.active__c ) {

                // Note that the content version records provided to us by the trigger
                // do not have their FileExtension field populated (not sure why). If you need to know
                // that value then you must re-query for the ContentVersions in the trigger.
                // To avoid that extra complexity, and not sure any benefit anyways,
                // we just avoid mapping file extension.

                chatterBotFile.content_document_id__c = version.contentDocumentId;
                chatterBotFile.content_version_id__c = version.id;
                chatterBotFile.title__c = version.title;
                chatterBotFile.description__c = version.description;
                chatterBotFile.version_number__c = version.versionNumber;
                chatterBotFile.reason_for_change__c = version.reasonForChange;
                chatterBotFile.file_type__c = version.fileType;

                chatterBotFilesToUpsert.add( chatterBotFile );

            }

        }

        if ( chatterBotFilesToUpsert.size() > 0 ) {
            Database.upsert( chatterBotFilesToUpsert, Chatter_Bot_File__c.Content_Document_ID__c );
        }

    }

    public void deleteChatterBotFiles( List<ContentDocument> contentDocuments ) {

        // When filtering on lookup fields, Salesforce has special
        // handling to treat 15 and 18 character IDs the same.
        // Since our query is on a text field and not an ID lookup field
        // then we have to handle both 15 and 18 character IDs as unique
        // values in our filter criteria.
        Set<String> contentDocumentIds = new Set<String>();
        for ( ContentDocument document : contentDocuments ) {
            contentDocumentIds.add( document.id );
            contentDocumentIds.add( String.valueOf( document.id ).left( 15 ) );
        }

        delete [ SELECT id FROM Chatter_Bot_File__c WHERE content_document_id__c IN :contentDocumentIds ];

    }

}