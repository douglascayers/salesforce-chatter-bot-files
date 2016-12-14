trigger ChatterBotFileDocumentTrigger on ContentDocument ( before delete ) {

    new ChatterBotFileVersionTriggerHandler().deleteChatterBotFiles( Trigger.old );

}