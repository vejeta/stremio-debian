#!/bin/bash
# Test package installation in Docker containers for each distribution
# This prevents Qt ABI and dependency mismatches from reaching users

set -euo pipefail

DISTRIBUTIONS="${1:-testing trixie bookworm sid noble}"
REPO_URL="${2:-https://debian.vejeta.com}"
TEST_RESULTS_DIR="test-results"

mkdir -p "$TEST_RESULTS_DIR"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "Package Installation Testing"
echo "=========================================="
echo "Testing distributions: $DISTRIBUTIONS"
echo "Repository: $REPO_URL"
echo ""

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

for distro in $DISTRIBUTIONS; do
    echo ""
    echo "=== Testing $distro ==="
    ((TOTAL_TESTS++))

    # Determine base Docker image
    case "$distro" in
        testing)
            BASE_IMAGE="debian:testing"
            ;;
        trixie)
            BASE_IMAGE="debian:trixie"
            ;;
        bookworm)
            BASE_IMAGE="debian:bookworm"
            ;;
        sid)
            BASE_IMAGE="debian:sid"
            ;;
        noble)
            BASE_IMAGE="ubuntu:noble"
            ;;
        *)
            echo -e "${RED}❌ Unknown distribution: $distro${NC}"
            ((FAILED_TESTS++))
            continue
            ;;
    esac

    echo "Using base image: $BASE_IMAGE"

    # Create test script to run inside container
    cat > "$TEST_RESULTS_DIR/test-$distro.sh" << 'INNER_EOF'
#!/bin/bash
set -euo pipefail

DISTRO="$1"
REPO_URL="$2"

echo "→ Updating package lists..."
apt-get update -qq

echo "→ Upgrading system to latest packages..."
apt-get upgrade -y -qq

echo "→ Installing prerequisites..."
apt-get install -y -qq wget gnupg ca-certificates

echo "→ Adding Stremio repository..."
wget -qO - "$REPO_URL/key.gpg" | gpg --dearmor -o /usr/share/keyrings/stremio-debian.gpg

echo "deb [signed-by=/usr/share/keyrings/stremio-debian.gpg] $REPO_URL $DISTRO main non-free" > /etc/apt/sources.list.d/stremio.list

echo "→ Updating package lists with new repository..."
apt-get update -qq

echo "→ Attempting to install stremio stremio-server..."
if apt-get install -y stremio stremio-server; then
    echo "✅ Installation successful"

    echo "→ Verifying package versions..."
    dpkg -l | grep stremio

    echo "→ Checking if binary exists..."
    if [ -f /usr/bin/stremio ]; then
        echo "✅ Binary installed at /usr/bin/stremio"
    else
        echo "❌ Binary not found"
        exit 1
    fi

    echo "→ Checking dependencies..."
    if ldd /usr/bin/stremio | grep -q "not found"; then
        echo "❌ Missing library dependencies:"
        ldd /usr/bin/stremio | grep "not found"
        exit 1
    else
        echo "✅ All library dependencies satisfied"
    fi

    exit 0
else
    echo "❌ Installation failed"
    exit 1
fi
INNER_EOF

    chmod +x "$TEST_RESULTS_DIR/test-$distro.sh"

    # Run test in Docker container
    echo "Starting Docker container..."
    if docker run --rm \
        -v "$PWD/$TEST_RESULTS_DIR/test-$distro.sh:/test.sh:ro" \
        "$BASE_IMAGE" \
        bash /test.sh "$distro" "$REPO_URL" \
        > "$TEST_RESULTS_DIR/$distro.log" 2>&1; then

        echo -e "${GREEN}✅ $distro: Installation test PASSED${NC}"
        ((PASSED_TESTS++))

        # Show summary from log
        echo "→ Installed packages:"
        grep "ii  stremio" "$TEST_RESULTS_DIR/$distro.log" || true

    else
        echo -e "${RED}❌ $distro: Installation test FAILED${NC}"
        ((FAILED_TESTS++))

        echo "→ Error details:"
        tail -20 "$TEST_RESULTS_DIR/$distro.log"

        echo ""
        echo "Full log saved to: $TEST_RESULTS_DIR/$distro.log"
    fi
done

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Total tests: $TOTAL_TESTS"
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✅ ALL INSTALLATION TESTS PASSED${NC}"
    echo "Packages are ready for release"
    exit 0
else
    echo -e "${RED}❌ SOME TESTS FAILED${NC}"
    echo "Do NOT release - fix dependency issues first"
    exit 1
fi
