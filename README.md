# Stremio Debian Packages

[![Build Status](https://github.com/vejeta/stremio-debian/actions/workflows/build-and-release.yml/badge.svg)](https://github.com/vejeta/stremio-debian/actions)
[![Repository](https://img.shields.io/badge/APT-debian.vejeta.com-blue)](https://debian.vejeta.com)
![GitHub release](https://img.shields.io/github/v/release/vejeta/stremio-debian)
![GitHub Downloads](https://img.shields.io/github/downloads/vejeta/stremio-debian/total)
![Repository Status](https://img.shields.io/website?down_message=offline&label=APT%20repository&up_message=online&url=https%3A%2F%2Fdebian.vejeta.com)
![GitHub issues](https://img.shields.io/github/issues/vejeta/stremio-debian)
![Platform](https://img.shields.io/badge/platform-Debian%20%7C%20Ubuntu-blue)
![Architecture](https://img.shields.io/badge/arch-amd64%20%7C%20arm64-green)
![License](https://img.shields.io/github/license/vejeta/stremio-debian)

Modern Debian packaging for the complete **Stremio** media center ecosystem.

**Hosted on GitHub Pages** | **Zero server costs** | **Automatic builds** | **ARM64 support for Raspberry Pi**

---

## Important: Qt5 End-of-Life Notice

**Qt5 has reached End-of-Life** and is being removed from Debian. The original `stremio` client uses Qt5/QtWebEngine, but QtWebEngine is not available for Qt6, making the Qt5 client unmaintainable going forward.

### What This Means

| Client | Status | Recommendation |
|--------|--------|----------------|
| **stremio** (Qt5) | Legacy - Qt5 EOL | Use on bookworm/trixie while available |
| **stremio-gtk** (GTK4/CEF) | **Active Development** | **Recommended for Debian sid** |

**stremio-gtk** is the successor client developed by Stremio using GTK4/Adwaita with CEF (Chromium Embedded Framework). It is the future-proof option that will continue to work as Qt5 is phased out.

---

## Quick Installation

### For Debian sid (Recommended: stremio-gtk)

```bash
# Add GPG key
wget -qO - https://debian.vejeta.com/key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/stremio-debian.gpg

# Add repository
echo "deb [signed-by=/usr/share/keyrings/stremio-debian.gpg] https://debian.vejeta.com sid main non-free" | sudo tee /etc/apt/sources.list.d/stremio.list

# Install stremio-gtk (modern GTK4/CEF client)
sudo apt update
sudo apt install stremio-gtk stremio-server
```

### For Debian bookworm/trixie (Legacy Qt5 client)

```bash
# Add GPG key
wget -qO - https://debian.vejeta.com/key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/stremio-debian.gpg

# Add repository (choose your distribution)
# For Debian testing (rolling):
echo "deb [signed-by=/usr/share/keyrings/stremio-debian.gpg] https://debian.vejeta.com testing main non-free" | sudo tee /etc/apt/sources.list.d/stremio.list

# OR for Debian 13 (trixie):
echo "deb [signed-by=/usr/share/keyrings/stremio-debian.gpg] https://debian.vejeta.com trixie main non-free" | sudo tee /etc/apt/sources.list.d/stremio.list

# OR for Debian 12 (bookworm):
echo "deb [signed-by=/usr/share/keyrings/stremio-debian.gpg] https://debian.vejeta.com bookworm main non-free" | sudo tee /etc/apt/sources.list.d/stremio.list

# Install Qt5 client
sudo apt update
sudo apt install stremio stremio-server
```

**Supported Distributions:**
- Debian sid (unstable) - **stremio-gtk** (recommended) + Qt5 client
- Debian testing - Qt5 client only
- Debian 13 (trixie) - Qt5 client only
- Debian 12 (bookworm) - Qt5 client only

---

## Package Components

### stremio-gtk (main) - **Recommended for Debian sid**

| Property | Value |
|----------|-------|
| **License** | GPL-3.0-only |
| **Architecture** | amd64 |
| **Distribution** | Debian sid only |
| **Upstream** | [github.com/Stremio/stremio-linux-shell](https://github.com/Stremio/stremio-linux-shell) |
| **Packaging** | [salsa.debian.org/mendezr/stremio-gtk](https://salsa.debian.org/mendezr/stremio-gtk) |

**Why stremio-gtk?**
- Modern GTK4/Adwaita interface following GNOME HIG
- Uses CEF (Chromium Embedded Framework) - actively maintained
- Native Wayland support
- Future-proof: continues to work as Qt5 is removed from Debian

**Dependencies** (installed automatically):
- `libcef144` - CEF runtime library
- `cef-resources` - CEF locales and resources
- `stremio-server` - Streaming server

### stremio (main) - Legacy Qt5 Client

| Property | Value |
|----------|-------|
| **License** | GPL-3.0-or-later |
| **Architecture** | amd64, arm64 |
| **Distribution** | All (bookworm, trixie, testing, sid) |
| **Status** | **Legacy** - Qt5 EOL |
| **Upstream** | [github.com/Stremio/stremio-shell](https://github.com/Stremio/stremio-shell) |
| **Packaging** | [salsa.debian.org/mendezr/stremio](https://salsa.debian.org/mendezr/stremio) |

**Note**: The Qt5 client will continue to work on existing distributions but will not receive updates once Qt5 is removed from Debian.

### stremio-server (non-free)

| Property | Value |
|----------|-------|
| **License** | Proprietary |
| **Architecture** | all (Node.js) |
| **Distribution** | All |
| **Upstream** | [dl.strem.io/server](https://dl.strem.io/server/) |
| **Packaging** | [salsa.debian.org/mendezr/stremio-server](https://salsa.debian.org/mendezr/stremio-server) |

Required for BitTorrent streaming, HLS transcoding, and casting support.

### CEF Packages (main) - Debian sid only

| Package | Description |
|---------|-------------|
| **libcef144** | CEF runtime library |
| **libcef-dev** | Development headers |
| **cef-resources** | Locales, PAK files, runtime resources |

CEF packages are required by stremio-gtk and are installed automatically as dependencies.

---

## Release Strategy

This repository uses **separate releases** for different package groups:

| Release Tag | Packages | Distribution |
|-------------|----------|--------------|
| `v*` (e.g., v5.0.0) | stremio (Qt5), stremio-server | All |
| `gtk-*` (e.g., gtk-1.0.0-beta.13.ds-1) | stremio-gtk | sid only |
| `cef-*` (e.g., cef-144.0.7) | libcef144, cef-resources, libcef-dev | sid only |

**For users**: The APT repository at `debian.vejeta.com` combines all packages automatically. Just `apt install` what you need.

---

## Debian Submission Status

### stremio-gtk - **Active ITP**

**ITP**: [Bug #1119815](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1119815)

- **Target**: Debian `main` archive
- **License**: GPL-3.0-only (DFSG-compliant)
- **Status**: Packaging complete, seeking sponsorship
- **Dependencies**: Requires CEF packages

### chromium-embedded-framework (CEF) - **Active ITP**

**ITP**: [Bug #915400](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=915400)

- **Target**: Debian `main` archive
- **License**: BSD-style (DFSG-compliant)
- **Status**: Packaging complete, builds available in this repository

### stremio (Qt5) - **Unlikely to be Sponsored**

**ITP**: [Bug #943703](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=943703)

- **Status**: **Qt5 End-of-Life** - sponsorship unlikely
- **Reason**: Qt5/QtWebEngine is being removed from Debian
- **Alternative**: stremio-gtk is the path forward

The Qt5 client ITP was filed in 2019, but Qt5 reaching EOL means this package cannot be accepted into Debian's main archive. The packaging work has been redirected to stremio-gtk which uses actively maintained technologies.

---

## Repository Architecture

```
┌─────────────────────────────────────────────────────────┐
│     Canonical Sources (Salsa Debian GitLab)             │
│  salsa.debian.org/mendezr/stremio                       │
│  salsa.debian.org/mendezr/stremio-server                │
│  salsa.debian.org/mendezr/stremio-gtk                   │
│  salsa.debian.org/mendezr/chromium-embedded-framework   │
└────────────────────┬────────────────────────────────────┘
                     │ Auto-Sync
                     ▼
┌─────────────────────────────────────────────────────────┐
│          GitHub Repository (Build System)               │
│      github.com/vejeta/stremio-debian                   │
│                                                         │
│  • GitHub Actions workflows                             │
│  • Automated package builds                             │
│  • GPG signing                                          │
│  • APT repository generation                            │
└────────────────────┬────────────────────────────────────┘
                     │
       ┌─────────────┴─────────────┐
       ▼                           ▼
┌──────────────┐          ┌────────────────┐
│GitHub Releases│         │ GitHub Pages   │
│              │          │                │
│ .deb files   │          │ APT Repository │
│ Download stats│         │ debian.vejeta  │
└──────────────┘          │     .com       │
                          └────────────────┘
```

---

## Build Status

| Component | License | Distribution | Architecture | Status |
|-----------|---------|--------------|--------------|--------|
| stremio-gtk | GPL-3.0-only | sid | amd64 | Active |
| stremio (Qt5) | GPL-3.0+ | all | amd64, arm64 | Legacy |
| stremio-server | Proprietary | all | all | Active |
| libcef144 | BSD | sid | amd64 | Active |
| cef-resources | BSD | sid | all | Active |

---

## For Developers

### Building Locally

```bash
# Clone repository
git clone --recursive https://github.com/vejeta/stremio-debian.git
cd stremio-debian

# Build stremio-gtk (requires Debian sid + CEF packages)
cd stremio-gtk
dpkg-buildpackage -us -uc

# Build Qt5 client
cd ../stremio-qt5
QT_DEFAULT_MAJOR_VERSION=5 dpkg-buildpackage -us -uc

# Build stremio-server
cd ../stremio-server
dpkg-buildpackage -us -uc
```

### Contributing

1. **Packaging Changes**: Submit to Salsa repositories
   - [stremio-gtk](https://salsa.debian.org/mendezr/stremio-gtk)
   - [stremio](https://salsa.debian.org/mendezr/stremio)
   - [stremio-server](https://salsa.debian.org/mendezr/stremio-server)
   - [chromium-embedded-framework](https://salsa.debian.org/mendezr/chromium-embedded-framework)

2. **Build System**: Submit to [GitHub repository](https://github.com/vejeta/stremio-debian)

3. **Issues**: Report at [GitHub Issues](https://github.com/vejeta/stremio-debian/issues)

---

## Support

- **Installation Issues**: Check [debian.vejeta.com](https://debian.vejeta.com)
- **Build Issues**: See [GitHub Actions logs](https://github.com/vejeta/stremio-debian/actions)
- **Bug Reports**: [GitHub Issues](https://github.com/vejeta/stremio-debian/issues)

### Community

- **Upstream**: [Stremio](https://www.stremio.com/)
- **Debian Salsa**: [mendezr](https://salsa.debian.org/mendezr)
- **GitHub**: [vejeta](https://github.com/vejeta)

---

## Acknowledgments

- **Stremio Team**: For creating Stremio and developing stremio-linux-shell (stremio-gtk)
- **Debian Community**: For packaging standards and infrastructure
- **GitHub**: For free hosting, CI/CD, and unlimited bandwidth
- **CEF Project**: For Chromium Embedded Framework

---

*Last updated: 2026-01-25*
