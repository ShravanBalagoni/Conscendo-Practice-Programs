public with sharing class searchContacts {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(String searchKey) {
        if (String.isBlank(searchKey)) {
        return new List<Contact>();
    }
        String key = '%' + searchKey + '%';
        return [SELECT Id, Name, Email, Phone FROM Contact WHERE Name LIKE :key LIMIT 20];
    }
}