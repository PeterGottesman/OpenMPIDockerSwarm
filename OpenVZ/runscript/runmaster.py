#!/usr/bin/env python3

import argparse
import math
import os
import threading
from queue import Queue
from time import sleep
from ast import literal_eval
from socket import gethostname
from subprocess import check_output, CalledProcessError

slaveips = []
lock = threading.Lock()
q = Queue()

def call(cmd, ErrorText, debug):
    try:
        print(cmd)
        log(cmd)
        out = check_output(cmd, shell=True).decode('utf-8')
        return out
    except CalledProcessError as err:
        print(ErrorText + " with code: " + str(err.returncode))
        print(err.output.decode('utf-8'))
        exit(1)

def log(string, mode='a'):
    with open('masterlogfile', mode) as f:
        f.write(str(string) + '\n')

def worker():
    while True:
        host, numslaves = q.get()
        for slave in range(1, numslaves+1):
            with lock:
                slaveips.extend(["10.1."+str(host)+"."+str(slave)])

        q.task_done()

def run(args):
    NumSlaves = args.NumSlaves
    Hostfile = args.hostfile
    SlaveAlloc = args.SlaveAlloc
    SlaveLayout = literal_eval(args.SlaveLayout)
    plot = args.plot
    debug = args.debug
    test = args.test
    friendlytest = args.friendlytest
    timestamp = args.timestamp
    debug_str = " --debug " if debug else " "

    #Init slaves
    print("Initializing Slaves")
    print(SlaveLayout)
    for host, allocnum in SlaveLayout.items():
        t = threading.Thread(target=worker)
        t.daemon = True
        t.start()
        q.put((int(host[-2:]), allocnum))

    q.join()
    #for host, allocnum in SlaveLayout.items():
    #    print(host + ":" + str(allocnum))
    #    slave_ip = call("pdsh -Nw " + host + " ~/OpenMPIDockerSwarm/OpenVZ/runscript/runslave.py " + debug_str + str(allocnum) + " " + host[-2:] + " 10",  "Error launching slaves", debug).split('\n')
    #    log(slave_ip)
    #slaveips.extend(slave_ip)

    #Check for error in slave response
    if "Error" in slaveips:
        print("Error launching slaves, dumping output:\n")
        print(slaveips)
        exit(1)
    print("Completed")

    #Create hostfile
    print("Creating hostfile")
    with open(os.getenv('HOME') + "/DockerShare/data/hostfile", 'w') as f:
        for ip in slaveips:
            f.write(ip + '\n')


    print("Completed")


    #Start master
    print("Starting master")
    #call("sudo vzctl restart 001 && sudo vzctl exec 001 /data/run.py /data/hosts.txt " + str(len(Hostlist)), "Error launching master container", debug)

    #Assume container is already started
    #call("sudo vzctl restart 001", "Error launching master container", debug)
    #sleep(0.1)
    call("ssh root@10.1." + gethostname()[-2:] + ".100 '/data/run.py " + test + " " + friendlytest + " /data/hostfile " + str(NumSlaves) + " " + timestamp + " " + SlaveAlloc + "'", "Error running run.py", debug)

def main():
    log('init', 'w')
    
    parser = argparse.ArgumentParser()
   
    parser = argparse.ArgumentParser()
    parser.add_argument('NumSlaves', metavar='X', type=int, help="Number of slaves to launch per host")
    parser.add_argument('timestamp', help="timestamp for run.py to identify this run")
    parser.add_argument('SlaveLayout')
    parser.add_argument('SlaveAlloc', help="Method for distributing slaves across the cluster\n\
                                            Options:\n\
                                            round: Distributes slaves across servers round-robin style\n\
                                            per-server: Num Slaves per server")
    parser.add_argument('test', help="test to run")
    parser.add_argument('friendlytest', help="name of test to run")
    parser.add_argument('--hosts', help="comma separated list of hostnames (takes priority over hostfile)")
    parser.add_argument('--hostfile', help="File contianing comma separated list of hostnames")
    parser.add_argument('--debug', dest='debug', action='store_true')
    parser.add_argument('--plot', dest='plot', action='store_true')
    args = parser.parse_args()
    run(args)

if __name__ == "__main__":
    main()
