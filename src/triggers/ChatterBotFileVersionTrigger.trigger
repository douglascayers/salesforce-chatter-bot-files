trigger ChatterBotFileVersionTrigger on ContentVersion ( after insert, after update ) {

    new ChatterBotFileVersionTriggerHandler().createChatterBotFiles( Trigger.new );

}