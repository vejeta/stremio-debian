# Stremio Debian Packages

[![CI](https://github.com/vejeta/stremio-debian/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/vejeta/stremio-debian/actions/workflows/ci.yml)
[![Release](https://github.com/vejeta/stremio-debian/actions/workflows/build-and-release.yml/badge.svg?event=push)](https://github.com/vejeta/stremio-debian/actions/workflows/build-and-release.yml)
[![Repository](https://img.shields.io/badge/APT-debian.vejeta.com-blue)](https://debian.vejeta.com)
[![Chromium](https://img.shields.io/endpoint?url=https%3A%2F%2Fdebian.vejeta.com%2Fversion.json)](https://security-tracker.debian.org/tracker/source-package/chromium)
![GitHub release](https://img.shields.io/github/v/release/vejeta/stremio-debian)
![GitHub Downloads](https://img.shields.io/github/downloads/vejeta/stremio-debian/total)
![Repository Status](https://img.shields.io/website?down_message=offline&label=APT%20repository&up_message=online&url=https%3A%2F%2Fdebian.vejeta.com)
![GitHub issues](https://img.shields.io/github/issues/vejeta/stremio-debian)
![Platform](https://img.shields.io/badge/platform-Debian%20%7C%20Ubuntu-blue)
![Architecture](https://img.shields.io/badge/arch-amd64%20%7C%20arm64-green)
![License](https://img.shields.io/github/license/vejeta/stremio-debian)

Debian packaging for **Stremio** client and engine variants that aren't (yet, or ever) in Debian's own archive.

**Hosted on GitHub Pages** | **Zero server costs** | **Automatic builds** | **ARM64 support for Raspberry Pi**

---

## Stremio is now part of Debian

Debian's own `stremio` (the GTK4/libadwaita/WebKitGTK6 client) was
[accepted into Debian unstable](https://tracker.debian.org/pkg/stremio) on 2026-09-24.
**It is the recommended client.** The Qt5 and CEF clients this repository used to ship are kept
here, renamed `stremio-qt5` and `stremio-cef`, **for archival purposes only**: use one of them only
if you find it performs better on your system than Debian's official `stremio`.

| Client | Status | Notes |
|--------|--------|-------|
| **stremio** (Debian) | Official | From Debian's own archive (unstable), not from this repository |
| **stremio-cef** (GTK4/CEF, was stremio-gtk) | Archival | Use only if it performs better for you than Debian's `stremio` (Debian sid only) |
| **stremio-qt5** (Qt5, was stremio) | Archival | Use only if it performs better for you than Debian's `stremio` |
| **stremio-qt6** | Experimental | Work in progress, not recommended |

---

## Option A: Debian's official `stremio` (recommended)

On **Debian unstable (sid)** with the `contrib` component enabled (for `stremio-server-installer`,
which sets up the streaming server). This repository is not needed:

```bash
sudo apt update
sudo apt install stremio stremio-server-installer
```

On trixie, bookworm or Ubuntu, Debian's `stremio` is not in your release yet: wait for it, or use
option B in the meantime (don't mix unstable packages into a stable system).

### Already using this repository?

1. **Upgrade** (any release). Moves `stremio` to `stremio-qt5` and `stremio-gtk` to `stremio-cef`;
   the old names stay as empty transitional packages. It has to be `full-upgrade` (plain `upgrade`
   keeps them back):
   ```bash
   sudo apt update && sudo apt full-upgrade
   ```
2. **Switch to Debian's `stremio`** (sid). Pin this repository first (see option B, step 3):
   without the pin, the next `full-upgrade` takes you back to this repository's transitional
   `stremio`, whose version number is higher. apt asks you to confirm a downgrade (from the 4.4.181
   transitional package to Debian's 1.2.0), which is expected:
   ```bash
   sudo apt update
   sudo apt install stremio/unstable
   sudo apt-mark manual stremio
   ```
3. **Keep or drop the archived clients.** To keep one, mark it manually installed *before*
   cleaning up, or `autoremove` may take it:
   ```bash
   sudo apt-mark manual stremio-qt5    # and/or stremio-cef
   sudo apt autoremove
   ```
   To drop them: `sudo apt remove stremio-qt5 stremio-cef && sudo apt autoremove`.

More detail, including how to leave this repository entirely, on
[debian.vejeta.com](https://debian.vejeta.com/#migrate).

**stremio-server is deprecated.** Debian's `stremio-server-installer` (contrib) does the same job.
It is unstable-only for now, so this repository keeps publishing `stremio-server` for
trixie/bookworm until Debian's version reaches those releases.

---

## Option B: this repository (archived clients)

Only if `stremio-qt5` or `stremio-cef` performs better on your system than Debian's `stremio`.

```bash
# 1. Add the GPG key
wget -qO - https://debian.vejeta.com/key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/stremio-debian.gpg

# 2. Add the repository (choose your distribution: sid, testing, trixie, bookworm, noble)
echo "deb [signed-by=/usr/share/keyrings/stremio-debian.gpg] https://debian.vejeta.com sid main non-free" | sudo tee /etc/apt/sources.list.d/stremio.list

# 3. Pin it below Debian, so Debian's own packages always win where both provide one
printf 'Package: *\nPin: origin debian.vejeta.com\nPin-Priority: 100\n' | sudo tee /etc/apt/preferences.d/debian-vejeta-com.pref

# 4. Install
sudo apt update
sudo apt install stremio-qt5    # Qt5 client, any release
sudo apt install stremio-cef    # CEF client, Debian sid only
```

**Supported Distributions:**
- Debian sid (unstable) - **stremio-cef** + stremio-qt5 + Qt6 client (experimental)
- Debian 13 (trixie) - stremio-qt5 + Qt6 client (experimental)
- Debian testing - stremio-qt5 only
- Debian 12 (bookworm) - stremio-qt5 only
- Ubuntu 25.04 (plucky) - Qt6 client (experimental)

---

## Package Components

### stremio-cef (main) - Debian sid only

| Property | Value |
|----------|-------|
| **License** | GPL-3.0-only |
| **Architecture** | amd64 |
| **Distribution** | Debian sid only |
| **Upstream** | [github.com/Stremio/stremio-linux-shell](https://github.com/Stremio/stremio-linux-shell) |
| **Packaging** | [salsa.debian.org/mendezr/stremio-cef](https://salsa.debian.org/mendezr/stremio-cef) |

Renamed from `stremio-gtk` on 2026-09-24 once Debian's own `stremio` became a GTK4 client too,
making the old "-gtk" suffix meaningless (the real difference is the renderer: CEF here, WebKitGTK6
in Debian's own package).

**Status: archival.** Debian's own `stremio` is the recommended client. Use stremio-cef only if
you find it performs better on your system than Debian's `stremio` (for example, where the CEF
renderer runs better on your hardware than WebKitGTK6).

**Dependencies** (installed automatically):
- `libcef<N>` - CEF runtime library
- `libcef-common` - CEF locales and resources
- `librust-cef-dev` - Rust CEF bindings
- `librust-cef-dll-sys-dev` - Rust CEF FFI bindings
- `stremio-server-installer` (Recommends; from Debian) or this repo's deprecated `stremio-server`

### brow6el (main) - Debian sid only

| Property | Value |
|----------|-------|
| **License** | MIT |
| **Architecture** | amd64 |
| **Distribution** | Debian sid only |
| **Upstream** | [codeberg.org/janantos/brow6el](https://codeberg.org/janantos/brow6el) |
| **Packaging** | [salsa.debian.org/mendezr/brow6el](https://salsa.debian.org/mendezr/brow6el) |

A full-featured terminal web browser built on CEF. Renders web pages as graphics directly in the terminal using Sixel or Kitty image protocols. Features a vim-inspired modal interface with bookmarks, user scripts, DNS-over-HTTPS, and proxy support.

**Dependencies** (installed automatically):
- `libcef<N>` - CEF runtime library
- `libcef-common` - CEF locales and resources

### Rust CEF Bindings (main) - Debian sid only

| Package | Description | License |
|---------|-------------|---------|
| **librust-cef-dll-sys-dev** | Rust FFI bindings to CEF | Apache-2.0 OR MIT |
| **librust-cef-dev** | Rust high-level bindings to CEF | Apache-2.0 OR MIT |

These are build and runtime dependencies for stremio-cef. They are built from the [cef-rs](https://github.com/tauri-apps/cef-rs) crates using [debcargo](https://packages.debian.org/debcargo) with Debian-specific patches to link against system CEF from `libcef-dev`.

- **rust-cef-dll-sys**: [ITP #1128612](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1128612) | [Salsa](https://salsa.debian.org/mendezr/rust-cef-dll-sys)
- **rust-cef**: [ITP #1128610](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1128610) | [Salsa](https://salsa.debian.org/mendezr/rust-cef)

### stremio-qt6 (main) - Experimental Qt6 Client

| Property | Value |
|----------|-------|
| **License** | GPL-3.0-or-later |
| **Architecture** | amd64, arm64 |
| **Distribution** | Debian trixie, sid; Ubuntu plucky (25.04) |
| **Status** | **Experimental** |
| **Upstream** | [github.com/vejeta/stremio-shell (qt6-migration)](https://github.com/vejeta/stremio-shell/tree/qt6-migration) |
| **Packaging** | [salsa.debian.org/mendezr/stremio-qt6](https://salsa.debian.org/mendezr/stremio-qt6) |

**Note**: This is an experimental Qt6 port intended as a workaround for users who prefer KDE/Plasma or Qt-based desktop environments and want a non-deprecated Qt client. Not recommended yet &mdash; prefer Debian's own `stremio`, or `stremio-cef`/`stremio-qt5` from this repo. On sid and Ubuntu, the Qt6 version supersedes stremio-qt5 due to its higher version number.

### stremio-qt5 (main) - Qt5 Client (archival)

| Property | Value |
|----------|-------|
| **License** | GPL-3.0-or-later |
| **Architecture** | amd64, arm64 |
| **Distribution** | All (bookworm, trixie, testing, sid) |
| **Status** | **Archival** |
| **Upstream** | [github.com/Stremio/stremio-shell](https://github.com/Stremio/stremio-shell) |
| **Packaging** | [salsa.debian.org/mendezr/stremio-qt5](https://salsa.debian.org/mendezr/stremio-qt5) |

Renamed from `stremio` on 2026-09-24, since Debian's own `stremio` package now uses that name for
the WebKitGTK6 rewrite. Kept for archival purposes: use it only if you find it performs better on
your system than Debian's official `stremio`.

### stremio-server (non-free) - **Deprecated**

| Property | Value |
|----------|-------|
| **License** | Proprietary |
| **Architecture** | all (Node.js) |
| **Distribution** | trixie, bookworm (kept until Debian's replacement reaches those suites) |
| **Upstream** | [dl.strem.io/server](https://dl.strem.io/server/) |
| **Packaging** | [salsa.debian.org/mendezr/stremio-server](https://salsa.debian.org/mendezr/stremio-server) |

Downloads and installs Stremio's streaming server (BitTorrent, HLS transcoding, casting). Debian's
own [`stremio-server-installer`](https://tracker.debian.org/pkg/stremio-server-installer) (contrib)
now does the same job the official way; as of this writing it's only in `unstable`, so we keep
publishing ours for trixie/bookworm in the meantime. Prefer Debian's on sid.

### CEF Packages (main) - Debian sid only

| Package | Description |
|---------|-------------|
| **libcef\<N\>** | CEF runtime library (soname-versioned; `<N>` is the current Chromium major) |
| **libcef-dev** | Development headers |
| **libcef-common** | Locales, PAK files, runtime resources |

CEF packages are required by stremio-cef and brow6el, and are installed automatically as dependencies. They are built from Debian's [`chromium` packaging (`cef` branch)](https://salsa.debian.org/mendezr/chromium/-/tree/cef), so they track the latest Chromium and inherit its [security fixes](https://security-tracker.debian.org/tracker/source-package/chromium). The current version is shown by the **chromium (cef)** badge at the top of this README.

---

## Release Strategy

This repository uses **separate releases** for different package groups:

| Release Tag | Packages | Distribution |
|-------------|----------|--------------|
| `v*` (e.g., v5.0.0) | stremio-qt5 (+ `stremio` transitional), stremio-server | All |
| `stremio-cef-*` (e.g., stremio-cef-1.0.0-beta.13.ds-8) | stremio-cef (+ `stremio-gtk` transitional), stremio-server, librust-cef-dev, librust-cef-dll-sys-dev | sid only |
| `cef-*` (e.g., cef-151.0.7922.71) | libcef\<N\>, libcef-common, libcef-dev | sid only |
| `brow6el-*` (e.g., brow6el-0.3.4-1) | brow6el | sid only |

**For users**: The APT repository at `debian.vejeta.com` combines all packages automatically. Just `apt install` what you need.

---

## Debian Submission Status

### stremio - **Accepted** (not this repo's build)

**ITP**: [Bug #943703](https://bugs.debian.org/943703) &mdash; accepted 2026-09-24 as the
GTK4/libadwaita/WebKitGTK6 rewrite, version 1.2.0+ds-1. Installed directly from Debian's own
archive; this repository does not build or publish it.

### stremio-cef - **Not headed for Debian (archival)**

**ITP**: [Bug #1119815](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1119815) (filed for stremio-gtk), closed

Upstream replaced CEF with WebKitGTK 6, and that version is what entered Debian as `stremio`.
stremio-cef (upstream's last CEF release, 1.0.0-beta.13) stays in this repository for archival
purposes only.

### Chromium Embedded Framework (CEF) - **Active ITP**

**ITP**: [Bug #915400](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=915400)

- **Target**: Debian `main` archive
- **License**: BSD-style (DFSG-compliant)
- **Status**: Built as a build profile of the [Debian Chromium package](https://salsa.debian.org/mendezr/chromium) (cef branch)

### brow6el - **Active ITP**

**ITP**: [Bug #1135705](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1135705)

- **Target**: Debian `main` archive
- **License**: MIT (DFSG-compliant)
- **Status**: Packaging complete, seeking sponsorship
- **Dependencies**: Requires CEF packages

### stremio-qt5 - **Superseded, not seeking sponsorship**

Previously filed as [Bug #943703](https://bugs.debian.org/943703) under the name `stremio`; that
ITP is now closed, fulfilled by Debian's own WebKitGTK6-based `stremio` rather than this Qt5
codebase. stremio-qt5 is kept published here for users who want it, but isn't itself headed for the
Debian archive.

---

## Repository Architecture

```
┌─────────────────────────────────────────────────────────┐
│     Canonical Sources (Salsa Debian GitLab)             │
│  salsa.debian.org/mendezr/stremio-qt5                   │
│  salsa.debian.org/mendezr/stremio-qt6                   │
│  salsa.debian.org/mendezr/stremio-server                │
│  salsa.debian.org/mendezr/stremio-cef                   │
│  salsa.debian.org/mendezr/chromium (cef branch)         │
│  salsa.debian.org/mendezr/rust-cef-dll-sys              │
│  salsa.debian.org/mendezr/rust-cef                       │
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
| stremio-cef | GPL-3.0-only | sid | amd64 | Archival |
| stremio-qt6 | GPL-3.0+ | trixie, sid, plucky | amd64, arm64 | Experimental |
| stremio-qt5 | GPL-3.0+ | all | amd64, arm64 | Archival |
| stremio-server | Proprietary | trixie, bookworm | all | Deprecated |
| libcef\<N\> | BSD-3-Clause | sid | amd64 | Active |
| libcef-common | BSD-3-Clause | sid | all | Active |
| librust-cef-dll-sys-dev | Apache-2.0 OR MIT | sid | amd64 | Active |
| librust-cef-dev | Apache-2.0 OR MIT | sid | amd64 | Active |
| brow6el | MIT | sid | amd64 | Active |

---

## For Developers

### Building Locally

```bash
# Clone repository
git clone --recursive https://github.com/vejeta/stremio-debian.git
cd stremio-debian

# Build stremio-cef (requires Debian sid + CEF packages)
cd stremio-cef
dpkg-buildpackage -us -uc

# Build Qt6 client (requires Debian sid or Ubuntu noble)
cd ../stremio-qt6
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
   - [stremio-cef](https://salsa.debian.org/mendezr/stremio-cef)
   - [stremio-qt5](https://salsa.debian.org/mendezr/stremio-qt5)
   - [stremio-qt6](https://salsa.debian.org/mendezr/stremio-qt6)
   - [stremio-server](https://salsa.debian.org/mendezr/stremio-server)
   - [chromium (cef branch)](https://salsa.debian.org/mendezr/chromium/-/tree/cef) — CEF build profile
   - [rust-cef-dll-sys](https://salsa.debian.org/mendezr/rust-cef-dll-sys)
   - [rust-cef](https://salsa.debian.org/mendezr/rust-cef)
   - [brow6el](https://salsa.debian.org/mendezr/brow6el)

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

- **Stremio Team**: For creating Stremio and developing stremio-linux-shell (stremio-cef) and the official Debian `stremio` package
- **Debian Community**: For packaging standards and infrastructure
- **GitHub**: For free hosting, CI/CD, and unlimited bandwidth
- **CEF Project**: For Chromium Embedded Framework

---

*Last updated: 2026-09-24*
