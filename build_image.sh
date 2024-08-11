#!/bin/bash
TAG_VERSION=$(git describe --tags || echo "unknown")
docker build \
    --build-arg UBUNTU_VERSION=24.04 \
    --build-arg YGGDRASIL_VERSION=v0.5.7 \
    --tag tor_yggdrasil:${TAG_VERSION} \
    --tag tor_yggdrasil:latest \
    .
