trigger AccountTrigger1 on Account (before update) {
    Set<Id> accIds = new Set<Id>();
    
    for(Account acc:Trigger.new){
        Account oldAcc = Trigger.oldMap.get(acc.Id);

        if(acc.Id!=null && acc.Phone!=oldAcc.Phone){
            acc.Description='Phone Number Changed';
        }
        
    }
    

}