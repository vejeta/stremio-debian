#!/bin/bash
# Export GPG public key for APT repository
# Usage: ./export-gpg-key.sh <output-file> [gpg-key-id]

set -euo pipefail

OUTPUT_FILE="${1:-key.gpg}"
GPG_KEY_ID="${2:-}"

echo "=== Exporting GPG Public Key ==="

if [ -z "$GPG_KEY_ID" ]; then
    echo "Listing available GPG keys:"
    gpg --list-secret-keys --keyid-format=long
    echo ""
    echo "Usage: $0 <output-file> <gpg-key-id>"
    echo "Example: $0 key.gpg 1234ABCD5678EFGH"
    exit 1
fi

# Export public key in binary format
gpg --armor --export "$GPG_KEY_ID" > "$OUTPUT_FILE"

if [ -f "$OUTPUT_FILE" ]; then
    echo "✓ GPG public key exported successfully"
    echo "  Output: $OUTPUT_FILE"
    echo "  Size: $(stat -c%s "$OUTPUT_FILE") bytes"
    echo ""
    echo "Key fingerprint:"
    gpg --fingerprint "$GPG_KEY_ID"
    echo ""
    echo "Users can import this key with:"
    echo "  wget -qO - https://debian.vejeta.com/key.gpg | sudo apt-key add -"
    echo "  # or (modern method):"
    echo "  wget -qO - https://debian.vejeta.com/key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/stremio-debian.gpg"
else
    echo "✗ Failed to export GPG key"
    exit 1
fi
