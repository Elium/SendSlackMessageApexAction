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

## Description of Files and Directories

## Issues
