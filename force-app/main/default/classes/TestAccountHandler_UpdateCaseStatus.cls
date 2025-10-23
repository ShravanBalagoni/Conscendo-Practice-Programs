
@isTest
private class TestAccountHandler_UpdateCaseStatus {
    @TestSetup
    static void makeData(){
        Account acnt = new Account(Name = 'Case Test Account',
            Customer_Relationship__c = 'Active');
        insert acnt;
        Contact con = new Contact(LastName='Test User',AccountId=acnt.Id);
        insert con;

        Case cs = new Case(ContactId = con.Id,
            AccountId = acc.Id, 
            Status = 'New',
            Origin = 'Phone');
            insert cs;
    }
    @isTest
    static void myUnitTest() {
        Account acnt = [Select Name,Customer_Relationship__c from Account Where Name = 'Case Test Account' Limit 1];

    }
}