@isTest
global class HttpCallOutMockTest implements HttpCalloutMock{
    protected String body;
    protected String endpoint;
    protected String method;
    
    public HTTPCalloutMockTest() {
        this.body = '{"success":true}';
        this.endpoint = 'https://www.google.com/recaptcha/api/siteverify';
        this.method = 'GET';
    }
    
    public HTTPCalloutMockTest(String body, String endpoint, String method) {
        this.body = body;
        this.endpoint = endpoint;
        this.method = method;
    }   
    
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals(endpoint, req.getEndpoint());
        System.assertEquals(method, req.getMethod());
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}