@isTest
private class TestAccountTriggerHandler {
    @TestSetup
    static void makeData(){
        Account acnt = new Account(Name='Test Account',Description='Initial Description');
        insert acnt;
        Contact Con1 = new Contact(LastName='John',AccountId=acnt.Id);
        Contact Con2 = new Contact(LastName='Jane',AccountId=acnt.Id);
        Test.startTest();
        insert new List<Contact>{Con1,Con2};
        Test.stopTest();
    }

    @isTest
    static void TesthandleAfterUpdate() {

        Account oldacc = [Select Id,Description from Account Where Name='Test Account'];
        Account newAcc = [Select Id,Description from Account Where Id=:oldacc.Id];
        newAcc.Description='Modified Description';
        Test.startTest();
        update newAcc;
        AccountTriggerHandler.handleAfterUpdate(new List<Account>{newAcc},new Map<Id,Account>{oldacc.Id=>oldacc});
        Test.stopTest();
        List<Contact> consList = [Select Id,AccountId,Description from Contact Where AccountId=:newAcc.Id];
        for(Contact con:consList){
            System.assertEquals('Modfied Description', con.Description);

        }
    }
    @isTest
    static void TestdoAssignAddress(){
        Account oldAcc = [Select Id,Description from Account Where Name='Test Account'];
        Account newAcc = [Select Id,Description from Account Where Id=:oldAcc.Id];
        newAcc.BillingCity='Hyderabad';
        newAcc.BillingCountry = 'India';
        Test.startTest();
        Update newAcc;
        AccountTriggerHandler.doAssignAddress(new List<Account>{newAcc},new Map<Id,Account>{oldAcc.Id=>oldAcc});
        Test.stopTest();
        Contact cons = [Select Id,AccountId,MailingCity,MailingCountry from Contact Where AccountId=:newAcc.Id ];
        for(Contact con:cons){
            System.assertEquals('Hyderabad', con.MailingCity);
            System.assertEquals('India', con.MailingCountry);
            

        }
    }
    @TestSetup
    static void makeData(){
        Account acntRec =new Account(Name='Test Account1',Customer_Relationship__c='Active');
        insert acnt;
        Contact conRec1= new Contact(LastName='TestCon1',AccountId=acntRec.Id);
        Contact conRec2= new Contact(LastName='TestCon2',AccountId=acntRec.Id);
        insert new List<Contact>{con1,con2};

        Case cs1= new Case(Name='TestCase1',Status='New',AccountId=acntRec.Id,ContactId=conRec1.Id);
        Case cs2= new Case(Name='TestCase2',Status='Working',AccountId=acntRec.Id,ContactId=conRec2.Id);
        insert new List<Case>{cs1,cs2};
    }
    @isTest
    static void TestUpdateCaseStatus(){
        Account oldacnt = [Select Id,Name,Customer_Relationship__c from Account Where Name='Test Account1'];
        Account newAcnt = [Select Id,Name,Customer_Relationship__c from Account Where Id=:oldacnt.Id];
        newAcnt.Customer_Relationship__c = 'No Relationship';
        Test.startTest();
        update newAcnt;
        AccountTriggerHandler.doUpdateCaseStatus(new List<Account>{newAcnt},new Map<Id,Account>{newAcnt.Id=>newAcnt});
        Test.stopTest();
        List<Case> csList = [Select Id,AccountId,ContactId,Status from Case Where AccountId In:newAcnt.Id];
        for(Case cs:csList){
            System.assertEquals('Closed', cs.Status);
        }
    }
    
    
}