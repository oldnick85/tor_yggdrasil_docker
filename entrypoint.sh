#!/bin/bash
# get strong yggdrasil address (https://yggdrasil-network.github.io/configuration.html#generating-stronger-addresses-and-prefixes)
python3 /UTILS/yggdrasil_get_keys/yggdrasil_get_keys.py \
    --genkeys="/YGGDRASIL/genkeys" \
    --yggdrasil-conf="/YGGDRASIL/yggdrasil.conf" \
    --timeout=10 \
    --environment
# find yggdrasil public peers
python3 /UTILS/yggdrasil_find_public_peers/yggdrasil_find_public_peers.py \
    --yggdrasil-conf="/YGGDRASIL/yggdrasil.conf" \
    --yggdrasil-peers-json="/UTILS/yggdrasil_find_public_peers/public_peers.json" \
    --parallel=40 \
    --pings=10 \
    --best=6 \
    --max-from-country=2 \
    --ping-interval=0.5
sysctl net.ipv6.conf.all.disable_ipv6=0 || true
# start YGGDRASIL
/YGGDRASIL/yggdrasil -useconffile /YGGDRASIL/yggdrasil.conf &
sleep 30s
# start TOR
tor &
wait -n
exit $?    