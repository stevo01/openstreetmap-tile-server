#!/bin/bash

STOP_CONT="no"

function sighandler_TERM() {
    echo "signal SIGTERM received"
    service apache2 stop
    STOP_CONT="yes"
}

if [ "$#" -ne 1 ]; then
    echo "usage: <run>"
    echo "commands: run"
    exit 1
fi

if [ "$1" = "run" ]; then
    trap 'sighandler_TERM' 15

    # start apache
    service apache2 restart

    echo "wait for terminate signal"
    while [  "$STOP_CONT" = "no"  ] ; do
      sleep 1
    done

    exit 0
fi

echo "invalid command"
exit 1
