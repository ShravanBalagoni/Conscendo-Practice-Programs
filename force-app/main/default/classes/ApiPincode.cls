public with sharing class ApiPincode {
    public static void getBranchTypes(String pincode) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.postalpincode.in/pincode/' + pincode);
        req.setMethod('GET');
        Http h = new Http();
        HttpResponse res = h.send(req);
        
        String body = res.getBody();
        System.debug('Raw response: ' + body);
        
        // Deserialize top-level JSON (an array) into wrapper list
        List<Wrapper> wrapperList = (List<Wrapper>) JSON.deserialize(body, List<Wrapper>.class);
        if (wrapperList == null || wrapperList.isEmpty()) {
            System.debug('No data found');
            return;
        }
        
        // Use only the first element
        Wrapper w = wrapperList[0];
        
        for (PostOfficeEntry entry : w.PostOffice) {
            System.debug('BranchType: ' + entry.BranchType);
        }
    }

    // Wrapper class matching the JSON structure, but only including fields you need
    public class Wrapper {
        public List<PostOfficeEntry> PostOffice;
        // You can include Message or Status if you also want to check them
        public String Message;
        public String Status;
    }
    
    public class PostOfficeEntry {
        public String BranchType;
        // Other fields can be omitted if you don’t need them
    }
}
