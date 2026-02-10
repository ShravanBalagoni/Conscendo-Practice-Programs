public class accFetchClass{
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(){
        return [Select Id,Name from Account Limit 50];
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(String accId){
        return [SELECT Id,FirstName,LastName,Title,Phone,Email,LeadSource
                FROM  Contact
                WHERE AccountId= :accId];
    }
}