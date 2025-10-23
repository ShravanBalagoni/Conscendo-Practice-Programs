public class OppoLine_to_Acc_Handler {

    public static void counter(List<OpportunityLineItem> opplist) {
        if (opplist.isEmpty()) return;

        // Step 1: Collect Opportunity Ids from the line items
        Set<Id> oppIds = new Set<Id>();
        for (OpportunityLineItem oli : opplist) {
            if (oli.OpportunityId != null && oli.TotalPrice > 50000) {
                oppIds.add(oli.OpportunityId);
            }
        }
        if (oppIds.isEmpty()) return;

        // Step 2: Query Opportunities with AccountId
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
            [SELECT Id, AccountId FROM Opportunity WHERE Id IN :oppIds AND AccountId != null]
        );

        if (oppMap.isEmpty()) return;

        // Step 3: Aggregate OpportunityLineItems per Account
        List<AggregateResult> aggResults = [
            SELECT COUNT(Id) totalCount, Opportunity.AccountId
            FROM OpportunityLineItem
            WHERE OpportunityId IN :oppMap.keySet() AND TotalPrice > 50000
            GROUP BY Opportunity.AccountId
        ];

        // Step 4: Prepare Accounts to update
        List<Account> accountsToUpdate = new List<Account>();
        for (AggregateResult ar : aggResults) {
            Id accId = (Id) ar.get('Opportunity.AccountId');
            Integer count = (Integer) ar.get('totalCount');
            accountsToUpdate.add(new Account(
                Id = accId,
                Total_OpportunityLine_Items__c = count
            ));
        }

        // Step 5: Update Accounts
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}
