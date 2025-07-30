# 朋友圈Demo - Flutter性能功耗测试

## 📊 项目状态

[![Flutter 3.27](https://img.shields.io/badge/Flutter-3.27-blue.svg)](https://flutter.dev)
[![Flutter 3.29](https://img.shields.io/badge/Flutter-3.29-green.svg)](https://flutter.dev)
[![API Level](https://img.shields.io/badge/API-21%2B-blue.svg)](https://android-arsenal.com/api?level=21)
[![Dart](https://img.shields.io/badge/Dart-2.17%2B-orange.svg)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)](https://flutter.dev)
[![FVM](https://img.shields.io/badge/FVM-Required-yellow.svg)](https://fvm.app)

基于Flutter的微信朋友圈应用，支持Flutter 3.27和3.29双版本，用于性能和功耗对比测试。

*[English Documentation](README.md)*

## APK 说明
1. Fultter ： 当前项目，提供两个版本的 flutter，主要用来测试 Performance 和 Power。
2. AOSP ：wechatfriendforperformance-release ：用来测试性能的 App，使用标准的 AOSP 实现。进去后有三种负载可以选择，主要测试平台性能 or Power。（apk 地址：(https://github.com/Gracker/Friends-Circle-Demo-Apks-For-Power-and-Performance-Test/tree/master/apk-released)）
3. AOSP：wechatfriendforpower-release：原项目 App 魔改，进去后是一个固定显示内容的 微信朋友圈 界面，每次进去显示的内容和每个位置的 item 都是一样的，用来测试固定性能 or Power。（apk 地址：(https://github.com/Gracker/Friends-Circle-Demo-Apks-For-Power-and-Performance-Test/tree/master/apk-released)）
4. WebView：wechatfriendforwebview-release ：用来测试性能的 App，使用标准的 WebView 实现。进去后有三种负载可以选择，主要测试平台性能  or Power。（apk 地址：(https://github.com/Gracker/Friends-Circle-Demo-Apks-For-Power-and-Performance-Test/tree/master/apk-released)）


## 🚀 快速开始

```bash
# 环境检查
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
├── quick_build.sh             # 快速构建脚本
├── check_env.sh               # 环境检查脚本
├── apk/                       # APK输出目录
│   ├── friends-flutter-v27-release.apk
│   └── friends-flutter-v29-release.apk
├── 3.27/                      # Flutter 3.27项目代码
└── 3.29/                      # Flutter 3.29项目代码
```

## 版本信息

| 版本 | 包名 | 应用名 | Flutter约束 |
|------|------|--------|-------------|
| 3.27 | `com.example.friendscircle.v27` | Flutter V3.27 朋友圈性能功耗测试 Demo | `>=3.27.0 <3.28.0` |
| 3.29 | `com.example.friendscircle.v29` | Flutter V3.29 朋友圈性能功耗测试 Demo | `>=3.29.0 <4.0.0` |

## 功能特性

### 性能测试
- **轻负载测试**：基础功能测试
- **中负载测试**：正常使用场景
- **重负载测试**：极限性能测试
- **双版本对比**：Flutter版本间性能对比

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

所有构建生成标准化英文命名文件：
- `friends-flutter-v27-release.apk`
- `friends-flutter-v29-release.apk`

## 安装方法

```bash
# 安装指定版本
adb install apk/friends-flutter-v27-release.apk
adb install apk/friends-flutter-v29-release.apk

# 批量安装
for apk in apk/*.apk; do adb install "$apk"; done
```

## 相关文档

- [BUILD_GUIDE.md](BUILD_GUIDE.md) - 详细构建说明
- [README.md](README.md) - 英文文档

## 许可证

MIT License