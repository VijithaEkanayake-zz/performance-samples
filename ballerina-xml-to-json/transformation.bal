import ballerina/http;
import ballerina/log;
import ballerinax/docker;

@docker:Expose {}
listener http:Listener listenerEP = new(9090);

http:Client clientEP = new("http://172.17.0.2:8688");

service xmlToJsonTransformation on listenerEP {
    @http:ResourceConfig {
        path: "/"
    }
    resource function transformXml(http:Caller caller, http:Request request) {
        var payload = request.getXmlPayload();
        if (payload is xml) {
            json jsonMessage = payload.toJSON({});
            request.setPayload(untaint jsonMessage);
            var clientResponse = clientEP->forward("/", request);
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
        } else {
            http:Response res = new;
            res.statusCode = 500;
            res.setTextPayload(untaint payload.reason());
            var result = caller->respond(res);
            if (result is error) {
        	log:printError(result.reason(), err = result);
    	    }
        }
    }
}

