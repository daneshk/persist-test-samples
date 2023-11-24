import ballerina/io;
import ballerina/log;
import ballerina/os;

public function main() returns error? {
    os:Process exec = check os:exec({value: "docker", arguments: ["compose", "up", "-d"]});
    int status = check exec.waitForExit();
    if status != 0 {
        return error("Docker run process exit with status: " + status.toString());
    }
    byte[] output = check exec.output(io:stdout);
    log:printInfo(string `Docker run process exit with status: ${status.toString()}`, processID = check string:fromBytes(output));

    int healthCheck = 1;
    int counter = 0;
    string containerStatus = "";
    while healthCheck != 0 && counter < 12 {
        counter = counter + 1;
        os:Process execResult = check os:exec({value: "docker", arguments: ["inspect", "--format='{{.State.Status}}'", "ballerina-persist-mysql"]});
        healthCheck = check execResult.waitForExit();
        byte[] bContainerStatus = check execResult.output(io:stdout);
        containerStatus = check string:fromBytes(bContainerStatus);
    }
    io:println("Container status: " + containerStatus);
    if healthCheck == 0 && containerStatus.includes("'running'") {
        log:printInfo("Health check success", containerStatus = containerStatus);
        return;
    } else {
        return error("Health check failed", containerStatus = containerStatus, healthCheck = healthCheck);
    }
}
