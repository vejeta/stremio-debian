# Stremio Debian Packages

Modern Debian packaging for the complete Stremio media center ecosystem, resolving compatibility issues with current Debian/Ubuntu distributions.

## 🚀 Quick Install
```bash
# Add repository and key
wget -qO - https://debian.vejeta.com/key.gpg | sudo apt-key add -
echo "deb https://debian.vejeta.com bookworm main non-free" | sudo tee /etc/apt/sources.list.d/stremio.list

# Install complete Stremio
sudo apt update
sudo apt install stremio stremio-server
```

## 📦 Package Components

This repository provides two complementary packages following Debian's architecture:

### `stremio` (main/free)
- **License**: GPL-3.0-or-later
- **Source**: https://salsa.debian.org/mendezr/stremio
- **Contains**: Desktop client (C++/Qt5)
- **Capabilities**: Local playback, HTTP streaming, add-on ecosystem

### `stremio-server` (non-free)
- **License**: Proprietary 
- **Source**: https://salsa.debian.org/mendezr/stremio-server
- **Contains**: BitTorrent streaming server (Node.js)
- **Capabilities**: Direct torrent streaming, enhanced functionality

## ✨ Key Improvements Over Upstream

- **FHS Compliance**: Proper `/usr` installation vs upstream `/opt`
- **Modern Dependencies**: Updated for current Debian releases  
- **License Separation**: Following Debian main/non-free model
- **Automated CI/CD**: GitHub Actions pipeline for both packages
- **Professional APT Repository**: Signed packages with proper metadata
- **Policy Compliance**: Lintian-clean packaging for both components

## 🛠️ Technical Stack

- **Packaging**: git-buildpackage workflow with pristine-tar
- **CI Platform**: GitHub Actions with Debian containers
- **Distribution**: Self-hosted APT repository with GPG signing
- **Standards**: Debian Policy 4.6+ compliant
- **Architecture**: Separate source packages for license compliance

## 🏗️ Repository Structure
```
├── stremio-client/          # GPL desktop client
├── stremio-server/          # Proprietary server component  
├── .github/workflows/       # CI/CD automation
├── repository-scripts/      # APT repo management
└── docs/                   # Installation guides
```

## 📋 Build Status

| Component | Build | Lintian | Deploy |
|-----------|-------|---------|--------|
| stremio | ✅ | ✅ | ✅ |
| stremio-server | ✅ | ✅ | ✅ |

## 🤝 Contributing & Debian Submission

Both packages are prepared for submission to the official Debian archive:
- **Main repository**: GPL client → Debian `main`
- **Server repository**: Proprietary server → Debian `non-free`

Canonical sources maintained at:
- https://salsa.debian.org/mendezr/stremio
- https://salsa.debian.org/mendezr/stremio-server

## 📄 License Transparency

This project demonstrates proper license separation as practiced in Debian:
- Free software components in main repository
- Proprietary components clearly separated  
- Users can choose level of functionality needed
- Full compliance with distribution policies

---

*Part of ongoing contribution to become a Debian Package Maintainer*
```

## Estructura del Proyecto GitHub:
```
stremio-debian/
├── .github/workflows/
│   ├── build-stremio-client.yml
│   ├── build-stremio-server.yml
│   └── deploy-repository.yml
├── stremio-client/         # Mirror de salsa.debian.org/mendezr/stremio
├── stremio-server/         # Mirror de salsa.debian.org/mendezr/stremio-server
├── repository/             # APT repo structure
└── docs/
    ├── installation.md
    └── building.md
