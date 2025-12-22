#!/bin/bash

# Flutter 朋友圈性能测试 - APK 安装脚本
# 由 build_release.sh 自动生成

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 日志函数
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_header() { echo -e "${CYAN}🚀 $1${NC}"; }

# 检查 adb 是否可用
if ! command -v adb &> /dev/null; then
    log_error "adb 命令未找到。请确保 Android SDK 已安装并添加到 PATH。"
    exit 1
fi

# 检查设备是否连接
if ! adb devices | grep -q "device$"; then
    log_error "没有连接的 Android 设备。请连接设备并开启 USB 调试。"
    exit 1
fi

log_header "安装 Flutter 朋友圈性能测试 APK"
echo ""

OUTPUT_DIR="apk-release"

if [ ! -d "$OUTPUT_DIR" ]; then
    log_error "APK 输出目录不存在: $OUTPUT_DIR"
    log_info "请先运行 ./build_release.sh 构建 APK"
    exit 1
fi

SUCCESS_COUNT=0
TOTAL_COUNT=0

# 定义安装配置（文件名模式|显示名|包名）
declare -a APK_CONFIG=(
    "v19sv|Flutter 3.19 SurfaceView|com.example.friendscircle.v19"
    "v19tv|Flutter 3.19 TextureView|com.example.friendscircle.v19.textureview"
    "v27sv|Flutter 3.27 SurfaceView|com.example.friendscircle.v27"
    "v27tv|Flutter 3.27 TextureView|com.example.friendscircle.v27.textureview"
    "v29sv|Flutter 3.29 SurfaceView|com.example.friendscircle.v29"
    "v29tv|Flutter 3.29 TextureView|com.example.friendscircle.v29.textureview"
)

# 安装每个 APK
for config in "${APK_CONFIG[@]}"; do
    IFS='|' read -r FILE_ID DISPLAY_NAME PACKAGE_NAME <<< "$config"

    APK_FILE="$OUTPUT_DIR/friends_circle_${FILE_ID}_release.apk"

    if [ ! -f "$APK_FILE" ]; then
        log_warning "$DISPLAY_NAME: APK 文件不存在，跳过"
        continue
    fi

    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    APK_SIZE=$(du -h "$APK_FILE" | cut -f1)

    log_info "安装: $DISPLAY_NAME ($APK_SIZE)"

    # 先卸载旧版本（如果存在）
    adb shell pm list packages | grep -q "$PACKAGE_NAME" && \
        log_info "  卸载旧版本..." && \
        adb uninstall "$PACKAGE_NAME" > /dev/null 2>&1

    # 安装新版本
    if adb install -r "$APK_FILE" > /dev/null 2>&1; then
        log_success "$DISPLAY_NAME: 安装成功"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        log_error "$DISPLAY_NAME: 安装失败"
    fi
    echo ""
done

log_header "安装结果"
log_info "成功: $SUCCESS_COUNT/$TOTAL_COUNT"
echo ""

if [ $SUCCESS_COUNT -eq $TOTAL_COUNT ]; then
    log_success "所有 APK 安装成功! 🎉"

    echo ""
    log_info "ADB 快速启动命令:"
    echo -e "${YELLOW}# Flutter 3.19 SurfaceView - Build Heavy${NC}"
    echo -e "${YELLOW}adb shell am start -n com.example.friendscircle.v19/.MainActivity -e \"load\" \"build_heavy\"${NC}"
    echo ""
    echo -e "${YELLOW}# Flutter 3.27 SurfaceView - Build Heavy${NC}"
    echo -e "${YELLOW}adb shell am start -n com.example.friendscircle.v27/.MainActivity -e \"load\" \"build_heavy\"${NC}"
    echo ""
    echo -e "${YELLOW}# Flutter 3.29 SurfaceView - Build Heavy${NC}"
    echo -e "${YELLOW}adb shell am start -n com.example.friendscircle.v29/.MainActivity -e \"load\" \"build_heavy\"${NC}"
    echo ""

elif [ $SUCCESS_COUNT -gt 0 ]; then
    log_warning "部分 APK 安装失败"
else
    log_error "所有 APK 安装失败"
    exit 1
fi
