// AUTO-GENERATED FILE. DO NOT MODIFY.
// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.
import ballerina/jballerina.java;
import ballerina/persist;
import ballerina/sql;
import ballerinax/java.jdbc;
import ballerinax/h2.driver as _;
import ballerinax/persist.sql as psql;
import mock_with_h2.db;

const DOCTOR = "doctors";

public isolated client class Client {
    *persist:AbstractPersistClient;

    private final jdbc:Client dbClient;

    private final map<psql:SQLClient> persistClients;

    private final record {|psql:SQLMetadata...;|} & readonly metadata = {
        [DOCTOR] : {
            entityName: "Doctor",
            tableName: "Doctor",
            fieldMetadata: {
                id: {columnName: "id"},
                name: {columnName: "name"},
                specialty: {columnName: "specialty"},
                phoneNumber: {columnName: "phoneNumber"}
            },
            keyFields: ["id"]
        }
    };

    public isolated function init(string url, string? user = (), string? password = (),
            jdbc:Options? options = ()) returns persist:Error? {
        jdbc:Client|error dbClient = new (url = url, user = user, password = password, options = {});
        if dbClient is error {
            return <persist:Error>error(dbClient.message());
        }
        self.dbClient = dbClient;
        self.persistClients = {[DOCTOR] : check new (dbClient, self.metadata.get(DOCTOR), psql:MYSQL_SPECIFICS)};
    }

    isolated resource function get doctors(db:DoctorTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "query"
    } external;

    isolated resource function get doctors/[int id](db:DoctorTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post doctors(db:DoctorInsert[] data) returns int[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(DOCTOR);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from db:DoctorInsert inserted in data
            select inserted.id;
    }

    isolated resource function put doctors/[int id](db:DoctorUpdate value) returns db:Doctor|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(DOCTOR);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/doctors/[id].get();
    }

    isolated resource function delete doctors/[int id]() returns db:Doctor|persist:Error {
        db:Doctor result = check self->/doctors/[id].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(DOCTOR);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    remote isolated function queryNativeSQL(sql:ParameterizedQuery sqlQuery, typedesc<record {}> rowType = <>) returns stream<rowType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor"
    } external;

    remote isolated function executeNativeSQL(sql:ParameterizedQuery sqlQuery) returns psql:ExecutionResult|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.MySQLProcessor"
    } external;

    public isolated function close() returns persist:Error? {
        error? result = self.dbClient.close();
        if result is error {
            return <persist:Error>error(result.message());
        }
        return result;
    }
}

