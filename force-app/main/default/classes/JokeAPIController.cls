public  class JokeAPIController {
    public static void lameJokes(){
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://official-joke-api.appspot.com/random_joke');
        request.setMethod('GET');
        Http http = new Http();
        HttpResponse response = http.send(request);
        ResponseWrapper wrapper = (ResponseWrapper) JSON.deserialize(response.getBody(),ResponseWrapper.class);
       // Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
        //System.debug(result.getStatusCode());
       
        System.debug(wrapper.id+10);

    }
    public class ResponseWrapper{
        public string type;
        public string setup;
        public string punchline;
        public Integer id;
    }
}   
