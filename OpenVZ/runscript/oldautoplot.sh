#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: ./autoplot.sh [num containers] [bare-metal]"
    echo "Set bare-meta to bare run bare metal"
    exit 1
fi

regex='^[0-9]+$'
if ! [[ $1 =~ $regex ]]; then
    echo "first arg must be a number"
    exit 1
fi

truncate -s 0  ~/DockerShare/data/times.txt

#if $2 is bare run ~/DockerShare/data/run.py with hostfile as hosts.txt
if [ "$2" == "bare" ]; then
    for num in $(seq 1 $1); do
        ~/DockerShare/data/run.py $(readlink -f hosts.txt) $num --bare
    done
else
    for num in $(seq 1 $1); do
        ./runmaster.py $num --hostfile hosts.txt --plot
    done
fi

gnuplot -e "times='/home/pgottesm/DockerShare/data/times.txt'" plot.gnu
