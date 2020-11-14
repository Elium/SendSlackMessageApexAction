# Send Slack Messages from Salesforce
<a href="https://githubsfdeploy.herokuapp.com?owner=halosight&repo=SendSlackMessageApexAction&ref=master">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

Sending real time information to members of your organization from Salesforce to Slack can be a pain. This APEX action removes all of the grunt work from that process and allows you to quickly and painlessly send Slack messages from a Salesforce flow.

## Setup
A small amount of setup is required to begin using this component. <a href="">This article</a> will quickly walk you through all the setup requirements.

## Parameters
**Bearer Token** (*String*): This parameter receives the *OAuth Token* provided by your Slack App.

**Message** (*String*): A combination of text, flow variables, and <a href="https://api.slack.com/reference/surfaces/formatting">mrkdwn</a> language (*see notes below on mrkdwn*) can be input into the Message. 

**Message Preview** (*String*): This message is displayed in the notification given to the user when the Slack message is received. Mrkdwn is not supported in this field.

**Slack Channel Name** (*String*): The *exact* channel name where the message should be posted to. **Important**: If your slack app is not added to this channel, the message will not be posted. Add your app to the channel by going to the desired channel and typing */invite @YourAppName* into the message box.

**Send Request Asynchronously** (*Boolean*): If set to true, the request will be sent Asynchronously. This parameter is **required** if the action is running inside of a Record-Triggered Flow. When set to true, the flow will not receive any sort of response from the action. When set to false, the action will be able to return 3 variables: *ok*, *warning*, and *error*. Because of this, it may be useful to test out the component without setting Send Request Asynchronously to true, so that if an error occurs, you can examine the response variables.

**User Mentions** (*String*): Accepts a comma separated string of Slack member IDs, for each ID present, the corresponding user will be @ mentioned in the message. The Slack member ID for a given user can be found by clicking the user's profile image in Slack and then going to *View full profile > More > Copy member ID*. A single ID may be entered here, or if needed, a comma separated String of IDs may also be entered.

## Formatting
Slack uses the mrkdwn language to format messages, you can use this language for any text inside of the *Message* input parameter. For official documentation on mrkdown from Slack, <a href="https://api.slack.com/reference/surfaces/formatting">click here</a>.  
  **IMPORTANT NOTE**: Because of certain Salesforce limitations, the *Line break* mrkdown action `\n` is not supported, instead, use `--n` to define a new line. For example:
```
This is a line of text. --nAnd this is another one.
```
Will produce the following formatting:
```
This is a line of text.
And this is another one.
```
#### Sections
To define larger line breaks, known as Sections, use the string `,,,`. For example:
```
This is one section.,,, And this is another section.
```
Will produce the following formatting:
```
This is one section.

And this is another section.
```

