public with sharing class OpportunityTriggerHandler {
    public static void doValidate(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap) {
        
        // Get current user info
        Id userId = UserInfo.getUserId();
        Profile p = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];
        String profileName = p.Name;
        set<Id> ownerIds = new set<Id>();
        for(opportunity opp:newOppList){
            if(opp.StageName=='Closed Won' ||opp.StageName=='Closed Lost'){
                ownerIds.add(opp.OwnerId);
            }
        }
        Map<Id,Id> ownerIdwithManagerId = new Map<Id,Id>();
        for(User usr :[Select Id,ManagerId from User where id In:ownerIds ]){
            ownerIdwithManagerId.put(usr.id,usr.ManagerId);
        }
        for(Opportunity opp:newOppList)
        {
            if(opp.IsClosed)
            {
                Id managerId = ownerIdwithManagerId.get(opp.OwnerId);
                Boolean isOwner = opp.OwnerId==userId;
                Boolean isManager = managerId!=null && managerId == userId;
                Boolean isSysAdmin = profileName == 'Systen Administration';
                if(!isOwner  &&!isManager && !isSysAdmin)
                {
                    opp.addError('You cannot edit a Closed Opportunity. Only the record owner or System Administrators can edit it.');
                }
            }
        }
        
        
    }
    public static void doCalculate(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap){
        //Collect the AccountIds of  Opportunities in a Set
        set<Id> accountids  = new set<Id> ();
        for(Opportunity opp:newOppList){
            //Insert
            if(opp.AccountId!=null &&oldOppMap==null ){
                accountids.add(opp.AccountId);
            }
            //Update
            else if(opp.AccountId!=null&& oldOppMap!=null){
                Opportunity oldOpp = oldOppMap.get(opp.Id);
                if(opp.AccountId!=null && opp.Amount!=oldOpp.Amount){
                    accountids.add(opp.AccountId);
                    accountids.add(oldOpp.AccountId);
                }
            }
        }
        // Include Account IDs if this is a delete operation
        if (oldOppMap != null && newOppList == null) {
            for (Opportunity oldOpp : oldOppMap.values()) {
                if (oldOpp.AccountId != null) accountIds.add(oldOpp.AccountId);
            }
        }
        
        
        List<AggregateResult> arVarList = [Select AccountId,Max(Amount) maxAmount,Min(Amount) minAmount
                                           from Opportunity
                                           Where AccountId in:accountids
                                           Group By AccountId];
        List<Account> toUpdateAccList = new List<Account>();
        for(AggregateResult ar:arVarList){
            Account acc = new Account();
            acc.id = (Id) ar.get('AccountId');
            if(acc.Id!=null){
                acc.Max_Opp_Amount__c = (Decimal) ar.get('maxAmount');
                acc.Min_Opp_Amount__c = (Decimal) ar.get('minAmount');
                toUpdateAccList.add(acc);
            }
        }
        if(!toUpdateAccList.isEmpty())
        {
            update toUpdateAccList;
        }
        
    }
}