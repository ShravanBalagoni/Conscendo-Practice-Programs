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

}