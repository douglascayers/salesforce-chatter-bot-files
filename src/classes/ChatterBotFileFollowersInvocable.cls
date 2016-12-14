/**
 * Designed to be used in Flow to retrieve all the email addresses
 * of the active users following a specific ContentDocumentId.
 */
public with sharing class ChatterBotFileFollowersInvocable {

    @InvocableMethod(
        label = 'CB: Get File Followers Emails'
        description = 'Gets the email addresses of a documents followers.'
    )
    public static List<Response> execute( List<Request> requests ) {

        System.debug( 'File follower email requests: ' + requests );

        Set<ID> contentDocumentIds = new Set<ID>();

        for ( Request req : requests ) {
            contentDocumentIds.add( req.contentDocumentId );
        }

        List<EntitySubscription> followers = new List<EntitySubscription>([
            SELECT
                parentId,
                subscriber.email,
                subscriber.isActive
            FROM
                EntitySubscription
            WHERE
                parentId IN :contentDocumentIds
            ORDER BY
                parentId
        ]);

        Map<ID, Set<String>> documentIdToFollowerEmailsMap = new Map<ID, Set<String>>();

        for ( EntitySubscription follower : followers ) {

            Set<String> emails = documentIdToFollowerEmailsMap.get( follower.parentId );

            if ( emails == null ) {
                emails = new Set<String>();
            }

            // we do our filtering here because EntitySubscription object does not
            // support nested field filtering in SOQL queries
            if ( follower.subscriber.isActive && String.isNotBlank( follower.subscriber.email ) ) {
                emails.add( follower.subscriber.email );
            }

            documentIdToFollowerEmailsMap.put( follower.parentId, emails );

        }

        List<Response> responses = new List<Response>();

        for ( Request req : requests ) {

            Response res = new Response();

            res.contentDocumentId = req.contentDocumentId;

            Set<String> emails = documentIdToFollowerEmailsMap.get( req.contentDocumentId );
            if ( emails != null && emails.size() > 0 ) {
                res.emailAddresses = new List<String>( emails );
            }

            System.debug( 'response: ' + res );

            responses.add( res );

        }

        return responses;
    }

    // -------------------------------------------------------------

    public class Request {

        @InvocableVariable(
            label = 'Content Document ID'
            description = 'Document whose followers emails to get'
            required = true
        )
        public ID contentDocumentId;

    }

    public class Response {

        @InvocableVariable(
            label = 'Content Document ID'
        )
        public ID contentDocumentId;

        @InvocableVariable(
            label = 'Email Addresses'
        )
        public List<String> emailAddresses;

    }

}