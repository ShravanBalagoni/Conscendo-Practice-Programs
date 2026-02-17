public with sharing class AccountDecisionService {
    
    @AuraEnabled
    public static void createAccountDecision(Id accountId, String decision, String comment) {
        // Validate input
        if (String.isBlank(accountId) || String.isBlank(decision)) {
            throw new AuraHandledException('Account ID and Decision are required');
        }
        
        // 1. Create Follow-up Task (✅ 100% Works)
        Task decisionTask = new Task(
            WhatId = accountId,
            Subject = 'Account Decision: ' + decision,
            Description = 'Decision: ' + decision + '\n\nComment: ' + 
                         (String.isBlank(comment) ? 'No comment provided' : comment),
            Status = 'In Progress',
            Priority = (decision == 'Escalated' ? 'High' : 'Normal'),
            Type = 'Account Decision'
        );
        insert decisionTask;
        
        // 2. SIMPLE Chatter Post (✅ No complex filters)
        FeedItem chatterPost = new FeedItem(
            ParentId = accountId,
            Body = '📋 **Account Decision: ' + decision + '**\n\n' +
                   'Comment: ' + (String.isBlank(comment) ? 'None' : comment) + '\n' +
                   'Task: ' + decisionTask.Subject
        );
        insert chatterPost;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Task> getRecentTasks(Id accountId) {
        return [SELECT Id, Subject, Status, Priority, CreatedDate, CreatedBy.Name
                FROM Task 
                WHERE WhatId = :accountId AND Type = 'Account Decision'
                ORDER BY CreatedDate DESC 
                LIMIT 5];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<FeedItem> getRecentFeedItems(Id accountId) {
        // ✅ FIXED: Query by ParentId only (no Body filter)
        return [SELECT Id, CreatedDate, CreatedBy.Name, Type
                FROM FeedItem 
                WHERE ParentId = :accountId 
                ORDER BY CreatedDate DESC 
                LIMIT 3];
    }
}
