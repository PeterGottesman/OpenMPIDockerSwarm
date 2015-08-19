#!/usr/bin/env python3

import argparse
from subprocess import check_output, CalledProcessError

def call(cmd, ErrorText):
    try:
        out = check_output(cmd, shell=True).decode('utf-8')
    except CalledProcessError as err:
        print(ErrorText + " with code: " + str(err.returncode))
        exit(1)

    return out

def spawn_slaves(args):
    NumSlaves = args.NumSlaves
    CoreList = call("hwloc-calc --physical --intersect PU machine:0", "Error getting list of cores, make sure hwloc is installed").split()

    ip = 49
    for slave in range(NumSlaves):
        core=CoreList[slave%len(CoreList)]
        ip += 1
        slaveid = call("docker run --name slave"+str(slave)+" -h slave"+str(slave)+" -d --privileged --cpuset-cpus="+str(core)+" -v ~/DockerShare/data:/data:z --lxc-conf=\"lxc.network.type = veth\" --lxc-conf=\"lxc.network.ipv4 = 10.2.0." + str(ip) + "\" --lxc-conf=\"lxc.network.link=dockerbridge0\" --lxc-conf=\"lxc.network.name = eth2\" --lxc-conf=\"lxc.network.flags=up\" ompiswarm", "Error launching slave container number " + str(slave))
        slaveip = call("docker inspect --format '{{ .NetworkSettings.IPAddress }}' " + slaveid, "Error getting slave ip for slave number " + str(slave))
        print(slaveip, "#", slaveid)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('NumSlaves', metavar='X', type=int)
    args = parser.parse_args()
    spawn_slaves(args)

if __name__ == "__main__":
    main()
