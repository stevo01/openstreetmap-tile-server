#!/bin/bash

# set -x

STOP_CONT="no"


# handler for term signal
function sighandler_TERM() {
    echo "signal SIGTERM received\n"

    echo "terminate apache2"
    service apache2 stop

    PID=`ps -eaf | grep renderd | grep -v grep | awk '{print $2}'`
    if [[ "" !=  "$PID" ]]; then
      echo "send SIGTERM to renderd PID=$PID"
      kill -n 15 $PID
    fi

    PID=`ps -eaf | grep tirex-master | grep -v grep | awk '{print $2}'`
    if [[ "" !=  "$PID" ]]; then
      echo "send SIGTERM to tirex-master PID=$PID"
      kill -n 15 $PID
    fi

    PID=`ps -eaf | grep tirex-backend-manager | grep -v grep | awk '{print $2}'`
    if [[ "" !=  "$PID" ]]; then
      echo "send SIGTERM to tirex-backend-manager PID=$PID"
      kill -n 15 $PID
    fi

    STOP_CONT="yes"
}


if [ "$#" -ne 1 ]; then
    echo "usage: <import|run>"
    echo "commands:"
    echo "    run: Runs Apache and renderd to serve tiles at /tile/{z}/{x}/{y}.png"
    exit 1
fi

if [ "$1" = "run" ]; then
    # add handler for signal SIHTERM
    trap 'sighandler_TERM' 15

    export PGHOST=localhost
    export PGPORT=5432
    export PGUSER=renderer
    export PGPASSWORD=renderer
    export PGDBNAME=gis

    # Clean /tmp
    rm -rf /tmp/*

    # Configure Apache CORS
    if [ "$ALLOW_CORS" == "1" ]; then
        echo "export APACHE_ARGUMENTS='-D ALLOW_CORS'" >> /etc/apache2/envvars
    fi

    # Start Apache
    service apache2 restart

    # start tirex
    sudo -u renderer tirex-backend-manager -f &
    sudo -u renderer tirex-master -d -f &

    echo "wait for terminate signal"
    while [  "$STOP_CONT" = "no"  ] ; do
      sleep 1
    done

    exit 0
fi

echo "invalid command"
exit 1
