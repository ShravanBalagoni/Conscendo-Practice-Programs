public with sharing class SampleIterableBatchJob implements Database.Batchable<SObject> {
    List<Contact> consList;
    public SampleIterableBatchJob(List<Contact> cons){
        cons = consList;
    }
    public Iterable <SObject> start(Database.BatchableContext bc){
        System.debug('***START***');
        return consList;
    }
    public void execute(Database.BatchableContext bc,List<SObject> dataList){
        System.debug('Execute'+dataList.size());

    }
    public static void finish(Database.BatchableContext bc){
        System.debug('Finish');
    }
}