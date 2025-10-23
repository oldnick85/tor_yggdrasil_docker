#!/bin/bash
set -e  # Exit immediately on any error - fail fast principle

echo "Starting Tor over Yggdrasil setup..."

# Logging function for consistent output format
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Generate strong Yggdrasil keys unless disabled by environment variable
# This enhances cryptographic security compared to default keys
if [ "${YGGDRASIL_GENERATE_KEYS:-true}" = "true" ]; then
    log "Generating strong Yggdrasil keys for enhanced security..."
    python3 /UTILS/yggdrasil_get_keys/yggdrasil_get_keys.py \
        --genkeys="/YGGDRASIL/genkeys" \
        --yggdrasil-conf="/YGGDRASIL/yggdrasil.conf" \
        --timeout=10 \
        --environment
else
    log "Skipping key generation (YGGDRASIL_GENERATE_KEYS=false)"
fi

# Discover and select optimal Yggdrasil public peers
# This finds the fastest and most reliable peers from public lists
log "Discovering and testing Yggdrasil public peers for optimal performance..."
python3 /UTILS/yggdrasil_find_public_peers/yggdrasil_find_public_peers.py \
    --yggdrasil-conf="/YGGDRASIL/yggdrasil.conf" \
    --yggdrasil-peers-json="/UTILS/yggdrasil_find_public_peers/public_peers.json" \
    --parallel=40 \
    --pings=10 \
    --best=8 \
    --max-from-country=2 \
    --ping-interval=0.5

# Enable IPv6 - required for Yggdrasil network functionality
log "Enabling IPv6 support for Yggdrasil network..."
sysctl net.ipv6.conf.all.disable_ipv6=0 || true

# Start Yggdrasil network service in background
log "Starting Yggdrasil decentralized network..."
/YGGDRASIL/yggdrasil -useconffile /YGGDRASIL/yggdrasil.conf &
# Capture process ID for monitoring
YGG_PID=$!

# Allow time for Yggdrasil to initialize and establish peer connections
log "Waiting for Yggdrasil network initialization (30 seconds)..."
sleep 30

# Verify Yggdrasil process is still running
if ! ps -p $YGG_PID > /dev/null; then
    log "ERROR: Yggdrasil process terminated unexpectedly!"
    exit 1
fi

# Start Tor proxy service - will route through Yggdrasil network
log "Starting Tor proxy service..."
tor &
TOR_PID=$!

log "Setup complete! All services are now running:"
echo "- Yggdrasil Network PID: $YGG_PID"
echo "- Tor Proxy PID: $TOR_PID"
echo "- SOCKS5 Proxy: localhost:9050 (for applications)"

# Wait for any process to exit, then cleanup
# This maintains container running until a service fails
wait -n
log "One of the services has stopped. Initiating shutdown sequence..."
# Graceful termination
kill $YGG_PID $TOR_PID 2>/dev/null || true
# Return the exit code of the failed process
exit $?