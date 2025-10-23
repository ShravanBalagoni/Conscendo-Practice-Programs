trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            OppoLine_to_Acc_Handler.counter(Trigger.new);
        }
    }
}
