trigger OpportunityTrigger on Opportunity (after insert,after  update,after delete) {
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        OpportunityTriggerHandler.doCalculate(trigger.new, null);
         if(trigger.isUpdate)
        OpportunityTriggerHandler.doCalculate(trigger.new, trigger.oldMap);
         if(trigger.isDelete)
        OpportunityTriggerHandler.doCalculate(trigger.old, trigger.oldMap);
         
    }
}