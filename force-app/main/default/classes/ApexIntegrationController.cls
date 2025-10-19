public class ApexIntegrationController {

    public static void hitSalesforce() {
        String token;
        String authUrl = 'https://butterflycrompton-dev-ed.develop.my.salesforce.com/services/oauth2/token';
        String grantType = 'client_credentials';
        String clientId = '3MVG9GCMQoQ6rpzRVqhB1XerpCyOvoNVLgfeNzQZVLfOaA03.ZfmtnoBOXiqmOHzGPxrPZjs4gWt_Pxm7QTD_';
        String clientSecret = 'E02C186080B1EE752C06B810496B9BA894B7FFB9AB10F36AD425FD5D54AE906D';
        String username = 'shravanbalagoni17377@agentforce.com';
        String password = 'PassW@123';
        String authBody = 'grant_type=' + EncodingUtil.urlEncode(grantType, 'UTF-8') +
                          '&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8') +
                          '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8') +
                          '&username=' + EncodingUtil.urlEncode(username, 'UTF-8') +
                          '&password=' + EncodingUtil.urlEncode(password, 'UTF-8');

        HttpRequest authReq = new HttpRequest();
        authReq.setEndpoint(authUrl);
        authReq.setMethod('POST');
        authReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        authReq.setBody(authBody);
        Http http = new Http();
        HTTPResponse authRes = http.send(authReq);
        System.debug('Auth Response: ' + authRes.getBody());

        if (authRes.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(authRes.getBody());
            token = (String) result.get('access_token');
            String endpointUrl = 'https://butterflycrompton-dev-ed.develop.my.salesforce.com/services/apexrest/butterfly/AccountCRUD/';
            List<Map<String, String>> accounts = new List<Map<String, String>>();
            accounts.add(new Map<String, String>{'name' => 'Sudheer Rupam 14', 'phone' => '6301898899'});
            accounts.add(new Map<String, String>{'name' => 'Sudheer Rupam 15', 'phone' => '7401899899'});
            String requestBody = JSON.serialize(accounts);

            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpointUrl);
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + token);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(requestBody);
            System.debug('Request Body: ' + req.getBody());

            Http http2 = new Http();
            HttpResponse endRes = http2.send(req);
            System.debug('End Response Code: ' + endRes.getStatusCode());
            System.debug('End Response Body: ' + endRes.getBody());
        } else {
            System.debug('Authentication failed with status code: ' + authRes.getStatusCode());
        }
    }
    //Butterfly_Org
     public static void hitSalesforceUsingNC(){
         List<Map<String, String>> accounts = new List<Map<String, String>>();
        accounts.add(new Map<String, String>{'Name' => 'Sudheer Rupam 14', 'salesRep' => 'Test 14'});
        accounts.add(new Map<String, String>{'Name' => 'Sudheer Rupam 15', 'salesRep' => 'Test 15'});
        String requestBody = JSON.serialize(accounts);
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setEndpoint('callout:Butterfly_Org/services/apexrest/butterfly/AccountCRUD/');
        req.setBody(requestBody);
        Http http2 = new Http();
        HttpResponse endRes = http2.send(req);
        System.debug('endRes Code: '+endRes.getStatusCode());
    }
}
