# Flutter朋友圈项目 - 构建指南

## 📋 快速开始

### 1. 环境检查
确保您的开发环境已正确配置：
```bash
# 检查FVM是否安装
fvm --version

# 检查Flutter版本
fvm list

# 确保3.27和3.29版本已安装
fvm install 3.27.0
fvm install 3.29.0
```

### 2. 使用自动构建脚本

#### 🚀 推荐：完整版构建脚本
```bash
./build_flutter_apks.sh
```

**功能特性：**
- ✅ 自动构建四个Flutter版本（SurfaceView + TextureView）
- ✅ 详细的构建日志和进度显示
- ✅ 错误处理和失败重试
- ✅ 自动生成版本信息文件
- ✅ 创建安装脚本和性能对比脚本
- ✅ 构建统计和结果分析
- ✅ 支持SurfaceView vs TextureView渲染模式对比

**输出文件：**
- `apk/friends-flutter-v27-release.apk` (3.27 SurfaceView版本)
- `apk/friends-flutter-v29-release.apk` (3.29 SurfaceView版本)
- `apk/friends-flutter-v27-textureview.apk` (3.27 TextureView版本)
- `apk/friends-flutter-v29-textureview.apk` (3.29 TextureView版本)
- 对应的版本信息文件 (.txt)
- `install_flutter_apks.sh` (自动安装脚本)
- `performance_compare.sh` (性能对比脚本)

#### ⚡ 快速：简化版构建脚本
```bash
./quick_build.sh              # 构建所有版本
./quick_build.sh 3.27         # 只构建3.27版本  
./quick_build.sh 3.29         # 只构建3.29版本
./quick_build.sh 3.27_TextureView  # 只构建3.27 TextureView版本
./quick_build.sh 3.29_TextureView  # 只构建3.29 TextureView版本
```

**适用场景：**
- 🔥 快速迭代开发
- 🔥 只需要APK文件
- 🔥 CI/CD集成
- 🔥 自动化测试

## 📱 使用生成的脚本

### 批量安装APK
```bash
./install_flutter_apks.sh
```
自动安装所有构建的APK文件到连接的Android设备。

### 性能对比测试
```bash
./performance_compare.sh
```
提供性能对比测试的指导和快速启动命令。

## 🔧 故障排除

### 常见问题

#### 1. FVM版本不匹配
```bash
# 错误：Flutter version X.X.X is not installed
cd 3.27
fvm use 3.27.0
cd ../3.29
fvm use 3.29.0
```

#### 2. 权限错误
```bash
# 为脚本添加执行权限
chmod +x *.sh
```

#### 3. 构建失败
```bash
# 手动清理并重试
cd 3.27
fvm flutter clean
fvm flutter pub get
fvm flutter build apk --release
```

#### 4. APK安装失败
```bash
# 检查设备连接
adb devices

# 卸载旧版本
adb uninstall com.example.friendscircle.v27
adb uninstall com.example.friendscircle.v29
adb uninstall com.example.friendscircle.v27.textureview
adb uninstall com.example.friendscircle.v29.textureview

# 重新安装
adb install apk/friends-flutter-v27-release.apk
adb install apk/friends-flutter-v29-release.apk
adb install apk/friends-flutter-v27-textureview.apk
adb install apk/friends-flutter-v29-textureview.apk
```

### 环境配置检查脚本
创建一个环境检查脚本：
```bash
#!/bin/bash
echo "🔍 Flutter朋友圈项目环境检查"
echo "================================"

# 检查FVM
if command -v fvm >/dev/null 2>&1; then
    echo "✅ FVM: $(fvm --version)"
else
    echo "❌ FVM: 未安装"
fi

# 检查Flutter版本
echo ""
echo "📱 已安装的Flutter版本:"
fvm list

# 检查项目配置
echo ""
echo "🏗️  项目配置检查:"
if [ -f "3.27/.fvmrc" ]; then
    echo "✅ 3.27版本配置: $(cat 3.27/.fvmrc)"
else
    echo "❌ 3.27版本配置缺失"
fi

if [ -f "3.29/.fvmrc" ]; then
    echo "✅ 3.29版本配置: $(cat 3.29/.fvmrc)"
else
    echo "❌ 3.29版本配置缺失"
fi

if [ -f "3.27_TextureView/.fvmrc" ]; then
    echo "✅ 3.27_TextureView版本配置: $(cat 3.27_TextureView/.fvmrc)"
else
    echo "❌ 3.27_TextureView版本配置缺失"
fi

if [ -f "3.29_TextureView/.fvmrc" ]; then
    echo "✅ 3.29_TextureView版本配置: $(cat 3.29_TextureView/.fvmrc)"
else
    echo "❌ 3.29_TextureView版本配置缺失"
fi

# 检查Android设备
echo ""
echo "📱 Android设备检查:"
adb devices
```

## 💡 性能测试建议

### 1. 构建Release版本
始终使用Release版本进行性能测试：
```bash
./build_flutter_apks.sh  # 自动构建Release版本
```

### 2. 真机测试
推荐在真机上进行性能测试，避免模拟器的性能差异。

### 3. 对比方法
1. 安装两个版本的APK
2. 分别启动应用
3. 使用相同的测试用例
4. 记录性能指标（内存、CPU、流畅度）

### 4. 测试场景
项目包含三种负载级别：
- **轻负载测试**：基础功能测试
- **中负载测试**：正常使用场景
- **重负载测试**：极限性能测试

### 5. 渲染模式对比
- **SurfaceView版本**：Flutter默认渲染模式，使用SurfaceView
- **TextureView版本**：使用Flutter官方FlutterTextureView，可参与View层级变换

## 📊 构建优化

### 减少构建时间
```bash
# 并行构建（如果有多核CPU）
./quick_build.sh 3.27 &
./quick_build.sh 3.29 &
./quick_build.sh 3.27_TextureView &
./quick_build.sh 3.29_TextureView &
wait
```

### 自定义构建参数
修改脚本中的构建命令：
```bash
# 添加更多优化参数
fvm flutter build apk --release --shrink --obfuscate --split-debug-info=debug_info/
```

## 🔄 CI/CD集成

### GitHub Actions示例
```yaml
name: Build Flutter APKs
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.0'
      - run: ./quick_build.sh
```

### 自动发布
```bash
# 构建并自动提交APK
./build_flutter_apks.sh
git add apk/
git commit -m "Auto build APKs $(date)"
git push
```