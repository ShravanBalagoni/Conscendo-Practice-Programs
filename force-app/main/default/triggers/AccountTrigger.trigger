trigger AccountTrigger on Account (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        AccountTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}