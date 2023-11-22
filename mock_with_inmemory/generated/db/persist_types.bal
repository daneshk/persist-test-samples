// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

public type Doctor record {|
    readonly int id;
    string name;
    string specialty;
    string phoneNumber;
|};

public type DoctorOptionalized record {|
    int id?;
    string name?;
    string specialty?;
    string phoneNumber?;
|};

public type DoctorTargetType typedesc<DoctorOptionalized>;

public type DoctorInsert Doctor;

public type DoctorUpdate record {|
    string name?;
    string specialty?;
    string phoneNumber?;
|};

