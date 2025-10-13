public  class AccountTriggerHandler {
    public AccountTriggerHandler() {

    }
    public static void handleAfterUpdate(List<Account> newAccounts, Map<Id, Account> oldAccountMap) {
        
        Map<Id,Account> accountToPrimaryContactMap = new Map<Id,Account>();
        for(Account acc: newAccounts){
            Account oldAcc = oldAccountMap.get(acc.Id);
            if(acc.Description!=oldAcc.Description && acc.Contacts.size()>0 )  
                accountToPrimaryContactMap.put(acc.Id,acc);
        }
        List<Contact> toUpdateconList = new List<Contact>();
        for(Contact con: [Select AccountId,Description from Contact 
                          Where AccountId in:accountToPrimaryContactMap.keyset()])
        {
            if(accountToPrimaryContactMap.containsKey(con.AccountId))
            {
                con.Description = accountToPrimaryContactMap.get(con.AccountId).description;
                toUpdateconList.add(con);
            }
        }
        if (!toUpdateconList.isEmpty())
            update toUpdateconList;
        
    }
}