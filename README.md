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
├── quick_build.sh             # Quick build script
├── check_env.sh               # Environment check
├── apk/                       # APK output directory
│   ├── friends-flutter-v27-release.apk
│   └── friends-flutter-v29-release.apk
├── 3.27/                      # Flutter 3.27 project
└── 3.29/                      # Flutter 3.29 project
```

## Version Information

| Version | Package Name | App Name | Flutter Constraint |
|---------|--------------|----------|-------------------|
| 3.27 | `com.example.friendscircle.v27` | Flutter V3.27 朋友圈性能功耗测试 Demo | `>=3.27.0 <3.28.0` |
| 3.29 | `com.example.friendscircle.v29` | Flutter V3.29 朋友圈性能功耗测试 Demo | `>=3.29.0 <4.0.0` |

## Features

### Performance Testing
- **Light Load**: Basic functionality testing
- **Medium Load**: Normal usage scenarios  
- **Heavy Load**: Extreme performance testing
- **Dual Version Comparison**: Compare performance between Flutter versions

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
- `friends-flutter-v27-release.apk`
- `friends-flutter-v29-release.apk`

## Installation

```bash
# Install specific version
adb install apk/friends-flutter-v27-release.apk
adb install apk/friends-flutter-v29-release.apk

# Batch install
for apk in apk/*.apk; do adb install "$apk"; done
```

## Documentation

- [BUILD_GUIDE.md](BUILD_GUIDE.md) - Detailed build instructions
- [README_CN.md](README_CN.md) - Chinese documentation

## License

MIT License