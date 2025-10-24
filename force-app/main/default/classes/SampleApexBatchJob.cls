public with sharing class SampleApexBatchJob implements Database.Batchable<SObject>{
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query ='Select Id,Name from Account';
        ret
    }
}