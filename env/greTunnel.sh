#!/bin/bash
REMOTE_NUM=$1
IP_ADDR=$(ifconfig | grep 172.28.182 | awk '{ print $2 }')
ID_NUM=$(ifconfig | grep 172.28.182 | awk '{ print $2 }' | awk -F "." '{ print $4 }')
#echo $ID_NUM
TUNNEL_NAME="tun${ID_NUM}"
sudo iptunnel add ${TUNNEL_NAME} mode gre local ${IP_ADDR} remote 172.28.182.${REMOTE_NUM}
sudo ifconfig ${TUNNEL_NAME} 10.0.${ID_NUM}.1
sudo ifconfig ${TUNNEL_NAME} up

sudo route add -net 172.17.${REMOTE_NUM}.0 netmask 255.255.255.0 dev ${TUNNEL_NAME}
sudo iptables -t nat -F POSTROUTING
sudo iptables -t nat -A POSRROUTING -s 172.17.${ID_NUM}.0/24 ! -d 172.17.0.0/16 -j MASQUERADE 

