public  class JokeAPIController {
    public static void lameJokes(){
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://official-joke-api.appspot.com/random_joke');
        request.setMethod('GET');
        Http http = new Http();
        HttpResponse response = http.send(request);
        ResponseWrapper wrapper = (ResponseWrapper) JSON.deserialize(response.getBody(),ResponseWrapper.class);
        System.debug(wrapper);
        System.debug(wrapper.id+10);

    }
    public class ResponseWrapper{
        public string type;
        public string setup;
        public string punchline;
        public Integer id;
    }
}   
