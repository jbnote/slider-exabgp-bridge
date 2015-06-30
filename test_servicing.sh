#! /bin/bash
SOCKNAME=./test
LOGS=./logs.txt

function launch_service() {
    ./run_servicing.sh $SOCKNAME 2> $LOGS &
    service_pid=$!
    echo "service on $service_pid"
    sleep 1
}

function end_service() {
    sleep 1
    kill $service_pid
    # Should not exist anymore after kill
    rm -f $SOCKNAME
}

# Protocol is
# First item: bind_address:port service_address:port
# Second line: ready for announcing
# Third line or EOF or process dies: withdraw

# Service spawned is
function test_complete() {
    socat UNIX-CONNECT:$SOCKNAME - <<EOF
127.0.0.1
announce
withdraw
EOF
}

function test_partial() {
    socat UNIX-CONNECT:$SOCKNAME - <<EOF
127.0.0.2
announce
EOF
}

function test_killing() {
    true
    #socat UNIX-CONNECT:$SOCKNAME <(echo "127.0.0.3"; sleep 100) &
    #terminated_pid=$!
    #echo "terminated on $terminated_pid"
    #sleep 1
    #kill $terminated_pid
}

function test_service() {
    test_complete
    test_partial
    test_killing
}

function validate_tests() {
    diff $LOGS logs_golden.txt && rm $LOGS
    status=$?
    exit $status
}

launch_service
test_service
end_service
validate_tests
