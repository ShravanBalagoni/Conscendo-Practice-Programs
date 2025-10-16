public with sharing class PincodeAPIController {
    public static void getPlaces(String pincode){
    HttpRequest req = new HttpRequest();
    req.setEndpoint('https://api.postalpincode.in/pincode/' + pincode);
    req.setMethod('GET');
    Http h = new Http();
    HttpResponse res = h.send(req);
    WrapperClass wrapper = (WrapperClass)JSON.deserializeUntyped(res.getBody(),WrapperClass.class);
    
    //Map<String,Object> responseMap = (Map<String,Object>) responselist[0];
    //List<Object> postOfficeList = (List<Object>)responseMap.get('PostOffice');
    for(innerWrapperClass wrp : wrapper.PostOffice){
        Map<String,Object> postofficeMap = (Map<String,Object>) wrp;
        System.debug(postofficeMap.get('BranchType')); // NOTE: The key here appears to be an empty string, which is unusual.
    }
}
    public class WrapperClass{
        public String Message;
        public String Status;
        public List<innerWrapperClass> PostOffice;
 
    }
    
    public class  innerWrapperClass{
            public String Name;
            public String BranchType;
            public String DeliveryStatus;
            public String District;
            public String Division;
            public String Region;
            public String Block;
            public String State;
            public String Country;
            public Integer Pincode;

        }

}