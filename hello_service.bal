
// A system package containing protocol access constructs
// Package objects referenced with 'http:' in code
import ballerina/http;
import ballerina/io;
import wso2/twitter;
import ballerina/config;
import ballerinax/docker;

endpoint twitter:Client twitter {
   clientId: config:getAsString("consumerKey"),
   clientSecret: config:getAsString("consumerSecret"),
   accessToken: config:getAsString("accessToken"),
   accessTokenSecret: config:getAsString("accessTokenSecret")
};
@docker:Expose {}

endpoint http:Listener listener {
    port:9090
};

// Docker configurations
@docker:Config {
    registry:"registry.hub.docker.com",
    name:"helloworld",
    tag:"v1.0"
}
@docker:CopyFiles {
    files:[
        {source:"./twitter.toml", target:"/home/ballerina/conf/twitter.toml", isBallerinaConf:true}
    ]
}



@http:ServiceConfig {
   basePath: "/"
}

service<http:Service> hello bind listener {
    @http:ResourceConfig {
    methods: ["POST"],
    path: "/"
    }

    documentation {
       A resource is an invokable API method
       Accessible at '/hello/sayHello
       'caller' is the client invoking this resource 

       P{{caller}} Server Connector
       P{{request}} Request
    }

    

    sayHello (endpoint caller, http:Request request) {

        string status = check request.getTextPayload();

        // Create object to carry data back to caller
        http:Response response = new;

        twitter:Status st = check twitter->tweet(status);
        response.setTextPayload("ID:" + <string>st.id + "\n");

        // Objects and structs can have function calls
        response.setTextPayload("Hello Ballerina!\n");

        // Send a response back to caller
        // Errors are ignored with '_'
        // -> indicates a synchronous network-bound call
        _ = caller -> respond(response);
    }
}