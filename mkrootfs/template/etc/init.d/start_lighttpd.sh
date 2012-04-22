#!/bin/bash
#
# start thttpd server

#  for NFS-Mode use different port number (8080) to avoid
#  conficts with the application WEB server
#
RC_THTTPD_CMD=${RC_THTTPD_CMD:-"/sbin/thttpd"}
SERVER_PORT=80
if [ $(ls /mnt/nfs | wc -c) -ne 0 ]; then  SERVER_PORT=8080; fi

exec $RC_THTTPD_CMD -p $SERVER_PORT -nos -D -u root -l /dev/null -d /www -c "**.cgi"
