import ballerina/http;

class DocumentStream {
    
    private Document[] currentEntries = [];
    private string continuationToken;

    int index = 0;
    private final http:Client httpClient;
    private final string path;
    private final http:Request request;
    
    function init(http:Client httpClient, string path, http:Request request) returns @tainted error? {
        self.httpClient = httpClient;
        self.path = path;
        self.request = request;
        self.continuationToken = EMPTY_STRING;
        self.currentEntries = check self.fetchDocuments();
    }

    public isolated function next() returns record {| Document value; |}|error? {
        if(self.index < self.currentEntries.length()) {
            record {| Document value; |} document = {value: self.currentEntries[self.index]};  
            self.index += 1;
            return document;
        }
        // if (self.continuationToken != EMPTY_STRING) {
        //     self.index = 0;
        //     // Fetch documents again when the continuation token is provided. But this function has a remote method 
        //     // call So, it is not isolated.
        //     self.currentEntries = check self.fetchDocuments(); /// Here is the problem
        //     record {| Document value; |} document = {value: self.currentEntries[self.index]};  
        //     self.index += 1;
        //     return document;
        // }
    }

    function fetchDocuments() returns @tainted Document[]|error {
        if (self.continuationToken != EMPTY_STRING) {
            self.request.setHeader(CONTINUATION_HEADER, self.continuationToken);
        }
        http:Response response = <http:Response> check self.httpClient->get(self.path, self.request);
        self.continuationToken = let var header = response.getHeader(CONTINUATION_HEADER) in header is string ? header : 
            EMPTY_STRING;
        json payload = check handleResponse(response);
        if (payload.Documents is json) {
            json[] array = let var load = payload.Documents in load is json ? <json[]>load : [];
            return convertToDocumentArray(array);
        } else {
            return prepareAzureError(INVALID_RESPONSE_PAYLOAD_ERROR);
        }
    }
}
