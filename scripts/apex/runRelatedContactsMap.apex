// Anonymous Apex script to test RelatedContactsMap
// Ensure the class is deployed and accessible in your org

// Query a sample list of contacts
List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE AccountId != NULL LIMIT 10];

// Instantiate the RelatedContactsMap class
RelatedContactsMap rcm = new RelatedContactsMap(contacts);

// Output the map to debug logs
System.debug('AccountId to Contacts Map: ' + rcm.accIdToContacts);
