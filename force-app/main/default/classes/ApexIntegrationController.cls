public class ApexIntegrationController {
    
    public static void hitSalesforce(){
        String token;
        String authUrl = 'https://login.salesforce.com/services/oauth2/token';
        String grantType = 'password';
        String clientId = '3MVG9fe4g9fhX0E4lxNVct5syfjOI1eMuiIqvkw6BjMbLwCEPVF2iGSDsSRdLfFMzwaNHs82cVIArmxfT1IRx';
        String clientSecret = '1DA0704EDCF6DD554426CF24659BB3A591B1D541E5BC81B092DF15BE9239F668';
        String username = 'sf.demo@gmail.com';
        String password = 'Venkata12$BdABOI6OwYelUOxJbqao0dHOH';
        String authBody = 'grant_type='+EncodingUtil.urlEncode(grantType,'UTF-8')+'&client_id='+EncodingUtil.urlEncode(clientId,'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(clientSecret,'UTF-8')+'&username='+EncodingUtil.urlEncode(username,'UTF-8')+'&password='+EncodingUtil.urlEncode(password,'UTF-8');
        //Setting the http request body
        HttpRequest authReq = new HttpRequest();
        authReq.setEndpoint(authUrl);
        authReq.setMethod('POST');
        authReq.setBody(authBody);
        Http http = new Http();
        HTTPResponse authRes = http.send(authReq);
        if (authRes.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(authRes.getBody());
            token = (String)result.get('access_token');
            String endpointUrl = 'https://venkata-sai-charan-bhupathi-dev-ed.develop.my.salesforce.com/services/apexrest/accountCRUD';
            List<Map<String, String>> accounts = new List<Map<String, String>>();
            accounts.add(new Map<String, String>{'Name' => 'Sudheer Rupam 14', 'salesRep' => 'Test 14'});
            accounts.add(new Map<String, String>{'Name' => 'Sudheer Rupam 15', 'salesRep' => 'Test 15'});
            String requestBody = JSON.serialize(accounts);
            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', 'Bearer ' + token);
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('POST');
            req.setEndpoint(endpointUrl);
            req.setBody(requestBody);
            Http http2 = new Http();
            HttpResponse endRes = http2.send(req);
            System.debug('endRes Code: '+endRes.getStatusCode());
        }
    }
    public static void hitSalesforceUsingNC(){
         List<Map<String, String>> accounts = new List<Map<String, String>>();
        accounts.add(new Map<String, String>{'Name' => 'Sudheer Rupam 14', 'salesRep' => 'Test 14'});
        accounts.add(new Map<String, String>{'Name' => 'Sudheer Rupam 15', 'salesRep' => 'Test 15'});
        String requestBody = JSON.serialize(accounts);
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setEndpoint('callout:NandaniSalesforce/services/apexrest/accountCRUD');
        req.setBody(requestBody);
        Http http2 = new Http();
        HttpResponse endRes = http2.send(req);
        System.debug('endRes Code: '+endRes.getStatusCode());
    }
}