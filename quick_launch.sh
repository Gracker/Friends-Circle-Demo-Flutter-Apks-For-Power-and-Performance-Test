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
