public class SwitchExample {
    public static void evaluateStatus(String status) {
        switch on status {
            when 'NEW' {
                System.debug('Status is NEW.');
            }
            when 'IN_PROGRESS' {
                System.debug('Status is IN_PROGRESS.');
            }
            when 'COMPLETED' {
                System.debug('Status is COMPLETED.');
            }
            when 'CANCELLED' {
                System.debug('Status is CANCELLED.');
            }
            when else {
                System.debug('Unknown status.');
            }
        }/*
        switchonsobject{
            whenAccounta{
            System.debug('account'+a);
            }
            whenContactc{
            System.debug('contact'+c);
            }
            whennull{
            System.debug('null');
            }
            whenelse{
            System.debug('default');
            }
 }*/
    }
}
