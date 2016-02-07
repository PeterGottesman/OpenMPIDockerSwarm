#!/bin/bash
sudo systemctl enable rpcbind
sudo systemctl enable nfs-server
sudo service rpcbind start
sudo service nfs-server start
