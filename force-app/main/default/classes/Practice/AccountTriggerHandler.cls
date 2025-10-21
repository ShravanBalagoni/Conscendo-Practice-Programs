public with sharing class AccountTriggerHandler {
    public static void doUpdate(List<Account> newAcntList,Map<Id,Account> oldAcntMap){
        Map<Id,Account> accToPrimaryContactMap = new Map<Id,Account>();
        for(Account acc:newAcntList){
            Account oldAcnt = oldAcntMap.get(acc.Id);
            if(acc.Description!=oldAcnt.Description && acc.Contacts.size()){
                accToPrimaryContactMap.put(acc.id, acc);
            }
        }
        for(Contact con:[Select AccountId,Description from Contact Where AccountId In:accToPrimaryContactMap.keySet()]){
            if(accToPrimaryContactMap.containsKey(con.AccountId)){
                con.Description = accToPrimaryContactMap.get(con.AccountId).Description;
            }
        }
    }
}