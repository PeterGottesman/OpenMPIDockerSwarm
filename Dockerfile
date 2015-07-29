#sshd
#
## VERSION  0.9.1
#
FROM ubuntu:14.04
MAINTAINER Tien Nguyen <thanhtien522@gmail.com>

# Install GNU compiler
RUN apt-get update && apt-get install -y gcc g++ gfortran openssh-server
RUN mkdir /var/run/sshd

RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Copy and extract OpenMPI source
COPY source/ompi1.8.7installed.tar.bz2 /root/
RUN tar -xf /root/ompi1.8.7installed.tar.bz2 -C /root/

#add paths to libraries and binaries for ompi
ENV LD_LIBRARY_PATH /root/.openmpi/lib
ENV PATH="$PATH:/root/.openmpi/bin"


RUN sed -i "1iexport PATH=$PATH:/root/.openmpi/bin" /root/.bashrc
RUN sed -i "1iexport LD_LIBRARY_PATH=/root/.openmpi/lib" /root/.bashrc

# Configure SSH service.
WORKDIR /root/
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
COPY ssh /root/.ssh

