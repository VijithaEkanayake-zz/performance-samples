import ballerina/http;
import ballerina/log;
import ballerinax/docker;

@docker:Expose {}
listener http:Listener listenerEP = new(9090);

http:Client clientEP = new("http://172.17.0.2:8688");

service passthrough on listenerEP {
    @http:ResourceConfig {
        path: "/"
    }
    resource function passthrough(http:Caller caller, http:Request req) {
        var clientResponse = clientEP->forward("/", req);
        if (clientResponse is http:Response) {
            var result = caller->respond(clientResponse);
            if (result is error) {
        	log:printError(result.reason(), err = result);
    	    }
        } else if (clientResponse is error) {
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload(string.convert(clientResponse.detail().message));
            var result = caller->respond(res);
            if (result is error) {
        	log:printError(result.reason(), err = result);
    	    }
        }
    }
}
