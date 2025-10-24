FROM debian:bookworm-slim

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update
RUN export DEBIAN_FRONTEND=noninteractive && apt-get install sudo wget apt-transport-https lsb-release libatomic1 libpython3.11 -y 
RUN wget -q https://apt.hyperion-project.org/hyperion.pub.key -O /etc/apt/trusted.gpg.d/hyperion.pub.asc
RUN echo "deb https://apt.hyperion-project.org/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hyperion.list
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update
RUN export DEBIAN_FRONTEND=noninteractive && apt-get install -y hyperion

# Flatbuffers Server port
EXPOSE 19400

# JSON-RPC Server Port
EXPOSE 19444

# Protocol Buffers Server port
EXPOSE 19445

# Boblight Server port
EXPOSE 19333

# Philips Hue Entertainment mode (UDP)
EXPOSE 2100

# HTTP and HTTPS Web UI default ports
EXPOSE 8090
EXPOSE 8092
EXPOSE 443

# Correct video group if needed
RUN [ $(getent group video) != .*"39".* ] && groupmod $(getent group 39 | awk -F ":" '{print $1}') -g 500 && groupmod video -g 39

ENV UID=1000
ENV GID=1000

RUN groupadd -f hyperion
RUN useradd -r -s /bin/bash -g hyperion -G video hyperion

RUN echo "#!/bin/bash -eu" > /usr/local/bin/start.sh
RUN echo "groupmod -g \$2 hyperion" >> /usr/local/bin/start.sh
RUN echo "usermod -u \$1 hyperion" >> /usr/local/bin/start.sh
RUN echo "chown hyperion:hyperion /config" >> /usr/local/bin/start.sh
RUN echo "sudo -u hyperion /usr/bin/hyperiond -i --service -u /config" >> /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh

VOLUME /config

CMD [ "bash", "-c", "/usr/local/bin/start.sh ${UID} ${GID}" ]