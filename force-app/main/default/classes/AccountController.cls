public with sharing class AccountController {
    @auraEnabled
     public static Id insertAccount(Account acct) {
    // server-side validation
    if (acct.Name == null || acct.Name.length() < 4 || acct.Name.length() > 15) {
      throw new AuraHandledException('Account Name must be between 4 and 15 characters');
    }
    if (acct.AccountNumber != null) {
      // must be numeric and up to 5 digits
      String acctNumStr = String.valueOf(acct.AccountNumber);
      if (acctNumStr.length() > 5) {
        throw new AuraHandledException('Account Number must not be more than 5 digits');
      }
    }
    insert acct;
    return acct.Id;
  }
}