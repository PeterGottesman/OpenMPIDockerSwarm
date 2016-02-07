#!/usr/bin/env python3

import threading
from queue import Queue
from socket import gethostname
from subprocess import call

q = Queue()
            
def worker():
    while True:
        hostname = q.get()
        call("pdsh -w " + hostname + " sudo /home/pgottesm/OpenMPIDockerSwarm/OpenVZ/runscript/startslaves.py", shell=True)
        q.task_done()

def createMaster(hostname = gethostname()):
    host = hostname[-2:]
    call("pdsh -w " + hostname + " sudo vzctl create 001 --ostemplate OMPI-Ubuntu-14.04_x86_64", shell=True)
    call("pdsh -w " + hostname + " sudo vzctl set 001 --ipadd 10.1." + host + ".100  --cpus 1 "  + " --save", shell=True)
    call("pdsh -w " + hostname + " sudo /home/pgottesm/OpenMPIDockerSwarm/OpenVZ/runscript/bind.sh 1" , shell=True)
    call("pdsh -w " + hostname + " sudo vzctl start 001", shell=True)

def main():
    with open('hosts.txt', 'r') as f:
        for hostname in f.readline().rstrip('\n').split(','):
            t = threading.Thread(target=worker)
            t.daemon = True
            t.start()

            q.put(hostname)

        q.join()

    createMaster()

if __name__ == "__main__":
    main()
