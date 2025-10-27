public with sharing class SampleApexLtngWebCmpnt {
    @auraEnabled(cacheable =true)
    public static String getPersonName(){
        return 'Shravan Balagoni';
    }
}