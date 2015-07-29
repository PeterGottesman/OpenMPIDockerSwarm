#!/bin/bash

function error_exit
{
    echo "$1" 1>&2
    exit 1
}

function help
{
    echo "Usage: $0 NUMBER_CONTAINER [OPTION]" 1>&2
    echo "OPTION:" 1>&2
    echo -e ' \t ' "clearall: Clear all container after exit (default)" 1>&2
    echo -e ' \t ' "holdmaster: Clear all container except master after exit" 1>&2
    echo -e ' \t ' "juststop: Just stop all container, all container data are still in disk and can be started again." 1>&2
}

if [ "$#" -lt 1 ]; then
    help
    exit 1
fi


NUMBER_SLAVE=$1
OPTION=$2

re='^[0-9]+$'
if ! [[ ${NUMBER_SLAVE} =~ $re ]] ; then
    error_exit "Error: Not a number"
    exit 1
fi

if [ ${NUMBER_SLAVE} -lt 1 ]; then
    error_exit "Number of container must greater or equal with 1!"
    exit 1
fi

echo "Building image..."
docker build -t ompiswarm ..
echo "Done"

NUMBER_SLAVE=`expr ${NUMBER_SLAVE} - 1`
NUMBER_CORES=$(nproc)

echo "Initializing Master container...."
masterid=$(docker run -d -it -P --privileged=true --cpuset-cpus=0 -v /data:/data ompiswarm)
masterip=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${masterid}`
echo "done."

echo "Initializing slave containers...."
for (( c=0; c<$NUMBER_SLAVE; c++ ))
do
    CORE=c%$NUMBER_CORES
    slaveid[${c}]=$(docker run -d -it -P --privileged=true --cpuset-cpus=$CORE -v /data:/data ompiswarm)
    slaveip[${c}]=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${slaveid[${c}]}`
done
SLAVE_NUM=${#slaveid[@]}
echo "done. ${SLAVE_NUM} slaves initialed!"

echo "Create host file..."
echo ${masterip} > /data/hostfile
for (( c=0; c<$SLAVE_NUM; c++ ))
do
    echo ${slaveip[${c}]} >> /data/hostfile
done
echo "Done."

docker exec -it ${masterid} /bin/bash

if [ "${OPTION}" == "holdmaster" ]; then
    for (( c=0; c<$SLAVE_NUM; c++))
    do
        docker stop ${slaveid[${c}]}
        docker rm ${slaveid[${c}]}
    done
    echo "Clear done."
    echo ""
    echo "Master id is: $masterid"
    echo "Master ip is: $masterip"
    #else if [  ]; then

else
    docker stop $(docker ps -a -q)
    docker rm $(docker ps -a -q)
    echo "Done."
    echo ""
    echo "All clean!"
    echo "Bye."
fi
