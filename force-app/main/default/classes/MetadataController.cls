public with sharing class MetadataController {
  @AuraEnabled(cacheable=true)
  public static List<My_Metadata__mdt> getMetadataRecords(){
    return [
      SELECT Id, MasterLabel, Value__c
      FROM My_Metadata__mdt
      WHERE Active__c = TRUE
    ];
  }
}
