@restResource(urlMapping='/myown/AccountCRUD/*')
Global with sharing class AccountCRUD {
    Global class AccountRequest{
        public String name;
        public String phone;
    }

    @HttpPost
    Global static void doPostData(){
        RestRequest req = RestContext.request;
        List<AccountRequest> accReqList = (List<AccountRequest>)JSON.deserialize(req.requestBody.toString(), List<AccountRequest>.class);
        List<Account> accountsList = new List<Account>();
        for(Account acc:accReqList){
            Account newAcc = new Account();
            newAcc.Name = acc.name;
            newAcc.Phone = acc.phone;

            accountsList.add(newAcc);
        }
        if(!accountsList.isEmpty())
        {
            insert accountsList;
        }
    }
}