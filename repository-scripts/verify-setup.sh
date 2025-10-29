#!/bin/bash
# Verify GitHub Pages APT repository setup
# Usage: ./verify-setup.sh [domain]

set -euo pipefail

DOMAIN="${1:-debian.vejeta.com}"
REPO_URL="https://${DOMAIN}"
SUITE="bookworm"

echo "=========================================="
echo "  APT Repository Setup Verification"
echo "=========================================="
echo ""
echo "Domain: $DOMAIN"
echo "Repository URL: $REPO_URL"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check functions
check_pass() {
    echo -e "${GREEN}✓${NC} $1"
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Test counter
PASS=0
FAIL=0
WARN=0

echo "=== DNS Resolution ==="
if dig +short "$DOMAIN" A | grep -q .; then
    IP=$(dig +short "$DOMAIN" A | head -1)
    check_pass "DNS resolves: $DOMAIN → $IP"
    ((PASS++))
else
    check_fail "DNS does not resolve for $DOMAIN"
    echo "  Configure CNAME: $DOMAIN → <username>.github.io"
    ((FAIL++))
fi
echo ""

echo "=== Repository Accessibility ==="
if curl -sf -I "$REPO_URL" | grep -q "200 OK"; then
    check_pass "Repository homepage accessible: $REPO_URL"
    ((PASS++))
else
    check_fail "Repository homepage not accessible"
    echo "  Check GitHub Pages deployment status"
    ((FAIL++))
fi

if curl -sf "$REPO_URL/key.gpg" > /dev/null; then
    check_pass "GPG public key accessible: $REPO_URL/key.gpg"
    ((PASS++))

    # Verify key format
    if curl -sf "$REPO_URL/key.gpg" | gpg --list-packets > /dev/null 2>&1; then
        check_pass "GPG key format valid"
        ((PASS++))
    else
        check_warn "GPG key format might be invalid"
        ((WARN++))
    fi
else
    check_fail "GPG public key not found"
    echo "  Check deploy workflow completed successfully"
    ((FAIL++))
fi
echo ""

echo "=== Repository Metadata ==="
if curl -sf "$REPO_URL/dists/$SUITE/Release" > /dev/null; then
    check_pass "Release file exists: $REPO_URL/dists/$SUITE/Release"
    ((PASS++))

    # Check Release file content
    RELEASE_CONTENT=$(curl -sf "$REPO_URL/dists/$SUITE/Release")

    if echo "$RELEASE_CONTENT" | grep -q "Components: main non-free"; then
        check_pass "Release file contains main and non-free components"
        ((PASS++))
    else
        check_warn "Release file missing expected components"
        ((WARN++))
    fi

    if echo "$RELEASE_CONTENT" | grep -q "SHA256:"; then
        check_pass "Release file contains SHA256 checksums"
        ((PASS++))
    else
        check_fail "Release file missing checksums"
        ((FAIL++))
    fi
else
    check_fail "Release file not found"
    ((FAIL++))
fi

if curl -sf "$REPO_URL/dists/$SUITE/InRelease" > /dev/null; then
    check_pass "InRelease file exists (clear-signed)"
    ((PASS++))

    # Verify signature (if GPG key already imported)
    if curl -sf "$REPO_URL/dists/$SUITE/InRelease" | gpg --verify 2>&1 | grep -q "Good signature"; then
        check_pass "InRelease signature verified (GPG key trusted)"
        ((PASS++))
    else
        check_warn "InRelease signature not verified (import GPG key first)"
        ((WARN++))
    fi
else
    check_fail "InRelease file not found (repository not signed)"
    ((FAIL++))
fi

if curl -sf "$REPO_URL/dists/$SUITE/Release.gpg" > /dev/null; then
    check_pass "Release.gpg file exists (detached signature)"
    ((PASS++))
else
    check_fail "Release.gpg file not found"
    ((FAIL++))
fi
echo ""

echo "=== Package Indices ==="
if curl -sf "$REPO_URL/dists/$SUITE/main/binary-amd64/Packages" > /dev/null; then
    check_pass "Packages file exists (main/amd64)"
    ((PASS++))

    # Check for stremio package
    if curl -sf "$REPO_URL/dists/$SUITE/main/binary-amd64/Packages" | grep -q "Package: stremio"; then
        check_pass "Package 'stremio' found in main component"
        ((PASS++))
    else
        check_warn "Package 'stremio' not found in main"
        ((WARN++))
    fi
else
    check_fail "Packages file not found (main/amd64)"
    ((FAIL++))
fi

if curl -sf "$REPO_URL/dists/$SUITE/main/binary-amd64/Packages.gz" > /dev/null; then
    check_pass "Packages.gz exists (compressed)"
    ((PASS++))
else
    check_warn "Packages.gz not found (optional)"
    ((WARN++))
fi

if curl -sf "$REPO_URL/dists/$SUITE/non-free/binary-amd64/Packages" > /dev/null; then
    check_pass "Packages file exists (non-free/amd64)"
    ((PASS++))

    # Check for stremio-server package
    if curl -sf "$REPO_URL/dists/$SUITE/non-free/binary-amd64/Packages" | grep -q "Package: stremio-server"; then
        check_pass "Package 'stremio-server' found in non-free component"
        ((PASS++))
    else
        check_warn "Package 'stremio-server' not found in non-free"
        ((WARN++))
    fi
else
    check_fail "Packages file not found (non-free/amd64)"
    ((FAIL++))
fi
echo ""

echo "=== HTTPS and Security ==="
if curl -sf -I "$REPO_URL" | grep -q "strict-transport-security"; then
    check_pass "HTTPS properly configured (HSTS enabled)"
    ((PASS++))
else
    check_warn "HTTPS might not be properly configured"
    ((WARN++))
fi

if curl -sf -I "$REPO_URL" | grep -q "content-security-policy"; then
    check_pass "Content Security Policy configured"
    ((PASS++))
else
    check_warn "CSP not configured (GitHub Pages may handle)"
    ((WARN++))
fi
echo ""

echo "=========================================="
echo "           Verification Summary"
echo "=========================================="
echo ""
echo -e "${GREEN}Passed:${NC}  $PASS tests"
echo -e "${YELLOW}Warnings:${NC} $WARN tests"
echo -e "${RED}Failed:${NC}  $FAIL tests"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✓ Repository setup is correct!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Test APT installation:"
    echo "     wget -qO - $REPO_URL/key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/stremio-debian.gpg"
    echo "     echo \"deb [signed-by=/usr/share/keyrings/stremio-debian.gpg] $REPO_URL $SUITE main non-free\" | sudo tee /etc/apt/sources.list.d/stremio.list"
    echo "     sudo apt update"
    echo "     sudo apt install stremio stremio-server"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Repository setup has issues${NC}"
    echo ""
    echo "Common fixes:"
    echo "  - DNS not resolving: Configure CNAME in DNS provider"
    echo "  - Repository not accessible: Check GitHub Pages deployment"
    echo "  - Missing files: Check GitHub Actions workflow completed"
    echo "  - GPG errors: Verify GPG_PRIVATE_KEY and GPG_KEY_ID secrets"
    echo ""
    echo "Detailed help: SETUP.md and TROUBLESHOOTING.md"
    echo ""
    exit 1
fi
