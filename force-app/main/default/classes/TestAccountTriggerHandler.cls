@isTest
private class TestAccountTriggerHandler {

    @testSetup
    static void setup() {
        // Create a test Account
        Account acc = new Account(Name='Test Account', Description='Initial Description');
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
        Account acnt = [SELECT Id, Description FROM Account WHERE Name='Test Account' LIMIT 1];
        acnt.Description = 'Modified Description';
        Test.startTest();
        update acnt;
        Test.stopTest();

        // Re-query the Contact records to get the updated Description
        List<Contact> consList = [SELECT Id, Description FROM Contact WHERE AccountId = :acnt.Id];
        for (Contact con : consList) {
            System.assertEquals('Modified Description', con.Description);
        }
    }
}
