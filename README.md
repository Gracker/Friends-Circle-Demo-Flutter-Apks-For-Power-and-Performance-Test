# Flutter朋友圈项目

这是一个使用Flutter开发的朋友圈应用，支持Flutter 3.27和3.29两个版本。

## 项目结构

```
FriendsCircle_Flutter/
├── 3.27/               # Flutter 3.27版本的项目代码
└── 3.29/               # Flutter 3.29版本的项目代码
```

## 版本说明

### Flutter 3.27版本
- 包名：com.example.friendscircle.v27
- 应用名：朋友圈V27
- 图标：蓝色主题

### Flutter 3.29版本
- 包名：com.example.friendscircle.v29
- 应用名：朋友圈V29
- 图标：绿色主题

## 开发环境要求

- Flutter SDK: 支持3.27和3.29版本
- Android Studio: 最新版本
- Xcode: 最新版本
- Android SDK: API 35
- iOS: iOS 12.0及以上

## 构建说明

### Flutter 3.27版本
```bash
cd 3.27
flutter clean
flutter pub get
flutter build apk --debug  # Android版本
flutter build ios          # iOS版本
```

### Flutter 3.29版本
```bash
cd 3.29
flutter clean
flutter pub get
flutter build apk --debug  # Android版本
flutter build ios          # iOS版本
```

## 功能特性

- 支持图片浏览和分享
- 支持点赞和评论
- 支持朋友圈列表滚动优化
- 支持图片缓存
- 支持本地数据存储

## 代码同步

两个版本的代码需要保持同步，在一个版本中修改代码后，需要同步到另一个版本。 