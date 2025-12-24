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
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL%203.0-green.svg)](https://www.gnu.org/licenses/gpl-3.0)

Modern Debian packaging for the complete **Stremio** media center ecosystem, resolving compatibility issues with current Debian/Ubuntu distributions.

**Hosted on GitHub Pages** • **Zero server costs** • **Unlimited bandwidth** • **Automatic builds** • **ARM64 support for Raspberry Pi**

---

## 🚀 Quick Installation

### Add Repository (Recommended)

```bash
# Add GPG key
wget -qO - https://debian.vejeta.com/key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/stremio-debian.gpg

# Add repository for your Debian version:

# For Debian testing (rolling) - Use if you have both trixie + testing sources
echo "deb [signed-by=/usr/share/keyrings/stremio-debian.gpg] https://debian.vejeta.com testing main non-free" | sudo tee /etc/apt/sources.list.d/stremio.list

# OR for Debian 13 (trixie - current stable) - Use if you ONLY have trixie sources
echo "deb [signed-by=/usr/share/keyrings/stremio-debian.gpg] https://debian.vejeta.com trixie main non-free" | sudo tee /etc/apt/sources.list.d/stremio.list

# OR for Debian 12 (bookworm - previous stable)
echo "deb [signed-by=/usr/share/keyrings/stremio-debian.gpg] https://debian.vejeta.com bookworm main non-free" | sudo tee /etc/apt/sources.list.d/stremio.list

# OR for Debian sid (unstable) / Kali Rolling
echo "deb [signed-by=/usr/share/keyrings/stremio-debian.gpg] https://debian.vejeta.com sid main non-free" | sudo tee /etc/apt/sources.list.d/stremio.list

# Install complete Stremio
sudo apt update
sudo apt install stremio stremio-server
```

**Supported Distributions:**
- Debian testing - Rolling distribution (use if you have both trixie + testing sources)
- Debian 13 (trixie) - Current stable (use if you only have trixie sources)
- Debian 12 (bookworm) - Previous stable
- Debian sid (unstable) - Rolling release (compatible with Kali Linux)

### Manual Installation

Download `.deb` files from [GitHub Releases](https://github.com/vejeta/stremio-debian/releases/latest):

```bash
# Download latest .deb files
wget https://github.com/vejeta/stremio-debian/releases/latest/download/stremio_4.4.169+dfsg-1_amd64-trixie.deb
wget https://github.com/vejeta/stremio-debian/releases/latest/download/stremio-server_4.20.12-1_all-trixie.deb

# Install
sudo dpkg -i stremio_*.deb stremio-server_*.deb
sudo apt install -f  # Fix dependencies if needed
```

---

## 📦 Package Components

This repository provides two complementary packages following Debian's architecture:

### `stremio` (main/free)
- **License**: GPL-3.0-or-later
- **Architecture**: amd64, arm64 (Raspberry Pi compatible)
- **Upstream**: [github.com/Stremio/stremio-shell](https://github.com/Stremio/stremio-shell)
- **Packaging**: [salsa.debian.org/mendezr/stremio](https://salsa.debian.org/mendezr/stremio)
- **Contents**: Desktop client (C++/Qt5/QML)
- **Capabilities**:
  - Local media playback (MPV integration)
  - HTTP streaming
  - Add-on ecosystem
  - System tray integration
  - Single-instance application

### `stremio-server` (non-free)
- **License**: Proprietary
- **Architecture**: all (Node.js)
- **Version**: 4.20.12-1 (independent versioning from client)
- **Upstream**: [dl.strem.io/server](https://dl.strem.io/server/)
- **Packaging**: [salsa.debian.org/mendezr/stremio-server](https://salsa.debian.org/mendezr/stremio-server)
- **Contents**: BitTorrent streaming server (server.js v4.20.12)
- **Capabilities**:
  - Direct torrent streaming
  - HLS transcoding
  - Casting support
  - Enhanced streaming performance

---

## ✨ Key Improvements Over Upstream

### Packaging Standards
- ✅ **FHS Compliance**: Proper `/usr` installation (not `/opt`)
- ✅ **System Libraries**: 100% Debian system libraries (zero bundled dependencies)
- ✅ **License Separation**: GPL client (main) + proprietary server (non-free)
- ✅ **Policy Compliance**: Lintian-clean packaging for both components

### Technical Achievements
- ✅ **Qt5/QML Stability**: Fixed QtWebEngine initialization crashes
- ✅ **Single-Instance**: Custom thread-safe implementation
- ✅ **Streaming Server**: Resolved QProcess environment variable issues
- ✅ **Binary Size**: 293KB optimized binary (vs 424KB debug)

### Infrastructure
- ✅ **Automated CI/CD**: GitHub Actions pipeline for both packages
- ✅ **Multi-Distribution Builds**: Separate builds for trixie, bookworm, and sid
- ✅ **Multi-Architecture Support**: Native amd64 and arm64 (Raspberry Pi) packages
- ✅ **GitHub Pages APT**: Professional repository with GPG signing
- ✅ **Zero Hosting Costs**: Unlimited bandwidth via GitHub infrastructure
- ✅ **Download Statistics**: Built-in analytics via GitHub Releases
- ✅ **Dependency Compatibility**: Each distribution gets packages with correct dependencies

---

## 📦 Release Strategy

This repository uses **separate releases** for different package groups:

| Release Tag | Packages | Trigger |
|-------------|----------|---------|
| `v*` (e.g., v5.0.0) | stremio, stremio-server | Tag push |
| `cef-*` (e.g., cef-138.0.1) | libcef138, cef-resources, libcef-dev | Manual |

**Why separate?** Each package group has different version schemes, build times, and release cadences. CEF follows Chromium versions and takes hours to build, while stremio follows its own versioning and builds in minutes.

**For users**: The APT repository at `debian.vejeta.com` combines all packages automatically. Just `apt install` what you need - no need to track individual releases.

---

## 🏗️ Repository Architecture

```
┌─────────────────────────────────────────────────────────┐
│     Canonical Sources (Salsa Debian GitLab)             │
│  salsa.debian.org/mendezr/stremio                       │
│  salsa.debian.org/mendezr/stremio-server                │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ Daily Auto-Sync
                     ▼
┌─────────────────────────────────────────────────────────┐
│          GitHub Repository (Build System)               │
│      github.com/vejeta/stremio-debian                   │
│                                                          │
│  • GitHub Actions workflows                             │
│  • Automated package builds                             │
│  • GPG signing                                          │
│  • APT repository generation                            │
└────────────────────┬────────────────────────────────────┘
                     │
       ┌─────────────┴─────────────┐
       │                           │
       ▼                           ▼
┌──────────────┐          ┌────────────────┐
│GitHub Releases│         │ GitHub Pages   │
│              │          │                │
│ .deb files   │          │ APT Repository │
│ Source files │          │ debian.vejeta  │
│ Download stats│         │     .com       │
└──────────────┘          └────────────────┘
```

**Key Points**:
- **Salsa**: Canonical source, maintained for Debian submission
- **GitHub**: CI/CD automation and distribution
- **Sync**: Instant webhooks from Salsa + weekly fallback cron
- **Releases**: Immutable package artifacts with download tracking
- **Pages**: APT repository metadata and package hosting
- **Multi-Distro**: Supports testing (rolling), trixie (Debian 13), bookworm (Debian 12), and sid (unstable/Kali)

---

## 🏗️ Multi-Distribution Build Strategy

This repository implements **true multi-distribution support** by building packages separately for each Debian release:

### Why Separate Builds?

When building Debian packages, `dpkg-shlibdeps` analyzes linked libraries and generates dependencies based on the **build environment**. A package built on Debian 12 (bookworm) will have bookworm-specific dependencies that may not exist in Debian sid or Kali Rolling.

**Problem Example**:
```
# Package built on bookworm requires:
Depends: qtdeclarative-abi-5-15-8

# But sid/Kali have:
qtdeclarative-abi-5-15-10
```

### Solution: Matrix Builds

GitHub Actions matrix strategy builds packages in separate containers:

- **`debian:testing`** → Packages with testing dependencies (Qt 5.15.17) → `dists/testing/`
- **`debian:trixie`** → Packages with trixie dependencies (Qt 5.15.15) → `dists/trixie/`
- **`debian:bookworm`** → Packages with bookworm dependencies → `dists/bookworm/`
- **`debian:sid`** → Packages with sid dependencies → `dists/sid/`

Each distribution gets **native packages** with correct dependencies for that release.

**Important**: Use `testing` packages if you have both trixie and testing sources configured (check `/etc/apt/sources.list` and `/etc/apt/sources.list.d/`). Use `trixie` packages if you only have trixie sources.

### Package Naming

To avoid conflicts, `.deb` files are renamed with distribution suffixes during build:
- `stremio_4.4.169+dfsg-1_amd64-testing.deb`
- `stremio_4.4.169+dfsg-1_amd64-trixie.deb`
- `stremio_4.4.169+dfsg-1_amd64-bookworm.deb`
- `stremio_4.4.169+dfsg-1_amd64-sid.deb`

The APT repository deployment process removes these suffixes and places packages in the correct distribution directories.

---

## 🔄 Update Strategy

### Automatic Updates

The repository uses **instant webhooks** from Salsa for real-time updates:

1. **Webhook Trigger**: Push to Salsa → instant GitHub Actions trigger
2. **Auto-Sync**: Changes synced immediately (seconds, not hours)
3. **Auto-Build**: Packages built automatically on sync
4. **Auto-Deploy**: APT repository updated with new packages
5. **Weekly Fallback**: Sunday 02:00 UTC cron catches any missed updates

This provides **near-instant updates** instead of waiting 24 hours.

Monitor: [GitHub Actions](https://github.com/vejeta/stremio-debian/actions)

### Manual Updates

For immediate updates:

```bash
# Trigger sync workflow manually
gh workflow run sync-from-salsa.yml

# Or create release tag
git tag -a v4.4.170-1 -m "Release 4.4.170-1"
git push origin v4.4.170-1
```

---

## 🛠️ For Developers

### Building Locally

```bash
# Clone repository
git clone --recursive https://github.com/vejeta/stremio-debian.git
cd stremio-debian

# Build stremio client (Qt5)
cd stremio-qt5
QT_DEFAULT_MAJOR_VERSION=5 dpkg-buildpackage -us -uc

# Build stremio-server
cd ../stremio-server
dpkg-buildpackage -us -uc
```

### Contributing

1. **Upstream Changes**: Submit to canonical Salsa repositories
   - [stremio](https://salsa.debian.org/mendezr/stremio)
   - [stremio-server](https://salsa.debian.org/mendezr/stremio-server)

2. **Build System**: Submit to GitHub repository
   - [stremio-debian](https://github.com/vejeta/stremio-debian)

3. **Issues**: Report at [GitHub Issues](https://github.com/vejeta/stremio-debian/issues)

### Setup Your Own Repository

Want to replicate this infrastructure for your packages? Check the workflows in `.github/workflows/` as templates.

**Features you'll get**:
- ✅ Automated package builds
- ✅ GitHub Pages APT repository
- ✅ GPG signing
- ✅ Zero hosting costs
- ✅ Unlimited bandwidth
- ✅ Download statistics

---

## 📊 Status

### Build Status

| Component | Build | Lintian | Version | License |
|-----------|-------|---------|---------|---------|
| stremio | ![Build](https://img.shields.io/badge/build-passing-success) | ![Lintian](https://img.shields.io/badge/lintian-clean-success) | 4.4.169+dfsg-1 | GPL-3.0+ |
| stremio-server | ![Build](https://img.shields.io/badge/build-passing-success) | ![Lintian](https://img.shields.io/badge/lintian-clean-success) | 4.20.12-1 | Proprietary |

### Repository Health

- ✅ **Builds**: Automated via GitHub Actions
- ✅ **Repository**: Deployed at [debian.vejeta.com](https://debian.vejeta.com)
- ✅ **GPG Signing**: All releases cryptographically signed
- ✅ **Sync**: Daily automatic sync from Salsa
- ✅ **Testing**: Packages installable on Debian bookworm

---

## 🤝 Debian Submission Status

Both packages are **prepared for submission** to the official Debian archive:

**ITP (Intent To Package)**: [Bug #943703](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=943703)

### Submission Plan

- **stremio** (main):
  - Target: Debian `main` archive
  - License: GPL-3.0-or-later (DFSG-compliant)
  - Status: ITP filed (#943703)
  - Blocker: Awaiting sponsorship

- **stremio-server** (non-free):
  - Target: Debian `non-free` archive
  - License: Proprietary
  - Status: ITP filed (#943703)
  - Blocker: Awaiting sponsorship

### Progress Tracker

- [x] Source packages created following Debian Policy
- [x] Lintian-clean packaging
- [x] 100% system libraries (no bundled dependencies)
- [x] FHS compliance
- [x] Copyright file with complete licensing info
- [x] Watch files for upstream monitoring
- [x] git-buildpackage workflow
- [x] Packages hosted on Salsa GitLab
- [x] ITP bug filed (#943703)
- [ ] Sponsorship obtained
- [ ] Upload to Debian NEW queue

**Timeline**: Submission planned for Q1 2025

---

## 📄 License Transparency

This project demonstrates proper license separation as practiced in Debian:

### Free Software (main)
- **stremio client**: GPL-3.0-or-later
- **Compatible with Debian Free Software Guidelines (DFSG)**
- Suitable for Debian `main` archive

### Proprietary Software (non-free)
- **stremio-server**: Proprietary license (Node.js server component)
- BitTorrent streaming functionality
- Suitable for Debian `non-free` archive

### User Choice

Users can choose their level of functionality:
- **Basic**: Install only `stremio` (free, GPL)
- **Full**: Install both `stremio` + `stremio-server` (adds BitTorrent)

---

## 🆘 Support

### Getting Help

- **Installation Issues**: Check [debian.vejeta.com](https://debian.vejeta.com) for latest instructions
- **Build Issues**: See [GitHub Actions logs](https://github.com/vejeta/stremio-debian/actions)
- **Bug Reports**: [GitHub Issues](https://github.com/vejeta/stremio-debian/issues)
- **Package Issues**: Submit to upstream Salsa repositories

### Community

- **Upstream Project**: [Stremio](https://www.stremio.com/)
- **Debian Salsa**: [mendezr](https://salsa.debian.org/mendezr)
- **GitHub**: [vejeta](https://github.com/vejeta)

---

## 🎯 Project Goals

1. ✅ **Replace ALL bundled dependencies** with Debian system libraries
2. ✅ **Achieve highest Debian packaging standards** (lintian-clean)
3. ✅ **Enable submission to official Debian archive**
4. ✅ **Provide reliable distribution infrastructure** (GitHub Pages)
5. ⏳ **Obtain Debian Package Maintainer status**

---

## 🙏 Acknowledgments

- **Stremio Team**: For creating an excellent media center
- **Debian Community**: For packaging standards and infrastructure
- **GitHub**: For free hosting, CI/CD, and unlimited bandwidth
- **Qt Project**: For excellent cross-platform framework

---

## 📈 Statistics

- **Repository Size**: ~21 MB per release
- **Download Bandwidth**: Unlimited (GitHub Pages CDN)
- **Build Time**: ~10 minutes per release
- **Hosting Cost**: $0/month
- **Uptime**: 99.9%+ (GitHub SLA)

---

**Part of ongoing contribution to become a Debian Package Maintainer**

*Last updated: 2025-10-30*
