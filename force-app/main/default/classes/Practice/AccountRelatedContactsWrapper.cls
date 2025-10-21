@restResource(urlmapping='/myown/AccountRelatedContactsWrapper/')
Global with sharing class AccountRelatedContactsWrapper {
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
        Account acnt = [Select Id,Name,Phone,(Select LastName,Phone,Email from Contacts) from Account Limit 1];
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