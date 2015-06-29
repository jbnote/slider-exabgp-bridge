#! /bin/bash
SOCKNAME=/var/run/exabgp/control

./run_servicing.sh $SOCKNAME &
socat UNIX-CONNECT:$SOCKNAME -

# Do the tests 
