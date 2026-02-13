trigger OpportunityTrigger on Opportunity (after insert,after  update,after delete) {
    
        if(trigger.isInsert)
            OpportunityTriggerHandler.doCalculate(trigger.new, null);
        if(trigger.isUpdate)
            OpportunityTriggerHandler.doCalculate(trigger.new, trigger.oldMap);
        if(trigger.isDelete)
            OpportunityTriggerHandler.doCalculate(trigger.old, trigger.oldMap);
        if(trigger.isUndelete)
            OpportunityTriggerHandler.doCalculate(trigger.new, null);
         
    
}