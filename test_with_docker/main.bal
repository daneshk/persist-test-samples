import ballerina/http;
import ballerina/persist;
import test_with_docker.db;
import ballerina/log;

final db:Client dbClient = check initializeClient();

function initializeClient() returns db:Client|error {
   return new ();
}

service /hospital on new http:Listener(9090) {

    // Define the resource to handle POST requests
    resource function post doctors(db:DoctorInsert doctor) returns http:InternalServerError & readonly|http:Created & readonly|http:Conflict & readonly {
        int[]|persist:Error result = dbClient->/doctors.post([doctor]);
        if result is persist:Error {
            log:printError("Error occurred while persisting the data", 'error = result);
            if result is persist:AlreadyExistsError {
                return http:CONFLICT;
            }
            return http:INTERNAL_SERVER_ERROR;
        }
        return http:CREATED;
    }

    // Define the resource to handle GET requests for doctors
    resource function get doctors() returns db:Doctor[]|error {
        stream<db:Doctor, persist:Error?> doctors = dbClient->/doctors.get();
        return from db:Doctor doctor in doctors
            select doctor;
    }

    // Define the resource to handle GET requests for doctors by id
    resource function get doctors/[int id]() returns db:Doctor|error {
        db:Doctor|persist:Error result = dbClient->/doctors/[id];
        if result is persist:Error {
            log:printError("Error occurred while retrieving the data", 'error = result);
            if result is persist:NotFoundError {
                return error("Doctor not found");
            }
            return error("Internal server error");
        }
        return result;
    }

    // Define the resource to handle PUT requests for doctors by id
    resource function put doctors/[int id](@http:Payload record {|string phoneNumber;|} number) returns http:InternalServerError & readonly|http:Ok & readonly|http:NotFound & readonly {
        db:Doctor|persist:Error result = dbClient->/doctors/[id].put(number);
        if result is persist:Error {
            log:printError("Error occurred while updating the data", 'error = result);
            if result is persist:NotFoundError {
                return http:NOT_FOUND;
            }
            return http:INTERNAL_SERVER_ERROR;
        }
        return http:OK;
    }

    // Define the resource to handle DELETE requests for doctors by id
    resource function delete doctors/[int id]() returns http:InternalServerError & readonly|http:Ok & readonly|http:NotFound & readonly {
        db:Doctor|persist:Error result = dbClient->/doctors/[id].delete();
        if result is persist:Error {
            log:printError("Error occurred while deleting the data", 'error = result);
            if result is persist:NotFoundError {
                return http:NOT_FOUND;
            }
            return http:INTERNAL_SERVER_ERROR;
        }
        return http:OK;
    }
}
