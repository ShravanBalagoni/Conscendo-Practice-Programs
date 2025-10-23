@isTest
private class TestAccountHandler_UpdateCaseStatus {

    @TestSetup
    static void makeData(){
        Account acnt = new Account(Name='Case Test Account', Customer_Relationship__c='Active');
        insert acnt;

        Contact con1 = new Contact(LastName='User1', AccountId=acnt.Id);
        Contact con2 = new Contact(LastName='User2', AccountId=acnt.Id);
        insert new List<Contact>{con1, con2};

        List<Case> caseList = new List<Case>{
            new Case(ContactId=con1.Id, AccountId=acnt.Id, Status='New', Origin='Phone'),
            new Case(ContactId=con2.Id, AccountId=acnt.Id, Status='New', Origin='Email')
        };
        insert caseList;
    }

    @isTest
    static void myUnitTest() {
        Account oldAcc = [SELECT Id, Customer_Relationship__c FROM Account WHERE Name='Case Test Account' LIMIT 1];

        Account newAcc = [SELECT Id, Customer_Relationship__c FROM Account WHERE Id=:oldAcc.Id];
        newAcc.Customer_Relationship__c = 'No Relationship';
        update newAcc;

        Map<Id, Account> oldMap = new Map<Id, Account>{ oldAcc.Id => oldAcc };

        Test.startTest();
        AccountTriggerHandler.doUpdateCaseStatus(
            new List<Account>{ newAcc },
            oldMap
        );
        Test.stopTest();

        // Query all Cases for the Account
        List<Case> updatedCases = [SELECT Id, Status FROM Case WHERE AccountId=:oldAcc.Id];

        // Assert all Cases updated
        for(Case cs : updatedCases){
            System.assertEquals('Closed', cs.Status, 'All Cases should be closed');
        }
    }
}
