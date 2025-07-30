# Flutter Friends Circle Project - Build Guide

*[中文指南](BUILD_GUIDE_CN.md)*

## 📋 Quick Start

### 1. Environment Check
Ensure your development environment is properly configured:
```bash
# Check if FVM is installed
fvm --version

# Check Flutter versions
fvm list

# Ensure versions 3.27 and 3.29 are installed
fvm install 3.27.0
fvm install 3.29.0
```

### 2. Using Automated Build Scripts

#### 🚀 Recommended: Complete Build Script
```bash
./build_flutter_apks.sh
```

**Features:**
- ✅ Automatically builds both Flutter versions
- ✅ Detailed build logs and progress display
- ✅ Error handling and failure retry
- ✅ Automatically generates version information files
- ✅ Creates installation scripts and performance comparison scripts
- ✅ Build statistics and result analysis

**Output Files:**
- `apk/friends-flutter-v27-release.apk`
- `apk/friends-flutter-v29-release.apk`
- `apk/friends-flutter-v27-release.txt` (version info)
- `install_flutter_apks.sh` (auto-install script)
- `performance_compare.sh` (performance comparison script)

#### ⚡ Quick: Simplified Build Script
```bash
./quick_build.sh              # Build all versions
./quick_build.sh 3.27         # Build 3.27 version only  
./quick_build.sh 3.29         # Build 3.29 version only
```

**Use Cases:**
- 🔥 Rapid iterative development
- 🔥 Only need APK files
- 🔥 CI/CD integration
- 🔥 Automated testing

## 📱 Using Generated Scripts

### Batch Install APKs
```bash
./install_flutter_apks.sh
```
Automatically installs all built APK files to connected Android devices.

### Performance Comparison Testing
```bash
./performance_compare.sh
```
Provides guidance for performance comparison testing and quick launch commands.

## 🔧 Troubleshooting

### Common Issues

#### 1. FVM Version Mismatch
```bash
# Error: Flutter version X.X.X is not installed
cd 3.27
fvm use 3.27.0
cd ../3.29
fvm use 3.29.0
```

#### 2. Permission Errors
```bash
# Add execute permissions to scripts
chmod +x *.sh
```

#### 3. Build Failures
```bash
# Manual cleanup and retry
cd 3.27
fvm flutter clean
fvm flutter pub get
fvm flutter build apk --release
```

#### 4. APK Installation Failures
```bash
# Check device connection
adb devices

# Uninstall old versions
adb uninstall com.example.friendscircle.v27
adb uninstall com.example.friendscircle.v29

# Reinstall
adb install apk/friends-flutter-v27-release.apk
```

### Environment Check Script
Create an environment check script:
```bash
#!/bin/bash
echo "🔍 Flutter Friends Circle Project Environment Check"
echo "================================"

# Check FVM
if command -v fvm >/dev/null 2>&1; then
    echo "✅ FVM: $(fvm --version)"
else
    echo "❌ FVM: Not installed"
fi

# Check Flutter versions
echo ""
echo "📱 Installed Flutter versions:"
fvm list

# Check project configuration
echo ""
echo "🏗️ Project configuration check:"
if [ -f "3.27/.fvmrc" ]; then
    echo "✅ 3.27 version config: $(cat 3.27/.fvmrc)"
else
    echo "❌ 3.27 version config missing"
fi

if [ -f "3.29/.fvmrc" ]; then
    echo "✅ 3.29 version config: $(cat 3.29/.fvmrc)"
else
    echo "❌ 3.29 version config missing"
fi

# Check Android devices
echo ""
echo "📱 Android device check:"
adb devices
```

## 💡 Performance Testing Recommendations

### 1. Build Release Versions
Always use Release versions for performance testing:
```bash
./build_flutter_apks.sh  # Automatically builds Release versions
```

### 2. Real Device Testing
Recommend performing performance tests on real devices to avoid performance differences from emulators.

### 3. Comparison Methods
1. Install both version APKs
2. Launch applications separately
3. Use identical test cases
4. Record performance metrics (memory, CPU, smoothness)

### 4. Test Scenarios
The project includes three load levels:
- **Light Load Test**: Basic functionality testing
- **Medium Load Test**: Normal usage scenarios
- **Heavy Load Test**: Extreme performance testing

## 📊 Build Optimization

### Reduce Build Time
```bash
# Parallel builds (if you have multi-core CPU)
./quick_build.sh 3.27 &
./quick_build.sh 3.29 &
wait
```

### Custom Build Parameters
Modify build commands in scripts:
```bash
# Add more optimization parameters
fvm flutter build apk --release --shrink --obfuscate --split-debug-info=debug_info/
```

## 🔄 CI/CD Integration

### GitHub Actions Example
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

### Automated Release
```bash
# Build and automatically commit APKs
./build_flutter_apks.sh
git add apk/
git commit -m "Auto build APKs $(date)"
git push
```

## 📁 File Naming Convention

All generated files follow standardized English naming:

### APK Files
- `friends-flutter-v27-release.apk` - Flutter 3.27 version
- `friends-flutter-v29-release.apk` - Flutter 3.29 version

### Version Information Files
- `friends-flutter-v27-release.txt` - Flutter 3.27 version info
- `friends-flutter-v29-release.txt` - Flutter 3.29 version info

### Key Features
- ✅ Consistent naming across builds
- ✅ Automatic cleanup of old versions
- ✅ English-only file names
- ✅ Version identification in file names

## 🎯 Best Practices

### Development Workflow
1. Use `./check_env.sh` to verify environment
2. Use `./quick_build.sh` for development iterations
3. Use `./build_flutter_apks.sh` for final releases
4. Test on real devices for performance validation

### Version Management
- Keep both versions synchronized
- Test changes in 3.27 first
- Apply to 3.29 after validation
- Document performance differences

### Performance Testing
- Use Release builds only
- Test on consistent hardware
- Use identical test scenarios
- Measure multiple metrics (CPU, memory, battery)

## 📚 Additional Resources

- [Flutter Official Documentation](https://flutter.dev/docs)
- [FVM Documentation](https://fvm.app)
- [Android Performance Best Practices](https://developer.android.com/topic/performance)
- [Flutter Performance Best Practices](https://flutter.dev/docs/perf/best-practices)