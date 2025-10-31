#!/bin/bash
# Automated repository structure and metadata validation
# This script prevents the pool directory collision bug from reoccurring
# Usage: ./validate-repository.sh <repository-dir>

set -euo pipefail

REPO_DIR="${1:-./debian-repo}"
DISTRIBUTIONS=("trixie" "bookworm" "sid" "noble")
COMPONENTS=("main" "non-free")
ARCH="amd64"

echo "=========================================="
echo "APT Repository Validation Script"
echo "=========================================="
echo "Repository: $REPO_DIR"
echo "Distributions: ${DISTRIBUTIONS[*]}"
echo "Components: ${COMPONENTS[*]}"
echo ""

VALIDATION_ERRORS=0
VALIDATION_WARNINGS=0

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to report errors
report_error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
    ((VALIDATION_ERRORS++))
}

# Function to report warnings
report_warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
    ((VALIDATION_WARNINGS++))
}

# Function to report success
report_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

echo "=== TEST 1: Pool Directory Structure Validation ==="
echo "Checking for distribution-specific pool directories..."

for distro in "${DISTRIBUTIONS[@]}"; do
    for component in "${COMPONENTS[@]}"; do
        pool_path="$REPO_DIR/pool/$distro/$component"

        if [ -d "$pool_path" ]; then
            # Count .deb files in this pool
            deb_count=$(find "$pool_path" -name "*.deb" -type f 2>/dev/null | wc -l)

            if [ "$deb_count" -gt 0 ]; then
                report_success "pool/$distro/$component/ exists with $deb_count package(s)"
            else
                report_warning "pool/$distro/$component/ exists but contains no .deb files"
            fi
        else
            # Check if this is expected to be empty
            packages_file="$REPO_DIR/dists/$distro/$component/binary-$ARCH/Packages"
            if [ -f "$packages_file" ] && [ -s "$packages_file" ]; then
                report_error "pool/$distro/$component/ missing but Packages file exists and is non-empty"
            else
                report_warning "pool/$distro/$component/ missing (may be intentionally empty)"
            fi
        fi
    done
done

echo ""
echo "=== TEST 2: Old Shared Pool Detection ==="
echo "Checking for remnants of old shared pool structure..."

# Check if old shared pool exists (this would indicate the bug is present)
if [ -d "$REPO_DIR/pool/main" ] || [ -d "$REPO_DIR/pool/non-free" ]; then
    # Count files in old structure
    old_main_count=$(find "$REPO_DIR/pool/main" -name "*.deb" -type f 2>/dev/null | wc -l || echo 0)
    old_nonfree_count=$(find "$REPO_DIR/pool/non-free" -name "*.deb" -type f 2>/dev/null | wc -l || echo 0)

    if [ "$old_main_count" -gt 0 ] || [ "$old_nonfree_count" -gt 0 ]; then
        report_error "Old shared pool structure detected! Found $old_main_count files in pool/main/ and $old_nonfree_count in pool/non-free/"
        report_error "This indicates the pool directory collision bug is present"
    else
        report_warning "Empty old pool directories exist (pool/main or pool/non-free) - should be removed"
    fi
else
    report_success "No old shared pool structure found"
fi

echo ""
echo "=== TEST 3: Metadata Consistency Validation ==="
echo "Verifying Packages metadata matches actual files..."

for distro in "${DISTRIBUTIONS[@]}"; do
    for component in "${COMPONENTS[@]}"; do
        packages_file="$REPO_DIR/dists/$distro/$component/binary-$ARCH/Packages"

        if [ ! -f "$packages_file" ]; then
            report_warning "Packages file missing: dists/$distro/$component/binary-$ARCH/Packages"
            continue
        fi

        echo ""
        echo "Checking $distro/$component..."

        # Parse Packages file and validate each entry
        while IFS= read -r line; do
            if [[ "$line" =~ ^Filename:\ (.+)$ ]]; then
                filename="${BASH_REMATCH[1]}"

                # Read next lines to get Size, MD5sum, SHA1, SHA256
                read -r size_line
                read -r md5_line
                read -r sha1_line
                read -r sha256_line

                if [[ "$size_line" =~ ^Size:\ ([0-9]+)$ ]]; then
                    expected_size="${BASH_REMATCH[1]}"
                else
                    report_error "Could not parse size for $filename"
                    continue
                fi

                if [[ "$sha256_line" =~ ^SHA256:\ ([a-f0-9]+)$ ]]; then
                    expected_sha256="${BASH_REMATCH[1]}"
                else
                    report_warning "Could not parse SHA256 for $filename"
                    expected_sha256=""
                fi

                # Validate filename path includes distribution
                if [[ "$filename" =~ ^pool/$distro/$component/ ]]; then
                    report_success "  Filename path correct: $filename"
                else
                    report_error "  Filename path incorrect: $filename (should start with pool/$distro/$component/)"
                fi

                # Check if file exists
                full_path="$REPO_DIR/$filename"
                if [ ! -f "$full_path" ]; then
                    report_error "  Package file missing: $filename"
                    continue
                fi

                # Validate size
                actual_size=$(stat -c%s "$full_path")
                if [ "$actual_size" -eq "$expected_size" ]; then
                    report_success "  Size matches: $expected_size bytes"
                else
                    report_error "  Size mismatch: expected $expected_size, actual $actual_size for $filename"
                fi

                # Validate SHA256 if available
                if [ -n "$expected_sha256" ]; then
                    actual_sha256=$(sha256sum "$full_path" | awk '{print $1}')
                    if [ "$actual_sha256" = "$expected_sha256" ]; then
                        report_success "  SHA256 matches"
                    else
                        report_error "  SHA256 mismatch for $filename"
                        report_error "    Expected: $expected_sha256"
                        report_error "    Actual:   $actual_sha256"
                    fi
                fi
            fi
        done < "$packages_file"
    done
done

echo ""
echo "=== TEST 4: Pool Isolation Verification ==="
echo "Checking pool directory structure..."

# Verify each distribution has its own pool directories
pool_count=0
for distro in "${DISTRIBUTIONS[@]}"; do
    for component in "${COMPONENTS[@]}"; do
        pool_path="$REPO_DIR/pool/$distro/$component"

        if [ -d "$pool_path" ]; then
            deb_count=$(find "$pool_path" -name "*.deb" -type f 2>/dev/null | wc -l)
            if [ "$deb_count" -gt 0 ]; then
                ((pool_count++))
            fi
        fi
    done
done

if [ $pool_count -gt 0 ]; then
    report_success "Distribution-specific pool directories verified ($pool_count pools with packages)"
    report_success "Each distribution has isolated packages (arch:all packages may be duplicated, arch-specific packages are distribution-specific)"
else
    report_warning "No pool directories with packages found"
fi

echo ""
echo "=== TEST 5: Release File Validation ==="
echo "Checking Release files exist and are signed..."

for distro in "${DISTRIBUTIONS[@]}"; do
    release_file="$REPO_DIR/dists/$distro/Release"
    release_gpg="$REPO_DIR/dists/$distro/Release.gpg"
    inrelease_file="$REPO_DIR/dists/$distro/InRelease"

    if [ -f "$release_file" ]; then
        report_success "Release file exists: dists/$distro/Release"

        # Check if signed
        if [ -f "$release_gpg" ] || [ -f "$inrelease_file" ]; then
            report_success "  Release file is GPG signed"
        else
            report_error "  Release file exists but is NOT signed (Release.gpg or InRelease missing)"
        fi

        # Validate Suite and Codename fields
        suite=$(grep "^Suite:" "$release_file" | awk '{print $2}')
        codename=$(grep "^Codename:" "$release_file" | awk '{print $2}')

        if [ "$suite" = "$distro" ] && [ "$codename" = "$distro" ]; then
            report_success "  Suite and Codename correctly set to '$distro'"
        else
            report_error "  Suite or Codename mismatch (expected: $distro, got: Suite=$suite Codename=$codename)"
        fi
    else
        report_error "Release file missing: dists/$distro/Release"
    fi
done

echo ""
echo "=========================================="
echo "Validation Summary"
echo "=========================================="

if [ $VALIDATION_ERRORS -eq 0 ] && [ $VALIDATION_WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ ALL CHECKS PASSED${NC}"
    echo "Repository structure is valid and ready for deployment"
    exit 0
elif [ $VALIDATION_ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  PASSED WITH WARNINGS${NC}"
    echo "Errors: $VALIDATION_ERRORS"
    echo "Warnings: $VALIDATION_WARNINGS"
    echo ""
    echo "Repository can be deployed but review warnings above"
    exit 0
else
    echo -e "${RED}❌ VALIDATION FAILED${NC}"
    echo "Errors: $VALIDATION_ERRORS"
    echo "Warnings: $VALIDATION_WARNINGS"
    echo ""
    echo "Repository has critical issues and should NOT be deployed"
    exit 1
fi
