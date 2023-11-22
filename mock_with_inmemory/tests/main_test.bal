import ballerina/http;
import ballerina/test;
import mock_with_inmemory.db;

@test:Mock {functionName: "initializeClient"}
isolated function getMockClient() returns db:Client|error {
    return test:mock(db:Client, check new Client());         
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
