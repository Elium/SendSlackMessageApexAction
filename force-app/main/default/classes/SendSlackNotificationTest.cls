@isTest
public class SendSlackNotificationTest {
    private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setBody('{"ok":true, "warning":"", "error":""}');
            res.setStatusCode(200);
            return res;
        }
    }
    @isTest static void testSendSlackNotification(){
        Test.setMock(HttpCalloutMock.class, new Mock());
        SendSlackNotification.Request r = new SendSlackNotification.Request();
        r.message = 'Test Message,,, Test Message Section 2,,, Test message section 3';
        r.bearerToken = '12345';
        r.userMentions = '123545, 123456, 53464';
        r.preview = 'Test message preview';
        r.slackChannelName = 'Test Channel';
        r.sendAsync = false;
        Test.startTest();
        List<APICallout.Response> resp = SendSlackNotification.SendMessage(r);
        Test.stopTest();
        System.assertEquals(200, resp[0].statusCode);
    }
    
    @isTest static void testSendSlackNotificationAsync(){
        Test.setMock(HttpCalloutMock.class, new Mock());
        SendSlackNotification.Request r = new SendSlackNotification.Request();
        r.message = 'Test Message,,, Test Message Section 2,,, Test message section 3';
        r.bearerToken = '12345';
        r.userMentions = '123545, 123456, 53464';
        r.preview = 'Test message preview';
        r.slackChannelName = 'Test Channel';
        r.sendAsync = true;
        Test.startTest();
        List<APICallout.Response> resp = SendSlackNotification.SendMessage(r);
        Test.stopTest();
        System.assertEquals(200, resp[0].statusCode);
    }
}