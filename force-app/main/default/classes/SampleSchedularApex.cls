public with sharing class SampleSchedularApex implements Schedulable{
    public void execute(SchedulableContext sc){
        contact con = new Contact();
        con.LastName = 'Test Schedular Contact';
        con.Phone = '890990000';
        insert con;
    }
}
/*String cronExp = '0 0 2 * * ?'; // every day at 2 AM
String jobName = 'Create Test Contact Daily';
System.schedule(jobName, cronExp, new SampleSchedularApex());
Seconds (0–59): Always set to 0 because Salesforce does not support scheduling at the second level.

Minutes (0–59): Specifies the exact minute when the job should run.

Hours (0–23): Specifies the hour of the day (in 24-hour format).

Day of the Month (1–31): Specifies the day of the month when the job should run.

Month (1–12 or JAN–DEC): Specifies the month when the job should run.

Day of the Week (1–7 or SUN–SAT): Specifies the day of the week when the job should run.

Year (optional, 1970–2099): Specifies the year when the job should run (optional).
*/