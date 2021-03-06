#!/usr/bin/env python3

import argparse
import math
import os
from subprocess import check_output, CalledProcessError

def call(cmd, ErrorText, debug):
    try:
        if debug: log(cmd)
        out = check_output(cmd, shell=True).decode('utf-8')
    except CalledProcessError as err:
        print(ErrorText + " with code: " + str(err.returncode))
        exit(1)

    return out

def log(string, mode='a'):
    with open('.masterlogfile', mode) as f:
        f.write(string + '\n')

def run(args):
    NumSlaves = args.NumSlaves
    f = open(args.Hosts, 'r')
    Hosts = f.readline().rstrip('\n')
    NumHosts = len(Hosts.split(','))
    plot = args.plot
    debug = args.debug
    debug_str = " --debug" if debug else ""
    
    if not (0 < NumSlaves <= 256):
        print("Error: Number of slaves must be greater than 0 and less than 256 times the number of hosts")
        exit(1)

    if not plot: print("Building Image")
    call("pdsh -w " + Hosts + " docker run --rm petergottesman/ompiswarm ", "Error building dockerfile", debug)
    if not plot: print("Done")

    print("Initializing slave containers")
    slaveips = []
    for host in Hosts.split(','):
        slave_ip = call("pdsh -N -w " + host + " ~/OpenMPIDockerSwarm/runscript/runslave.py " + str(NumSlaves) + " " + host[-2:] + debug_str, "Error launching slaves", debug).split('\n')
        slaveips.extend(slave_ip)

    if "Error" in slaveips:
        print("Error launching slaves, dumping output:")
        print(slaveips)
        exit(1)
    if not plot: print("Done")

    if not plot: print("Creating hostfile")
    f = open(os.getenv('HOME')+"/DockerShare/data/hostfile", 'w')
    for ip in slaveips:
        f.write(ip + '\n')
    f.close()
    if not plot: print("Done")

    if not plot: print("Starting master")
    call("docker run --name master -h master -dit --privileged --cpuset-cpus=0 -v ~/DockerShare/data:/data petergottesman/ompiswarm /data/startup.sh master", "Error launching master container, ensure run.sh is present", debug)



def main():
    log('init', 'w')
    with open('/home/pgottesm/DockerShare/data/times.txt', 'w') as f:
        f.write('\n')

    parser = argparse.ArgumentParser()
    parser.add_argument('NumSlaves', metavar='X', type=int, help="Number of slaves to launch per host")
    parser.add_argument('Hosts', help="Comma separated list of hostnames")
    parser.add_argument('--debug', dest='debug', action='store_true')
    parser.add_argument('--plot', dest='plot', action='store_true')
    args = parser.parse_args()
    run(args)

if __name__ == "__main__":
    main()
