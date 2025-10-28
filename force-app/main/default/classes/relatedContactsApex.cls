public with sharing class relatedContactsApex {
    @AuraEnabled(cacheable = true)
    public static List<Contact> getrelatedContacts(String accountId){
        return [Select Id,AccountId,LastName from Contact Where AccountId=:accountId];
    }
}