#!/bin/bash

# Flutter 朋友圈性能测试项目 - Debug (TraceFix) APK 构建脚本
# 作者: Chris
# 使用方法: ./build_debug.sh
#
# 构建 release 模式 APK，但启用 TraceFix 插件进行 ASM 字节码插桩，
# 自动在所有方法前后注入 android.os.Trace.beginSection/endSection，
# 用于 systrace/Perfetto 性能分析。

set -e  # 遇到错误立即退出

# 启用 TraceFix 插桩
export TRACEFIX_ENABLED=true

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

# 显示开始信息
log_header "Flutter 朋友圈性能测试 - Debug (TraceFix) APK 构建脚本"
log_info "TraceFix 已启用: 自动注入 Trace.beginSection/endSection"
echo ""

# 检查 FVM 是否安装
if ! command -v fvm &> /dev/null; then
    log_error "FVM 命令未找到。请先安装 FVM: brew install fvm"
    exit 1
fi

log_info "使用 FVM 管理多个 Flutter 版本"

# 创建输出目录
OUTPUT_DIR="apk-debug"
mkdir -p "$OUTPUT_DIR"
log_info "输出目录: $OUTPUT_DIR"

# 定义构建模块（目录名|显示名|包名标识|Flutter版本|渲染模式|包名）
declare -a MODULE_CONFIG=(
    "3.19_SurfaceView|Flutter 3.19 SurfaceView|v19sv|3.19|SurfaceView|com.example.friendscircle.v19"
    "3.19_TextureView|Flutter 3.19 TextureView|v19tv|3.19|TextureView|com.example.friendscircle.v19.textureview"
    "3.27_SurfaceView|Flutter 3.27 SurfaceView|v27sv|3.27|SurfaceView|com.example.friendscircle.v27"
    "3.27_TextureView|Flutter 3.27 TextureView|v27tv|3.27|TextureView|com.example.friendscircle.v27.textureview"
    "3.29_SurfaceView|Flutter 3.29 SurfaceView|v29sv|3.29|SurfaceView|com.example.friendscircle.v29"
    "3.29_TextureView|Flutter 3.29 TextureView|v29tv|3.29|TextureView|com.example.friendscircle.v29.textureview"
)

# 构建时间
BUILD_TIME=$(date +"%Y%m%d_%H%M%S")
log_info "构建时间: $BUILD_TIME"
echo ""

SUCCESS_COUNT=0
TOTAL_COUNT=0
FAILED_MODULES=()

# 处理每个模块
for config in "${MODULE_CONFIG[@]}"; do
    # 解析配置
    IFS='|' read -r MODULE_DIR MODULE_NAME MODULE_ID FLUTTER_VER RENDER_MODE PKG_NAME <<< "$config"

    log_header "构建 (TraceFix): $MODULE_NAME"
    log_info "目录: $MODULE_DIR"

    TOTAL_COUNT=$((TOTAL_COUNT + 1))

    # 进入模块目录
    if [ ! -d "$MODULE_DIR" ]; then
        log_error "目录不存在: $MODULE_DIR"
        FAILED_MODULES+=("$MODULE_NAME")
        continue
    fi

    cd "$MODULE_DIR"

    # 检查 pubspec.yaml 是否存在
    if [ ! -f "pubspec.yaml" ]; then
        log_error "pubspec.yaml 不存在，跳过此模块"
        cd ..
        FAILED_MODULES+=("$MODULE_NAME")
        continue
    fi

    # 获取当前项目实际使用的 Flutter 版本
    FVM_FLUTTER_VERSION=""
    if [ -f ".fvm/fvm_config.json" ]; then
        FVM_FLUTTER_VERSION=$(cat .fvm/fvm_config.json | grep '"flutterSdkVersion"' | sed 's/.*": "\(.*\)".*/\1/')
        log_info "使用 Flutter 版本: $FVM_FLUTTER_VERSION (通过 FVM)"
    else
        log_warning "未找到 .fvm/fvm_config.json，使用系统默认 Flutter"
    fi

    # 执行 Flutter 构建（使用 FVM）
    log_info "开始构建 Debug (TraceFix) APK..."

    # 生成正确的 local.properties，指向 FVM 管理的 Flutter SDK
    if [ -n "$FVM_FLUTTER_VERSION" ]; then
        # Resolve the SDK path: try FVM symlink first, then common FVM cache locations
        FLUTTER_SDK_DIR=""
        if [ -d ".fvm/flutter_sdk" ]; then
            FLUTTER_SDK_DIR=$(cd .fvm/flutter_sdk && pwd -P)
        elif [ -d "${HOME}/fvm/versions/${FVM_FLUTTER_VERSION}" ]; then
            FLUTTER_SDK_DIR="${HOME}/fvm/versions/${FVM_FLUTTER_VERSION}"
        elif [ -d "${HOME}/.fvm/versions/${FVM_FLUTTER_VERSION}" ]; then
            FLUTTER_SDK_DIR="${HOME}/.fvm/versions/${FVM_FLUTTER_VERSION}"
        fi

        if [ -n "$FLUTTER_SDK_DIR" ] && [ -d "$FLUTTER_SDK_DIR" ]; then
            # 生成 local.properties，包含 Flutter SDK 路径和源目录
            cat > android/local.properties << EOF
flutter.sdk=${FLUTTER_SDK_DIR}
flutter.source=../..
EOF
            log_info "Flutter SDK: $FLUTTER_SDK_DIR"
        else
            log_warning "FVM Flutter SDK 目录未找到 (版本: $FVM_FLUTTER_VERSION)"
        fi
    fi

    if fvm flutter build apk --release \
        --dart-define=FLUTTER_VERSION=$FLUTTER_VER \
        --dart-define=RENDER_MODE=$RENDER_MODE \
        --dart-define=PACKAGE_NAME=$PKG_NAME; then
        # 查找生成的 APK 文件
        APK_PATH=$(find build/app/outputs/flutter-apk -name "app-release.apk" 2>/dev/null | head -1)

        if [ -f "$APK_PATH" ]; then
            # 获取文件大小
            FILE_SIZE=$(du -h "$APK_PATH" | cut -f1)

            # 复制到输出目录
            OUTPUT_APK="../$OUTPUT_DIR/friends_circle_${MODULE_ID}_debug.apk"
            cp "$APK_PATH" "$OUTPUT_APK"

            log_success "$MODULE_NAME 构建成功! ($FILE_SIZE)"
            log_info "APK 位置: $OUTPUT_APK"
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            log_error "$MODULE_NAME APK 文件未找到"
            FAILED_MODULES+=("$MODULE_NAME")
        fi
    else
        log_error "$MODULE_NAME 构建失败"
        FAILED_MODULES+=("$MODULE_NAME")
    fi

    cd ..
    echo ""
done

# 构建结果统计
log_header "构建结果统计"
log_info "成功: $SUCCESS_COUNT/$TOTAL_COUNT"
echo ""

if [ $SUCCESS_COUNT -eq $TOTAL_COUNT ]; then
    log_success "所有模块构建成功! 🎉"
elif [ $SUCCESS_COUNT -gt 0 ]; then
    log_warning "部分模块构建失败"
    echo ""
    log_error "失败的模块:"
    for module in "${FAILED_MODULES[@]}"; do
        echo -e "${RED}   ✗ $module${NC}"
    done
    echo ""
else
    log_error "所有模块构建失败!"
    exit 1
fi

# 显示生成的 APK 文件
log_info "生成的 APK 文件 (TraceFix 已启用):"
for apk in "$OUTPUT_DIR"/*.apk; do
    if [ -f "$apk" ]; then
        SIZE=$(du -h "$apk" | cut -f1)
        echo -e "${CYAN}   📱 $(basename "$apk") (${SIZE})${NC}"
    fi
done
echo ""

# 创建安装脚本
log_info "创建安装脚本..."

INSTALL_SCRIPT="install_debug_apks.sh"
cat > "$INSTALL_SCRIPT" << 'EOF'
#!/bin/bash

# Flutter 朋友圈性能测试 - Debug (TraceFix) APK 安装脚本
# 由 build_debug.sh 自动生成

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

log_header "安装 Flutter 朋友圈性能测试 Debug (TraceFix) APK"
echo ""

OUTPUT_DIR="apk-debug"

if [ ! -d "$OUTPUT_DIR" ]; then
    log_error "APK 输出目录不存在: $OUTPUT_DIR"
    log_info "请先运行 ./build_debug.sh 构建 APK"
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

    APK_FILE="$OUTPUT_DIR/friends_circle_${FILE_ID}_debug.apk"

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
EOF

chmod +x "$INSTALL_SCRIPT"
log_success "已创建安装脚本: $INSTALL_SCRIPT"
echo ""

# 实用命令提示
log_header "实用命令"
echo -e "${YELLOW}# 安装所有 Debug APK${NC}"
echo -e "${YELLOW}   ./install_debug_apks.sh${NC}"
echo ""
echo -e "${YELLOW}# 单独安装指定版本${NC}"
echo -e "${YELLOW}   adb install apk-debug/friends_circle_v27sv_debug.apk${NC}"
echo ""
echo -e "${YELLOW}# 启动指定版本和负载${NC}"
echo -e "${YELLOW}   adb shell am start -n com.example.friendscircle.v27/.MainActivity -e \"load\" \"build_heavy\"${NC}"
echo ""
echo -e "${YELLOW}# 使用 Perfetto 抓取 trace (TraceFix 注入的方法会出现在 trace 中)${NC}"
echo -e "${YELLOW}   perfetto -o /data/misc/perfetto-traces/trace.perfetto-trace -t 10s sched freq idle am wm gfx view binder_driver hal dalvik camera input res memory${NC}"
echo ""

log_success "脚本执行完成! 🎉"
