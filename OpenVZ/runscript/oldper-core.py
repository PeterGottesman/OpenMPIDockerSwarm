#!/usr/bin/env python3

import argparse
from subprocess import call

def main(args):
    SlaveAllocRange = args.SlaveAllocRange.split('-')
    Hostfile = args.Hostfile
    Hosts = args.Hosts
    timestamp = args.timestamp
    test_type = args.test_type
    NumSlaves = {}

    if Hostfile is None and Hosts is None:
        print("Must specify hostfile or hosts")
        exit(1)

    if Hosts is None:
        with open(Hostfile, 'r') as f:
            Hosts = f.readline().rstrip('\n')

    Hostlist = Hosts.split(',')

    for MaxHost in range(1, len(Hostlist)+1):
        MiniHostlist = Hostlist[:MaxHost]
        for TotalSlaves in range(int(SlaveAllocRange[0]), int(SlaveAllocRange[1])):
        
            if TotalSlaves > 20:
                print("There can be no more than 20 slaves per server")
                exit(1)

            for host in MiniHostlist:
                NumSlaves[host] = TotalSlaves

            call(["./runmaster.py", str(TotalSlaves), timestamp, str(NumSlaves), "per-server", test_type, "--plot"])
            print(sorted(NumSlaves))

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('SlaveAllocRange')
    parser.add_argument('timestamp')
    parser.add_argument('test_type')
    parser.add_argument('--Hostfile') 
    parser.add_argument('--Hosts')
    args = parser.parse_args()

    main(args)
