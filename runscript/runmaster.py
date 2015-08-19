#!/usr/bin/env python3

import argparse
import math
import os
from subprocess import check_output, CalledProcessError

def call(cmd, ErrorText):
    try:
        out = check_output(cmd, shell=True).decode('utf-8')
    except CalledProcessError as err:
        print(ErrorText + " with code: " + str(err.returncode))
        exit(1)

    return out

def run(args):
    NumSlaves = args.NumSlaves
    Hosts = args.Hosts
    NumHosts = len(Hosts.split(','))
    
    if not (0 < NumSlaves <= 256):
        print("Error: Number of slaves must be greater than 0 and less than 256 times the number of hosts")
        exit(1)

    print("Building Image")
    call("pdsh -w " + Hosts + " docker build -t ompiswarm ~/OpenMPIDockerSwarm/ | uniq -u", "Error building dockerfile")
    print("Done")

    print("Initializing slave containers")
    slaveips = call("pdsh -w " + Hosts + " ~/OpenMPIDockerSwarm/runscript/runslave.py " + str(NumSlaves), "Error launching slaves")
    if "Error" in slaveips:
        print("Error launching slaves, dumping output:")
        print(slaveips)
        exit(1)
    print("Done")

    print("Creating hostfile")
    f = open(os.getenv('HOME')+"/DockerShare/data/hostfile", 'w')
    f.write(slaveips)
    f.close()
    print("Done")

    print("Starting master")
    print(call("docker run --name master -h master -dt --privileged --cpuset-cpus=0 -v ~/DockerShare/data:/data:z --lxc-conf=\"lxc.network.type = veth\" --lxc-conf=\"lxc.network.ipv4 = 10.2.0.49\" --lxc-conf=\"lxc.network.link=dockerbridge0\" --lxc-conf=\"lxc.network.name = eth2\" --lxc-conf=\"lxc.network.flags=up\" ompiswarm ping -c 5 10.2.0.34", "Error launching master container, ensure run.sh is present"))



def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('NumSlaves', metavar='X', type=int, help="Number of slaves to launch per host")
    parser.add_argument('Hosts', help="Comma separated list of hostnames")
    args = parser.parse_args()
    run(args)

if __name__ == "__main__":
    main()
