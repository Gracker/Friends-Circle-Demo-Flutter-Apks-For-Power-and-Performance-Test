#!/bin/bash

# Flutter Friends Circle Project - Quick Build Script (Simplified)
# Usage: ./quick_build.sh [3.27|3.29|all]

set -e

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Get parameters
VERSION=${1:-"all"}

# Build function
build_version() {
    local ver=$1
    local app_name=$2
    
    log_info "Building Flutter $ver..."
    cd "$ver"
    
    # Clean and build
    fvm flutter clean > /dev/null 2>&1
    fvm flutter pub get > /dev/null 2>&1
    
    if fvm flutter build apk --release > /dev/null 2>&1; then
        # Define standard APK file name
        local apk_name=""
        if [ "$ver" = "3.27" ]; then
            apk_name="friends-flutter-v27-release.apk"
        else
            apk_name="friends-flutter-v29-release.apk"
        fi
        
        # Clean old version
        rm -f "../apk/$apk_name"
        
        # Copy APK
        cp "build/app/outputs/flutter-apk/app-release.apk" "../apk/$apk_name"
        local size=$(du -h "../apk/$apk_name" | cut -f1)
        log_success "$app_name build completed -> $apk_name ($size)"
    else
        log_error "$app_name build failed"
        cd ..
        return 1
    fi
    
    cd ..
    return 0
}

# Execute build
case $VERSION in
    "3.27")
        build_version "3.27" "Friends Circle V27"
        ;;
    "3.29")
        build_version "3.29" "Friends Circle V29"
        ;;
    "all"|*)
        log_info "Building all versions..."
        build_version "3.27" "Friends Circle V27"
        build_version "3.29" "Friends Circle V29"
        ;;
esac

log_success "Build completed! APK files are in apk/ directory"