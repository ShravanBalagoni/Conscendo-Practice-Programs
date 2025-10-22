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
}