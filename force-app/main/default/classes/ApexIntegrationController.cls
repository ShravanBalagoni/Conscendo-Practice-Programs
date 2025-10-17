public class ApexIntegrationController {
    
    public static void hitSalesforce(){
        String token;
        String authUrl = 'https://orgfarm-b79d2a8624-dev-ed.develop.my.salesforce.com/services/oauth2/token';
        String grantType = 'client_credentials';
        String clientId = '3MVG9dAEux2v1sLt6fwIw9M91CfKOao5EGOqLcuRulTtnUDgIxo2G0gClVNd.g1kC4tViOEIRShVIukEd68U2';
        String clientSecret = '18C5771CF623C462982D4A12B2F427AC0F5300AF204F429EB3EA515D18DB0F33';
        String username = 'shravanbalagoni17377@agentforce.com';
        String password = 'PassW@123';
        String authBody = 'grant_type='+EncodingUtil.urlEncode(grantType,'UTF-8')+'&client_id='+EncodingUtil.urlEncode(clientId,'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(clientSecret,'UTF-8')+'&username='+EncodingUtil.urlEncode(username,'UTF-8')+'&password='+EncodingUtil.urlEncode(password,'UTF-8');
        //Setting the http request body
        HttpRequest authReq = new HttpRequest();
        authReq.setEndpoint(authUrl);
        authReq.setMethod('POST');
        authReq.setBody(authBody);
        Http http = new Http();
        HTTPResponse authRes = http.send(authReq);
        System.debug('response'+authRes.getBody());
      
    }
   
}