@restResource(urlmapping='/myown/AccountWrapperGET/')
Global with sharing class AccountWrapperGET {
    Global class CustomerData{
        public String name;
        public String phone;
    }
    @httpGET
    Global Static CustomerData getData(){
        Account acnt =[Select Id,Name,Phone from Account Limit 1];

        CustomerData cData = new CustomerData();
        cData.name = acnt.Name;
        cData.phone = acnt.Phone;

        return cData;
    }
}