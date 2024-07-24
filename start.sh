#!/bin/bash

UBUNTU="$(pwd)/ubuntu"
SCRIPT="$(pwd)/installimage"
CONF="$(pwd)/tmp"

if [ -d "$UBUNTU" ] && [ "$(ls -A $UBUNTU)" ]; then
    echo "Collecting and moving the Ubuntu image" &&
    cat ubuntu/Ubuntu-2204-jammy-amd64-base.tar.gz.part-* > ubuntu/Ubuntu-2204-jammy-amd64-base.tar.gz &&
    mv ubuntu/Ubuntu-2204-jammy-amd64-base.tar.gz /root/ &&
    echo "DONE"

else
    echo "Directory $UBUNTU is empty or does not exist"
fi

if [ -d "$SCRIPT" ] && [ "$(ls -A $SCRIPT)" ]; then
    echo "Moving installation files" &&
    mv $SCRIPT/* /usr/local/bin &&
    echo "DONE"
else
    echo "Directory $SCRIPT is empty or does not exist"
fi

if [ -d "$CONF" ] && [ "$(ls -A $CONF)" ]; then
    echo "Moving installation files" &&
    mv $CONF /root/ &&
    echo "DONE"
else
    echo "Directory $CONF is empty or does not exist"
fi

echo "STARTING..." &&
cd /root/tmp &&
installimage -a -c setup.conf -x post-install.sh
