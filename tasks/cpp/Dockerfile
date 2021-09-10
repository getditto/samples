# our local base image
FROM ubuntu 

LABEL description="Container for use with Visual Studio Code" 

# install build dependencies 
RUN apt-get update && apt-get install -y g++ rsync zip openssh-server make 

# configure SSH for communication with Visual Studio 
RUN mkdir -p /var/run/sshd

RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \ 
   ssh-keygen -A 

# expose port 22 
EXPOSE 22