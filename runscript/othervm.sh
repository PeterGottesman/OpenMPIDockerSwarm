#!/bin/bash
NUMBER_SLAVE=$1

echo "Initializing slave containers...."
for (( c=0; c<$NUMBER_SLAVE; c++ ))
do
  slaveid[${c}]=$(docker run -d -it --privileged=true -v /data:/data tiennt/ompi)
  slaveip[${c}]=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${slaveid[${c}]}`
done
SLAVE_NUM=${#slaveid[@]}
echo "done. ${SLAVE_NUM} slaves initialed!"

echo "Generate RSA key..."

for (( c=0; c<$SLAVE_NUM; c++ ))
do
  docker exec ${slaveid[${c}]} ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa >> /dev/null
done
echo "done."

echo "Create host file..."
for (( c=0; c<$SLAVE_NUM; c++ ))
do
  echo ${slaveip[${c}]} >> /data/hostfile
done
echo "Done."