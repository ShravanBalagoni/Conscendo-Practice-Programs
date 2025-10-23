
@isTest
private class TestAccountTriggerHandler {

    @testSetup
    static void setup() {
        // Create a test Account
        Account acc = new Account(Name='Test Account',Description='Initial Description');
        insert acc;
        //create related Contacts
        Contact con1 = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acc.Id);
        Contact con2 = new Contact(FirstName = 'Jane', LastName = 'Doe', AccountId = acc.Id);
        insert new List<Contact>{con1,con2};
    }
    @isTest
    static void TesthandleAfterUpdate(){
        //Retreive the test Account and modify its description
        Account acnt = [Select Id,Name,Description from Account Where Name='Test Account' Limit 1];
        acnt.Description = 'Modified Description';
        update acnt;
        List<Contact> consList = [Select Id,Description from Contact Where AccountId=:acnt.Id];
        for(Contact con:consList){
            System.assertEquals('Modified Description', con.Description);
        }
    }
}