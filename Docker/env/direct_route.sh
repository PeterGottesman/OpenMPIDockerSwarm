#!/bin/bash

ROUTE_TO=$1

LOCAL_ID=$(ifconfig | grep "172.28.182" | awk '{ print $2 }' | awk -F "." '{ print $4 }')

sudo route add -net 172.17.${ROUTE_TO}.0 netmask 255.255.255.0 gw 172.28.182.${ROUTE_TO}
sudo iptables -t nat -F POSTROUTING
sudo iptables -t nat -A POSTROUTING -s 172.17.${LOCAL_ID}.0/24 ! -d 172.17.0.0/16
