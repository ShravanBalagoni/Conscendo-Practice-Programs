public with sharing class AccountController {
    @AuraEnabled
    public static Id insertAccount(Account acct) {
        // Server-side validation for Name
        if (acct.Name == null || acct.Name.length() < 4 || acct.Name.length() > 15) {
            throw new AuraHandledException('Account Name must be between 4 and 15 characters');
        }
        // Server-side validation for AccountNumber (if provided)
        if (acct.AccountNumber != null) {
            String acctNumStr = String.valueOf(acct.AccountNumber);
            if (acctNumStr.length() > 5) {
                throw new AuraHandledException('Account Number must not be more than 5 digits');
            }
        }
        // Determine insert vs update
        if (acct.Id != null) {
            update acct;
        } else {
            insert acct;
        }
        return acct.Id;
    }
}
