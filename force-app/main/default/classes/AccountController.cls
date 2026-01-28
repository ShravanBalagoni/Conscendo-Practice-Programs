public with sharing class AccountController {
    @AuraEnabled
    public static Account insertAccount(
        String accountName, 
        String accountNumber, 
        String billingAddress, 
        String description
    ) {
        try {
            // Validate Account Name
            if (String.isBlank(accountName)) {
                throw new AuraHandledException('Account Name is required');
            }
            
            if (accountName.length() < 4 || accountName.length() > 15) {
                throw new AuraHandledException('Account Name must be between 4 and 15 characters');
            }
            
            // Validate Account Number
            if (String.isNotBlank(accountNumber) && accountNumber.length() > 5) {
                throw new AuraHandledException('Account Number cannot exceed 5 digits');
            }
            
            // Create Account record
            Account newAccount = new Account(
                Name = accountName,
                AccountNumber = accountNumber,
                BillingStreet = billingAddress,
                Description = description
            );
            
            insert newAccount;
            
            return newAccount;
            
        } catch (DmlException e) {
            throw new AuraHandledException('DML Error: ' + e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static Account updateAccount(
        Id accountId,
        String accountName, 
        String accountNumber, 
        String billingAddress, 
        String description
    ) {
        try {
            // Validate Account ID
            if (accountId == null) {
                throw new AuraHandledException('Account ID is required for update');
            }
            
            // Validate Account Name
            if (String.isBlank(accountName)) {
                throw new AuraHandledException('Account Name is required');
            }
            
            if (accountName.length() < 4 || accountName.length() > 15) {
                throw new AuraHandledException('Account Name must be between 4 and 15 characters');
            }
            
            // Validate Account Number
            if (String.isNotBlank(accountNumber) && accountNumber.length() > 5) {
                throw new AuraHandledException('Account Number cannot exceed 5 digits');
            }
            
            // Retrieve and update Account
            Account accountToUpdate = [
                SELECT Id, Name, AccountNumber, BillingStreet, Description 
                FROM Account 
                WHERE Id = :accountId 
                LIMIT 1
            ];
            
            accountToUpdate.Name = accountName;
            accountToUpdate.AccountNumber = accountNumber;
            accountToUpdate.BillingStreet = billingAddress;
            accountToUpdate.Description = description;
            
            update accountToUpdate;
            
            return accountToUpdate;
            
        } catch (QueryException e) {
            throw new AuraHandledException('Account not found: ' + e.getMessage());
        } catch (DmlException e) {
            throw new AuraHandledException('DML Error: ' + e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [SELECT Id, Name, Phone, Type FROM Account LIMIT 10];
    }
}