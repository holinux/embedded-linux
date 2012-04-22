#!/bin/bash

#  start sshd used for test
#

PROG_NAME=$(basename $0)
TEST_SSHD_OPTIONS=${TEST_SSHD_OPTIONS:-""}
TEST_SSHD_CMD=${TEST_SSHD_CMD:-"/usr/sbin/sshd"}

log_msg(){
    echo   "[$PROG_NAME] $*"
    logger "[$PROG_NAME] $*"
}

TEST_SSHD_OPTIONS="$TEST_SSHD_OPTIONS -D -o PermitRootLogin=yes -p 22"  # root login allowed
log_msg "(Re)-starting test sshd [$TEST_SSHD_OPTIONS]..."
exec /etc/init.d/start_service.sh sshd $TEST_SSHD_CMD $TEST_SSHD_OPTIONS
