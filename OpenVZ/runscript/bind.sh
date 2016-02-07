CTID=$1
 
echo '#!/bin/bash
. /etc/vz/vz.conf
. ${VE_CONFFILE}
SRC=/home/pgottesm/DockerShare/data
DST=/data
if [ ! -e ${VE_ROOT}${DST} ]; then mkdir -p ${VE_ROOT}${DST}; fi
mount -n -t simfs ${SRC} ${VE_ROOT}${DST} -o ${SRC}

SRC2=/home/pgottesm/DockerShare/.openmpi
DST2=/home/pgottesm/DockerShare/.openmpi
if [ ! -e ${VE_ROOT}${DST2} ]; then mkdir -p ${VE_ROOT}${DST2}; fi
mount -n -t simfs ${SRC2} ${VE_ROOT}${DST2} -o ${SRC2}

SRC3=/home/pgottesm/DockerShare/ssh
DST3=/root/.ssh
if [ ! -e ${VE_ROOT}${DST3} ]; then mkdir -p ${VE_ROOT}${DST3}; fi
mount -n -t simfs ${SRC3} ${VE_ROOT}${DST3} -o ${SRC3}
' > /etc/vz/conf/${CTID}.mount
 
chmod +x /etc/vz/conf/${CTID}.mount
