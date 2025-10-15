@restResource(urlmapping='/myownservices5/customerdata/*')
Global class SampleRestIntegration5 {
    Global class customerData{
        public string customerName;
        public string customerPhoneNumber;
        public List<customerContact> customerContacts;
    }
    Global class customerContact{
        public string LastName;
        public string Phone;
        public string email;
    }
	@httpGET
    global static customerData doSendData(){
        RestRequest req = RestContext.request;
        string recordId = req.requestURI.substring(req.requestURI.lastIndexof('/')+1);
        Account acnt = [
            SELECT Id, Name, Phone,
            (SELECT LastName, Phone, Email FROM Contacts)
            FROM Account
           Where Id=:recordId
        ];

        customerData cData = new customerData();
        cData.customerName = acnt.Name;
        cData.customerPhoneNumber = acnt.Phone;
        
        List<customerContact> cContactsList = new List<customerContact>();
        for(Contact con: acnt.Contacts)
        {
            customerContact cContact = new customerContact();
            cContact.LastName = con.LastName;
            cContact.phone = con.phone;
            cContact.email = con.email;
            cContactsList.add(cContact);
        }
        cData.customerContacts = cContactsList;
        return cData;
      
    }
}