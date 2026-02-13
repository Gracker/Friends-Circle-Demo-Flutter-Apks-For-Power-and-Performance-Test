#!/bin/bash

# Flutter 朋友圈性能测试项目 - Release APK 构建脚本
# 作者: Chris
# 使用方法: ./build_release.sh

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

# 显示开始信息
log_header "Flutter 朋友圈性能测试 - Release APK 构建脚本"
echo ""

# 检查 FVM 是否安装
if ! command -v fvm &> /dev/null; then
    log_error "FVM 命令未找到。请先安装 FVM: brew install fvm"
    exit 1
fi

log_info "使用 FVM 管理多个 Flutter 版本"

# 创建输出目录
OUTPUT_DIR="apk-release"
mkdir -p "$OUTPUT_DIR"
log_info "输出目录: $OUTPUT_DIR"

# 定义构建模块（目录名|显示名|包名标识|Flutter版本|渲染模式|包名）
declare -a MODULE_CONFIG=(
    "3.19_SurfaceView|Flutter 3.19 SurfaceView|v19sv|3.19.0|SurfaceView|com.example.friendscircle.v19"
    "3.19_TextureView|Flutter 3.19 TextureView|v19tv|3.19.0|TextureView|com.example.friendscircle.v19.textureview"
    "3.27_SurfaceView|Flutter 3.27 SurfaceView|v27sv|3.27.0|SurfaceView|com.example.friendscircle.v27"
    "3.27_TextureView|Flutter 3.27 TextureView|v27tv|3.27.0|TextureView|com.example.friendscircle.v27.textureview"
    "3.29_SurfaceView|Flutter 3.29 SurfaceView|v29sv|3.29.0|SurfaceView|com.example.friendscircle.v29"
    "3.29_TextureView|Flutter 3.29 TextureView|v29tv|3.29.0|TextureView|com.example.friendscircle.v29.textureview"
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

    log_header "构建: $MODULE_NAME"
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
        log_info "FVM 配置版本: $FVM_FLUTTER_VERSION"
    else
        log_warning "未找到 .fvm/fvm_config.json，自动配置 FVM..."
        if ! fvm install "$FLUTTER_VER" 2>/dev/null; then
            log_error "FVM 安装 Flutter $FLUTTER_VER 失败"
            FAILED_MODULES+=("$MODULE_NAME")
            cd ..
            continue
        fi
        echo "y" | fvm use "$FLUTTER_VER" 2>/dev/null
        FVM_FLUTTER_VERSION="$FLUTTER_VER"
        log_info "已自动配置 FVM: $FLUTTER_VER"
    fi

    if [ "$FVM_FLUTTER_VERSION" != "$FLUTTER_VER" ]; then
        log_error "Flutter 版本不匹配！"
        log_error "  期望版本: $FLUTTER_VER"
        log_error "  实际版本: $FVM_FLUTTER_VERSION"
        log_error "  请运行: cd $MODULE_DIR && fvm use $FLUTTER_VER"
        FAILED_MODULES+=("$MODULE_NAME")
        cd ..
        continue
    fi
    log_success "版本校验通过: Flutter $FLUTTER_VER"

    # 执行 Flutter 构建（使用 FVM）
    log_info "开始构建 Release APK..."

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
            OUTPUT_APK="../$OUTPUT_DIR/friends_circle_${MODULE_ID}_release.apk"
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
log_info "生成的 APK 文件:"
for apk in "$OUTPUT_DIR"/*.apk; do
    if [ -f "$apk" ]; then
        SIZE=$(du -h "$apk" | cut -f1)
        echo -e "${CYAN}   📱 $(basename "$apk") (${SIZE})${NC}"
    fi
done
echo ""

# 创建安装脚本
log_info "创建安装脚本..."

INSTALL_SCRIPT="install_apks.sh"
cat > "$INSTALL_SCRIPT" << 'EOF'
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
EOF

chmod +x "$INSTALL_SCRIPT"
log_success "已创建安装脚本: $INSTALL_SCRIPT"
echo ""

# 创建快速启动脚本
QUICK_LAUNCH_SCRIPT="quick_launch.sh"
cat > "$QUICK_LAUNCH_SCRIPT" << 'EOF'
#!/bin/bash

# Flutter 朋友圈性能测试 - 快速启动脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_header() { echo -e "${CYAN}🚀 $1${NC}"; }

# 检查 adb
if ! command -v adb &> /dev/null; then
    echo -e "${RED}错误: adb 命令未找到${NC}"
    exit 1
fi

# 检查设备
if ! adb devices | grep -q "device$"; then
    echo -e "${RED}错误: 没有连接的设备${NC}"
    exit 1
fi

# 显示菜单
show_menu() {
    echo ""
    log_header "Flutter 朋友圈性能测试 - 快速启动"
    echo ""
    echo "选择 Flutter 版本:"
    echo "  1) Flutter 3.19 SurfaceView"
    echo "  2) Flutter 3.19 TextureView"
    echo "  3) Flutter 3.27 SurfaceView"
    echo "  4) Flutter 3.27 TextureView"
    echo "  5) Flutter 3.29 SurfaceView"
    echo "  6) Flutter 3.29 TextureView"
    echo ""
    echo "选择负载类型:"
    echo "  a) Minimal       b) Build Light   c) Build Medium"
    echo "  d) Build Heavy   e) Paint Light   f) Paint Medium"
    echo "  g) Paint Heavy   h) PostFrame Light   i) PostFrame Medium"
    echo "  j) PostFrame Heavy   k) Mixed Light   l) Mixed Medium"
    echo "  m) Mixed Heavy"
    echo ""
    echo "  q) 退出"
    echo ""
}

# 包名映射
declare -A PACKAGES=(
    ["1"]="com.example.friendscircle.v19"
    ["2"]="com.example.friendscircle.v19.textureview"
    ["3"]="com.example.friendscircle.v27"
    ["4"]="com.example.friendscircle.v27.textureview"
    ["5"]="com.example.friendscircle.v29"
    ["6"]="com.example.friendscircle.v29.textureview"
)

# 负载类型映射
declare -A LOAD_TYPES=(
    ["a"]="minimal"
    ["b"]="build_light"
    ["c"]="build_medium"
    ["d"]="build_heavy"
    ["e"]="paint_light"
    ["f"]="paint_medium"
    ["g"]="paint_heavy"
    ["h"]="postframe_light"
    ["i"]="postframe_medium"
    ["j"]="postframe_heavy"
    ["k"]="mixed_light"
    ["l"]="mixed_medium"
    ["m"]="mixed_heavy"
)

declare -A LOAD_NAMES=(
    ["a"]="Minimal"
    ["b"]="Build Light"
    ["c"]="Build Medium"
    ["d"]="Build Heavy"
    ["e"]="Paint Light"
    ["f"]="Paint Medium"
    ["g"]="Paint Heavy"
    ["h"]="PostFrame Light"
    ["i"]="PostFrame Medium"
    ["j"]="PostFrame Heavy"
    ["k"]="Mixed Light"
    ["l"]="Mixed Medium"
    ["m"]="Mixed Heavy"
)

# 主循环
while true; do
    show_menu
    read -p "请选择 (1-6, a-m, q): " choice

    if [[ "$choice" == "q" ]]; then
        echo "退出"
        exit 0
    fi

    # 解析选择
    version_choice="${choice:0:1}"
    load_choice="${choice:1}"

    if [[ -z "${PACKAGES[$version_choice]}" ]] || [[ -z "${LOAD_TYPES[$load_choice]}" ]]; then
        echo -e "${RED}无效选择，请重试${NC}"
        continue
    fi

    PACKAGE="${PACKAGES[$version_choice]}"
    LOAD_TYPE="${LOAD_TYPES[$load_choice]}"
    LOAD_NAME="${LOAD_NAMES[$load_choice]}"

    log_info "启动: $PACKAGE - $LOAD_NAME"

    adb shell am start -n "$PACKAGE/.MainActivity" -e "load" "$LOAD_TYPE"

    if [ $? -eq 0 ]; then
        log_success "启动成功!"
    else
        echo -e "${RED}启动失败，应用可能未安装${NC}"
    fi
done
EOF

chmod +x "$QUICK_LAUNCH_SCRIPT"
log_success "已创建快速启动脚本: $QUICK_LAUNCH_SCRIPT"
echo ""

# 实用命令提示
log_header "实用命令"
echo -e "${YELLOW}# 安装所有 APK${NC}"
echo -e "${YELLOW}   ./install_apks.sh${NC}"
echo ""
echo -e "${YELLOW}# 快速启动应用${NC}"
echo -e "${YELLOW}   ./quick_launch.sh${NC}"
echo ""
echo -e "${YELLOW}# 单独安装指定版本${NC}"
echo -e "${YELLOW}   adb install apk-release/friends_circle_v27sv_release.apk${NC}"
echo ""
echo -e "${YELLOW}# 启动指定版本和负载${NC}"
echo -e "${YELLOW}   adb shell am start -n com.example.friendscircle.v27/.MainActivity -e \"load\" \"build_heavy\"${NC}"
echo ""
echo -e "${YELLOW}# 查看已安装的应用${NC}"
echo -e "${YELLOW}   adb shell pm list packages | grep friendscircle${NC}"
echo ""

log_success "脚本执行完成! 🎉"
