# TOR over YGGDRASIL Docker Container

[![Docker](https://img.shields.io/badge/Docker-Enabled-blue.svg)](https://docker.com)
[![Tor](https://img.shields.io/badge/Tor-Proxy-red.svg)](https://torproject.org)
[![Yggdrasil](https://img.shields.io/badge/Yggdrasil-Network-green.svg)](https://yggdrasil-network.github.io/)

A Docker container that routes Tor traffic through the Yggdrasil decentralized network for enhanced anonymity and censorship circumvention.

## 🌟 Features

- **Dual Anonymity**: Tor over Yggdrasil for multiple privacy layers
- **Automatic Peer Discovery**: Finds best Yggdrasil peers automatically  
- **Strong Key Generation**: Creates cryptographically strong Yggdrasil keys
- **Health Monitoring**: Built-in health checks for service reliability
- **Persistent Configuration**: Saves settings between container restarts

## 🏗 Architecture

Internet → Yggdrasil Network → Tor SOCKS5 (9050) → Your Applications

## 🚀 Quick Start

### Prerequisites
- Docker Engine 20.10+
- Docker Compose 2.0+

### Building the Image
```bash
./build_image.sh
```

### Running the Container
```bash
docker-compose up -d
```

## ⚙️ Configuration

### Environment Variables

| Variable                | Default | Description                            |
|-------------------------|---------|----------------------------------------|
| YGGDRASIL_GENERATE_KEYS | true    | Generate new Yggdrasil keys on startup |

## 🔧 Usage

### Test Tor over Yggdrasil

```bash
# Test SOCKS5 proxy
curl --socks5-hostname localhost:9050 https://check.torproject.org/
```

### Check Yggdrasil Status

```bash
docker exec -it tor_over_yggdrasil /YGGDRASIL/yggdrasilctl getself
```

## 🛠 Development

### Project Structure
```text
tor_yggdrasil/
├── docker-compose.yml      # Container orchestration
├── Dockerfile             # Multi-stage container build
├── entrypoint.sh          # Startup script
├── torrc                  # Tor configuration
├── yggdrasil.conf         # Yggdrasil base configuration
└── build_image.sh         # Build script
```

### Build Arguments

 - UBUNTU_VERSION: Base OS version (default: 24.04)
 - YGGDRASIL_VERSION: Yggdrasil release (default: v0.5.12)

## 🔒 Security Features

 - Non-privileged: Runs without root privileges when possible
 - Capability Limits: Only necessary Linux capabilities
 - Network Isolation: Controlled network access
 - Health Monitoring: Automatic service health checks

## 🐛 Troubleshooting

### Check Container Status
```bash
docker-compose ps
docker logs tor_over_yggdrasil
```

### Verify Services
```bash
# Check Yggdrasil
docker exec tor_over_yggdrasil ping6 -c 3 200::1

# Check Tor
curl --socks5 localhost:9050 https://check.torproject.org/
```

## 📄 License

This project is provided for educational and research purposes. Users are responsible for complying with local laws and regulations.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## ⚠️ Disclaimer

This tool is designed for privacy research and legal anonymity purposes. Users are responsible for ensuring their use complies with applicable laws.
