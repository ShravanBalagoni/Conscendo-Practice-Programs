public with sharing class PincodeAPIController {
    public static void getPlaces(String pincode){
    HttpRequest req = new HttpRequest();
    req.setEndpoint('https://api.postalpincode.in/pincode/' + pincode);
    req.setMethod('GET');
    Http h = new Http();
    HttpResponse res = h.send(req);
    List<Object> responselist = (List<Object>)JSON.deserializeUntyped(res.getBody());
    Map<String,Object> responseMap = (Map<String,Object>) responselist[0];
    List<Object> postOfficeList = (List<Object>)responseMap.get('PostOffice');
    for(Object obj : postOfficeList){
        Map<String,Object> postofficeMap = (Map<String,Object>) obj;
        System.debug(postofficeMap.get('')); // NOTE: The key here appears to be an empty string, which is unusual.
    }
}

//System.debug(wrapper.id+10);
}