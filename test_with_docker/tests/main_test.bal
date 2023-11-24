import ballerina/http;
import ballerina/test;
import test_with_docker.db;
import ballerina/os;
import ballerina/io;
import ballerina/log;
import ballerinax/mysql.driver as _;
import ballerina/lang.runtime;

@test:Mock {functionName: "initializeClient"}
isolated function getMockClient() returns db:Client|error {
    check startDockerContainer();
    runtime:sleep(60);
    return test:mock(db:Client, check new db:Client("localhost", "dbuser", "dbpwd123", "hospitaldb", 3307));      
}

@test:BeforeSuite
isolated function beforeSuite() returns error? {
}

@test:AfterSuite
function afterSuite() returns error? {
    check stopDockerContainer();
}


http:Client testClient = check new ("http://localhost:9090");

@test:Config {}
function testDoctorInsert() {
    http:Response|http:ClientError unionResult = testClient->/hospital/doctors.post({
        "id": 6,
        "name": "Dr. House",
        "specialty": "Neurologist",
        "phoneNumber": "1234567890"
    });
    if unionResult is http:ClientError {
        test:assertFail("Error occurred while calling the service");
    } else {
        test:assertEquals(unionResult.statusCode, 201, "Status code should be 201");
    }
}


@test:Config {dependsOn: [testDoctorInsert]}
function testDoctorGet() {
    db:Doctor[]|http:ClientError unionResult = testClient->/hospital/doctors.get();
    if unionResult is http:ClientError {
        test:assertFail("Error occurred while calling the service");
    } else {

        test:assertEquals(unionResult.length(), 6, "Status code should be 200");
    }
}

@test:Config {dependsOn: [testDoctorGet]}
function testDoctorGetById() {
    db:Doctor|http:ClientError unionResult = testClient->/hospital/doctors/[6];
    if unionResult is http:ClientError {
        test:assertFail("Error occurred while calling the service");
    } else {
        test:assertEquals(unionResult.id, 6, "doctor id should be 6");
    }
}

@test:Config {dependsOn: [testDoctorGetById]}
function testDoctorUpdate() {
    http:Response|http:ClientError unionResult = testClient->/hospital/doctors/[6].put({phoneNumber: "0987654321"});
    if unionResult is http:ClientError {
        test:assertFail("Error occurred while calling the service");
    } else {
        test:assertEquals(unionResult.statusCode, 200, "Status code should be 200");
    }
}

@test:Config {dependsOn: [testDoctorUpdate]}
function testDoctorDelete() {
    http:Response|http:ClientError unionResult = testClient->/hospital/doctors/[6].delete();
    if unionResult is http:ClientError {
        test:assertFail("Error occurred while calling the service");
    } else {
        test:assertEquals(unionResult.statusCode, 200, "Status code should be 200");
    }
}

public isolated function startDockerContainer() returns error? {
    os:Process exec = check os:exec({value: "docker", arguments: ["compose", "up", "-d"]});
    int status = check exec.waitForExit();
    if status != 0 {
        return error("Docker run process exit with status: " + status.toString());
    }
    byte[] output = check exec.output(io:stdout);
    log:printInfo(string `Docker run process exit with status: ${status.toString()}`, processID = check string:fromBytes(output));

    int healthCheck = 1;
    int counter = 0;
    string containerStatus = "";
    while healthCheck != 0 && counter < 12 {
        counter = counter + 1;
        os:Process execResult = check os:exec({value: "docker", arguments: ["inspect", "--format='{{.State.Status}}'", "ballerina-persist-mysql"]});
        healthCheck = check execResult.waitForExit();
        byte[] bContainerStatus = check execResult.output(io:stdout);
        containerStatus = check string:fromBytes(bContainerStatus);
    }
    io:println("Container status: " + containerStatus);
    if healthCheck == 0 && containerStatus.includes("'running'") {
        log:printInfo("Health check success", containerStatus = containerStatus);
        return;
    } else {
        return error("Health check failed", containerStatus = containerStatus, healthCheck = healthCheck);
    }
}


public isolated function stopDockerContainer() returns error? {
    os:Process exec = check os:exec({value: "docker", arguments: ["compose", "down"]});
    int status = check exec.waitForExit();
    if status != 0 {
        return error("Docker run process exit with status: " + status.toString());
    }
    byte[] output = check exec.output(io:stdout);
    log:printInfo(string `Docker run process exit with status: ${status.toString()}`, processID = check string:fromBytes(output));
}
