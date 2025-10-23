
@isTest
private class TestOpportunityTriggerHandler {
    @TestSetup
    static void makeData(){
        
        Account acnt = new Account(Name='Test Account');
        insert acnt;
        Opportunity opp1 = new Opportunity(Name = 'Opp 1',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 50000,
            AccountId = acc.Id
            );
        Opportunity opp2 = new Opportunity(Name = 'Opp 2',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 150000,
            AccountId = acc.Id
            );

        insert new List<Opportunity>{opp1,opp2};



    }

    @isTest
    static void TestdoValidate() {
       
        Opportunity opp = new Opportunity(Name='New Opp',StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 150000,
            AccountId = acc.Id);
            Test.startTest();
            insert opp;
            Opportunity oldopp = [Select Id,Name,Amount,AccountId from Opportunity Where Name='New Opp'];
            oldopp.Amount=500;
            update oldopp;
            OpportunityTriggerHandler.doCalculate(new List<Opportunity>{oldopp}, new Map<Id,Opportunity>{oldopp.id=>oldopp});
            Test.stopTest();
            Account acnts = [Select Id,Max_Opp_Amount__c,Min_Opp_Amount__c from Account Where Id=:acnt.Id];
            

            


        // TO DO: implement unit test
    }
}