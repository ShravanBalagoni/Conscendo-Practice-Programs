trigger ContactTrigger on SOBJECT (after insert) {
    ContactTriggerHandler.doCreateCase(trigger.new,trigger.oldMap);
}