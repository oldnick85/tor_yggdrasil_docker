# syntax=docker/dockerfile:1
ARG UBUNTU_VERSION=24.04

# === STAGE 1: Build Yggdrasil from source ===
FROM ubuntu:${UBUNTU_VERSION} as builder_yggdrasil
ARG YGGDRASIL_VERSION=v0.5.12

# Install build dependencies
RUN DEBIAN_FRONTEND=noninteractive \
 apt-get update && \
 apt-get install -y --no-install-recommends \
 git golang ca-certificates && \
 apt-get clean && \
 rm -rf /var/lib/apt/lists/*

# Clone and build Yggdrasil from official repository
WORKDIR /BUILD_YGGDRASIL/
RUN git clone --depth 1 --branch $YGGDRASIL_VERSION \
 https://github.com/yggdrasil-network/yggdrasil-go.git

# Build Yggdrasil with static linking for better portability
WORKDIR /BUILD_YGGDRASIL/yggdrasil-go
# add genkeys to build
RUN sed -i -e 's/yggdrasil yggdrasilctl/yggdrasil yggdrasilctl genkeys/g' build
RUN ./build

# === STAGE 2: Runtime environment ===
FROM ubuntu:${UBUNTU_VERSION}

# Install runtime dependencies
RUN DEBIAN_FRONTEND=noninteractive \
 apt-get update && \
 apt-get install -y --no-install-recommends \
 # Tor and related services
 tor obfs4proxy \ 
 # Utilities and scripting
 git python3 python3-pip iputils-ping curl && \ 
 # Clear
 apt-get clean && \
 rm -rf /var/lib/apt/lists/*

# === UTILITIES SECTION ===
WORKDIR /UTILS/
RUN git config --global advice.detachedHead false
# Clone key generation script for strong Yggdrasil address (https://yggdrasil-network.github.io/configuration.html#generating-stronger-addresses-and-prefixes)
RUN git clone --depth 1 --branch v0 \
 https://github.com/oldnick85/yggdrasil_get_keys.git \
 /UTILS/yggdrasil_get_keys

# Clone peer discovery script for finding public Yggdrasil peers 
RUN git clone --depth 1 --branch v5 \
 https://github.com/oldnick85/yggdrasil_find_public_peers.git \
 /UTILS/yggdrasil_find_public_peers

# Install Python dependencies
RUN python3 -m pip install --break-system-packages \
 -r /UTILS/yggdrasil_get_keys/requirements.txt && \
 python3 -m pip install --break-system-packages \
 -r /UTILS/yggdrasil_find_public_peers/requirements.txt

# Pre-fetch public peers list as fallback in case repository is unavailable
RUN python3 /UTILS/yggdrasil_find_public_peers/yggdrasil_find_public_peers.py \
 --yggdrasil-conf="" \
 --yggdrasil-peers-json="/UTILS/yggdrasil_find_public_peers/public_peers.json"
# ==== YGGDRASIL ====
#   Ports used by YGGDRASIL
EXPOSE 10654
WORKDIR /YGGDRASIL/
# Copy built binaries from builder stage
COPY --from=builder_yggdrasil /BUILD_YGGDRASIL/yggdrasil-go/yggdrasil .
COPY --from=builder_yggdrasil /BUILD_YGGDRASIL/yggdrasil-go/yggdrasilctl .
COPY --from=builder_yggdrasil /BUILD_YGGDRASIL/yggdrasil-go/genkeys .
# Base configuration file
COPY ./yggdrasil.conf . 

# === TOR PROXY SETUP ===
# SOCKS5 proxy port
EXPOSE 9050
EXPOSE 8118 
# Tor configuration
COPY ./torrc /etc/tor/torrc 
COPY ./tor /etc/default/tor
RUN chmod -R 0700 /etc/default/tor
# === CONTAINER STARTUP ===
COPY ./entrypoint.sh /entrypoint.sh
# Make entrypoint executable
RUN chmod +x /entrypoint.sh 
# Default container command
ENTRYPOINT ["/entrypoint.sh"] 