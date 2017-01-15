/**
 * Designed to be invoked by Flow or Process Builder to send an email
 * to specified addresses in the context of a single Chatter Bot File record.
 *
 * The email content is configurable via email template.
 *
 * This is a workaround because EmailTemplates cannot be created for
 * the ContentDocument, ContentVersion, or ContentNote objects.
 * And, when trying to send HTML formatted emails from Flow it renders wrong.
 *
 * IdeaExchange: Vote early, vote often!
 *      - https://success.salesforce.com/ideaView?id=0873A000000E35YQAS
 *      - https://success.salesforce.com/issues_view?id=a1p300000008XFtAAM
 */
public with sharing class ChatterBotFileSendEmailInvocable {

    @InvocableMethod(
        label = 'CB: Send Email to File Followers'
        description = 'A way to send emails to people about changes to Content Documents by using Chatter Bot for Files.'
    )
    public static void execute( List<Request> requests ) {

        System.debug( 'Send email requests: ' + requests );

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

        Map<String, EmailTemplate> emailTemplateMap = new Map<String, EmailTemplate>();

        Set<String> emailTemplateNames = new Set<String>();

        for ( Request req : requests ) {

            if ( String.isNotBlank( req.emailTemplateName ) ) {
                emailTemplateNames.add( req.emailTemplateName );
            }

        }

        for ( EmailTemplate template : [ SELECT id, developerName FROM EmailTemplate WHERE developerName IN :emailTemplateNames ] ) {
            emailTemplateMap.put( template.developerName, template );
        }

        for ( Request req : requests ) {

            EmailTemplate template = emailTemplateMap.get( req.emailTemplateName );

            Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(
                template.id,
                UserInfo.getUserId(),
                req.chatterBotFile.id
            );

            if ( req.toAddresses != null && req.toAddresses.size() > 0 ) {
                message.setToAddresses( req.toAddresses );
            }

            if ( req.ccAddresses != null && req.ccAddresses.size() > 0 ) {
                message.setCcAddresses( req.ccAddresses );
            }

            if ( req.bccAddresses != null && req.bccAddresses.size() > 0 ) {
                message.setBccAddresses( req.bccAddresses );
            }

            if ( req.attachFile != null && req.attachFile ) {
                message.setEntityAttachments( new List<String>{ req.chatterBotFile.content_version_id__c } );
            }

            messages.add( message );

        }

        System.debug( 'Sending email: ' + messages );

        Messaging.sendEmail( messages );

    }

    // -------------------------------------------------------------

    public class Request {

        @InvocableVariable(
            label = 'Chatter Bot File'
            description = 'Record that represents the content document version update to notify people about'
            required = true
        )
        public Chatter_Bot_File__c chatterBotFile;

        @InvocableVariable(
            label = 'Email Template Unique Name'
            description = 'Developer Name of an email template using Chatter_Bot_File__c merge fields.'
            required = true
        )
        public String emailTemplateName;

        @InvocableVariable(
            label = 'To Addresses'
            description = 'Email addresses to send email to'
        )
        public List<String> toAddresses;

        @InvocableVariable(
            label = 'CC Addresses'
            description = 'Email addresses to send email to'
        )
        public List<String> ccAddresses;

        @InvocableVariable(
            label = 'BCC Addresses'
            description = 'Email addresses to send email to'
        )
        public List<String> bccAddresses;

        @InvocableVariable(
            label = 'Attach File?'
            description = 'Should the document be attached to email? Default is false.'
        )
        public Boolean attachFile = false;

    }

}