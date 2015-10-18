#!/bin/bash

if [ "$1" = "clean" ]; then
    docker stop $(docker ps -aq) && docker rm $(docker ps -aq)
    if [ "$2" = "complete" ]; then
        echo "complete clean"
        sleep 5
        docker rmi $(docker images -q)
    else
        echo "$2"
    fi
else
    pdsh -w $(cat hosts.txt) /home/pgottesm/OpenMPIDockerSwarm/runscript/clean.sh clean "$1"
fi
