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
    public static Map<String,Object> getContactsPg(String searchKey,Integer pageNumber){
        Integer offset = (pageNumber -1) * 5;
        String searchTerm = '%'+searchKey+'%';
        List<Account> accounts = [SELECT Id,Name,Rating,Phone from Account 
                                    Where Name LIKE:searchTerm 
                                    LIMIT 5 OFFSET :offset];
        return new Map<String,Object>{
            'accounts'=>accounts
        };
    
    }
} 