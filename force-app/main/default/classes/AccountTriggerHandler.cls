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
    public static void doAssignAddress(List<Account> newAccList,Map<Id,Account>oldAccsMap){
        Map<Id,Account> AddressChangedMap = new Map<Id,Account>();
        for(Account acc:newAccList){
            Account oldacc = oldAccsMap.get(acc.id);
            if(acc.BillingCity!=oldacc.BillingCity&& acc.BillingCountry!=oldacc.BillingCountry){
                AddressChangedMap.put(acc.Id, acc);
            }
        }
        List<Contact> toUpdateConList = new List<Contact>();
        for(Contact con:[Select MailingCity,MailingCountry from Contact Where AccountId In:AddressChangedMap.keySet()]){
            Account acc = AddressChangedMap.get(con.AccountId);
            con.MailingCity = acc.BillingCity;
            con.MailingCountry = acc.BillingCountry;
            toUpdateConList.add(con);

        }
        if(!toUpdateConList.isEmpty()){
            update toUpdateConList;
        }
    }
}