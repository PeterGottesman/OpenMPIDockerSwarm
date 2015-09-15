#!/bin/bash
pdsh -w $(cat hosts.txt) docker stop $(docker ps -aq) && docker rm $(docker ps -aq)

if [ "$1" = "complete" ]; then
    echo "--Complete clean--"
    pdsh -w $(cat hosts.txt) $(docker rmi docker images -q)
fi
