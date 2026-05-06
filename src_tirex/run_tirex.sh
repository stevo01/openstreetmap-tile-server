#!/bin/bash

STOP_CONT="no"

function sighandler_TERM() {
    echo "signal SIGTERM received"
    echo "send SIGTERM to tirex and related processes"
    PID=`ps -eaf | grep tirex-master | grep -v grep | awk '{print $2}'`
    if [[ "" !=  "$PID" ]]; then
      kill -n 15 $PID
    fi

    PID=`ps -eaf | grep tirex-backend-manager | grep -v grep | awk '{print $2}'`
    if [[ "" !=  "$PID" ]]; then
      kill -n 15 $PID
    fi

    STOP_CONT="yes"
}

if [ "$#" -ne 1 ]; then
    echo "usage: <run>"
    echo "commands: run"
    exit 1
fi

if [ "$1" = "run" ]; then
    trap 'sighandler_TERM' 15

    export PGHOST=${PGHOST:-osmpsql}
    export PGPORT=${PGPORT:-5432}
    export PGUSER=${PGUSER:-renderer}
    export PGPASSWORD=${PGPASSWORD:-renderer}
    export PGDBNAME=${PGDBNAME:-gis}

    rm -rf /tmp/*

    mkdir -p /var/lib/mod_tile/ajt
    chown renderd:renderd /var/lib/mod_tile/ajt

    # start tirex processes (if installed in image)
    if command -v tirex-backend-manager >/dev/null 2>&1; then
      sudo -u renderer tirex-backend-manager -f &
    fi
    if command -v tirex-master >/dev/null 2>&1; then
      sudo -u renderer tirex-master -d -f &
    fi

    echo "wait for terminate signal"
    while [  "$STOP_CONT" = "no"  ] ; do
      sleep 1
    done

    exit 0
fi

echo "invalid command"
exit 1
