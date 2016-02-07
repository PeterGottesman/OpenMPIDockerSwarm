#!/usr/bin/env python3

import argparse
import threading
from queue import Queue
from socket import gethostname
from subprocess import check_output, CalledProcessError
from ast import literal_eval
from socket import gethostname

threads = []
lock = threading.Lock()
q = Queue()

def call(cmd, ErrorText, debug):
    try:
        log(cmd)
        out = check_output(cmd, shell=True, timeout=20).decode('utf-8')
    except CalledProcessError as err:
        print(ErrorText + " with code: " + str(err.returncode))
        out = ErrorText + " with code: " + str(err.returncode)

    return out

def log(string, mode='a'):
    with open('slavelogfile' + gethostname(), mode) as f:
        f.write(string + '\n')

def spawn_slaves(args):
    NumSlaves = literal_eval(args.SlaveLayou)t[gethostname()]
    NodeNum = gethostname()[-2:]
    LaunchThreads = args.LaunchThreads
    debug = args.debug

    log(str(NodeNum))
    CoreList = call("hwloc-calc --physical --intersect PU machine:0", "Error getting list of cores, make sure hwloc is installed", debug).rstrip('\n').split(',')

    for i in  range(LaunchThreads):
        t = threading.Thread(target=worker)
        threads.append(t)
        t.daemon = True
        t.start()

    for slave in range(1, NumSlaves+1):
        q.put((slave, args))

    q.join()


def worker():
    while True:
        slave = q.get()
        if slave is None:
            break
        start_slave(slave)
        q.task_done()

def start_slave(slv):
    slave = slv[0]
    NodeNum = slv[1].NodeNum
    debug = slv[1].debug
    with lock:
        log("starting slave %s" %str(slave))
    CTID = str(NodeNum) + str(slave)
    slaveip = "10.1." + str(NodeNum)+ "." + str(slave)
    #out = call("sudo vzctl restart " + CTID, "Error launching slave container number " + str(slave), debug)
    with lock:
       print(slaveip)
       log(slaveip)
       log("Completed slave")
    #   log(out)

def main():
    log('init', 'w')

    parser = argparse.ArgumentParser()
    parser.add_argument('SlaveLayout')
    parser.add_argument('LaunchThreads', type=int, default=4)
    parser.add_argument('--debug', dest='debug', action='store_true')
    args = parser.parse_args()
    spawn_slaves(args)

if __name__ == "__main__":
    main()
