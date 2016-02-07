#!/usr/bin/env python3

import argparse
from subprocess import call

def main(args):
    SlaveAllocRange = args.SlaveAllocRange.split('-')
    Hostfile = args.Hostfile
    Hosts = args.Hosts
    timestamp = args.timestamp
    test_type = args.test_type
    test_type_friendly = args.test_type_friendly
    NumSlaves = {}

    if Hostfile is None and Hosts is None:
        print("Must specify hostfile or hosts")
        exit(1)

    if Hosts is None:
        with open(Hostfile, 'r') as f:
            Hosts = f.readline().rstrip('\n')

    Hostlist = Hosts.split(',')
    NumHosts = len(Hostlist)

    for TotalSlaves in range(int(SlaveAllocRange[0]), int(SlaveAllocRange[1])):
        if TotalSlaves > 20*NumHosts:
            print("There can only be a maximum of 20 slaves per server")
            exit(1)

        rem = TotalSlaves%NumHosts
        for host in Hostlist:
            slaves = TotalSlaves//NumHosts + (1 if rem > 0 else 0)
            NumSlaves[host] = slaves
            rem-=1

        call(["./runmaster.py", str(TotalSlaves), timestamp, str(NumSlaves), "per-core", test_type, test_type_friendly, "--plot"])

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('SlaveAllocRange')
    parser.add_argument('timestamp')
    parser.add_argument('test_type')
    parser.add_argument('test_type_friendly')
    parser.add_argument('--Hostfile') 
    parser.add_argument('--Hosts')
    args = parser.parse_args()

    main(args)

#call([test_type+".py", SlaveAllocRange, timestamp, "--hostfile", hostlist, "--plot"]) 
