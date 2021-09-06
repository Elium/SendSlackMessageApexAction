// Copyright 2020 Halosight

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

global class APICallout {
    @InvocableMethod(label='API Callout')
    global static List<Response> ApiCallout(List<Request> request){
        List<Response> responses = new List<Response>();
        for(Request r : request){
            Response response = new Response();
            response = GenerateApiCallout(r);
            responses.add(response);
        }
        return responses;
    }

    public static Response GenerateApiCallout(Request r){
        Response response = new response();
        String endpoint = '';
        if(r.sendAsync == null){
            r.sendAsync = false;
        }
        if(!String.isBlank(r.namedCredential)){
            if(NamedCredentialExists(r.namedCredential)){
                endpoint = 'callout:' + r.namedCredential;
            } else {
                response = setCustomResponseError('Named Credential: ' + r.namedCredential + ' does not exist.');
                return response;
            }
        }

        if(!String.isBlank(r.urlParameter)){
            String regex = '(\\{\\{)(.*)(\\}\\})';
            Pattern regexPattern = Pattern.compile(regex);
            Matcher regexMatcher = regexPattern.matcher(r.endpoint);
            String replacedEndpoint;
            if(regexMatcher.find()){
                replacedEndpoint = r.endpoint.replaceAll(regex, r.urlParameter);
                endpoint = endpoint + replacedEndpoint;
            } else {
                response = setCustomResponseError('A URL Parameter has been defined, but it\'s reference was not found in the URL. Make sure to include a reference to the parameter in the URL string. The reference must be wrapped in double brackets {{}}. i.e. /endpoint/{{myVarName}}/');
                return response;
            }
        } else {
            endpoint = endpoint + r.endpoint;
        }
        
        
        if(!r.sendAsync){
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod(r.requestType);
            if(String.isBlank(r.contentType)){
                req.setHeader('Content-type', 'application/json');
            } else {
                req.setHeader('Content-type', r.contentType);
            }
            req.setHeader('charset', 'utf-8');
            
            if(!String.isBlank(r.bearerToken)){
                req.setHeader('Authorization', 'Bearer ' + r.bearerToken);
            }
            if (r.requestType == 'POST' || r.requestType == 'PUT'){
                if(!String.isBlank(r.body)){
                    req.setBody(r.body);
                }
            }

            System.debug(req);
            
            Http h = new Http();
            HttpResponse httpResponse = h.send(req);
            response.statusCode = httpResponse.getStatusCode();
            if(httpResponse.getStatusCode() == 200){
                response.responseBody = httpResponse.getBody();
            } else {
                response.errorMessage = 'The following error occurred while issuing a callout to: ' + endpoint + ' -- Status Code: ' + httpResponse.getStatusCode() + ' -- ' + httpResponse.getStatus();
                response.errorMessage = response.errorMessage + '\nRequest Endpoint: ' + endpoint; 
                response.errorMessage = response.errorMessage + '\nRequest Method: ' + r.requestType;
                response.errorMessage = response.errorMessage + '\nRequest Body: ' + r.body;
            }
        } else {
            System.debug('No JSON');
            launchFuture(endpoint, r.requestType, r.contentType, r.bearerToken, r.body);
            response.responseBody = 'Request was sent Asynchronously, no return value will be provided.';
            response.statusCode = 200;
        }
        
        return response;
    }

    @future(callout=true)
    private static void launchFuture(String endpoint, String requestType, String contentType, String bearerToken, String body){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(requestType);
        if(String.isBlank(contentType)){
            req.setHeader('Content-type', 'application/json');
        } else {
            req.setHeader('Content-type', contentType);
        }
        req.setHeader('charset', 'utf-8');
        
        if(!String.isBlank(bearerToken)){
            req.setHeader('Authorization', 'Bearer ' + bearerToken);
        }
        if (requestType == 'POST' || requestType == 'PUT'){
            if(!String.isBlank(body)){
                req.setBody(body);
            }
        }

        HttpResponse httpResponse = new Http().send(req);
    }

    public static Response setCustomResponseError(String error){
        Response response = new response();
        response.statusCode = 404;
        response.errorMessage = error;
        return response;
    }

    public static Boolean NamedCredentialExists(String namedCredential){
        List<NamedCredential> namedCredentials = [SELECT Id, DeveloperName FROM NamedCredential WHERE DeveloperName = :namedCredential];
        return !namedCredentials.isEmpty();
    }

    global class Response {
        @InvocableVariable(label='Status Code' description='Returns the HTTP status code.')
        global Integer statusCode;

        @InvocableVariable(label='Error Message' description='Returns an error message if the status code is not 200.')
        global String errorMessage;

        @InvocableVariable(label='Response Body' description='Returns the response body as a string')
        global String responseBody;
    }

    global class Request {
        @InvocableVariable(label='Named Credential' description='Enter a named credential if necesary for the callout')
        global String namedCredential;

        @InvocableVariable(label='Endpoint' description='If a URL is needed to be appended to the Named Credential, add it here. Create URL variable placeholders by wrapping the variable name with {{}}. i.e. /path/{{variableName}}' required=true)
        global String endpoint;

        @InvocableVariable(label='URL Parameter' description='Enter the value for the URL variable here')
        global String urlParameter;

        @InvocableVariable(label='Body' description='Enter the request body here if needed.')
        global String body;

        @InvocableVariable(label='Request Type' description='The request type i.e (POST, PUT, GET)' required=true)
        global String requestType;

        @InvocableVariable(label='Bearer Token' description='The API Bearer token. Leave blank if none.')
        global String bearerToken;

        @InvocableVariable(label='Content Type' description='Defaults to "application/json" if left blank.')
        global String contentType;

        @InvocableVariable(label='Send Request Asynchronously' description='If true, the request is sent in a future method.')
        global Boolean sendAsync;
    }
}
