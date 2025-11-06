public with sharing class SampleApexLtngWebCmpnt {
    @auraEnabled(cacheable =true)
    public static String getPersonName(){
        return 'Shravan Balagoni';
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
    @auraEnabled
    public static List<Case> getCases(){
        return [Select Id,CaseNumber,Priority,Origin from Case Limit 25];
    }
} 