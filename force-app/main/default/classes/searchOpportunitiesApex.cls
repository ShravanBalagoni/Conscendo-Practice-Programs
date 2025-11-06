public with sharing class searchOpportunitiesApex {
    @AuraEnabled
    public static List<Opportunity> getOpps(String searchKey){
        String key='%'+searchKey+'%';
        if(String.isBlank(key)){
            return new List<Opportunity>();
        }
        return [Select Id,Name,StageName from Opportunity Where Name Like:key Limit 20];
    }
}