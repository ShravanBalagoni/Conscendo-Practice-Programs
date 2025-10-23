
@isTest
private class TestContactTriggerHandler {
    @TestSetup
    static void makeData(){
         Account acc = new Account(Name='Test Account');
        insert acc;
        Contact con = new Contact(FirstName='Test',LastName='ClassContact',Description='Initial Description',AccountId=acc.Id);
        insert con;

    }
    @isTest

    static void TestupdateDescription() {
       Contact oldCon = [SELECT Id, FirstName, LastName, Description, AccountId 
                  FROM Contact 
                  WHERE LastName='ClassContact' LIMIT 1];

        Contact newCon = [SELECT Id, FirstName, LastName, Description, AccountId 
                  FROM Contact 
                  WHERE Id=:oldCon.Id];
        Test.startTest();
        newCon.Description='Modified Description';
        update newCon;
        ContactTriggerHandler.updateDescription(new List<Contact>{newCon}, new Map<Id,Contact> {oldCon.Id=>oldCon});
        Test.stopTest();
        
        Account acnt = [SELECT Id, Description FROM Account WHERE Id=:newCon.AccountId];
        System.assertEquals('Modified Description', acnt.Description);
    }
    static void TestdoCreateCase(){
        Contact oldCon = [Select Id,AccountId,FirstName,LastName from Contact Where LastName='ClassContact' LIMIT 1];
        Contact newCon = [Select Id,AccountId,FirstName,LastName from Contact Where AccountId=:oldCon.AccountId];
        Test.startTest();
        insert newCon;
        ContactTriggerHandler.doCreateCase(new List<newCon>, new Map<Id,Contact>{newCon.Id=>newCon});
        Case csList = [Select Id,AccountId,ContactId from Case Where AccountId=:acc.Id];
        System.assertEquals(newCon.Id, csList[0].ContactId);

    }
}