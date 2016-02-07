#!/usr/bin/env python

from socket import gethostname
from subprocess import call

hostname = gethostname()
host = hostname[-2:].lstrip('0')
for core in range(20):
    call("sudo vzctl create " + host + str(core+1) + " --ostemplate OMPI-Ubuntu-14.04_x86_64", shell=True)
    call("sudo vzctl set " + host + str(core+1) + " --ipadd 10.1." + host  + "." +  str(core+ 1) + " --cpus 1 --cpumask " + str(core) + " --save", shell=True)
    call("sudo /home/pgottesm/OpenMPIDockerSwarm/OpenVZ/runscript/bind.sh " + host + str(core+1), shell=True)
    call("sudo vzctl start " + host + str(core+1), shell=True)
