#!/bin/bash
# Generate APT repository structure and metadata
# Usage: ./generate-apt-repo.sh <packages-dir> <output-dir> <suite> <component> [arch]

set -euo pipefail

PACKAGES_DIR="${1:-./packages}"
OUTPUT_DIR="${2:-./debian-repo}"
SUITE="${3:-bookworm}"
COMPONENT="${4:-main}"
ARCH="${5:-amd64}"

echo "=== Generating APT Repository ==="
echo "Packages directory: $PACKAGES_DIR"
echo "Output directory: $OUTPUT_DIR"
echo "Suite: $SUITE"
echo "Component: $COMPONENT"
echo "Architecture: $ARCH"

# Create directory structure with distribution-specific pool
mkdir -p "$OUTPUT_DIR/dists/$SUITE/$COMPONENT/binary-$ARCH"
mkdir -p "$OUTPUT_DIR/pool/$SUITE/$COMPONENT"

# Copy .deb files to distribution-specific pool
echo "=== Copying packages to pool/$SUITE/$COMPONENT ==="
if [ -d "$PACKAGES_DIR" ]; then
    find "$PACKAGES_DIR" -name "*.deb" -type f -exec cp -v {} "$OUTPUT_DIR/pool/$SUITE/$COMPONENT/" \;
else
    echo "Warning: Packages directory not found: $PACKAGES_DIR"
fi

# Generate Packages file
echo "=== Generating Packages file ==="
cd "$OUTPUT_DIR"

# Use dpkg-scanpackages to generate package index for this architecture
if command -v dpkg-scanpackages &> /dev/null; then
    # Only scan packages matching this architecture
    dpkg-scanpackages --arch "$ARCH" --multiversion "pool/$SUITE/$COMPONENT" /dev/null > "dists/$SUITE/$COMPONENT/binary-$ARCH/Packages"
else
    echo "Error: dpkg-scanpackages not found"
    exit 1
fi

# dpkg-scanpackages adds Architecture: all packages to every architecture's
# index. These ones only make sense where this repo builds stremio-cef and
# libcef, which is amd64 only: on arm64 the stremio-gtk transitional would be
# listed but never installable (its dependency stremio-cef is not built there).
AMD64_ONLY_ALL_PACKAGES="stremio-gtk libcef-common"
if [ "$ARCH" != "amd64" ]; then
    awk -v drop="$AMD64_ONLY_ALL_PACKAGES" '
        BEGIN { RS = ""; ORS = "\n\n"; n = split(drop, d, " "); for (i = 1; i <= n; i++) skip[d[i]] = 1 }
        { if (match($0, /(^|\n)Package: [^\n]+/)) { p = substr($0, RSTART, RLENGTH); sub(/.*Package: /, "", p) } else p = ""
          if (!(p in skip)) print }
    ' "dists/$SUITE/$COMPONENT/binary-$ARCH/Packages" > "dists/$SUITE/$COMPONENT/binary-$ARCH/Packages.tmp"
    mv "dists/$SUITE/$COMPONENT/binary-$ARCH/Packages.tmp" "dists/$SUITE/$COMPONENT/binary-$ARCH/Packages"
fi

# Compress Packages file
gzip -9c "dists/$SUITE/$COMPONENT/binary-$ARCH/Packages" > "dists/$SUITE/$COMPONENT/binary-$ARCH/Packages.gz"
bzip2 -9c "dists/$SUITE/$COMPONENT/binary-$ARCH/Packages" > "dists/$SUITE/$COMPONENT/binary-$ARCH/Packages.bz2"

echo "=== Generated Packages files for $ARCH ==="
ls -lh "dists/$SUITE/$COMPONENT/binary-$ARCH/"

# Note: Release file is generated later by deploy-repository.yml after all architectures are processed
# This prevents overwriting when processing multiple architectures

cd - > /dev/null

echo ""
echo "=== Repository structure created successfully ==="
tree -L 4 "$OUTPUT_DIR" || find "$OUTPUT_DIR" -type f
