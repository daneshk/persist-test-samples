import ballerina/http;
import ballerina/test;
import mock_with_h2.db;

@test:Mock {functionName: "initializeClient"}
isolated function getMockClient() returns db:Client|error {
    return test:mock(db:Client, check new db:MockClient("jdbc:h2:./test", "sa", "", options = {}));         
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

        test:assertEquals(unionResult.length(), 1, "Status code should be 200");
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
