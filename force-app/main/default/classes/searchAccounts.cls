public with sharing class searchAccounts {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(String searchKey){
        if(String.isBlank(searchKey)){
            return new List<Account>();
        }
        String key = '%'+ searchKey+'%';

        return [Select Id,Name,Rating,Phone from Account Where Name Like : key Limit 25];
        
    }
}