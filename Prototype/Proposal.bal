import ballerina/io;
import ballerina/kafka;
import ballerina/log;
import ballerina/http;

//Allow for the reading of content from a json file
function closeRc(io:ReadableCharacterChannel rc) {
    var result = rc.close();
    if (result is error) {
        log:printError("Error occurred while closing character stream",
                        err = result);
    }
}

function read(string path) returns @tainted json|error {

    io:ReadableByteChannel rbc = check io:openReadableFile(path);

    io:ReadableCharacterChannel rch = new (rbc, "UTF8");
    var result = rch.readJson();
    closeRc(rch);
    return result;
}
//----------------------------------------------------------------------

//Kafka configurations

kafka:ProducerConfiguration producerConfiguration = {
    bootstrapServers: "localhost:9092",
    clientId: "basic-producer",
    acks: "all",
    retryCount: 3
    
};

kafka:Producer kafkaProducer = new (producerConfiguration);

//Http service endpoint

listener http:Listener httpListener = new(9094);

@http:ServiceConfig{
    basePath:"/upload"
}

service upload on httpListener{//Requires configuration through given port

    @http:ResourceConfig {
        path:"proposal/{name}"
    }   

    resource function notes(http:Caller outboundEP, http:Request request, string name){
        http:Response response = new;

        //Construct message to be published
        json Proposal = {"Proposal name":name, "proposal":"link to location of proposal, for instance as a jsonfile"};
        
        //Send information information    
        byte[] serializedMsg = Proposal.toString().toBytes();
    
        var sendResult = kafkaProducer->send(serializedMsg, string `${name}proposal`, partition = 0);

    //Error if uploading failed
    if (sendResult is error) {
        response.statusCode = 500;
        response.setJsonPayload({"Message":"Proposal failed to Upload." });
        var responseResult = outboundEP->respond(response);

    } else {
        io:println("Message sent successfully.");        
    }
    
    response.setJsonPayload({"Status":"${name}-proposal upload success"});
    var responseResult = outboundEP->respond(response);
    }
}







