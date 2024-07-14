# TOR_YGGDRASIL_DOCKER

## Description

This project is a set of tools for run TOR over [YGGDRASIL](https://yggdrasil-network.github.io/) docker images.

At startup, the script searches YGGDRASIL public peers and chooses several best of them. 
Then it generates YGGDRASIL *PublicKey* and *PrivateKey* unless the keys not set in environment variables.

## Building

You can build docker image by simply run script *build_image.sh*. 

> bash build_image.sh

Feel free to modify it with your own building arguments.

## Running

To run docker container just run

> docker-compose up
