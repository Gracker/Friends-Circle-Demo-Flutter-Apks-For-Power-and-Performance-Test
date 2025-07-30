#!/bin/bash

# Flutter Friends Circle Project - Automated APK Build Script
# Support for dual Flutter versions (3.27 & 3.29) compilation
# Author: Chris
# Usage: ./build_flutter_apks.sh

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 日志函数
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
        
        # 检查APK文件
        local source_apk="build/app/outputs/flutter-apk/app-release.apk"
        if [ -f "$source_apk" ]; then
            # 获取文件大小
            local file_size=$(du -h "$source_apk" | cut -f1)
            log_success "APK文件生成成功 ($file_size)"
            
            # 定义标准的APK文件名
            local apk_name=""
            if [ "$version" = "3.27" ]; then
                apk_name="friends-flutter-v27-release.apk"
            else
                apk_name="friends-flutter-v29-release.apk"
            fi
            
            # 清理旧版本
            rm -f "../$OUTPUT_DIR/$apk_name"
            
            # 复制APK到输出目录
            local target_apk="../$OUTPUT_DIR/$apk_name"
            cp "$source_apk" "$target_apk"
            log_success "APK已复制到: $target_apk"
            
            # 创建版本信息文件
            local info_name=""
            if [ "$version" = "3.27" ]; then
                info_name="friends-flutter-v27-release.txt"
            else
                info_name="friends-flutter-v29-release.txt"
            fi
            
            # 清理旧的版本信息文件
            rm -f "../$OUTPUT_DIR/$info_name"
            local info_file="../$OUTPUT_DIR/$info_name"
            cat > "$info_file" << EOF
Flutter朋友圈项目 - 版本信息
================================
应用名称: $app_name
Flutter版本: $version
包名: $package_name
构建时间: $BUILD_TIME
Git提交: $GIT_HASH
APK大小: $file_size
构建类型: Release
签名状态: Debug签名

安装命令:
adb install "$target_apk"
EOF
            log_info "版本信息已保存到: $info_file"
            
            cd ..
            return 0
        else
            log_error "APK文件未找到: $source_apk"
            cd ..
            return 1
        fi
    else
        log_error "Flutter $version 构建失败!"
        cd ..
        return 1
    fi
}

# 开始构建所有版本
log_header "开始构建所有Flutter版本..."
echo ""

for i in "${!FLUTTER_VERSIONS[@]}"; do
    version="${FLUTTER_VERSIONS[$i]}"
    app_name="${APP_NAMES[$i]}"
    package_name="${PACKAGE_NAMES[$i]}"
    
    echo ""
    if build_flutter_version "$version" "$app_name" "$package_name"; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        log_success "✨ $app_name 构建完成"
    else
        BUILD_ERRORS+=("$app_name")
        log_error "💥 $app_name 构建失败"
    fi
    echo ""
done

# 构建结果统计
echo ""
log_header "构建结果统计"
echo -e "${PURPLE}════════════════════════════════════════════════${NC}"
log_info "成功构建: $SUCCESS_COUNT/$TOTAL_COUNT"

if [ $SUCCESS_COUNT -eq $TOTAL_COUNT ]; then
    log_success "🎉 所有版本构建成功!"
    
    echo ""
    log_info "生成的APK文件:"
    for apk in "$OUTPUT_DIR"/*.apk; do
        if [ -f "$apk" ]; then
            local size=$(du -h "$apk" | cut -f1)
            echo -e "${CYAN}   📱 $(basename "$apk") (${size})${NC}"
        fi
    done
    
    echo ""
    log_info "安装命令示例:"
    echo -e "${YELLOW}   # 安装Flutter 3.27版本${NC}"
    echo -e "${YELLOW}   adb install \"$OUTPUT_DIR/friends-flutter-v27-release.apk\"${NC}"
    echo ""
    echo -e "${YELLOW}   # 安装Flutter 3.29版本${NC}"
    echo -e "${YELLOW}   adb install \"$OUTPUT_DIR/friends-flutter-v29-release.apk\"${NC}"
    echo ""
    echo -e "${YELLOW}   # 批量安装所有APK${NC}"
    echo -e "${YELLOW}   for apk in $OUTPUT_DIR/*.apk; do adb install \"\$apk\"; done${NC}"
    
    # 创建安装脚本
    local install_script="install_flutter_apks.sh"
    cat > "$install_script" << EOF
#!/bin/bash
# Flutter朋友圈项目 - 自动安装APK脚本
# 生成时间: $(date)

echo "🚀 开始安装Flutter朋友圈APK..."
echo ""

SUCCESS=0
TOTAL=0

for apk in $OUTPUT_DIR/*.apk; do
    if [ -f "\$apk" ]; then
        TOTAL=\$((TOTAL + 1))
        echo "📱 安装: \$(basename "\$apk")"
        if adb install "\$apk"; then
            echo "✅ 安装成功"
            SUCCESS=\$((SUCCESS + 1))
        else
            echo "❌ 安装失败"
        fi
        echo ""
    fi
done

echo "📊 安装统计: \$SUCCESS/\$TOTAL"
if [ \$SUCCESS -eq \$TOTAL ]; then
    echo "🎉 所有APK安装完成!"
else
    echo "⚠️  部分APK安装失败，请检查设备连接状态"
fi
EOF
    chmod +x "$install_script"
    log_info "📜 已创建安装脚本: $install_script"
    
    # 创建性能对比脚本
    local compare_script="performance_compare.sh"
    cat > "$compare_script" << EOF
#!/bin/bash
# Flutter版本性能对比脚本
echo "🔍 Flutter版本性能对比工具"
echo "================================"
echo "1. 确保两个版本的APK都已安装"
echo "2. 分别启动应用进行性能测试"
echo "3. 使用Android Studio的Profiler进行对比"
echo ""
echo "📱 已安装的APK:"
for apk in $OUTPUT_DIR/*.apk; do
    if [ -f "\$apk" ]; then
        echo "   - \$(basename "\$apk")"
    fi
done
echo ""
echo "🚀 快速启动命令:"
echo "   # 启动Flutter 3.27版本"
echo "   adb shell am start -n com.example.friendscircle.v27/.MainActivity"
echo ""
echo "   # 启动Flutter 3.29版本"  
echo "   adb shell am start -n com.example.friendscircle.v29/.MainActivity"
EOF
    chmod +x "$compare_script"
    log_info "📊 已创建性能对比脚本: $compare_script"
    
elif [ $SUCCESS_COUNT -gt 0 ]; then
    log_warning "部分版本构建成功"
    log_info "失败的版本:"
    for error in "${BUILD_ERRORS[@]}"; do
        echo -e "${RED}   ❌ $error${NC}"
    done
else
    log_error "所有版本构建失败"
    exit 1
fi

echo ""
log_header "📋 后续操作建议"
echo -e "${PURPLE}════════════════════════════════════════════════${NC}"
log_info "1. 使用生成的安装脚本批量安装APK"
log_info "2. 在真机上进行性能测试对比"
log_info "3. 使用Android Studio Profiler分析性能差异"
log_info "4. 记录测试结果并更新项目文档"

echo ""
log_success "🎯 脚本执行完成! 所有APK已准备就绪!"
echo -e "${PURPLE}════════════════════════════════════════════════${NC}"