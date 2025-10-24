public with sharing class SampleApexBatchJob implements Database.Batchable<SObject>{
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query ='Select Id,Name from Account';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.Batchable bc,List<SObject> dataList){
        system.debug('**Execute**');
    }
    public void finish(Database.BatchableContext bc){
        System.debug('finish');
    }
}
/*SampleApexBatchJob job = new SampleApexBatchJob();
Id jobId = Database.executeBatch(job);  
 */