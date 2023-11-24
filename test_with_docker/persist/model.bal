import ballerina/persist as _;

type Doctor record {|
    readonly int id;
    string name;
    string specialty;
    string phoneNumber;
|};
