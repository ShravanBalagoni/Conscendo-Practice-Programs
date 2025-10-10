public  class AccountTriggerHandler {
    public AccountTriggerHandler() {

    }
    public static void handleAfterUpdate(List<Account> newAccounts, Map<Id, Account> oldAccountMap) {
       
       Map<Id,String> accountToPrimaryContactMap = new Map<Id,String>();
   
       for(Account acc: newAccounts){
        Account oldAcc = oldAccountMap.get(acc.Id);
        if(acc.Description!=oldAcc.Description)
        {   
            accountToPrimaryContactMap.put(acc.Id,acc.Description);
        
        }
}
    List<Contact> conList = [Select Id,LastName,Description from COntact Where AccountId in:accountToPrimaryContactMap.keyset()];
    List<Contact> toUpdateconList = new List<Contact>();
    for(Id accIds:accountToPrimaryContactMap.keySet())
    {
        for(Contact con: conList)
        {
            if(con.AccountId==accIds)
            {
                con.Description = accountToPrimaryContactMap.get(accIds);
                toUpdateconList.add(con);
            }
        }
    }

       if (!toUpdateconList.isEmpty()) {
            update toUpdateconList;
       }
    }
}