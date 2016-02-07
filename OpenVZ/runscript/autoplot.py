#!/usr/bin/env python3

import argparse
from ast import literal_eval
from subprocess import call
from datetime import datetime

def main(args):
    hostlist = args.hostlist
    with open(hostlist, 'r') as f:
        NumHosts = len(f.readline().split(','))
    testlist = args.testlist
    with open(testlist, 'r') as f:
        tests = f.readlines()

    timestamp = datetime.now().strftime("%x-%X.%f").replace('/', '.')

    for test in tests:
        if test[0] is ';': continue
        SlaveAllocList = test.split(';')[2].split()
        print(SlaveAllocList)
        for SlaveAllocSet in SlaveAllocList:
            test_type = test.split(';')[0]
            test_type_friendly = test.split(';')[1]
            print(test_type, "SlaveAllocLoop")
            SplitSet = SlaveAllocSet.replace(' ', '').split(':')
            SlaveAlloc = SplitSet[0]
            SlaveAllocRange = SplitSet[1]
            TestRuns = int(SplitSet[2])
            print(SlaveAllocSet)
            for run in range(TestRuns):
                format_str = "" if SlaveAlloc != "bare" else "/home/pgottesm/DockerShare"
                print(format_str)
                test_type = test_type.format(format_str).strip('\n')
                print(test_type, "Post Format")
                print(test_type.format(format_str), "Formatted")
                call(["./" + SlaveAlloc+".py", SlaveAllocRange, timestamp, "--Hostfile", hostlist, test_type, test_type_friendly])
        
            plot_infile = "'/home/pgottesm/DockerShare/data/times/" + timestamp + "/" + test_type_friendly.replace("/", "") + "-" + SlaveAlloc + ".txt'"
            plot_outfile = "'/home/pgottesm/DockerShare/data/times/" + timestamp + "/" + test_type_friendly.replace("/", "") + "-" + SlaveAlloc + ".png'"
            plot_title = "Job Launch Time: " + test_type_friendly + " averaged over " + str(TestRuns) + " runs"

            averager_infile = "/home/pgottesm/DockerShare/data/times/" + timestamp + "/" + test_type_friendly.replace("/", "") + "-" + SlaveAlloc + "-multirun.txt"
            averager_outfile = plot_infile.strip("'")

            call(["./averager.py", averager_infile, averager_outfile])
            call(["gnuplot", "-e", "times=" + plot_infile + "", "-e", "out=" + plot_outfile + "", "-e", "plottitle='" + plot_title + "'", "plot.gnu"])


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("hostlist")
    parser.add_argument("testlist", help="file containing list of tests to run")
    args = parser.parse_args()

    main(args)
