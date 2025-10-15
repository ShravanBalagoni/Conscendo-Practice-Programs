// Define a REST resource with a custom URL mapping
@RestResource(urlMapping='/myown/customerdata/')
global class SampleRestIntegration3 {

    // Inner class to structure the customer data response
    global class customerData {
        public String customerName; // Customer's name
        public String customerPhoneNumber; // Customer's phone number
    }

    // HTTP GET method to fetch customer data
    @HttpGet
    global static customerData doSendData() {
        // Query to retrieve the first Account record's Name and Phone fields
        Account acnt = [SELECT Id, Name, Phone FROM Account LIMIT 1];

        // Instantiate the customerData class to hold the response data
        customerData cData = new customerData();
        cData.customerName = acnt.Name; // Assign Account Name to customerName
        cData.customerPhoneNumber = acnt.Phone; // Assign Account Phone to customerPhoneNumber

        // Return the populated customerData object as the response
        return cData;
    }
}
