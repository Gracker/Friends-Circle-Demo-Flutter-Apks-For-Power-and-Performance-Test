# 朋友圈Demo - Flutter性能功耗测试

## 📊 项目状态

[![Flutter 3.27](https://img.shields.io/badge/Flutter-3.27-blue.svg)](https://flutter.dev)
[![Flutter 3.29](https://img.shields.io/badge/Flutter-3.29-green.svg)](https://flutter.dev)
[![API Level](https://img.shields.io/badge/API-21%2B-blue.svg)](https://android-arsenal.com/api?level=21)
[![Dart](https://img.shields.io/badge/Dart-2.17%2B-orange.svg)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)](https://flutter.dev)
[![FVM](https://img.shields.io/badge/FVM-Required-yellow.svg)](https://fvm.app)

一个用于性能和功耗测试的微信朋友圈Flutter应用，支持Flutter 3.27和3.29双版本。

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

## 项目结构

```
FriendsCircle_Flutter/
├── README.md                   # 英文文档
├── README_CN.md               # 中文文档
├── BUILD_GUIDE.md             # 构建指南
├── build_flutter_apks.sh      # 完整构建脚本
├── build_flutter_apks_cn.sh   # 中文构建脚本
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

## 四个项目版本的目的

该仓库包含四个独立的Flutter项目，旨在创建一个全面的性能测试矩阵。其目标是围绕两个关键维度来分析和比较性能：**Flutter SDK版本** 和 **Android渲染模式**。

1.  **Flutter版本对比 (`3.27` vs. `3.29`)**
    -   这允许在两个不同的Flutter SDK版本之间进行直接的性能比较。这对于在计划框架升级时，识别潜在的性能衰退或改进至关重要。

2.  **Android渲染模式对比 (`SurfaceView` vs. `TextureView`)**
    -   **SurfaceView (`3.27` 和 `3.29` 目录):** 这是Flutter在Android上的默认渲染模式。它的性能非常高，但在与原生Android视图集成时存在限制（即“平台视图空域问题”）。
    -   **TextureView (`3.27_TextureView` 和 `3.29_TextureView` 目录):** 此渲染模式使Flutter视图的行为类似于标准的Android视图，允许它被变换、设置动画以及与其他视图分层。这种兼容性可能会带来一定的性能开销。

通过在这个2x2的矩阵中进行测试，我们可以回答诸如“Flutter 3.29是否提升了TextureView的性能？”或“新版Flutter中SurfaceView和TextureView之间的性能差距是否缩小了？”等问题。

## 版本信息

### SurfaceView 版本 (Flutter 默认渲染)
| 版本 | 包名 | 应用名 | Flutter约束 | 渲染模式 |
|---------|--------------|----------|-------------------|----------------|
| 3.27 | `com.example.friendscircle.v27` | 朋友圈V27 | `>=3.27.0 <3.28.0` | SurfaceView |
| 3.29 | `com.example.friendscircle.v29` | 朋友圈V29 | `>=3.29.0 <4.0.0` | SurfaceView |

### TextureView 版本 (官方 FlutterTextureView)
| 版本 | 包名 | 应用名 | Flutter约束 | 渲染模式 |
|---------|--------------|----------|-------------------|----------------|
| 3.27_TextureView | `com.example.friendscircle.v27.textureview` | 朋友圈V27-TextureView | `>=3.27.0 <3.28.0` | TextureView |
| 3.29_TextureView | `com.example.friendscircle.v29.textureview` | 朋友圈V29-TextureView | `>=3.29.0 <4.0.0` | TextureView |

## APK 说明

该项目提供 **7个不同的测试应用**，用于全面的性能和功耗分析：

### 1. **Flutter SurfaceView** (当前项目)
- **说明**: 提供两个使用SurfaceView渲染的Flutter版本 (3.27 & 3.29)
- **目的**: 测试使用默认SurfaceView渲染的Flutter框架性能
- **特性**: 标准Flutter渲染、双版本构建、自动化CI/CD、已签名的APK
- **位置**: 当前仓库 (`3.27/` 和 `3.29/` 目录)

### 2. **Flutter TextureView** (当前项目)
- **说明**: 提供两个使用TextureView渲染的Flutter版本 (3.27 & 3.29)
- **目的**: 用于对比测试使用TextureView渲染的Flutter框架性能
- **特性**: 官方FlutterTextureView实现、双版本构建、已签名的APK
- **技术**: 使用 `FlutterActivity.getRenderMode() = RenderMode.texture`
- **位置**: 当前仓库 (`3.27_TextureView/` 和 `3.29_TextureView/` 目录)

### 3. **AOSP 性能版** 
- **文件**: `wechatfriendforperformance-release.apk`
- **说明**: 使用标准AOSP实现，用于性能测试的应用
- **特性**: 三种负载级别 (轻/中/重)，用于平台性能和功耗测试
- **仓库**: [Friends-Circle-Demo-Apks-For-Power-and-Performance-Test](https://github.com/Gracker/Friends-Circle-Demo-Apks-For-Power-and-Performance-Test/tree/master/apk-released)

### 4. **AOSP 固定内容版**
- **文件**: `wechatfriendforpower-release.apk` 
- **说明**: 修改版应用，具有固定的微信朋友圈界面
- **特性**: 内容和项目位置一致，用于稳定的性能/功耗测试
- **用途**: 具有可预测负载模式的基准测试
- **仓库**: [Friends-Circle-Demo-Apks-For-Power-and-Performance-Test](https://github.com/Gracker/Friends-Circle-Demo-Apks-For-Power-and-Performance-Test/tree/master/apk-released)

### 5. **WebView 实现版**
- **文件**: `wechatfriendforwebview-release.apk`
- **说明**: 使用标准WebView实现，用于性能测试的应用
- **特性**: 三种负载级别，用于平台性能和功耗测试
- **目的**: 对比原生与WebView的性能特征
- **仓库**: [Friends-Circle-Demo-Apks-For-Power-and-Performance-Test](https://github.com/Gracker/Friends-Circle-Demo-Apks-For-Power-and-Performance-Test/tree/master/apk-released)

### 6. **高性能版**
- **额外APK**: 在配套仓库中提供
- **目的**: 用于最大性能基准测试的优化实现
- **仓库**: [Friends-Circle-Demo-Apks-For-Power-and-Performance-Test](https://github.com/Gracker/Friends-Circle-Demo-Apks-For-Power-and-Performance-Test/tree/master/apk-released)

## 功能特性

### 性能测试
- **轻负载测试**：基础功能测试
- **中负载测试**：正常使用场景
- **重负载测试**：极限性能测试
- **双版本对比**：Flutter版本间性能对比
- **渲染模式对比**：对比SurfaceView与TextureView的性能

### 核心功能
- 图片浏览和分享
- 点赞和评论功能
- 列表滚动优化
- 图片缓存
- 本地数据存储

## 构建要求

- **Flutter SDK**：3.27和3.29版本
- **FVM**：Flutter版本管理工具
- **Android SDK**：API 21+
- **iOS**：12.0+

## 输出文件

所有构建均生成标准化的英文命名文件：
- `friends-flutter-v27-release.apk` (SurfaceView)
- `friends-flutter-v29-release.apk` (SurfaceView)
- `friends-flutter-v27-textureview.apk` (TextureView)
- `friends-flutter-v29-textureview.apk` (TextureView)

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

## 🚀 用于自动化测试的深层链接

为了方便自动化测试，您可以使用`adb`命令直接启动应用并进入特定的负载测试场景（轻、中、重负载）。这是通过在启动时传递一个`Intent`额外参数（`-e "load" "<场景>"`）来实现的。

### 命令模板

```bash
# 启动到指定的负载场景
adb shell am start -n <包名>/.MainActivity -e "load" "<场景>"

# 正常启动（显示主页）
adb shell am start -n <包名>/.MainActivity
```

-   将 `<包名>` 替换为目标应用的包名。
-   将 `<场景>` 替换为以下之一: `light`, `medium`, `heavy`。

### 各版本包名

| App 版本             | 包名                                               |
| -------------------- | -------------------------------------------------- |
| 3.27 (SurfaceView)   | `com.example.friendscircle.v27`                    |
| 3.29 (SurfaceView)   | `com.example.friendscircle.v29`                    |
| 3.27 (TextureView)   | `com.example.friendscircle.v27.textureview`        |
| 3.29 (TextureView)   | `com.example.friendscircle.v29.textureview`        |

### 示例

要启动 **v27 (SurfaceView)** 应用的**轻负载测试**：

```bash
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "light"
```

## 相关文档

- [BUILD_GUIDE.md](BUILD_GUIDE.md) - 详细构建说明
- [README.md](README.md) - 英文文档

## 许可证

MIT License
