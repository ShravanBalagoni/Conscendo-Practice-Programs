@RestResource(urlMapping='/butterfly/AccountCRUD/*')
global with sharing class AccountCRUD {

    // Inner class to represent incoming JSON for account creation
    global class AccountRequest {
        public String name;
        public String phone;
    }

    // Inner class for response
    global class AccountResponse {
        public String status;
        public String accountId;
        public String error;
    }

    @HttpPost
    global static AccountResponse createAccounts() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        AccountResponse resp = new AccountResponse();

        // Parse the request body JSON into a List<AccountRequest>
        List<AccountRequest> acctReqList;
        try {
            acctReqList = (List<AccountRequest>) JSON.deserialize(req.requestBody.toString(), List<AccountRequest>.class);
        } catch (Exception ex) {
            resp.status = 'error';
            resp.error = 'Invalid JSON: ' + ex.getMessage();
            res.statusCode = 400;
            return resp;
        }

        // Create and insert accounts
        List<Account> newAccounts = new List<Account>();
        for (AccountRequest acctReq : acctReqList) {
            if (acctReq.name == null || acctReq.name.trim().length() == 0) {
                resp.status = 'error';
                resp.error = 'Name is required';
                res.statusCode = 400;
                return resp;
            }

            Account newAcc = new Account();
            newAcc.Name = acctReq.name;
            newAcc.Phone = acctReq.phone;
            newAccounts.add(newAcc);
        }

        try {
            insert newAccounts;
            resp.status = 'success';
            res.statusCode = 201; // Created
        } catch (Exception ex) {
            resp.status = 'error';
            resp.error = 'Insert failed: ' + ex.getMessage();
            res.statusCode = 500;
        }

        return resp;
    }
}
/*@RestResource(urlMapping='/butterfly/AccountCRUD/*')
global with sharing class AccountCRUD {

    global class AccountRequest {
        public String name;
        public String phone;
    }

    @HttpPost
    global static void createAccounts() {
        RestRequest req = RestContext.request;
        List<AccountRequest> acctReqList = (List<AccountRequest>) JSON.deserialize(req.requestBody.toString(), List<AccountRequest>.class);

        List<Account> newAccounts = new List<Account>();
        for (AccountRequest acctReq : acctReqList) {
            Account newAcc = new Account();
            newAcc.Name = acctReq.name;
            newAcc.Phone = acctReq.phone;
            newAccounts.add(newAcc);
        }

        insert newAccounts;
    }
}
 */
