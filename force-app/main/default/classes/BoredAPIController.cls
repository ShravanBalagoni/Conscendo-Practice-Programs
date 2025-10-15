public with sharing class BoredAPIController {
   @AuraEnabled
   public static Map<String,Object> getBoredApis(){
    try {
        Http http =new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://bored-api.appbrewery.com/random');
        request.setMethod('GET');

        HttpResponse response = http.send(request);
        if(response.getStatusCode()==200){
            Map<String,Object> result = ( Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            return result;
        }
        else{
            throw new CalloutException('Error during API Call: '+response.getStatusCode());
        }

    } catch (Exception e) {
         throw new CalloutException('Error during API Call: '+e.getMessage());
    }
   }
}