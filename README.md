# Friends Circle Demo - Flutter Performance & Power Test

## 📊 Project Status

[![Flutter 3.27](https://img.shields.io/badge/Flutter-3.27-blue.svg)](https://flutter.dev)
[![Flutter 3.29](https://img.shields.io/badge/Flutter-3.29-green.svg)](https://flutter.dev)
[![API Level](https://img.shields.io/badge/API-21%2B-blue.svg)](https://android-arsenal.com/api?level=21)
[![Dart](https://img.shields.io/badge/Dart-2.17%2B-orange.svg)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)](https://flutter.dev)
[![FVM](https://img.shields.io/badge/FVM-Required-yellow.svg)](https://fvm.app)

A Flutter WeChat Moments application supporting dual Flutter versions (3.27 & 3.29) for performance and power consumption testing.

*[中文文档](README_CN.md)*

## 🚀 Quick Start

```bash
# Check environment
./check_env.sh

# Build all versions
./build_flutter_apks.sh

# Quick build single version
./quick_build.sh 3.27
./quick_build.sh 3.29
```

## Project Structure

```
FriendsCircle_Flutter/
├── README.md                   # English documentation
├── README_CN.md               # Chinese documentation
├── BUILD_GUIDE.md             # Build guide
├── build_flutter_apks.sh      # Complete build script
├── build_flutter_apks_cn.sh   # CN build script
├── quick_build.sh             # Quick build script
├── check_env.sh               # Environment check
├── apk/                       # APK output directory
│   ├── friends-flutter-v27-release.apk        # SurfaceView version
│   ├── friends-flutter-v29-release.apk        # SurfaceView version
│   ├── friends-flutter-v27-textureview.apk    # TextureView version
│   └── friends-flutter-v29-textureview.apk    # TextureView version
├── 3.27/                      # Flutter 3.27 project (SurfaceView)
├── 3.29/                      # Flutter 3.29 project (SurfaceView)
├── 3.27_TextureView/          # Flutter 3.27 project (TextureView)
└── 3.29_TextureView/          # Flutter 3.29 project (TextureView)
```

## Purpose of the Four Project Variants

This repository contains four distinct Flutter projects to create a comprehensive performance testing matrix. The goal is to analyze and compare performance across two key dimensions: **Flutter SDK version** and **Android rendering mode**.

1.  **Flutter Version Comparison (`3.27` vs. `3.29`)**
    -   This allows for direct performance comparison between two different Flutter SDK versions. It's crucial for identifying potential performance regressions or improvements when planning a framework upgrade.

2.  **Android Rendering Mode Comparison (`SurfaceView` vs. `TextureView`)**
    -   **SurfaceView (`3.27` & `3.29` directories):** This is Flutter's default rendering mode on Android. It is highly performant but has limitations when integrating with native Android views (known as the "platform view airspace problem").
    -   **TextureView (`3.27_TextureView` & `3.29_TextureView` directories):** This rendering mode makes a Flutter view behave like a standard Android view, allowing it to be transformed, animated, and layered with other views. This compatibility comes at a potential performance cost.

By testing across this 2x2 matrix, we can answer questions like, "Did Flutter 3.29 improve performance on TextureView?" or "Is the performance gap between SurfaceView and TextureView smaller in the newer Flutter version?".

## Version Information

### SurfaceView Versions (Default Flutter Rendering)
| Version | Package Name | App Name | Flutter Constraint | Rendering Mode |
|---------|--------------|----------|-------------------|----------------|
| 3.27 | `com.example.friendscircle.v27` | 朋友圈V27 | `>=3.27.0 <3.28.0` | SurfaceView |
| 3.29 | `com.example.friendscircle.v29` | 朋友圈V29 | `>=3.29.0 <4.0.0` | SurfaceView |

### TextureView Versions (Official FlutterTextureView)
| Version | Package Name | App Name | Flutter Constraint | Rendering Mode |
|---------|--------------|----------|-------------------|----------------|
| 3.27_TextureView | `com.example.friendscircle.v27.textureview` | 朋友圈V27-TextureView | `>=3.27.0 <3.28.0` | TextureView |
| 3.29_TextureView | `com.example.friendscircle.v29.textureview` | 朋友圈V29-TextureView | `>=3.29.0 <4.0.0` | TextureView |

## APK Description

This project provides **7 different testing applications** for comprehensive performance and power consumption analysis:

### 1. **Flutter SurfaceView** (Current Project)
- **Description**: Provides two Flutter versions (3.27 & 3.29) using SurfaceView rendering
- **Purpose**: Test Flutter framework performance with default SurfaceView rendering
- **Features**: Standard Flutter rendering, dual version builds, automated CI/CD, signed APKs
- **Location**: Current repository (`3.27/` and `3.29/` directories)

### 2. **Flutter TextureView** (Current Project)
- **Description**: Provides two Flutter versions (3.27 & 3.29) using TextureView rendering
- **Purpose**: Test Flutter framework performance with TextureView rendering for comparison
- **Features**: Official FlutterTextureView implementation, dual version builds, signed APKs
- **Technical**: Uses `FlutterActivity.getRenderMode() = RenderMode.texture`
- **Location**: Current repository (`3.27_TextureView/` and `3.29_TextureView/` directories)

### 3. **AOSP Performance** 
- **File**: `wechatfriendforperformance-release.apk`
- **Description**: Performance testing app using standard AOSP implementation
- **Features**: Three load levels (Light/Medium/Heavy) for platform performance and power testing
- **Repository**: [Friends-Circle-Demo-Apks-For-Power-and-Performance-Test](https://github.com/Gracker/Friends-Circle-Demo-Apks-For-Power-and-Performance-Test/tree/master/apk-released)

### 4. **AOSP Fixed Content**
- **File**: `wechatfriendforpower-release.apk` 
- **Description**: Modified original app with fixed WeChat Moments interface
- **Features**: Consistent content and item positioning for stable performance/power testing
- **Use Case**: Baseline testing with predictable load patterns
- **Repository**: [Friends-Circle-Demo-Apks-For-Power-and-Performance-Test](https://github.com/Gracker/Friends-Circle-Demo-Apks-For-Power-and-Performance-Test/tree/master/apk-released)

### 5. **WebView Implementation**
- **File**: `wechatfriendforwebview-release.apk`
- **Description**: Performance testing app using standard WebView implementation
- **Features**: Three load levels for platform performance and power testing
- **Purpose**: Compare native vs WebView performance characteristics
- **Repository**: [Friends-Circle-Demo-Apks-For-Power-and-Performance-Test](https://github.com/Gracker/Friends-Circle-Demo-Apks-For-Power-and-Performance-Test/tree/master/apk-released)

### 6. **High Performance**
- **Additional APK**: Available in the companion repository
- **Purpose**: Optimized implementation for maximum performance benchmarks
- **Repository**: [Friends-Circle-Demo-Apks-For-Power-and-Performance-Test](https://github.com/Gracker/Friends-Circle-Demo-Apks-For-Power-and-Performance-Test/tree/master/apk-released)

## Features

### Performance Testing
- **Light Load**: Basic functionality testing
- **Medium Load**: Normal usage scenarios  
- **Heavy Load**: Extreme performance testing
- **Dual Version Comparison**: Compare performance between Flutter versions
- **Rendering Mode Comparison**: Compare SurfaceView vs TextureView performance

### Core Components
- Image browsing and sharing
- Like and comment functionality
- Optimized list scrolling
- Image caching
- Local data storage

## Build Requirements

- **Flutter SDK**: Versions 3.27 and 3.29
- **FVM**: Flutter version management
- **Android SDK**: API 21+
- **iOS**: 12.0+

## Output Files

All builds generate standardized English-named files:
- `friends-flutter-v27-release.apk` (SurfaceView)
- `friends-flutter-v29-release.apk` (SurfaceView)
- `friends-flutter-v27-textureview.apk` (TextureView)
- `friends-flutter-v29-textureview.apk` (TextureView)

## Installation

```bash
# Install specific version
adb install apk/friends-flutter-v27-release.apk
adb install apk/friends-flutter-v29-release.apk
adb install apk/friends-flutter-v27-textureview.apk
adb install apk/friends-flutter-v29-textureview.apk

# Batch install
for apk in apk/*.apk; do adb install "$apk"; done
```

## 🚀 Deep Linking for Automated Testing

To facilitate automated testing, you can launch the application directly into a specific load test scenario (Light, Medium, or Heavy) using `adb` commands. This is achieved by passing an `Intent` extra (`-e "load" "<scenario>"`) during launch.

### Command Template

```bash
# Launch into a specific load scenario
adb shell am start -n <package_name>/.MainActivity -e "load" "<scenario>"

# Normal launch (shows the home screen)
adb shell am start -n <package_name>/.MainActivity
```

-   Replace `<package_name>` with the target application's package name.
-   Replace `<scenario>` with one of the following: `light`, `medium`, `heavy`.

### Package Names

| App Version          | Package Name                                       |
| -------------------- | -------------------------------------------------- |
| 3.27 (SurfaceView)   | `com.example.friendscircle.v27`                    |
| 3.29 (SurfaceView)   | `com.example.friendscircle.v29`                    |
| 3.27 (TextureView)   | `com.example.friendscircle.v27.textureview`        |
| 3.29 (TextureView)   | `com.example.friendscircle.v29.textureview`        |

### Example

To launch the **light load test** on the **v27 (SurfaceView)** app:

```bash
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "light"
```

## Documentation

- [BUILD_GUIDE.md](BUILD_GUIDE.md) - Detailed build instructions
- [README_CN.md](README_CN.md) - Chinese documentation

## License

MIT License