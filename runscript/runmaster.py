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
    f = open(args.Hosts, 'r')
    Hosts = f.readline().rstrip('\n')
    NumHosts = len(Hosts.split(','))
    
    if not (0 < NumSlaves <= 256):
        print("Error: Number of slaves must be greater than 0 and less than 256 times the number of hosts")
        exit(1)

    print("Building Image")
    call("pdsh -w " + Hosts + " docker run --rm -t petergottesman/ompiswarm ", "Error building dockerfile")
    print("Done")

    print("Initializing slave containers")
    slaveips = []
    for host in Hosts.split(','):
        slave_ip = call("pdsh -N -w " + host + " ~/OpenMPIDockerSwarm/runscript/runslave.py " + str(NumSlaves) + " " + host[-2:], "Error launching slaves").split('\n')
        slaveips.extend(slave_ip)

    if "Error" in slaveips:
        print("Error launching slaves, dumping output:")
        print(slaveips)
        exit(1)
    print("Done")

    print("Creating hostfile")
    f = open(os.getenv('HOME')+"/DockerShare/data/hostfile", 'w')
    for ip in slaveips:
        f.write(ip + '\n')
    f.close()
    print("Done")

    print("Starting master")
    print(call("docker run --name master -h master -dit --privileged --cpuset-cpus=0 -v ~/DockerShare/data:/data --lxc-conf=\"lxc.network.type = veth\" --lxc-conf=\"lxc.network.ipv4 = 10.20.49.1/16\" --lxc-conf=\"lxc.network.link=dockerbridge0\" --lxc-conf=\"lxc.network.name = eth3\" --lxc-conf=\"lxc.network.flags=up\" petergottesman/ompiswarm /bin/bash ", "Error launching master container, ensure run.sh is present"))



def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('NumSlaves', metavar='X', type=int, help="Number of slaves to launch per host")
    parser.add_argument('Hosts', help="Comma separated list of hostnames")
    args = parser.parse_args()
    run(args)

if __name__ == "__main__":
    main()
