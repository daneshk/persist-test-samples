import ballerina/http;
import mock_with_inmemory.db;
import ballerina/persist;

final db:Client dbClient = check initializeClient();

function initializeClient() returns db:Client|error {
   return new ();
}

service /hospital on new http:Listener(9090) {

    // Define the resource to handle POST requests
    resource function post doctors(db:DoctorInsert doctor) returns http:InternalServerError & readonly|http:Created & readonly|http:Conflict & readonly {
        int[]|persist:Error result = dbClient->/doctors.post([doctor]);
        if result is persist:Error {
            if result is persist:AlreadyExistsError {
                return http:CONFLICT;
            }
            return http:INTERNAL_SERVER_ERROR;
        }
        return http:CREATED;
    }
}
