#!/bin/bash

FRP_NAME=frps

while ! test -z "$(ps -A | grep -w ${FRP_NAME})"; do
    FRPSPID=$(ps -A | grep -w ${FRP_NAME} | awk 'NR==1 {print $1}')
    echo "Killing process with PID: $FRPSPID"
    kill -9 $FRPSPID
done
