#!/bin/bash

PROG_NAME=`basename $0`

log_msg(){
  echo   "[$PROG_NAME] $*"
  logger "[$PROG_NAME] $*"
}

prt_usage(){
  echo "USAGE: $PROG_NAME <service-name> <path-name> <args>..."
}

log_msg "Starting Service $1..."
shift

exec $*

while true
do
    log_msg "Bummer: exec  failed"
    sleep 10
done

exit 1
