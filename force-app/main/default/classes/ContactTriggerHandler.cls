public with sharing class ContactTriggerHandler {
public static void updateDescription(List<Contact> consList, Map<Id,Contact> oldConsMap){
    List<Account> accList = new List<Account>();
    for(Contact con : consList){
        Contact oldContact = oldConsMap.get(con.Id);
        if(oldContact != null && con.Description != oldContact.Description && con.AccountId != null){
            Account accRecord = new Account(
                Id = con.AccountId,
                Description = con.Description
            );
            accList.add(accRecord);
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
public static void dopreventDuplicate(List<Contact> newConsList,Map<Id,Contact> oldConsMap){
    Set<String> emailSet = new Set<String>();
    for(Contact con:newConsList){
        if(con.Email!=null){
            emailSet.add(con.Email);
        }
    }
    Set<String> existingEmailSet = new Set<String>();
    Map<Id,Contact> accIdConMap = new Map<Id,Contact>();
    for(Contact con:[Select Id,Email from Contact Where Email in:emailSet]){
        existingEmailSet.add(con.Email);
        accIdConMap.put(con.AccountId, con);
    }
    for(Contact con:newConsList){
        if(existingEmailSet.contains(con.Email)&&accIdConMap.containsKey(con.AccountId)){
            con.addError('Duplicate Email exists already');
        }
    }

}
public static void doUpdateStatus(List<Contact> newConsList,Map<Id,Contact> oldConsMap){
    Set<Id> conIds = new Set<Id>();
    for(Contact con:newConsList){
        Contact oldCon = oldConsMap.get(con.Id);
        if(con.Description!=oldCon.Description){
            conIds.add(con.Id);
        }
    }
    Map<Id,List<Case>> conIdCaseMap = new Map<Id,List<Case>>();

    for(Case cs:[Select ContactId,Status from Case Where ContactIdId in:conIds]){
        if(!conIdCaseMap.containsKey(cs.ContactId)){
            conIdCaseMap.put(cs.ContactId,new List<Case>());
        }
    }
}
}


