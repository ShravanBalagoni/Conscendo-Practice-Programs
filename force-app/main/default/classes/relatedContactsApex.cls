public with sharing class relatedContactsApex {
   @AuraEnabled(cacheable=true)
   public static List<Contact> getRelatedContacts(String accountIdVar){
    return [Select Id,AccountId,LastName,Email from Contact Where AccountId=:accountIdVar];
   }
}