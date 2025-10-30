trigger ContactTrigger on Contact (after update) {
    //ContactTriggerHandler.doCreateCase(trigger.new,trigger.oldMap);
    ContactTriggerHandler.UpdateCaseDesc(trigger.new,trigger.oldMap);
}