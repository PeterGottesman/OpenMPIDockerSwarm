#sshd
#
## VERSION  0.9.1
#
FROM ubuntu:14.04
MAINTAINER Tien Nguyen <thanhtien522@gmail.com>

# Install GNU compiler
RUN apt-get update && apt-get install -y gcc g++ gfortran openssh-server libnuma-dev
RUN mkdir /var/run/sshd

RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Copy and extract OpenMPI source
COPY source/.openmpi /home/pgottesm/DockerShare/.openmpi

#add paths to libraries and binaries for ompi
ENV LD_LIBRARY_PATH /home/pgottesm/DockerShare/.openmpi/lib
ENV PATH="$PATH:/home/pgottesm/DockerShare.openmpi/bin"


RUN sed -i "1iexport PATH=$PATH:/home/pgottesm/DockerShare/.openmpi/bin" /root/.bashrc
RUN sed -i "1iexport LD_LIBRARY_PATH=/home/pgottesm/DockerShare/.openmpi/lib" /root/.bashrc

# Configure SSH service.
WORKDIR /root/
EXPOSE 22
RUN /usr/sbin/sshd

COPY ssh /root/.ssh

