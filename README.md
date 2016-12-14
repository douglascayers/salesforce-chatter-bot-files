Salesforce Chatter Bot for Files
================================

Overview
--------
Chatter Bot for Files is a way to easily listen for version changes to Chatter Files and take action.
An example would be to automatically notify each user following a File that a new version has been uploaded.
Unfortunately, you cannot just leverage Process Builder to monitor for updates to ContentVersion object.
This project makes it easy by monitoring for insert and updates on ContentVersion object and then creating a custom object that you can leverage within Process Builder.

Installation
----------------------

* [Deploy from Github](https://githubsfdeploy.herokuapp.com)

Getting Started
----------------------

1. Deploy code using link above
2. Assign **Chatter Bot Files Admin** permission set to your user
3. Switch to **Chatter Bot Files** app
4. Upload a new File to Salesforce then navigate to the **Chatter Bot File** tab to see the new record.
5. Upload another version to that File and notice that the **Chatter Bot File** record was updated too.

Everytime a ContentVersion record is inserted or updated then a **Chatter Bot File** record will be upserted. You can use Process Builder to execute when that object is created or updated and take any actions that you need.

For any given `ContentDocumentId` value there will be exactly one `Chatter Bot File` record. If you need to get access to all file revisions you can query for `ContentVersion` records filtered by the `ContentDocumentId`.