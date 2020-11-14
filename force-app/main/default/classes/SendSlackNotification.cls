global class SendSlackNotification {
    @InvocableMethod(label = 'Send Slack Message')
    global static void SendSlackMessage(List<Request> requests){
        for(Request request : requests){
            SendMessage(request);
        }
    }

    public static List<APICallout.Response> SendMessage(Request r){
        if(r.sendAsync == null){
            r.sendAsync = false;
        }
        if(String.isBlank(r.bearerToken)){
            throw new slackException('No Slack Bot bearer token has been received. Please make sure you have entered a valid bearer token');
        }
        if(String.isBlank(r.slackChannelName)){
            throw new slackException('No Slack Channel name was found. Please enter a valid channel name.');
        }
        SlackBlock body = new SlackBlock();
        body.channel = r.slackChannelName;
        body.text = r.preview;
        List<String> messages = r.message.split(',,,'); //Split the message into blocks--the user can define blocks by entering ,,,.
        // List<String> messages = new List<String>();
        // messages.add('This is a test for \n new line testing');
        for(Integer i = 0; i < messages.size(); i++){
            //Add message content with mark down capabilities.
            SlackContent content = new SlackContent();
            content.type = 'mrkdwn';
            messages[i] = messages[i].replaceAll('--n', '\n');
            //If user mentions are included, add the mention markdown to the first section of the block
            if(i == 0){
                if(!String.isBlank(r.userMentions)){
                    List<String> userMentions = r.userMentions.split(',');
                    String mentions = '';
                    for(String userMention : userMentions){
                        mentions += '<@' + userMention.trim() + '> '; 
                    }
                    content.text = mentions + messages[i].trim();
                } else {
                    content.text = messages[i].trim();
                }
            } else {
                content.text = messages[i].trim();
            }
            //Define the section.
            SlackSection section = new SlackSection();
            section.type = 'section';
            section.text = content;

            //Add the section to the body.
            body.blocks.add(section);
        }

        List<APICallout.Request>reqs = new List<APICallout.Request>();
        APICallout.Request req = new APICallout.Request();
        if(r.sendAsync){
            req.sendAsync = true;
        }
        req.bearerToken = r.bearerToken;
        req.namedCredential = 'SlackConnection';
        req.endpoint = '/api/chat.postMessage';
        req.requestType = 'POST';
        System.debug(JSON.serialize(body));
        req.body = JSON.serialize(body);
        reqs.add(req);
        List<APICallout.Response> resp = APICallout.ApiCallout(reqs);
        SlackResponse sResponse = new SlackResponse();
        if(!r.sendAsync){
            sResponse = parseSlackResponse(resp[0].responseBody);
        } else {
            sResponse.ok = true;
            sResponse.warning = 'Request was sent Asyncronously, no useful return value is provided.';
        }
        
        System.debug(sResponse);
        if(!sResponse.ok){
            if(sResponse.error == 'channel_not_found'){
                throw new slackException('Slack Callout Error: ' + sResponse.error + '. This may occur if the SlackBot/App has not been invited as a member of the target slack channel. The Bot can be invited by typing "/invite @YourApp" in the target channel. -- Warning: ' + sResponse.warning);
            }
            throw new slackException('Slack Callout Error: ' + sResponse.error + ' -- Warning: ' + sResponse.warning);
        }
        if(resp[0].statusCode != 200) {
            throw new slackException('An error occurred with the Send Slack Message callout. Error Code -- ' + resp[0].statusCode + ': ' + resp[0].errorMessage);
        }
        return resp;
    }

    public class slackException extends Exception {}

    private class SlackBlock {
        private String channel;
        private String text; //This is the preview text that is shown to users.
        private List<SlackSection> blocks = new List<SlackSection>();
    }

    private class SlackSection {
        //private String block_id;
        private String type;
        private SlackContent text = new SlackContent();
    }

    private class SlackContent {
        private String type;
        private String text;
    }

    global class Request {
        @InvocableVariable(label='Message' description='The message to be sent to slack, separate message blocks with three commas i.e. (This is message block one,,, This is message block two).' required=true)
        global String message;

        @InvocableVariable(label='Message Preview' description='The preview is a simple preview or description of the message that is shown to the user when notified of a new message.' required=true)
        global String preview;

        @InvocableVariable(label='Bearer Token' description='The bearer token for the Bot that will be sending the message.' required=true)
        global String bearerToken;

        @InvocableVariable(label='Slack Channel Name' description='If the channel is public, it must be preceded with the # symbol i.e. #general. If private, no symbol is needed i.e. private-channel' required=true)
        global String slackChannelName;

        @InvocableVariable(label='User Mentions' description='Mention multiple users by separating Slack Ids with a comma i.e. {!$User1.SlackId}, {!$User2.SlackId}')
        global String userMentions;

        @InvocableVariable(label='Send Request Asynchronously' description='Allows the request to be sent on triggers.')
        global Boolean sendAsync;
    }

    public class SlackResponse {
        public Boolean ok {get; set;}
        public String error {get; set;}
        public String warning {get; set;}
    }
    
    public static SlackResponse parseSlackResponse(String json) {
        System.debug(json);
        return (SlackResponse) System.JSON.deserialize(json, SlackResponse.class);
    }
}
