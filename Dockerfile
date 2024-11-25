FROM pytorch/pytorch:2.3.0-cuda12.1-cudnn8-devel

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
WORKDIR /

COPY config/apt-install.txt /usr/local/apt-install.txt
RUN apt update && \
    grep -v "^#" /usr/local/apt-install.txt | xargs apt-get install -y --no-install-recommends
#install code
RUN curl -s -L "https://go.microsoft.com/fwlink/?LinkID=760868" -o vscode.deb && \
    apt-get install -y --no-install-recommends ./vscode.deb && rm ./vscode.deb 

COPY config /opt/config
RUN pip install -r /opt/config/requirements.txt

# define access permissions for openssh server and create folder for sshd
RUN echo "+:ALL:ALL" >> /etc/security/access.conf && \
    mkdir -p /var/run/sshd

# copy launch scripts
COPY scripts/* /usr/local/bin/

# entrypoint that run the services
ENTRYPOINT []

# CMD set to run bash
CMD ["/bin/bash"]