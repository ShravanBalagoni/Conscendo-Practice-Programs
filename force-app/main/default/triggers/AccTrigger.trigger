trigger AccTrigger on Account (after update) {
    Set<Id> accIds = new Set<Id>();
    for(Account acc:trigger.New){
        Account oldAcc = trigger.oldMap.get(acc.Id);
        if(acc.Phone!=oldAcc.Phone){
            accIds.add(acc.Id);
        }
    }

    List<Contact> conList = new List<Contact>();
    for(Contact con:[Select Id,AccountId,Description from Contact 
                    Where AccountId 
                    In:accIds]){
                        Account newAcc = Trigger.newMap.get(con.AccountId);
                        if(newAcc.Phone!=null){
                            con.Description = newAcc.Phone;
                        }
                        conList.add(con);
                    }
    
                    if(!conList.isEmpty()){
                        update conList;
                    }
}