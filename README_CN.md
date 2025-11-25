# 朋友圈Demo - Flutter性能功耗测试

## 📊 项目状态

[![Flutter 3.27](https://img.shields.io/badge/Flutter-3.27-blue.svg)](https://flutter.dev)
[![Flutter 3.29](https://img.shields.io/badge/Flutter-3.29-green.svg)](https://flutter.dev)
[![API Level](https://img.shields.io/badge/API-21%2B-blue.svg)](https://android-arsenal.com/api?level=21)
[![Dart](https://img.shields.io/badge/Dart-2.17%2B-orange.svg)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)](https://flutter.dev)
[![FVM](https://img.shields.io/badge/FVM-Required-yellow.svg)](https://fvm.app)
[![Load Types](https://img.shields.io/badge/Load%20Types-13-orange.svg)]()

一个用于性能和功耗测试的微信朋友圈Flutter应用，支持Flutter 3.27和3.29双版本，提供**13种负载类型**的全面性能测试。

*[English Documentation](README.md)*

## 🚀 快速开始

```bash
# 检查环境
./check_env.sh

# 构建所有版本
./build_flutter_apks.sh

# 快速构建单个版本
./quick_build.sh 3.27
./quick_build.sh 3.29
```

## 📱 13种负载类型

本项目支持13种不同的负载类型，覆盖Flutter应用的各种性能场景：

### 负载类型一览表

| 类别 | 负载类型 | ADB参数 | 说明 |
|-----|---------|--------|------|
| **基准负载** | 最轻负载 | `minimal` | 无额外计算，作为性能基准 |
| **Build负载（帧内）** | Build轻负载 | `build_light` | Widget.build()中轻量CPU计算 |
| | Build中负载 | `build_medium` | Widget.build()中中等CPU计算 |
| | Build重负载 | `build_heavy` | Widget.build()中重度CPU计算 |
| **Paint负载（帧内-GPU）** | Paint轻负载 | `paint_light` | CustomPainter绑制少量图形 |
| | Paint中负载 | `paint_medium` | CustomPainter绘制中等图形+阴影 |
| | Paint重负载 | `paint_heavy` | CustomPainter绘制大量复杂图形 |
| **PostFrame负载（帧间）** | PostFrame轻负载 | `postframe_light` | 帧渲染后轻量计算 |
| | PostFrame中负载 | `postframe_medium` | 帧渲染后中等计算 |
| | PostFrame重负载 | `postframe_heavy` | 帧渲染后重度计算 |
| **Mixed负载（混合）** | Mixed轻负载 | `mixed_light` | Build+PostFrame组合轻负载 |
| | Mixed中负载 | `mixed_medium` | Build+PostFrame组合中负载 |
| | Mixed重负载 | `mixed_heavy` | Build+PostFrame组合重负载 |

### 负载类型详解

#### 1. Build负载（帧内）
- **执行时机**: 在`Widget.build()`方法中
- **影响**: 直接影响UI线程的帧构建时间
- **模拟场景**: 复杂的业务逻辑计算、数据处理

#### 2. Paint负载（帧内-GPU）
- **执行时机**: 在`CustomPainter.paint()`方法中
- **影响**: 产生GPU负载，影响绘制性能
- **模拟场景**: 复杂图形绘制、动画效果、特效

#### 3. PostFrame负载（帧间）
- **执行时机**: 在`addPostFrameCallback()`中
- **影响**: 在帧渲染完成后执行，影响帧间隔
- **模拟场景**: 后台数据同步、缓存处理

#### 4. Mixed负载（混合）
- **组合方式**: Build负载(50%) + PostFrame负载(50%)
- **影响**: 同时影响帧内和帧间性能
- **模拟场景**: 真实复杂应用的综合负载

## 项目结构

```
FriendsCircle_Flutter/
├── README.md                   # 英文文档
├── README_CN.md               # 中文文档
├── build_flutter_apks.sh      # 完整构建脚本
├── quick_build.sh             # 快速构建脚本
├── check_env.sh               # 环境检查脚本
├── apk/                       # APK输出目录
│   ├── friends-flutter-v27-release.apk        # SurfaceView版本
│   ├── friends-flutter-v29-release.apk        # SurfaceView版本
│   ├── friends-flutter-v27-textureview.apk    # TextureView版本
│   └── friends-flutter-v29-textureview.apk    # TextureView版本
├── 3.27/                      # Flutter 3.27项目 (SurfaceView)
├── 3.29/                      # Flutter 3.29项目 (SurfaceView)
├── 3.27_TextureView/          # Flutter 3.27项目 (TextureView)
└── 3.29_TextureView/          # Flutter 3.29项目 (TextureView)
```

## 代码架构

```
lib/
├── main.dart                    # 应用入口，支持ADB深层链接
├── constants.dart               # 常量定义（13种负载类型、颜色等）
├── data/
│   └── data_center.dart         # 数据中心（测试数据生成）
├── utils/
│   ├── load_calculator.dart     # 负载计算工具类
│   └── asset_generator.dart     # 资源生成工具
├── models/                      # 数据模型
├── screens/
│   ├── home_screen.dart         # 主页（负载类型选择）
│   └── unified_load_screen.dart # 统一负载测试屏幕
└── widgets/
    ├── paint_load_painter.dart  # Paint负载CustomPainter
    ├── post_item.dart           # 帖子组件
    └── ...                      # 其他UI组件
```

## 四个项目版本

该仓库包含四个独立的Flutter项目，形成2x2测试矩阵：

### Flutter版本 × 渲染模式

|  | SurfaceView | TextureView |
|--|-------------|-------------|
| **Flutter 3.27** | 3.27/ | 3.27_TextureView/ |
| **Flutter 3.29** | 3.29/ | 3.29_TextureView/ |

### 版本信息

| 版本 | 包名 | 应用名 | 渲染模式 |
|-----|------|-------|---------|
| 3.27 | `com.example.friendscircle.v27` | 朋友圈V27 | SurfaceView |
| 3.29 | `com.example.friendscircle.v29` | 朋友圈V29 | SurfaceView |
| 3.27_TextureView | `com.example.friendscircle.v27.textureview` | 朋友圈V27-TextureView | TextureView |
| 3.29_TextureView | `com.example.friendscircle.v29.textureview` | 朋友圈V29-TextureView | TextureView |

## 🚀 ADB自动化测试

### 命令模板

```bash
# 启动到指定的负载场景
adb shell am start -n <包名>/.MainActivity -e "load" "<负载类型>"

# 正常启动（显示主页）
adb shell am start -n <包名>/.MainActivity
```

### 完整负载类型列表

```bash
# 基准负载
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "minimal"

# Build负载（帧内）
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "build_light"
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "build_medium"
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "build_heavy"

# Paint负载（帧内-GPU）
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "paint_light"
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "paint_medium"
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "paint_heavy"

# PostFrame负载（帧间）
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "postframe_light"
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "postframe_medium"
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "postframe_heavy"

# Mixed负载（混合）
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "mixed_light"
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "mixed_medium"
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "mixed_heavy"
```

### 兼容旧版命令

```bash
# 以下命令仍然有效（映射到Build负载）
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "light"
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "medium"
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "heavy"
```

## 构建要求

- **Flutter SDK**：3.27和3.29版本
- **FVM**：Flutter版本管理工具
- **Android SDK**：API 21+
- **iOS**：12.0+

## 安装方法

```bash
# 安装指定版本
adb install apk/friends-flutter-v27-release.apk
adb install apk/friends-flutter-v29-release.apk
adb install apk/friends-flutter-v27-textureview.apk
adb install apk/friends-flutter-v29-textureview.apk

# 批量安装
for apk in apk/*.apk; do adb install "$apk"; done
```

## 负载参数配置

### Build负载迭代次数
| 级别 | 迭代次数 |
|-----|---------|
| 轻 | 10 |
| 中 | 2,000 |
| 重 | 20,000 |

### Paint负载图形数量
| 级别 | 图形数量 | 路径点数 | 阴影 | 模糊 |
|-----|---------|---------|-----|-----|
| 轻 | 50 | 10 | ❌ | ❌ |
| 中 | 200 | 50 | ✅ | ❌ |
| 重 | 800 | 200 | ✅ | ✅ |

### PostFrame负载迭代次数
| 级别 | 迭代次数 |
|-----|---------|
| 轻 | 5,000 |
| 中 | 50,000 |
| 重 | 200,000 |

### Mixed负载组合
| 级别 | Build迭代 | PostFrame迭代 |
|-----|----------|--------------|
| 轻 | 5 | 2,500 |
| 中 | 1,000 | 25,000 |
| 重 | 10,000 | 100,000 |

## 相关项目

- [Friends-Circle-Demo-Apks-For-Power-and-Performance-Test](https://github.com/Gracker/Friends-Circle-Demo-Apks-For-Power-and-Performance-Test) - AOSP原生实现版本

## 许可证

MIT License
