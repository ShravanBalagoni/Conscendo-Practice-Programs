public with sharing class CurrencyAPIController {
    public static Map<String, Object> getRates() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.coindesk.com/v1/bpi/currentprice.json');
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse response = http.send(req);
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            return result;
        } else {
            System.debug('Error: ' + response.getStatusCode() + ' - ' + response.getStatus());
            return null;
        }
    }
}
