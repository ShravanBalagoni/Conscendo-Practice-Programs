public with sharing class CodeBulkificationMaps {
    public static void doMaps(){
        List<Contact> consList = [Select Id,AccountId,Phone from Contact Where AccountId!=null];
        Map<Id,Contact> consMap = new Map<Id,Contact>();
        for(Contact con:consList){
            consMap.put(con.Id, con);
        }
        set<Id> allKeys = consMap.keySet();
        System.debug(allKeys);
        List<Contact> allValues = consMap.values();
        System.debug(allValues);
    }
    public static void doMaps2(){
        Map<Id,Contact> consMap = new Map<Id,Contact>([Select Id,AccountId,Phone from Contact Where AccountId!=null]);
        system.debug('Map Data:'+consMap);
        system.debug('The size of Map Data:'+consMap.size());
    }
    public static void dogetallAccountsinMap(){
        Map<Id,Account> acntMap = new Map<Id,Account>([select id,Name,phone from Account]);
        for(Id key:acntMap.keySet()){
            Account value = acntMap.get(key);
            system.debug('The Data of Map:'+value);
        }
    }
    public static void dogetallAccountfromcontacts(){
        Set<Id> accIdSet = new Set<Id>();
        for(Contact con:[Select Id,AccountId,Phone from Contact Where AccountId!=null]){
            accIdSet.add(con.AccountId);
        } 
        Map<Id,Account>acntMap = new Map<Id,Account>([Select Id,Name,Phone from Account Where Id In:accIdSet]);
    }

}