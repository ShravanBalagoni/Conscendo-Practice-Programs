
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
    static void myUnitTest() {
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
}