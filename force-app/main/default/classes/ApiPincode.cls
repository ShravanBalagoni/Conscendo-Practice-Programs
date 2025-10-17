public with sharing class ApiPincode {
    public static void getBranchTypes(String pincode) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.postalpincode.in/pincode/' + pincode);
        req.setMethod('GET');
        Http h = new Http();
        HttpResponse res = h.send(req);
        System.debug('Raw response: ' + res.getBody());
        List<Wrapper> wrapperList = (List<Wrapper>) JSON.deserialize(res.getBody(), List<Wrapper>.class);
        if (wrapperList == null || wrapperList.isEmpty()) {
            System.debug('No data found');
            return;
        }
        Wrapper w = wrapperList[0];
        for (PostOfficeEntry entry : w.PostOffice) {
            System.debug('BranchType: ' + entry.BranchType);
        }
    }
    public class Wrapper {
        public List<PostOfficeEntry> PostOffice;
       
        public String Message;
        public String Status;
    }
    public class PostOfficeEntry {
        public String BranchType;
        
    }
}
