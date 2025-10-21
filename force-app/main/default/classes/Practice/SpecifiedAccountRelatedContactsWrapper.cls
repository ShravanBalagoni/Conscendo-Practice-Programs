@restResource(urlmapping='/myown/SpecificAccountRelatedContactsWrapper/*')
Global with sharing class SpecifiedAccountRelatedContactsWrapper {
    Global class CustomerData{
        public string CustomerName;
        public string CustomerPhone;
        public List<CustomerContact> customerContacts;
    }
    Global class CustomerContact{
        public String contactLastName;
        public String contactPhone;
        public String contactEmail;
    }
    @httpGET
    global Static CustomerData getData(){
        RestRequest req = RestContext.request;
        String recordId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Account acnt = [Select Id,Name,Phone,(Select LastName,Phone,Email from Contacts) from Account 
                            Where Id =:recordId];
        CustomerData cData = new CustomerData();
        cData.CustomerName = acnt.Name;
        cData.CustomerPhone = acnt.Phone;
        List<CustomerContact> cContactList = new List<CustomerContact>();
        for(Contact con:acnt.Contacts){
            CustomerContact cCon = new CustomerContact();
            cCon.contactLastName = con.LastName;
            cCon.contactEmail = con.Email;
            cCon.contactPhone = con.Phone;
            cContactList.add(cCon);
        }
        cData.customerContacts = cContactList;
        return cData;
    }
}