#!/bin/bash
# Generate APT repository structure and metadata
# Usage: ./generate-apt-repo.sh <packages-dir> <output-dir> <suite> <component>

set -euo pipefail

PACKAGES_DIR="${1:-./packages}"
OUTPUT_DIR="${2:-./debian-repo}"
SUITE="${3:-bookworm}"
COMPONENT="${4:-main}"
ARCH="amd64"

echo "=== Generating APT Repository ==="
echo "Packages directory: $PACKAGES_DIR"
echo "Output directory: $OUTPUT_DIR"
echo "Suite: $SUITE"
echo "Component: $COMPONENT"
echo "Architecture: $ARCH"

# Create directory structure
mkdir -p "$OUTPUT_DIR/dists/$SUITE/$COMPONENT/binary-$ARCH"
mkdir -p "$OUTPUT_DIR/pool/$COMPONENT"

# Copy .deb files to pool
echo "=== Copying packages to pool ==="
if [ -d "$PACKAGES_DIR" ]; then
    find "$PACKAGES_DIR" -name "*.deb" -type f -exec cp -v {} "$OUTPUT_DIR/pool/$COMPONENT/" \;
else
    echo "Warning: Packages directory not found: $PACKAGES_DIR"
fi

# Generate Packages file
echo "=== Generating Packages file ==="
cd "$OUTPUT_DIR"

# Use dpkg-scanpackages to generate package index
if command -v dpkg-scanpackages &> /dev/null; then
    dpkg-scanpackages --multiversion "pool/$COMPONENT" /dev/null > "dists/$SUITE/$COMPONENT/binary-$ARCH/Packages"
else
    echo "Error: dpkg-scanpackages not found"
    exit 1
fi

# Compress Packages file
gzip -9c "dists/$SUITE/$COMPONENT/binary-$ARCH/Packages" > "dists/$SUITE/$COMPONENT/binary-$ARCH/Packages.gz"
bzip2 -9c "dists/$SUITE/$COMPONENT/binary-$ARCH/Packages" > "dists/$SUITE/$COMPONENT/binary-$ARCH/Packages.bz2"

echo "=== Generated Packages files ==="
ls -lh "dists/$SUITE/$COMPONENT/binary-$ARCH/"

# Generate Release file
echo "=== Generating Release file ==="
cat > "dists/$SUITE/Release" << EOF
Origin: Stremio Debian Repository
Label: Stremio
Suite: $SUITE
Codename: $SUITE
Components: main non-free
Architectures: $ARCH
Description: Unofficial Debian packages for Stremio media center
Date: $(date -R -u)
EOF

# Calculate and append file checksums to Release
echo "MD5Sum:" >> "dists/$SUITE/Release"
find "dists/$SUITE" -type f ! -name "Release*" | while read file; do
    relative_path="${file#dists/$SUITE/}"
    md5=$(md5sum "$file" | awk '{print $1}')
    size=$(stat -c%s "$file")
    printf " %s %8d %s\n" "$md5" "$size" "$relative_path" >> "dists/$SUITE/Release"
done

echo "SHA1:" >> "dists/$SUITE/Release"
find "dists/$SUITE" -type f ! -name "Release*" | while read file; do
    relative_path="${file#dists/$SUITE/}"
    sha1=$(sha1sum "$file" | awk '{print $1}')
    size=$(stat -c%s "$file")
    printf " %s %8d %s\n" "$sha1" "$size" "$relative_path" >> "dists/$SUITE/Release"
done

echo "SHA256:" >> "dists/$SUITE/Release"
find "dists/$SUITE" -type f ! -name "Release*" | while read file; do
    relative_path="${file#dists/$SUITE/}"
    sha256=$(sha256sum "$file" | awk '{print $1}')
    size=$(stat -c%s "$file")
    printf " %s %8d %s\n" "$sha256" "$size" "$relative_path" >> "dists/$SUITE/Release"
done

echo "=== Release file generated ==="
cat "dists/$SUITE/Release"

cd - > /dev/null

echo ""
echo "=== Repository structure created successfully ==="
tree -L 4 "$OUTPUT_DIR" || find "$OUTPUT_DIR" -type f
