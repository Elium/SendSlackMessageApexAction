@isTest
public class APICalloutTest {
    private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setBody('{"test":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest static void TestAPICallout(){
        Test.setMock(HttpCalloutMock.class, new Mock());
        APICallout.Request r = new APICallout.Request();
        List<APICallout.Request> requests = new List<APICallout.Request>();
        r.endpoint = '/test/parameter/{{urlParam}}';
        r.urlParameter = 'testParam';
        r.requestType = 'GET';
        requests.add(r);
        Test.startTest();
        List<APICallout.Response> resp = APICallout.ApiCallout(requests);
        Test.stopTest();

        System.assertEquals(200, resp[0].statusCode);
        System.assertEquals('{"test":"test"}', resp[0].responseBody);

    }

    @isTest static void TestAPICalloutInvalidNamedCredential(){
        Test.setMock(HttpCalloutMock.class, new Mock());
        APICallout.Request r = new APICallout.Request();
        List<APICallout.Request> requests = new List<APICallout.Request>();
        r.endpoint = '/test/parameter/{{urlParam}}';
        r.urlParameter = 'testParam';
        r.requestType = 'GET';
        r.namedCredential = 'This Should be an invalid named credential ---';
        requests.add(r);
        Test.startTest();
        List<APICallout.Response> resp = APICallout.ApiCallout(requests);
        Test.stopTest();

        System.assertEquals(404, resp[0].statusCode);

    }
    
    @isTest static void TestAPICalloutAsync(){
        Test.setMock(HttpCalloutMock.class, new Mock());
        APICallout.Request r = new APICallout.Request();
        List<APICallout.Request> requests = new List<APICallout.Request>();
        r.endpoint = '/test/parameter/{{urlParam}}';
        r.urlParameter = 'testParam';
        r.requestType = 'GET';
        r.sendAsync = true;
        requests.add(r);
        Test.startTest();
        List<APICallout.Response> resp = APICallout.ApiCallout(requests);
        Test.stopTest();

        System.assertEquals(200, resp[0].statusCode);

    }
}