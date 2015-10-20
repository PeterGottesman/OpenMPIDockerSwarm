#!/usr/bin/env python3

import argparse
from socket import gethostname
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
    with open('.slavelogfile_' + gethostname(), mode) as f:
        f.write(string + '\n')

def spawn_slaves(args):
    NumSlaves = args.NumSlaves
    NodeNum = args.NodeNum
    log(str(NodeNum))
    debug = args.debug
    CoreList = call("hwloc-calc --physical --intersect PU machine:0", "Error getting list of cores, make sure hwloc is installed", debug).rstrip('\n').split(',')
    print("#node" + str(NodeNum))

    for slave in range(NumSlaves):
        core=CoreList[slave%len(CoreList)]
        slaveid = call("docker run --name slave"+str(slave)+" -h slave"+str(slave)+" -dit --privileged --cpuset-cpus="+str(core)+" -v ~/DockerShare/data:/data:z petergottesman/ompiswarm /data/startup.sh slave", "Error launching slave container number " + str(slave), debug)
        slaveip = call("docker inspect --format '{{ .NetworkSettings.IPAddress }}' " + slaveid, "Error getting slaveip for slave number " + str(slave), debug)
        print(slaveip + "#" + slaveid[:-1])

def main():
    log('init', 'w')

    parser = argparse.ArgumentParser()
    parser.add_argument('NumSlaves', metavar='X', type=int)
    parser.add_argument('NodeNum', metavar='Y')
    parser.add_argument('--debug', dest='debug', action='store_true')
    args = parser.parse_args()
    spawn_slaves(args)

if __name__ == "__main__":
    main()
