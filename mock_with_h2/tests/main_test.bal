import ballerina/http;
import ballerina/test;
import mock_with_h2.db;

isolated final Client h2Client = check new Client(url, user, password);

@test:Mock {functionName: "initializeClient"}
isolated function getMockClient() returns db:Client|error {
    return test:mock(db:Client, check new Client("jdbc:h2:./test", "sa", "", options = {}));         
}

@test:BeforeSuite
isolated function beforeSuite() returns error? {
    _ = check h2Client->executeNativeSQL(`CREATE TABLE Doctor (id INT NOT NULL, name VARCHAR(191) NOT NULL, specialty VARCHAR(191) NOT NULL, phoneNumber VARCHAR(191) NOT NULL, PRIMARY KEY(id))`);
}

@test:AfterSuite
function afterSuite() returns error? {
    _ = check h2Client->executeNativeSQL(`DROP TABLE Doctor`);
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
