public with sharing class OpportunityTriggerHandler {
    public static void doValidate(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap) {

        // Get current user info
        Id userId = UserInfo.getUserId();
        Profile p = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];
        String profileName = p.Name;

        for (Opportunity opp : newOppList) {
            // Prevent edits on closed opportunities unless by owner or admin
            if (opp.IsClosed && opp.OwnerId != userId && profileName != 'System Administrator') {
                opp.addError('You cannot edit a Closed Opportunity. Only the record owner or System Administrators can edit it.');
            }
        }
    }
}
