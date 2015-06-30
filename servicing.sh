#! /bin/bash

# This one process will be forked and is responsible for one address
# no idea how socat will actually terminate it
#
# We need to be able to write to socat's stdout -- possible ?
# Otherwise, we need another proxy

function exabgp_withdraw() {
    IP=$1
    errcho "withdraw address $IP"
    echo "withdraw route $IP/32 next-hop self"
}

function exabgp_announce() {
    IP=$1
    errcho "announce address $IP"
    echo "announce route $IP/32 next-hop self"
}

function send_exabgp() {
    cmd=$1
    shift
    EXABGP_PIPE=/var/run/exabgp/pipe
    EXABGP_LOCK=/var/run/exabgp/pipe_lock
    (
        flock -n 1 || return 1
        $cmd $@ > $EXABGP_PIPE
    ) 1>$EXABGP_LOCK
    return 0
}

function do_announce() {
    send_exabgp exabgp_announce $@
}

function do_withdraw() {
    send_exabgp exabgp_withdraw $@
}

function errcho() {
    >&2 echo $@
}

read IP
function finish() {
    do_withdraw $IP
}
errcho "echo $IP"
echo "OK"

read COMMAND
errcho "echo $COMMAND"
trap finish EXIT
do_announce $IP

read COMMAND
errcho "echo $COMMAND"
exit 0
