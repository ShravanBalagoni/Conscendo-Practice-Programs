public with sharing class searchContacts {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(String searchKey) {
        if (String.isBlank(searchKey)) {
        return new List<Contact>();
    }
        String key = '%' + searchKey + '%';
        return [SELECT Id, Name, Email, Phone FROM Contact WHERE Name LIKE :key LIMIT 20];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsPg(Integer pageNumber, Integer pageSize) {
        Integer offsetVal = (pageNumber - 1) * pageSize;
        return [
            SELECT Id, Name, Email, Phone 
            FROM Contact 
            ORDER BY Name 
            LIMIT :pageSize OFFSET :offsetVal
        ];
    }
} 