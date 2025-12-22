# Flutter 朋友圈性能测试

## 📊 项目状态

[![Flutter 3.27](https://img.shields.io/badge/Flutter-3.27-blue.svg)](https://flutter.dev)
[![Flutter 3.29](https://img.shields.io/badge/Flutter-3.29-green.svg)](https://flutter.dev)
[![API Level](https://img.shields.io/badge/API-21%2B-blue.svg)](https://android-arsenal.com/api?level=21)
[![Dart](https://img.shields.io/badge/Dart-2.17%2B-orange.svg)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)](https://flutter.dev)
[![FVM](https://img.shields.io/badge/FVM-Required-yellow.svg)](https://fvm.app)
[![Load Types](https://img.shields.io/badge/Load%20Types-13-orange.svg)]()


## 快速开始

```bash
# 构建所有版本
./build_release.sh

# 安装到设备
./install_apks.sh

# 快速启动（交互式菜单）
./quick_launch.sh
```

## 为什么有 6 个 APK 版本？

这个项目包含 **6 个独立的 APK**，用于在两个维度上进行性能对比测试：

### 维度一：Flutter 版本对比 (3.19 vs 3.27 vs 3.29)

| 版本 | 渲染引擎 | 主要变化 |
|------|----------|----------|
| **Flutter 3.19** | Skia | 基准版本，使用传统 Skia 渲染器 |
| **Flutter 3.27** | Impeller | Impeller 成为默认渲染引擎，底层从 `queueBuffer/dequeueBuffer` 改为 `QueueSubmit` |
| **Flutter 3.29** | Impeller | Impeller 渲染引擎进一步优化 |

**测试目的**：评估 Flutter 升级对性能的影响，特别是 3.27 版本引入 Impeller 后的性能变化。

### 维度二：Android 渲染模式对比 (SurfaceView vs TextureView)

| 渲染模式 | 特点 | 性能 |
|----------|------|------|
| **SurfaceView** | Flutter 默认模式，直接渲染到 Surface | 性能最佳 |
| **TextureView** | 渲染到 SurfaceTexture，支持视图变换/动画 | 有额外性能开销 |

**测试目的**：对比不同渲染模式下的性能差异，评估 TextureView 的性能损耗。

### APK 版本对照表

| 应用名称 | Flutter 版本 | 渲染模式 | 包名 |
|----------|-------------|----------|------|
| Flu-V319-Surface | 3.19 | SurfaceView | `com.example.friendscircle.v19` |
| Flu-V319-Texture | 3.19 | TextureView | `com.example.friendscircle.v19.textureview` |
| Flu-V327-Surface | 3.27 | SurfaceView | `com.example.friendscircle.v27` |
| Flu-V327-Texture | 3.27 | TextureView | `com.example.friendscircle.v27.textureview` |
| Flu-V329-Surface | 3.29 | SurfaceView | `com.example.friendscircle.v29` |
| Flu-V329-Texture | 3.29 | TextureView | `com.example.friendscircle.v29.textureview` |

## 负载类型

每个应用支持 13 种负载类型，用于测试不同场景下的性能表现：

| 类别 | 负载类型 | 说明 |
|------|----------|------|
| **Baseline** | Minimal | 无额外计算，作为性能基线 |
| **Build** (In-Frame) | Light / Medium / Heavy | Widget.build() 阶段的 CPU 计算 |
| **Paint** (In-Frame GPU) | Light / Medium / Heavy | CustomPainter.paint() 阶段的 GPU 绘图 |
| **PostFrame** (Between-Frames) | Light / Medium / Heavy | 帧渲染后的 CPU 计算 |
| **Mixed** (Combined) | Light / Medium / Heavy | Build + PostFrame 混合负载 |

## ADB 快速启动

```bash
# 格式
adb shell am start -n <包名>/.MainActivity -e "load" "<负载类型>"

# 示例：启动 3.27 SurfaceView + Build Heavy
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "build_heavy"

# 示例：启动 3.29 TextureView + Paint Heavy
adb shell am start -n com.example.friendscircle.v29.textureview/.MainActivity -e "load" "paint_heavy"
```

## 负载类型参数

```bash
minimal          # 基线
build_light       # Build 轻负载
build_medium      # Build 中负载
build_heavy       # Build 重负载
paint_light       # Paint 轻负载
paint_medium      # Paint 中负载
paint_heavy       # Paint 重负载
postframe_light   # PostFrame 轻负载
postframe_medium  # PostFrame 中负载
postframe_heavy   # PostFrame 重负载
mixed_light       # Mixed 轻负载
mixed_medium      # Mixed 中负载
mixed_heavy       # Mixed 重负载
```

## 项目结构

```
FriendsCircle_Flutter/
├── 3.19_SurfaceView/    # Flutter 3.19 + SurfaceView
├── 3.19_TextureView/    # Flutter 3.19 + TextureView
├── 3.27_SurfaceView/    # Flutter 3.27 + SurfaceView
├── 3.27_TextureView/    # Flutter 3.27 + TextureView
├── 3.29_SurfaceView/    # Flutter 3.29 + SurfaceView
├── 3.29_TextureView/    # Flutter 3.29 + TextureView
├── build_release.sh     # 一键构建脚本
├── install_apks.sh      # 批量安装脚本
├── quick_launch.sh      # 快速启动脚本
└── apk-release/         # APK 输出目录
```
