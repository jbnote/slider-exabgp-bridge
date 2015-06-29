#! /bin/bash
SOCKNAME=${1:-/var/run/exabgp/control}
rm -f $SOCKNAME;
socat UNIX-LISTEN:$SOCKNAME,reuseaddr,fork EXEC:"./servicing.sh "
