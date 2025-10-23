@isTest
private class TestAccountTriggerHandler {

    @testSetup
    static void setup() {
        // Create a test Account
        Account acc = new Account(Name='Test Account', Description='Initial Description',BillingCity='Inital city',BillingCountry='Initial Country');
        insert acc;
        
        // Create related Contacts
        Contact con1 = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acc.Id);
        Contact con2 = new Contact(FirstName = 'Jane', LastName = 'Doe', AccountId = acc.Id);
        Test.startTest();
        insert new List<Contact>{con1, con2};
        Test.stopTest();
    }

    @isTest
    static void TesthandleAfterUpdate() {
        // Retrieve the test Account and modify its description
       Account oldAcc = [SELECT Id, Description FROM Account WHERE Name='Test Account' LIMIT 1];
Account acnt = oldAcc.clone(false, true, false, false); // clone to get a new instance for update
acnt.Description = 'Modified Description';

Test.startTest();
update acnt;

// Pass the correct old map to simulate after update
Map<Id, Account> oldMap = new Map<Id, Account>{ oldAcc.Id => oldAcc };
AccountTriggerHandler.handleAfterUpdate(new List<Account>{acnt}, oldMap);
Test.stopTest();


        // Re-query the Contact records to get the updated Description
        List<Contact> consList = [SELECT Id, Description FROM Contact WHERE AccountId = :acnt.Id];
        for (Contact con : consList) {
            System.assertEquals('Modified Description', con.Description);
        }
    }
    @isTest
    static void TestdoAssignAddress(){
        Account acnt =[Select Id,BillingCity,BillingCountry from Account Where Name='Test Account' Limit 1];
        acnt.BillingCity='Hyderabad';
        acnt.BillingCountry='India';
        update acnt;
        Test.startTest();
        AccountTriggerHandler.doAssignAddress(new List<Account>{acnt},new Map<Id,Account>{acnt.Id=>acnt});
        Test.stopTest();
        List<Contact> consList = [SELECT Id,AccountId,MailingCity,MailingCountry From Contact Where AccountId=:acnt.Id];
        for(Contact con:consList){
            System.assertEquals('Hyderabad', con.MailingCity);
            System.assertEquals('India', con.MailingCountry);
        }

    }
}
