public with sharing class SampleApexLtngWebCmpnt {
    @auraEnabled(cacheable =true)
    public static String getPersonName(){
        return 'Shravan Balagoni';
    }
     @auraEnabled(cacheable =true)
    public static List<Contact> getContacts(){
        String key = '%' + searchKey + '%';
        return [SELECT Id, Name, Email, Phone FROM Contact WHERE Name LIKE :key LIMIT 20];
    }
    
    @auraEnabled
    public static List<Account> getAccountIMP(){
        return [Select Id,Name,Industry,Rating from Account];
    }
    @auraEnabled
    public static Id doCreateAccount(String acntName){
        Account acnt = new Account();
        acnt.Name= acntName;
        insert acnt;
        return acnt.Id;
    }
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getRelatedOpps(String accIdVar){
        return[Select AccountId,Name,StageName from Opportunity where AccountId=:accIdVar];
    }
} 