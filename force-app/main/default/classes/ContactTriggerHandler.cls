public with sharing class ContactTriggerHandler {
public static void updateDescription(){
    
    List<Account> accList = new List<Account>();
    for(Contact con : Trigger.new){
        Contact oldContact = trigger.oldMap.get(con.Id);
        if(oldContact != null && con.Description!= oldContact.Description){
            accList.add(con.AccountId);
            Account accRecord = new Account();
            accRecord.Id = con.AccountId;
            accRecord.Description = con.Description;
            accList.add(accRecord) ;
    }
}
if(!accList.isEmpty()){
    update accList; 


}
}
public static void doCreateCase(List<Contact> consList,Map<Id,Contact> oldConsMap){
    List<Case> csList = new List<Case>();
    for(Contact con:consList)
    {
        if(con.AccountId!=null )
        {
        Case cs = new Case();
        
        cs.AccountId = con.AccountId;
        cs.ContactId = con.Id;
        csList.add(cs);
    }
}
    if(!csList.isEmpty())
    {
        insert csList;
    }
}
}


