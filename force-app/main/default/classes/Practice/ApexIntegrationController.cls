public with sharing class ApexIntegrationController {
    public static void hitSalesforce(){
        public String token;
        public String authurl='';
        public String Clientid='';
        public String Clientsecret='';
        public String grantType='';
        public String userName = '';
        public String password='';
        public String authBody='';
        HttpRequest authRequest = new HttpRequest();
        authRequest.setEndpoint(authurl);
        authRequest.setMethod('POST');
        authRequest.setBody(authBody);
        Http http =new Http();
        HttpResponse authResp = http.send(authRequest);
        System.debug(authResp.getBody());
        System.debug(authResp.getStatusCode());
        if(authResp.getStatusCode()=='200'){
            Map<String,Object> result = (Map<String,Object>)JSON.deserialize(authResp.getBody());
            token = (String )result.get('access_token');
            String endpointurl = '';
            List<Map<String,String>> accounts = new List<Map<String,String>>();
            accounts.add(new Map<String,String>{'name'=>'Shra1','phone'=>'9979189400'});
            accounts.add(new Map<String,String>{'name'=>'Pa1','phone'=>'9979109800'});
            String requestBody = JSON.serialize(accounts);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpointurl);
            req.setMethod('POST');
            req.setBody(requestBody);
            Http http2 = new Http();
            HttpResponse resp = http2.send(req);
            System.debug('Raw BODY: '+resp.getBody());

            }
            else {
                System.debug('End Response code:'+authResp.getStatusCode());
            }
    }
}