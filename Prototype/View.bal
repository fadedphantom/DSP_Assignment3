import ballerina/kafka;
import ballerina/log;
import ballerina/lang.'string as strings;
import ballerina/io;

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

kafka:ConsumerConfiguration consumerConfigs = {
    bootstrapServers: "localhost:9092, localhost:9096",
    groupId: "group-id",

    topics: ["test-kafka-topic"],
    pollingIntervalInMillis: 1000

};

listener kafka:Consumer consumer = new (consumerConfigs);
service kafkaService on consumer {
    resource function onMessage(kafka:Consumer kafkaConsumer,
            kafka:ConsumerRecord[] records) {

        foreach var kafkaRecord in records {
            processKafkaRecord(kafkaRecord);
        }

        var commitResult = kafkaConsumer->commit();
        if (commitResult is error) {
            log:printError("Error occurred while committing the " +
                "offsets for the consumer ", commitResult);
        }
    }
}

function processKafkaRecord(kafka:ConsumerRecord kafkaRecord) {
    anydata serializedMsg = kafkaRecord.value;
    byte[] a = <byte[]>serializedMsg;
    
    string|error msg = 'strings:fromBytes(a);
    anydata key = kafkaRecord.key;
   
    if (msg is string) {
        io:println("Topic: ",kafkaRecord.topic, "Partition: ", kafkaRecord.partition.toString(),
        "Message is: ", msg);
       
}

else {
        log:printError("Error occured during conversion of message data", msg);

}

//Viewing the proposal
  string read = io:readln("Enter 1 to read the proposal");

   if (read.equalsIgnoreCaseAscii("1")){

       string link = io:readln("Enter link to proposal: ");
    //   json|error rResult = read("./data.json");


      

      
      io:println("Proposal has been accepted.");
  }
 

  else{

      io:println("Pproposal will not be read!");
      
  }


//Accepting the proposal
  string choice = io:readln("If you want to accept this proposal enter 1, else enter 2: ");

  if (choice.equalsIgnoreCaseAscii("1")){
      
      io:println("Proposal has been accepted.");
  }

  if (choice.equalsIgnoreCaseAscii("2")){

      io:println("Proposal has been rejected.");
      
  }

  else{

      io:println("Wrong Input!");
      
  }
 
}







