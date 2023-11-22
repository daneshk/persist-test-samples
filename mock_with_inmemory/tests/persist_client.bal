// AUTO-GENERATED FILE. DO NOT MODIFY.
// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.
import ballerina/jballerina.java;
import ballerina/persist;
import ballerinax/persist.inmemory;
import mock_with_inmemory.db;

const DOCTOR = "doctors";
final isolated table<db:Doctor> key(id) doctorsTable = table [];

public isolated client class Client {
    *persist:AbstractPersistClient;

    private final map<inmemory:InMemoryClient> persistClients;

    public isolated function init() returns persist:Error? {
        final map<inmemory:TableMetadata> metadata = {
            [DOCTOR] : {
                keyFields: ["id"],
                query: queryDoctors,
                queryOne: queryOneDoctors
            }
        };
        self.persistClients = {[DOCTOR] : check new (metadata.get(DOCTOR).cloneReadOnly())};
    }

    isolated resource function get doctors(db:DoctorTargetType targetType = <>) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.inmemory.datastore.InMemoryProcessor",
        name: "query"
    } external;

    isolated resource function get doctors/[int id](db:DoctorTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.inmemory.datastore.InMemoryProcessor",
        name: "queryOne"
    } external;

    isolated resource function post doctors(db:DoctorInsert[] data) returns int[]|persist:Error {
        int[] keys = [];
        foreach db:DoctorInsert value in data {
            lock {
                if doctorsTable.hasKey(value.id) {
                    return persist:getAlreadyExistsError("Doctor", value.id);
                }
                doctorsTable.put(value.clone());
            }
            keys.push(value.id);
        }
        return keys;
    }

    isolated resource function put doctors/[int id](db:DoctorUpdate value) returns db:Doctor|persist:Error {
        lock {
            if !doctorsTable.hasKey(id) {
                return persist:getNotFoundError("Doctor", id);
            }
            db:Doctor doctor = doctorsTable.get(id);
            foreach var [k, v] in value.clone().entries() {
                doctor[k] = v;
            }
            doctorsTable.put(doctor);
            return doctor.clone();
        }
    }

    isolated resource function delete doctors/[int id]() returns db:Doctor|persist:Error {
        lock {
            if !doctorsTable.hasKey(id) {
                return persist:getNotFoundError("Doctor", id);
            }
            return doctorsTable.remove(id).clone();
        }
    }

    public isolated function close() returns persist:Error? {
        return ();
    }
}

isolated function queryDoctors(string[] fields) returns stream<record {}, persist:Error?> {
    table<db:Doctor> key(id) doctorsClonedTable;
    lock {
        doctorsClonedTable = doctorsTable.clone();
    }
    return from record {} 'object in doctorsClonedTable
        select persist:filterRecord({
            ...'object
        }, fields);
}

isolated function queryOneDoctors(anydata key) returns record {}|persist:NotFoundError {
    table<db:Doctor> key(id) doctorsClonedTable;
    lock {
        doctorsClonedTable = doctorsTable.clone();
    }
    from record {} 'object in doctorsClonedTable
    where persist:getKey('object, ["id"]) == key
    do {
        return {
            ...'object
        };
    };
    return persist:getNotFoundError("Doctor", key);
}

