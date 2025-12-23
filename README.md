# Flutter Moments Performance Test

## 📊 Project Status

[![Flutter 3.19](https://img.shields.io/badge/Flutter-3.19-blue.svg)](https://flutter.dev)
[![Flutter 3.27](https://img.shields.io/badge/Flutter-3.27-cyan.svg)](https://flutter.dev)
[![Flutter 3.29](https://img.shields.io/badge/Flutter-3.29-green.svg)](https://flutter.dev)
[![API Level](https://img.shields.io/badge/API-21%2B-blue.svg)](https://android-arsenal.com/api?level=21)
[![Dart](https://img.shields.io/badge/Dart-3.3%2B%20~%203.7-orange.svg)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-lightgrey.svg)](https://flutter.dev)
[![FVM](https://img.shields.io/badge/FVM-Required-yellow.svg)](https://fvm.app)
[![Load Types](https://img.shields.io/badge/Load%20Types-13-orange.svg)]()

A WeChat Moments-style Flutter application for performance and power consumption testing, supporting **Flutter 3.19, 3.27, and 3.29** version comparison with **13 load types** for comprehensive performance testing.

[中文文档](README_CN.md)

## Quick Start

```bash
# Build APKs (requires FVM)
./build_release.sh

# Install to device
./install_apks.sh

# Quick launch (interactive menu)
./quick_launch.sh
```

## Flutter Version Differences

This project includes 3 Flutter versions, each with significant architectural changes:

### Version Comparison

| Feature | Flutter 3.19 | Flutter 3.27 | Flutter 3.29 |
|---------|-------------|-------------|-------------|
| **Rendering Engine** | Skia | Impeller | Impeller |
| **Main Thread Merger** | No | No | Yes |
| **UI Thread** | Separate `1.ui` thread | Separate `1.ui` thread | Merged into main thread |
| **GPU Submission** | `queueBuffer/dequeueBuffer` | `QueueSubmit` | `QueueSubmit` |
| **Dart Version** | 3.3.0 | 3.6.0 | 3.7.0 |

### Detailed Description

#### Flutter 3.19 - Skia Renderer

- **Rendering Engine**: Uses traditional Skia renderer
- **Thread Model**: Flutter UI thread (`1.ui`) is separate from Android main thread
- **GPU Communication**: Communicates with SurfaceFlinger via `queueBuffer/dequeueBuffer`

#### Flutter 3.27 - Impeller Renderer

- **Rendering Engine**: Impeller becomes the default renderer
- **Thread Model**: Flutter UI thread (`1.ui`) remains separate from Android main thread
- **GPU Communication**: Switches to `QueueSubmit` API, reducing GPU communication latency

#### Flutter 3.29 - Main Thread Merger

- **Rendering Engine**: Impeller renderer (further optimized)
- **Thread Model**: **Flutter UI thread merged with Android main thread**
- **Impact**: No separate `1.ui` thread, all UI operations execute on main thread

## Perfetto Trace Analysis

### Thread Structure Differences

#### Flutter 3.19 / 3.27 (Non-Merged Mode)

In Perfetto, you can see the following threads:

| Thread Name | Description |
|-------------|-------------|
| `main` | Android main thread (Java/Kotlin) |
| `1.ui` | Flutter UI thread (Dart) running independently |
| `1.raster` | Flutter rasterization thread |
| `1.io` | Flutter IO thread |
| `gpu_completion` | GPU completion thread |

**Trace Characteristics**:
```
┌─────────────────────────────────────────────────────────────┐
│ main (Android)                                              │
│   └─ Activity lifecycle, JNI calls                         │
├─────────────────────────────────────────────────────────────┤
│ 1.ui (Flutter UI Thread)                                   │
│   └─ Dart execution, Layout, Paint                         │
│   └─ BuildFrame                                            │
├─────────────────────────────────────────────────────────────┤
│ 1.raster (Raster Thread)                                  │
│   └─ Skia/Impeller rasterization                           │
└─────────────────────────────────────────────────────────────┘
```

#### Flutter 3.29 (Main Thread Merged Mode)

In Perfetto, you can see the following threads:

| Thread Name | Description |
|-------------|-------------|
| `main` | Android main thread + Flutter UI thread (merged) |
| `1.raster` | Flutter rasterization thread |
| `1.io` | Flutter IO thread |
| `gpu_completion` | GPU completion thread |

**Trace Characteristics**:
```
┌─────────────────────────────────────────────────────────────┐
│ main (Android + Flutter UI Merged)                         │
│   ├─ Activity lifecycle, JNI calls                         │
│   ├─ Dart execution, Layout, Paint (directly on main)      │
│   └─ BuildFrame                                            │
├─────────────────────────────────────────────────────────────┤
│ 1.raster (Raster Thread)                                  │
│   └─ Impeller rasterization                               │
└─────────────────────────────────────────────────────────────┘
```

### GPU Communication Differences

#### Skia (3.19) - queueBuffer/dequeueBuffer

```
[1.ui] → queueBuffer() → SurfaceFlinger → dequeueBuffer()
         └─ Producer buffer enqueue
```

**Trace Characteristics**:
- Visible `queueBuffer` and `dequeueBuffer` calls
- Buffer exchange overhead visible

#### Impeller (3.27/3.29) - QueueSubmit

```
[1.ui/main] → QueueSubmit() → GPU
              └─ Direct command submission
```

**Trace Characteristics**:
- Uses `AHardwareQueue_submit` or similar API
- Reduced buffer exchange overhead

### Performance Analysis Key Metrics

When analyzing in Perfetto, focus on these slices:

| Metric | 3.19/3.27 (Non-Merged) | 3.29 (Merged) |
|--------|------------------------|---------------|
| **Frame Build Time** | In `BuildFrame` slice on `1.ui` thread | In `BuildFrame` slice on `main` thread |
| **JNI Overhead** | `main` → `1.ui` inter-thread communication | No cross-thread communication |
| **GPU Submission** | `1.ui` → `1.raster` → GPU | `main` → `1.raster` → GPU |
| **Frame Interval** | More stable frame interval | Potentially tighter frame interval |

### Trace Characteristics Under Load Testing

#### Build Load (Widget.build() computation)

- **3.19/3.27**: `BuildFrame` slice on `1.ui` thread becomes longer
- **3.29**: `BuildFrame` slice on `main` thread becomes longer

#### Paint Load (CustomPainter GPU drawing)

- **All versions**: `1.raster` thread activity increases
- **3.27/3.29**: More efficient GPU command submission

#### PostFrame Load (inter-frame computation)

- **3.19/3.27**: May affect next frame's `1.ui` thread scheduling
- **3.29**: Directly affects `main` thread, may compete with other main thread operations

## APK Version Reference

| App Name | Flutter Version | Render Mode | Package Name |
|----------|----------------|-------------|--------------|
| Flu-V319-Surface | 3.19 (Skia) | SurfaceView | `com.example.friendscircle.v19` |
| Flu-V319-Texture | 3.19 (Skia) | TextureView | `com.example.friendscircle.v19.textureview` |
| Flu-V327-Surface | 3.27 (Impeller) | SurfaceView | `com.example.friendscircle.v27` |
| Flu-V327-Texture | 3.27 (Impeller) | TextureView | `com.example.friendscircle.v27.textureview` |
| Flu-V329-Surface | 3.29 (Impeller+Merged) | SurfaceView | `com.example.friendscircle.v29` |
| Flu-V329-Texture | 3.29 (Impeller+Merged) | TextureView | `com.example.friendscircle.v29.textureview` |

## Load Types

Each app supports 13 load types:

| Category | Load Types | Description |
|----------|------------|-------------|
| **Baseline** | Minimal | No extra computation, performance baseline |
| **Build** (In-Frame) | Light / Medium / Heavy | CPU computation in Widget.build() phase |
| **Paint** (In-Frame GPU) | Light / Medium / Heavy | GPU drawing in CustomPainter.paint() phase |
| **PostFrame** (Between-Frames) | Light / Medium / Heavy | CPU computation after frame rendering |
| **Mixed** (Combined) | Light / Medium / Heavy | Build + PostFrame combined load |

## ADB Quick Launch

```bash
# Format
adb shell am start -n <package_name>/.MainActivity -e "load" "<load_type>"

# Example: Launch 3.27 SurfaceView + Build Heavy
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "build_heavy"

# Example: Launch 3.29 TextureView + Paint Heavy
adb shell am start -n com.example.friendscircle.v29.textureview/.MainActivity -e "load" "paint_heavy"
```

## Project Structure

```
FriendsCircle_Flutter/
├── 3.19_SurfaceView/    # Flutter 3.19 + SurfaceView (Skia)
├── 3.19_TextureView/    # Flutter 3.19 + TextureView (Skia)
├── 3.27_SurfaceView/    # Flutter 3.27 + SurfaceView (Impeller)
├── 3.27_TextureView/    # Flutter 3.27 + TextureView (Impeller)
├── 3.29_SurfaceView/    # Flutter 3.29 + SurfaceView (Impeller + Main Thread Merger)
├── 3.29_TextureView/    # Flutter 3.29 + TextureView (Impeller + Main Thread Merger)
├── build_release.sh     # One-click build script
├── install_apks.sh      # Batch install script
├── quick_launch.sh      # Quick launch script
├── .github/workflows/   # GitHub Actions CI/CD
└── apk-release/         # APK output directory
```

## Build Instructions

### Using FVM to Manage Multiple Flutter Versions

```bash
# Install FVM
brew install fvm

# Install Flutter versions
fvm install 3.19.0
fvm install 3.27.0
fvm install 3.29.0

# Each project is configured with the corresponding Flutter version
# Simply run the build script
./build_release.sh
```

## Load Parameter Configuration

### Build Load Iterations
| Level | Iterations |
|-------|------------|
| Light | 10 |
| Medium | 2,000 |
| Heavy | 20,000 |

### Paint Load Shape Count
| Level | Shape Count | Path Points | Shadow | Blur |
|-------|-------------|-------------|--------|------|
| Light | 50 | 10 | ❌ | ❌ |
| Medium | 200 | 50 | ✅ | ❌ |
| Heavy | 800 | 200 | ✅ | ✅ |

### PostFrame Load Iterations
| Level | Iterations |
|-------|------------|
| Light | 5,000 |
| Medium | 50,000 |
| Heavy | 200,000 |

### Mixed Load Combination
| Level | Build Iterations | PostFrame Iterations |
|-------|------------------|---------------------|
| Light | 5 | 2,500 |
| Medium | 1,000 | 25,000 |
| Heavy | 10,000 | 100,000 |

## Related Projects

- [Friends-Circle-Demo-Apks-For-Power-and-Performance-Test](https://github.com/Gracker/Friends-Circle-Demo-Apks-For-Power-and-Performance-Test) - AOSP native implementation

## License

MIT License
