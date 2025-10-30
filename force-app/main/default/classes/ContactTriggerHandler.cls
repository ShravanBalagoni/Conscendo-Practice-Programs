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
public static void UpdateCaseDesc(List<Contact>conList,Map<Id,Contact>conMap){
        Map<Id,String> contactToDescription = new Map<Id,String>();
        for(Contact con:conList){
            if(con.Description!=null && con.Description!=conMap.get(con.Id).Description){
                contactToDescription.put(con.Id,con.Description);
            }
        }
        List<Case> csList = [Select Id,Status from Case Where ContactId in:contactToDescription.keySet()];
        List<Case>toUpdateCaseList = new List<Case>();
        List<Case>toInsertCaseList = new List<Case>();
        set<Id>consWithOpenCase = new Set<Id>();
        for(Case cs:csList){
            if(cs.Status!='Closed'){
                cs.Description=contactToDescription.get(cs.ContactId);
                consWithOpenCase.add(cs.Id);
                toUpdateCaseList.add(cs);
            }
        }
        for(Id contactIds:contactToDescription.keySet()){
            if(!consWithOpenCase.contains(contactIds)){
                Case cs = new Case();
                cs.Status='New';
                cs.Description = contactToDescription.get(contactIds);
                cs.ContactId = contactIds;
                toInsertCaseList.add(cs);
            }
        }
        if(!toUpdateCaseList.isEmpty()){
            update toUpdateCaseList;
        }
         if(!toInsertCaseList.isEmpty()){
            update toInsertCaseList;
        }

    }
}


