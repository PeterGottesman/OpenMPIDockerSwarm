#!/bin/bash

echo "" > /data/hostfile

#########################################
# Launch all container in other host    #
#########################################

while read -r hostip
do
  ssh root@${hostip} 'bash -s' < othervm.sh
done


#########################################
# Launch all container in master host   #
#########################################
echo "Initializing Master container...."
masterid=$(docker run -d -it -P --privileged=true -v /data:/data tiennt/ompi)
masterip=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${masterid}`
NUMBER_SLAVE=$1
echo "done."

echo "Initializing slave containers...."
for (( c=0; c<$NUMBER_SLAVE; c++ ))
do
  slaveid[${c}]=$(docker run -d -it --privileged=true -v /data:/data tiennt/ompi)
  slaveip[${c}]=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${slaveid[${c}]}`
done
SLAVE_NUM=${#slaveid[@]}
echo "done. ${SLAVE_NUM} slaves initialed!"

echo "Create host file..."

for (( c=0; c<$SLAVE_NUM; c++ ))
do
  echo ${slaveip[${c}]} >> /data/hostfile
done
echo "Done."

echo "Generate RSA key..."
docker exec ${masterid} ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa >> /dev/null

for (( c=0; c<$SLAVE_NUM; c++ ))
do
  docker exec ${slaveid[${c}]} ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa >> /dev/null
done
echo "done."

###########################################
#  Finished launch all containers         #
###########################################


###########################################
# Add ssh key of master to all slaves     #
###########################################
num=0
while read -r ipaddr
do
  ${slaveip[${num}]}=${ipaddr}
  num=$(($num+1))
done < "/data/hostfile"


echo "Add ssh key of master to slaves.."
for (( c=0; c<$SLAVE_NUM; c++ ))
do
  docker exec ${masterid} /root/ssh/ssh-copy-id.sh ${slaveip[${c}]} >> /dev/null
done

echo "done."
#docker exec ${masterid} touch /root/hostfile



docker exec -it ${masterid} /bin/bash

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)