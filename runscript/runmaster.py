#!/bin/python3

import argparse
from multiprocessing import cpu_count
from subprocess import check_output, CalledProcessError

def call(cmd, ErrorText):
    try:
        out = check_output(cmd, shell=True).decode('utf-8').split('\n', 1)[0]
    except CalledProcessError as err:
        print(ErrorText + " with code: " + str(err.returncode))
        exit(1)
    
    return out

def run(args):
    NumContainers = args.NumContainers
    NumSlaves = NumContainers - 1
    NumCores = cpu_count()
    
    if NumContainers <= 0:
        print("Error: Number of Containers must be greater than 0")
        exit(1)

    print("Building image")
    call("sudo docker build -t ompiswarm ..", "Error building dockerfile")
    print("Done")

    print("Initializing Master container")
    masterid = call("sudo docker run --name master -d -it -P --privileged --cpuset-cpus=0 -v /data:/data ompiswarm", "Error creating master container")
    masterip = call("sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' " + masterid, "Error getting master ip")
    print("Done")

    print("Initializing slave containers")
    slaveid = []
    slaveip = []
    for slave in range(NumSlaves):
        core = slave%NumCores
        slaveid.append(call("sudo docker run -d -it -P --privileged --cpuset-cpus=" + str(core) + " -v /data:/data ompiswarm", "Error creating slave container number " + str(slave)))
        slaveip.append(call("sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' " + slaveid[slave], "Error getting ip for slave number " + str(slave)))
    print("Done, " + str(len(slaveip)) + " slave initialized")

    print("Creating hosts ")
    f = open("/data/hostfile", 'w')
    f.write(masterip + "\n")
    for ip in slaveip:
        f.write(ip + "\n")
    f.close()
    print("Done")

    call("xterm -e sudo docker exec -it " + masterid + " /bin/bash", "Error putting you into interactive shell with master container")

    call("sudo docker stop $(sudo docker ps -aq)", "")
    call("sudo docker rm $(sudo docker ps -aq)", "")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('NumContainers', metavar='X', type=int)
    args = parser.parse_args()
    run(args)

if __name__ == "__main__":
    main()
