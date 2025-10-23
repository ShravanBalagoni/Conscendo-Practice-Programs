public  class AccountTriggerHandler {
    public AccountTriggerHandler() {

    }
    public static void handleAfterUpdate(List<Account> newAccounts, Map<Id, Account> oldAccountMap) {
        
        Map<Id,Account> accountToPrimaryContactMap = new Map<Id,Account>();
        for(Account acc: newAccounts){
            Account oldAcc = oldAccountMap.get(acc.Id);
            if(acc.Description!=oldAcc.Description  )  
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

    public static void doUpdateCaseStatus(List<Account> newAccList,Map<Id,Account>oldAccsMap){
        set<id> accIdSet = new set<Id>();
        for(Account acc:newAccList){
            Account oldAcc = oldAccsMap.get(acc.id);
            if(acc.Customer_Relationship__c!=oldAcc.Customer_Relationship__c && acc.Customer_Relationship__c=='No Relationship'){
                accIdSet.add(acc.Id);
            }
        }
         List<Case> relcaseList = new List<Case>();
        for(Contact con:[Select Id,AccountId,(Select Id,Status from Cases) from Contact Where AccountId In:accIdSet]){
           List<Case> openCases = con.Cases;
           relcaseList.addAll(openCases);
        }
        List<Case> toUpdateCaseList = new List<Case>();
        for(Case cs:relcaseList){
            cs.Status='Closed';
            toUpdateCaseList.add(cs);
        }
        if(!toUpdateCaseList.isEmpty()){
            update toUpdateCaseList;
        }
    }
}
