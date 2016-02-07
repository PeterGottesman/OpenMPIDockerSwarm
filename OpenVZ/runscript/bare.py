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
    bare = args.bare
    NumSlaves = {}

    if Hostfile is None and Hosts is None:
        print("Must specify hostfile or hosts")
        exit(1)

    if Hosts is None:
        with open(Hostfile, 'r') as f:
            Hosts = f.readline().rstrip('\n')

    Hostlist = Hosts.split(',')

    SlaveAllocMin = int(SlaveAllocRange[0])
    SlaveAllocMax = int(SlaveAllocRange[1])

    if SlaveAllocMax > len(Hostlist)+1:
        print("SlaveAllocRange can not exceed hostlist length")
        exit(1)

    for MaxHost in range(SlaveAllocMin, SlaveAllocMax):
        call(["/home/pgottesm/DockerShare/data/run.py", test_type, test_type_friendly, "hosts.txt", str(MaxHost), timestamp, "bare"])

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('SlaveAllocRange')
    parser.add_argument('timestamp')
    parser.add_argument('test_type')
    parser.add_argument('test_type_friendly')
    parser.add_argument('--Hostfile') 
    parser.add_argument('--Hosts')
    parser.add_argument('--bare', action='store_true', dest='bare')
    args = parser.parse_args()

    main(args)
