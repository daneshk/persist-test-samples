//import ballerina/test;

// isolated final MockClient h2Client = check new MockClient(url, user, password);

// @test:BeforeSuite
// isolated function beforeSuite() returns error? {
//     _ = check h2Client->executeNativeSQL(`CREATE TABLE Doctor (id INT NOT NULL, name VARCHAR(191) NOT NULL, specialty VARCHAR(191) NOT NULL, phoneNumber VARCHAR(191) NOT NULL, PRIMARY KEY(id))`);
// }

// @test:AfterSuite
// function afterSuite() returns error? {
//     _ = check h2Client->executeNativeSQL(`DROP TABLE Doctor`);
// }