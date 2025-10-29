#!/bin/bash
# Sign APT repository Release file with GPG
# Usage: ./sign-repository.sh <repo-dir> <suite> [gpg-key-id]

set -euo pipefail

REPO_DIR="${1:-./debian-repo}"
SUITE="${2:-bookworm}"
GPG_KEY_ID="${3:-}"

RELEASE_FILE="$REPO_DIR/dists/$SUITE/Release"
RELEASE_GPG="$REPO_DIR/dists/$SUITE/Release.gpg"
INRELEASE_FILE="$REPO_DIR/dists/$SUITE/InRelease"

echo "=== Signing APT Repository ==="
echo "Repository: $REPO_DIR"
echo "Suite: $SUITE"
echo "Release file: $RELEASE_FILE"

if [ ! -f "$RELEASE_FILE" ]; then
    echo "Error: Release file not found: $RELEASE_FILE"
    exit 1
fi

# Check if GPG key is available
if [ -n "$GPG_KEY_ID" ]; then
    GPG_OPTS="--default-key $GPG_KEY_ID"
else
    GPG_OPTS=""
fi

# Test GPG availability
if ! command -v gpg &> /dev/null; then
    echo "Error: gpg command not found"
    exit 1
fi

# List available keys
echo "=== Available GPG keys ==="
gpg --list-secret-keys --keyid-format=long || echo "No secret keys found"

# Sign Release file (detached signature)
echo "=== Creating Release.gpg (detached signature) ==="
gpg --batch --yes --armor --detach-sign $GPG_OPTS \
    --output "$RELEASE_GPG" "$RELEASE_FILE"

if [ -f "$RELEASE_GPG" ]; then
    echo "✓ Release.gpg created successfully"
    ls -lh "$RELEASE_GPG"
else
    echo "✗ Failed to create Release.gpg"
    exit 1
fi

# Sign Release file (clear-sign for InRelease)
echo "=== Creating InRelease (clear-signed) ==="
gpg --batch --yes --clearsign $GPG_OPTS \
    --output "$INRELEASE_FILE" "$RELEASE_FILE"

if [ -f "$INRELEASE_FILE" ]; then
    echo "✓ InRelease created successfully"
    ls -lh "$INRELEASE_FILE"
else
    echo "✗ Failed to create InRelease"
    exit 1
fi

# Verify signatures
echo "=== Verifying signatures ==="
echo "Verifying Release.gpg:"
gpg --verify "$RELEASE_GPG" "$RELEASE_FILE" 2>&1 | head -3

echo ""
echo "Verifying InRelease:"
gpg --verify "$INRELEASE_FILE" 2>&1 | head -3

echo ""
echo "=== Repository signed successfully ==="
echo "Files created:"
echo "  - $RELEASE_GPG"
echo "  - $INRELEASE_FILE"
