#!/bin/bash

if [ "$1" = "clean" ]; then
    docker stop $(docker ps -aq) && docker rm $(docker ps -aq)
    if [ "$2" = "complete" ]; then
        docker rmi $(docker images -q)
    fi
else
    pdsh -w $(cat hosts.txt) /home/pgottesm/OpenMPIDockerSwarm/runscript/clean.sh clean "$2"
fi
