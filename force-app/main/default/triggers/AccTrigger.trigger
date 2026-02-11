trigger AccTrigger on Account (after update) {
    Set<Id> accIds = new Set<Id>();
    for(Account acc:trigger.new){
        Account oldAcc = trigger.oldMap.get(acc.Id);
        if(acc.Phone!=oldAcc.Phone){
            accIds.add(acc.Id);
        }
    }

    AccountTriggerHandler.doSyncPhone(accIds,Trigger.newMap);
}