public class SimpleExceptionDemo {
    public static void tryInsertAccount() {
        try {
            // Attempt to insert Account without Name (required)
            Account acc = new Account();
            insert acc; // This will throw a DmlException
            System.debug('Account inserted successfully');
        } catch (DmlException ex) {
            System.debug('Caught a DML Exception: ' + ex.getMessage());
        } finally {
            System.debug('This is the finally block: always runs!');
        }
    }
}
