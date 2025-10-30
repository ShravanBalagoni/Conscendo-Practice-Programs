trigger ContactTrigger on Contact (after update) {
    //ContactTriggerHandler.doCreateCase(trigger.new,trigger.oldMap);
    ContactTriggerHandler.doUpdateStatus(trigger.new,trigger.oldMap);
}