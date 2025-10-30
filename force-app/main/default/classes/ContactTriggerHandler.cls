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
public static void UpdateCaseDesc(Map<Id,Contact>conMap, LIst<Contact>conList){
        Map<ID, String> ConDesc= new Map<Id, String>();
        for (Contact con: ConList){
            if (con.Description !=Null && con.Description !=conMap.get(Con.id).Description){
                ConDesc.put(Con.Id,con.Description);
            }
        }
        List<Case>csList= [select id,Status, Description, ContactID from Case where ContactID IN: ConDesc.keyset()];
        // in CsList only the triggered Contact related Cases will be Stored only of the description changed
        List<Case> CaseToBeUpdates=new List<Case>();// for to UPdate
        List<Case> CaseToBeinsert=new List<Case>();  // for to Insert
        //it is for to track that contacts which have open cases
        set<Id> ConsWithOpenCase=new Set<Id>();
        for (Case cs:csList){
            //if (ConDesc.containskey(cs.ContactId)){
            if (cs.Status!='Closed'){  //only open Cases
                cs.Description=ConDesc.get(cs.ContactId);
                ConsWithOpenCase.add(cs.ContactId);
                CaseToBeUpdates.add(cs);	
            }
        }
        for (Id ConIds:ConDesc.keyset()){
            // it will execute only if the Contact Ids Does not Present in the set
            if (!ConsWithOpenCase.Contains(ConIds)){
                case newCase=new case();
                newCase.Origin='Web';
                newCase.Status='New';
                newCase.ContactId=ConIds;
                newCase.Description=ConDesc.get(ConIds);
                CaseToBeinsert.add(newCase);
            }
        }
        if (!CaseToBeUpdates.isEmpty()){
            Update CaseToBeUpdates;
        }
        if (!CaseToBeinsert.isEmpty()){
            insert CaseToBeinsert;
        }
    }
}


