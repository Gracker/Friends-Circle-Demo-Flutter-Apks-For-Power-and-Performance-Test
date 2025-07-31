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

## Documentation

- [BUILD_GUIDE.md](BUILD_GUIDE.md) - Detailed build instructions
- [README_CN.md](README_CN.md) - Chinese documentation

## License

MIT License