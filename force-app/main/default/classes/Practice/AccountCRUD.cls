@restResource(urlMapping='/myown/AccountCRUD/*')
Global with sharing class AccountCRUD {
    Global class AccountRequest{
        public String Name;
        public String Phone;
    }
    @HttpPost
    global static void createAccount(){
        RestRequest req= RestContext.request;
        List<AccountRequest> accReqList = (List<AccountRequest>)JSON.deserialize(req.requestBody.toString(),List<AccountRequest>.class);
        List<Account> newAccounts = new List<Account>();
        for(AccountRequest acc:accReqList){
            Account newAcc = new Account();
            newAcc.Name = acc.Name;
            newAcc.Phone = acc.Phone;
            newAccounts.add(newAcc);
        }
        if(!newAccounts.isEmpty())
        {
            insert newAccounts;
        }
    }
}