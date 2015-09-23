#!/bin/bash

if [ "$1" = "clean" ]; then
   docker stop $(docker ps -aq) && docker rm $(docker ps -aq)
else
    pdsh -w $(cat hosts.txt) /home/pgottesm/OpenMPIDockerSwarm/runscript/clean.sh clean
fi
