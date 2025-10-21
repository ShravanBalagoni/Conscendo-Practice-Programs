@RestResource(urlmapping='/crompton/smb/customerdataP/*')
global class CustomResponseController{
	global class customerData{
		public string customerName;
		public string customerPhoneNumber;
		public List<customerContact> customerContacts;
	}
	global class customerContact{
		public string LastName;
		public string phone;
		public string email;
    }
	
	
	@httpGET
	global static void doSendData(){
	{	
        RestRequest req = RestContext.request;
        RestResponse resp = RestContext.response;
        try{
            string recordId = req.requestURI.substring(req.requestURI.lastIndexof('/')+1);
		    Account acnt = [Select Id,Name,Phone,
				(Select Id,LastName,Phone,Email 
				from Contacts) 
				from Account Where Id=:recordId];
		customerData cData = new customerData();
		cData.customerName = acnt.Name;
		cData.customerPhoneNumber = acnt.Phone;
		
		List<customerContact> cContactsList = new List<customerContact>();
		for(Contact con:acnt.Contacts)
		{
			customerContact cContact = new customerContact();
			cContact.LastName = con.LastName;
			cContact.phone = con.phone;
			cContact.email = con.email;
			cContactsList.add(cContact);
		}
		cData.customerContacts = cContactsList;
        String jsonBody = JSON.serializepretty(cData);
        resp.statuscode = 200;
        resp.responseBody = blob.valueof(jsonBody);
        }
        catch(exception ex){
            resp.statuscode=400;
            string jsonBody ='Some issue,reachout to system admin:'+ex;
            resp.responseBody = blob.valueof(jsonBody);            
        }
        
}
}
}