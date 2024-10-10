# syntax=docker/dockerfile:1
ARG UBUNTU_VERSION=24.04

FROM ubuntu:${UBUNTU_VERSION} as builder_yggdrasil
ARG YGGDRASIL_VERSION=v0.5.8
RUN DEBIAN_FRONTEND=noninteractive\
    apt-get update &&\
    apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive\
    apt-get install -y git golang
WORKDIR /BUILD_YGGDRASIL/
RUN git clone --depth 1 --branch $YGGDRASIL_VERSION https://github.com/yggdrasil-network/yggdrasil-go.git
ENV CGO_ENABLED=0
WORKDIR /BUILD_YGGDRASIL/yggdrasil-go
# add genkeys to build
RUN sed -i -e 's/yggdrasil yggdrasilctl/yggdrasil yggdrasilctl genkeys/g' build
RUN ./build

FROM ubuntu:${UBUNTU_VERSION}
RUN DEBIAN_FRONTEND=noninteractive\
    apt-get update &&\
    apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive\ 
    apt-get install -y --fix-missing\
    tor obfs4proxy\
    git python3 python3-pip iputils-ping
# ==== UTILS ====
WORKDIR /UTILS/
RUN git config --global advice.detachedHead false
#   script to get strong yggdrasil address (https://yggdrasil-network.github.io/configuration.html#generating-stronger-addresses-and-prefixes)
RUN git clone --depth 1 --branch v0 https://github.com/oldnick85/yggdrasil_get_keys.git /UTILS/yggdrasil_get_keys
RUN python3 -m pip install --break-system-packages -r /UTILS/yggdrasil_get_keys/requirements.txt
#   script to find yggdrasil public peers
RUN git clone --depth 1 --branch v4 https://github.com/oldnick85/yggdrasil_find_public_peers.git /UTILS/yggdrasil_find_public_peers
RUN python3 -m pip install --break-system-packages -r /UTILS/yggdrasil_find_public_peers/requirements.txt
#   save peers to use in case of unavailable repository
RUN python3 /UTILS/yggdrasil_find_public_peers/yggdrasil_find_public_peers.py \
    --yggdrasil-conf="" \
    --yggdrasil-peers-json="/UTILS/yggdrasil_find_public_peers/public_peers.json"
# ==== YGGDRASIL ====
#   Ports used by YGGDRASIL
#   Listen
EXPOSE 10654
#   Default yggdrasil port
EXPOSE 9001
WORKDIR /YGGDRASIL/
COPY --from=builder_yggdrasil /BUILD_YGGDRASIL/yggdrasil-go/yggdrasil .
COPY --from=builder_yggdrasil /BUILD_YGGDRASIL/yggdrasil-go/yggdrasilctl .
COPY --from=builder_yggdrasil /BUILD_YGGDRASIL/yggdrasil-go/genkeys .
COPY ./yggdrasil.conf .
# ==== TOR ====
EXPOSE 9050
EXPOSE 8118
WORKDIR /tmp/
COPY ./torrc /etc/tor
RUN ls /etc/tor
COPY ./tor /etc/default/tor
RUN chmod -R 0700 /etc/default/tor
RUN cat /etc/default/tor
RUN cat /etc/tor/torrc
WORKDIR /
COPY ./entrypoint.sh .
ENTRYPOINT ["bash", "/entrypoint.sh"]