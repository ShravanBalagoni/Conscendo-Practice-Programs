@RestResource(urlmapping='/myown/CustomerData/RestApex4/*')
global class SampleRestIntegration4 {

    // Inner class to structure customer data
    global class customerData {
        public String CustomerName;             // Customer's full name
        public String CustomerPhoneNumber;      // Customer's phone number
        public List<customerContact> customerContacts;  // List to hold customer contacts
    }

    // Inner class to structure customer contact details
    global class customerContact {
        public String LastName;   // Contact's last name
        public String Phone;      // Contact's phone number
        public String email;      // Contact's email address
    }

    // HTTP GET method to retrieve customer and contact information
    @HttpGet
    global static customerData doSendData() {

        // Query to fetch the first Account record along with its related Contacts
        Account acnt = [SELECT Id, Name, Phone,
                        (SELECT LastName, Phone, Email FROM Contacts)
                        FROM Account LIMIT 1];

        // Instantiate the customerData object to hold the retrieved data
        customerData cData = new customerData();
        cData.CustomerName = acnt.Name;  // Assign Account Name to CustomerName
        cData.CustomerPhoneNumber = acnt.Phone;  // Assign Account Phone to CustomerPhoneNumber

        // Initialize a list to hold customer contact details
        List<customerContact> cContactsList = new List<customerContact>();

        // Loop through each Contact related to the Account
        for (Contact con : acnt.Contacts) {
            customerContact cContact = new customerContact();
            cContact.LastName = con.LastName;  // Assign Contact's Last Name
            cContact.Phone = con.Phone;        // Assign Contact's Phone
            cContact.email = con.Email;        // Assign Contact's Email
            cContactsList.add(cContact);       // Add the contact to the list
        }

        // Assign the list of contacts to the customerData object
        cData.customerContacts = cContactsList;

        // Return the populated customerData object
        return cData;
    }
}
