public with sharing class UserTriggerHandler {
    public static void doAfterUpdate(List<User> newUserList,Map<Id,User> oldUserMap,List<User> oldUserList,Map<Id,User> newUserMap){
        Map<Id,Id> managerIdwithUserId = new Map<Id,Id>();
        for(User u:newUserList){
            if(u.IsActive==false && oldUserMap.get(u.Id).IsActive!=u.IsActive){
                managerIdwithUserId.put(u.Id, u.ManagerId);

            }
        }
    }
    @future
    public static void ownerShipTransfer(Map<Id,Id> managerIdwithUserId){
        List<Account> accList = [Select Id,ownerId from Account Where ownerId in:managerIdwithUserId.keySet()];
        List<Account> toUpdateAccList = new List<Account>();
        for(Account acc:accList){
            acc.OwnerId = managerIdwithUserId.get(acc.OwnerId);
            toUpdateAccList.add(acc);
        }
        if(!toUpdateAccList.isEmpty()){
            update toUpdateAccList;
        }
    }
}