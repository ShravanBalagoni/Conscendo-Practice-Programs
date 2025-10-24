public with sharing class SampleSchedularApex implements Schedulable{
    public void execute(SchedulableContext sc){
        contact con = new Contact();
        con.LastName = 'Test Schedular Contact';
        con.Phone = '890990000';
        insert con;
    }
}