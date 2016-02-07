#!/bin/bash

IP_POSFIX=$(ifconfig | grep 'inet 172.28.182' | awk '{print $2}' | awk -F "." '{print $4}')
BRIDGE_NAME=docker0
NETMASK=255.255.255.0
BRIDGE_IP="172.17.${IP_POSFIX}.1"
echo ${IP_POSFIX}
echo ${BRIDGE_IP}
sudo brctl delbr ${BRIDGE_NAME}
sudo brctl addbr ${BRIDGE_NAME}
sudo ifconfig ${BRIDGE_NAME} ${BRIDGE_IP}  netmask ${NETMASK}

sudo bash -c  "echo \"OPTIONS=\"--selinux-enabled -b=${BRIDGE_NAME}\"\" > /etc/sysconfig/docker"
sudo bash -c 'echo "DOCKER_CERT_PATH=/etc/docker" >> /etc/sysconfig/docker'
sudo service docker restart
