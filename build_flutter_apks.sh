#!/bin/bash

# Flutter Friends Circle Project - Automated APK Build Script
# Support for dual Flutter versions (3.27 & 3.29) compilation
# Author: Chris
# Usage: ./build_flutter_apks.sh

set -e  # Exit immediately on error

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Log functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_header() {
    echo -e "${PURPLE}🚀 $1${NC}"
}

log_step() {
    echo -e "${CYAN}📱 $1${NC}"
}

# Display script start information
clear
log_header "Flutter Friends Circle Project - Dual Version APK Auto Build Script"
echo -e "${PURPLE}════════════════════════════════════════════════${NC}"
log_info "Supported Versions: Flutter 3.27 & Flutter 3.29"
log_info "Output Format: Release APK"
log_info "Build Method: FVM + Flutter"
echo ""

# Check necessary tools
log_step "Checking build environment..."

# Check FVM
if ! command -v fvm &> /dev/null; then
    log_error "FVM not installed or not in PATH, please install FVM first"
    log_info "Install command: dart pub global activate fvm"
    exit 1
fi
log_success "FVM installed"

# Check if in project root directory
if [ ! -d "3.27" ] || [ ! -d "3.29" ]; then
    log_error "Please run this script from project root directory"
    exit 1
fi
log_success "Project directory check passed"

# Create output directory
OUTPUT_DIR="apk"
mkdir -p "$OUTPUT_DIR"
log_success "Output directory: $OUTPUT_DIR"

# Get build information
BUILD_TIME=$(date +"%Y%m%d_%H%M%S")
GIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
log_info "Build time: $BUILD_TIME"
log_info "Git commit: $GIT_HASH"

echo ""

# Build statistics variables
SUCCESS_COUNT=0
TOTAL_COUNT=2
BUILD_ERRORS=()

# Flutter version configuration
FLUTTER_VERSIONS=("3.27" "3.29")
APP_NAMES=("Friends Circle V27" "Friends Circle V29")
PACKAGE_NAMES=("com.example.friendscircle.v27" "com.example.friendscircle.v29")

# Build function
build_flutter_version() {
    local version=$1
    local app_name=$2
    local package_name=$3
    
    log_header "Starting Flutter $version Build"
    echo -e "${PURPLE}────────────────────────────────────────────────${NC}"
    
    # Enter version directory
    cd "$version" || {
        log_error "Cannot enter directory: $version"
        return 1
    }
    
    # Check Flutter version configuration
    if [ ! -f ".fvmrc" ]; then
        log_warning ".fvmrc file not found, may need manual FVM version configuration"
    else
        local fvm_version=$(cat .fvmrc)
        log_info "FVM configured version: $fvm_version"
    fi
    
    # Clean and get dependencies
    log_step "Cleaning project..."
    if ! fvm flutter clean; then
        log_error "Flutter clean failed"
        cd ..
        return 1
    fi
    
    log_step "Getting dependencies..."
    if ! fvm flutter pub get; then
        log_error "Flutter pub get failed"
        cd ..
        return 1
    fi
    
    # Build APK
    log_step "Building Release APK..."
    log_info "Package name: $package_name"
    log_info "App name: $app_name"
    
    if fvm flutter build apk --release; then
        log_success "Flutter $version build successful!"
        
        # Check APK file
        local source_apk="build/app/outputs/flutter-apk/app-release.apk"
        if [ -f "$source_apk" ]; then
            # Get file size
            local file_size=$(du -h "$source_apk" | cut -f1)
            log_success "APK file generated successfully ($file_size)"
            
            # Define standard APK file name
            local apk_name=""
            if [ "$version" = "3.27" ]; then
                apk_name="friends-flutter-v27-release.apk"
            else
                apk_name="friends-flutter-v29-release.apk"
            fi
            
            # Clean old version
            rm -f "../$OUTPUT_DIR/$apk_name"
            
            # Copy APK to output directory
            local target_apk="../$OUTPUT_DIR/$apk_name"
            cp "$source_apk" "$target_apk"
            log_success "APK copied to: $target_apk"
            
            # Create version information file
            local info_name=""
            if [ "$version" = "3.27" ]; then
                info_name="friends-flutter-v27-release.txt"
            else
                info_name="friends-flutter-v29-release.txt"
            fi
            
            # Clean old version info file
            rm -f "../$OUTPUT_DIR/$info_name"
            local info_file="../$OUTPUT_DIR/$info_name"
            cat > "$info_file" << EOF
Flutter Friends Circle Project - Version Information
==================================================
App Name: $app_name
Flutter Version: $version
Package Name: $package_name
Build Time: $BUILD_TIME
Git Commit: $GIT_HASH
APK Size: $file_size
Build Type: Release
Signature: Debug signature

Install Command:
adb install "$target_apk"
EOF
            log_info "Version info saved to: $info_file"
            
            cd ..
            return 0
        else
            log_error "APK file not found: $source_apk"
            cd ..
            return 1
        fi
    else
        log_error "Flutter $version build failed!"
        cd ..
        return 1
    fi
}

# Start building all versions
log_header "Starting Flutter Version Builds..."
echo ""

for i in "${!FLUTTER_VERSIONS[@]}"; do
    version="${FLUTTER_VERSIONS[$i]}"
    app_name="${APP_NAMES[$i]}"
    package_name="${PACKAGE_NAMES[$i]}"
    
    echo ""
    if build_flutter_version "$version" "$app_name" "$package_name"; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        log_success "✨ $app_name build completed"
    else
        BUILD_ERRORS+=("$app_name")
        log_error "💥 $app_name build failed"
    fi
    echo ""
done

# Build result statistics
echo ""
log_header "Build Result Statistics"
echo -e "${PURPLE}════════════════════════════════════════════════${NC}"
log_info "Successful builds: $SUCCESS_COUNT/$TOTAL_COUNT"

if [ $SUCCESS_COUNT -eq $TOTAL_COUNT ]; then
    log_success "🎉 All versions built successfully!"
    
    echo ""
    log_info "Generated APK files:"
    for apk in "$OUTPUT_DIR"/*.apk; do
        if [ -f "$apk" ]; then
            local size=$(du -h "$apk" | cut -f1)
            echo -e "${CYAN}   📱 $(basename "$apk") (${size})${NC}"
        fi
    done
    
    echo ""
    log_info "Installation command examples:"
    echo -e "${YELLOW}   # Install Flutter 3.27 version${NC}"
    echo -e "${YELLOW}   adb install \"$OUTPUT_DIR/friends-flutter-v27-release.apk\"${NC}"
    echo ""
    echo -e "${YELLOW}   # Install Flutter 3.29 version${NC}"
    echo -e "${YELLOW}   adb install \"$OUTPUT_DIR/friends-flutter-v29-release.apk\"${NC}"
    echo ""
    echo -e "${YELLOW}   # Batch install all APKs${NC}"
    echo -e "${YELLOW}   for apk in $OUTPUT_DIR/*.apk; do adb install \"\$apk\"; done${NC}"
    
    # Create installation script
    local install_script="install_flutter_apks.sh"
    cat > "$install_script" << EOF
#!/bin/bash
# Flutter Friends Circle Project - Auto Install APK Script
# Generated at: $(date)

echo "🚀 Starting Flutter Friends Circle APK installation..."
echo ""

SUCCESS=0
TOTAL=0

for apk in $OUTPUT_DIR/*.apk; do
    if [ -f "\$apk" ]; then
        TOTAL=\$((TOTAL + 1))
        echo "📱 Installing: \$(basename "\$apk")"
        if adb install "\$apk"; then
            echo "✅ Installation successful"
            SUCCESS=\$((SUCCESS + 1))
        else
            echo "❌ Installation failed"
        fi
        echo ""
    fi
done

echo "📊 Installation statistics: \$SUCCESS/\$TOTAL"
if [ \$SUCCESS -eq \$TOTAL ]; then
    echo "🎉 All APKs installed successfully!"
else
    echo "⚠️  Some APKs failed to install, please check device connection"
fi
EOF
    chmod +x "$install_script"
    log_info "📜 Installation script created: $install_script"
    
    # Create performance comparison script
    local compare_script="performance_compare.sh"
    cat > "$compare_script" << EOF
#!/bin/bash
# Flutter Version Performance Comparison Script
echo "🔍 Flutter Version Performance Comparison Tool"
echo "=============================================="
echo "1. Ensure both version APKs are installed"
echo "2. Launch applications separately for performance testing"
echo "3. Use Android Studio Profiler for comparison"
echo ""
echo "📱 Installed APKs:"
for apk in $OUTPUT_DIR/*.apk; do
    if [ -f "\$apk" ]; then
        echo "   - \$(basename "\$apk")"
    fi
done
echo ""
echo "🚀 Quick launch commands:"
echo "   # Launch Flutter 3.27 version"
echo "   adb shell am start -n com.example.friendscircle.v27/.MainActivity"
echo ""
echo "   # Launch Flutter 3.29 version"  
echo "   adb shell am start -n com.example.friendscircle.v29/.MainActivity"
EOF
    chmod +x "$compare_script"
    log_info "📊 Performance comparison script created: $compare_script"
    
elif [ $SUCCESS_COUNT -gt 0 ]; then
    log_warning "Some versions built successfully"
    log_info "Failed versions:"
    for error in "${BUILD_ERRORS[@]}"; do
        echo -e "${RED}   ❌ $error${NC}"
    done
else
    log_error "All version builds failed"
    exit 1
fi

echo ""
log_header "📋 Next Steps Recommendations"
echo -e "${PURPLE}════════════════════════════════════════════════${NC}"
log_info "1. Use generated installation script for batch APK installation"
log_info "2. Perform performance testing comparison on real devices"
log_info "3. Use Android Studio Profiler to analyze performance differences"
log_info "4. Record test results and update project documentation"

echo ""
log_success "🎯 Script execution completed! All APKs are ready!"
echo -e "${PURPLE}════════════════════════════════════════════════${NC}"