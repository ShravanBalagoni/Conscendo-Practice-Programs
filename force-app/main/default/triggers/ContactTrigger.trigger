trigger ContactTrigger on Contact (after insert,after update,after delete,after undelete) {
    //ContactTriggerHandler.doCreateCase(trigger.new,trigger.oldMap);
    //ContactTriggerHandler.UpdateCaseDesc(trigger.new,trigger.oldMap);
    if(trigger.isInsert)
    {
        ContactTriggerHandler.doCalculateRelatedContacts(trigger.new,trigger.newMap);
    }

    if(trigger.isUpdate)
    {
        ContactTriggerHandler.doCalculateRelatedContacts(trigger.new,trigger.oldMap);
    }

    if(trigger.isDelete)
    {
        ContactTriggerHandler.doCalculateRelatedContacts(trigger.old,trigger.oldMap);
    }

    if(trigger.isUndelete)
    {
        ContactTriggerHandler.doCalculateRelatedContacts(trigger.new,trigger.oldMap);
    }
}