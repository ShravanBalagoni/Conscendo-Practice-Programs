public with sharing class SampleApexLtngWebCmpnt {
    @auraEnabled(cacheable =true)
    public static String getPersonName(){
        return 'Shravan Balagoni';
    }
     @auraEnabled(cacheable =true)
    public static List<Contact> getContacts(){
        return [Select Id,LastName from Contact ];
    }
    @auraEnabled
    public static List<Account> getAccountIMP(){
        return [Select Id,Name,Industry,Rating from Account];
    }
    @auraEnabled(cacheable=true)
    public static String doCreateAccount(String acntName){
        Account acnt = new Account();
        acnt.Name= acntName;
        insert acnt;
        return acnt.Id;
    }
}