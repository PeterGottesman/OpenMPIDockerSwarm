#!/usr/bin/env python3


with open('hosts.txt') as f:
    hosts = f.readline().rstrip('\n')

for host in hosts:
    for core in range(20):
        call("pdsh -w " + host + " vzctl create " + host[-2:] + str(core) + " --ostemplate OMPI-Ubuntu-14.04")
        call("pdsh -w " + host + " vzctl set " + host[-2:] + str(core) + " --ipadd 10.20." + host[-2:] + str(core) + " --cpus 1 --cpumask " + str(core) + "--save")
