public with sharing class SampleApexLtngWebCmpnt {
    @auraEnabled(cacheable =true)
    public static String getPersonName(){
        return 'Shravan Balagoni';
    }
    public static List<Contact> getContacts(){
        return [Select Id,LastName from Contact ];
    }
}