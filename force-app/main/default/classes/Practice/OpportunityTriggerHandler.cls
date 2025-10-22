public with sharing class OpportunityTriggerHandler {
    public static void doValidate(List<Opportunity> newOppsList,Map<Id,Opportunity>oldOppsMap){
        id loggedinUserId = UserInfo.getUserId();
        Profile p = [Select Name from Profile Where Id =: UserInfo.getProfileId() Limit 1 ];
        String ProfileName = p.Name;
        Set<Id> ownerIds = new Set<Id>();
        for(Opportunity opp:newOppsList){
            if(opp.StageName=='Closed Won' && opp.StageName=='Closed Lost'){
                ownerIds.add(opp.OwnerId);
            }
        }
        Map<Id,Id> ownerIdWithManagerIdMap = new Map<Id,Id>();
        for(User usr:[Select Id,ManagerId from User where Id In:ownerIds]){
            ownerIdWithManagerIdMap.put(usr.Id, usr.ManagerId);
        }
        for(Opportunity opp:newOppsList){
            if(opp.IsClosed){
                Id ManagerId = ownerIdWithManagerIdMap.get(opp.OwnerId);
                Boolean isOwner = opp.OwnerId==loggedinUserId;
                Boolean isManager = ManagerId!=null && ManagerId==loggedinUserId;
                Boolean isSysAdmin = ProfileName=='System Administartor';

                if(!isOwner&&!isManager&&!isSysAdmin){
                    opp.addError('You are not authorized to Modify this Closed Record, Only the Manger of that user and System Admin have Access');
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
    
