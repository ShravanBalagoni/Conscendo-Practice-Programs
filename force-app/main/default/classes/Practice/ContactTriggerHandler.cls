public with sharing class ContactTriggerHandler {
    public static void doUpdate(List<Contact> newConList,Map<Id,Contact> oldConMap){
        List<Account> accList = new List<Account>();
        for(Contact con:newConList){
            Contact oldCon = oldConMap.get(con.Id);
            if(oldCon!=null && con.Description!=oldCon.Description){
                accList.add(con.Account);
                Account accRecord = new Account();
                accRecord.id = con.AccountId;
                accRecord.Description = con.Description;
            }
        }
        if(!accList.isEmpty()){
            update accList;
        }
    }
}