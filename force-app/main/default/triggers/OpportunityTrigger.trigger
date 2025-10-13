trigger OpportunityTrigger on Opportunity (before insert,before update) {
    OpportunityTriggerHandler.doValidate(trigger.new, trigger.oldMap);
}