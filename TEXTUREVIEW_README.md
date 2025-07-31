# Flutter TextureView 版本说明

## 项目概述

本项目新增了两个TextureView版本的实现：`3.27_TextureView` 和 `3.29_TextureView`，用于演示和对比Flutter在Android平台上的两种不同宿主渲染模式。

## 版本对比

现在项目包含以下四个版本：

### SurfaceView版本（原有）
- **3.27/**: Flutter 3.27 + SurfaceView（默认渲染模式）
- **3.29/**: Flutter 3.29 + SurfaceView（默认渲染模式）

### TextureView版本（新增）
- **3.27_TextureView/**: Flutter 3.27 + TextureView渲染模式
- **3.29_TextureView/**: Flutter 3.29 + TextureView渲染模式

## TextureView vs SurfaceView

### SurfaceView特点
- **性能优势**: 更好的渲染性能，适合高频率更新的场景
- **内存效率**: 更低的内存占用
- **限制**: 不支持某些视觉效果（如透明度、旋转、缩放等）
- **层级问题**: 总是在其他View的底层

### TextureView特点
- **灵活性**: 支持透明度、旋转、缩放等视觉效果
- **层级控制**: 可以与其他View正常层叠
- **动画支持**: 更好的动画效果支持
- **性能开销**: 相对更高的内存和CPU使用

## 技术实现

### 核心组件

1. **TextureViewWidget**: Flutter端的TextureView封装组件
2. **TextureViewFactory**: Android端的TextureView工厂类
3. **TextureViewMethodChannel**: Flutter与Android通信桥梁
4. **MainActivity**: 注册TextureView相关组件

### 关键配置

#### Android端配置
```kotlin
// MainActivity.kt
override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    
    // 注册TextureView PlatformView
    flutterEngine
        .platformViewsController
        .registry
        .registerViewFactory("flutter_texture_view", TextureViewFactory())
    
    // 设置方法通道
    val methodChannel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        "texture_view_bridge"
    )
}
```

#### Flutter端配置
```dart
// 使用TextureView渲染
AndroidView(
  viewType: 'flutter_texture_view',
  layoutDirection: TextDirection.ltr,
  creationParams: <String, dynamic>{},
  creationParamsCodec: const StandardMessageCodec(),
)
```

### 包名配置

#### 3.27_TextureView
- **包名**: `com.example.friendscircle.v27.textureview`
- **应用名**: `朋友圈V27-TextureView`
- **Flutter版本**: `>=3.27.0 <3.28.0`

#### 3.29_TextureView  
- **包名**: `com.example.friendscircle.v29.textureview`
- **应用名**: `朋友圈V29-TextureView`
- **Flutter版本**: `>=3.29.0 <4.0.0`

## 新增功能

### TextureView测试屏幕
- 专门的TextureView演示界面
- 实时状态显示（TextureView是否可用）
- 与原有朋友圈功能保持一致的UI
- 增加了TextureView渲染标识

### 方法通道功能
- `initialize()`: 初始化TextureView
- `updateContent()`: 更新TextureView内容
- `setProperty()`: 设置TextureView属性
- `getProperty()`: 获取TextureView属性

## 构建说明

### 构建命令
```bash
# 构建3.27_TextureView版本
cd 3.27_TextureView
fvm flutter clean
fvm flutter pub get
fvm flutter build apk --release

# 构建3.29_TextureView版本
cd 3.29_TextureView
fvm flutter clean
fvm flutter pub get
fvm flutter build apk --release
```

### 生成的APK文件
- `friends-flutter-v27-textureview-release.apk`: 3.27 TextureView版本
- `friends-flutter-v29-textureview-release.apk`: 3.29 TextureView版本

## 使用方法

1. **安装APK**: 将对应版本的APK安装到Android设备
2. **启动应用**: 打开应用后可以看到标题显示"(TextureView)"标识
3. **测试功能**: 
   - 点击"TextureView测试"按钮进入专门的TextureView演示界面
   - 或使用原有的轻/中/重负载测试（保持与SurfaceView版本一致的功能）

## 性能对比建议

### 测试场景
1. **滚动性能**: 对比SurfaceView和TextureView在长列表滚动时的性能
2. **内存使用**: 监控两种模式下的内存占用情况
3. **CPU使用**: 对比渲染过程中的CPU使用率
4. **电池消耗**: 长时间使用下的电池消耗对比

### 测试工具
- Android Studio Profiler
- Firebase Performance Monitoring
- 设备内置性能监控工具

## 注意事项

1. **兼容性**: TextureView需要Android API 14及以上版本
2. **性能**: TextureView可能在某些设备上性能较SurfaceView略低
3. **内存**: TextureView通常会消耗更多内存
4. **动画**: 如果需要复杂的视觉效果，TextureView是更好的选择

## 开发规范

1. **代码同步**: 两个TextureView版本的功能实现保持同步
2. **包名规范**: 遵循已定义的包名命名规则
3. **版本管理**: 使用FVM管理不同Flutter版本
4. **构建脚本**: 可以集成到现有的构建脚本中

## 扩展建议

1. **自动化测试**: 添加自动化性能测试脚本
2. **监控集成**: 集成更详细的性能监控
3. **配置选项**: 添加运行时切换渲染模式的选项
4. **基准测试**: 建立详细的性能基准测试套件

---

*更新时间: 2025年7月31日*
*Flutter版本: 3.27.0 & 3.29.0*
*支持平台: Android (API 21+)*