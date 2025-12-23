# 朋友圈Demo - Flutter性能功耗测试

## 📊 项目状态

[![Flutter 3.19](https://img.shields.io/badge/Flutter-3.19-blue.svg)](https://flutter.dev)
[![Flutter 3.27](https://img.shields.io/badge/Flutter-3.27-cyan.svg)](https://flutter.dev)
[![Flutter 3.29](https://img.shields.io/badge/Flutter-3.29-green.svg)](https://flutter.dev)
[![API Level](https://img.shields.io/badge/API-21%2B-blue.svg)](https://android-arsenal.com/api?level=21)
[![Dart](https://img.shields.io/badge/Dart-3.3%2B%20~%203.7-orange.svg)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-lightgrey.svg)](https://flutter.dev)
[![FVM](https://img.shields.io/badge/FVM-Required-yellow.svg)](https://fvm.app)
[![Load Types](https://img.shields.io/badge/Load%20Types-13-orange.svg)]()

一个用于性能和功耗测试的微信朋友圈 Flutter 应用，支持 **Flutter 3.19、3.27、3.29** 三版本对比，提供 **13 种负载类型**的全面性能测试。

[English Documentation](README.md)

## 快速开始

```bash
# 构建 APK（需要先安装 FVM）
./build_release.sh

# 安装到设备
./install_apks.sh

# 快速启动（交互式菜单）
./quick_launch.sh
```

## Flutter 版本差异

本项目包含 3 个 Flutter 版本，每个版本都有重要的架构变化：

### 版本对比

| 特性 | Flutter 3.19 | Flutter 3.27 | Flutter 3.29 |
|------|-------------|-------------|-------------|
| **渲染引擎** | Skia | Impeller | Impeller |
| **主线程融合** | 否 | 否 | 是 |
| **UI 线程** | 独立的 `1.ui` 线程 | 独立的 `1.ui` 线程 | 融合到主线程 |
| **GPU 提交** | `queueBuffer/dequeueBuffer` | `QueueSubmit` | `QueueSubmit` |
| **Dart 版本** | 3.3.0 | 3.6.0 | 3.7.0 |

### 详细说明

#### Flutter 3.19 - Skia 渲染器

- **渲染引擎**: 使用传统 Skia 渲染器
- **线程模型**: Flutter UI 线程 (`1.ui`) 与 Android 主线程独立
- **GPU 通信**: 通过 `queueBuffer/dequeueBuffer` 与 SurfaceFlinger 通信

#### Flutter 3.27 - Impeller 渲染器

- **渲染引擎**: Impeller 成为默认渲染引擎
- **线程模型**: Flutter UI 线程 (`1.ui`) 仍然与 Android 主线程独立
- **GPU 通信**: 改用 `QueueSubmit` API，减少 GPU 通信延迟

#### Flutter 3.29 - 主线程融合

- **渲染引擎**: Impeller 渲染引擎（进一步优化）
- **线程模型**: **Flutter UI 线程与 Android 主线程融合**
- **影响**: 无独立的 `1.ui` 线程，所有 UI 操作在主线程执行

## Perfetto Trace 分析

### 线程结构差异

#### Flutter 3.19 / 3.27（非融合模式）

在 Perfetto 中可以看到以下线程：

| 线程名 | 说明 |
|--------|------|
| `main` | Android 主线程（Java/Kotlin） |
| `1.ui` | Flutter UI 线程（Dart）独立运行 |
| `1.raster` | Flutter 光栅化线程 |
| `1.io` | Flutter IO 线程 |
| `gpu_completion` | GPU 完成线程 |

**Trace 特征**:
```
┌─────────────────────────────────────────────────────────────┐
│ main (Android)                                              │
│   └─ Activity生命周期、JNI调用                              │
├─────────────────────────────────────────────────────────────┤
│ 1.ui (Flutter UI Thread)                                   │
│   └─ Dart代码执行、Layout、Paint                           │
│   └─ BuildFrame                                            │
├─────────────────────────────────────────────────────────────┤
│ 1.raster (Raster Thread)                                  │
│   └─ Skia/Impeller 光栅化                                  │
└─────────────────────────────────────────────────────────────┘
```

#### Flutter 3.29（主线程融合模式）

在 Perfetto 中可以看到以下线程：

| 线程名 | 说明 |
|--------|------|
| `main` | Android 主线程 + Flutter UI 线程（融合） |
| `1.raster` | Flutter 光栅化线程 |
| `1.io` | Flutter IO 线程 |
| `gpu_completion` | GPU 完成线程 |

**Trace 特征**:
```
┌─────────────────────────────────────────────────────────────┐
│ main (Android + Flutter UI 融合)                           │
│   ├─ Activity生命周期、JNI调用                              │
│   ├─ Dart代码执行、Layout、Paint（直接在主线程）            │
│   └─ BuildFrame                                            │
├─────────────────────────────────────────────────────────────┤
│ 1.raster (Raster Thread)                                  │
│   └─ Impeller 光栅化                                      │
└─────────────────────────────────────────────────────────────┘
```

### GPU 通信差异

#### Skia (3.19) - queueBuffer/dequeueBuffer

```
[1.ui] → queueBuffer() → SurfaceFlinger → dequeueBuffer()
         └─ 生产者缓冲区入队
```

**Trace 特征**:
- 可以看到 `queueBuffer` 和 `dequeueBuffer` 调用
- Buffer 交换开销可见

#### Impeller (3.27/3.29) - QueueSubmit

```
[1.ui/main] → QueueSubmit() → GPU
              └─ 直接命令提交
```

**Trace 特征**:
- 使用 `AHardwareQueue_submit` 或类似 API
- 减少 Buffer 交换开销

### 性能分析关键指标

在 Perfetto 中分析时，关注以下切片：

| 指标 | 3.19/3.27 (非融合) | 3.29 (融合) |
|------|-------------------|-------------|
| **帧构建时间** | 在 `1.ui` 线程的 `BuildFrame` 切片中 | 在 `main` 线程的 `BuildFrame` 切片中 |
| **JNI 开销** | `main` → `1.ui` 线程间通信 | 无跨线程通信 |
| **GPU 提交** | `1.ui` → `1.raster` → GPU | `main` → `1.raster` → GPU |
| **帧间隔** | 更稳定的帧间隔 | 可能更紧凑的帧间隔 |

### 负载测试下的 Trace 特征

#### Build 负载 (Widget.build() 计算)

- **3.19/3.27**: `1.ui` 线程 `BuildFrame` 切片变长
- **3.29**: `main` 线程 `BuildFrame` 切片变长

#### Paint 负载 (CustomPainter GPU 绘图)

- **所有版本**: `1.raster` 线程活动增加
- **3.27/3.29**: GPU 命令提交更高效

#### PostFrame 负载 (帧间计算)

- **3.19/3.27**: 可能影响下一帧的 `1.ui` 线程调度
- **3.29**: 直接影响 `main` 线程，可能与其他主线程操作竞争

## 负载类型

本项目支持 13 种不同的负载类型，覆盖 Flutter 应用的各种性能场景：

### 负载类型一览表

| 类别 | 负载类型 | ADB参数 | 说明 |
|-----|---------|--------|------|
| **基准负载** | 最轻负载 | `minimal` | 无额外计算，作为性能基准 |
| **Build负载（帧内）** | Build轻负载 | `build_light` | Widget.build()中轻量CPU计算 |
| | Build中负载 | `build_medium` | Widget.build()中中等CPU计算 |
| | Build重负载 | `build_heavy` | Widget.build()中重度CPU计算 |
| **Paint负载（帧内-GPU）** | Paint轻负载 | `paint_light` | CustomPainter绑定少量图形 |
| | Paint中负载 | `paint_medium` | CustomPainter绘制中等图形+阴影 |
| | Paint重负载 | `paint_heavy` | CustomPainter绘制大量复杂图形 |
| **PostFrame负载（帧间）** | PostFrame轻负载 | `postframe_light` | 帧渲染后轻量计算 |
| | PostFrame中负载 | `postframe_medium` | 帧渲染后中等计算 |
| | PostFrame重负载 | `postframe_heavy` | 帧渲染后重度计算 |
| **Mixed负载（混合）** | Mixed轻负载 | `mixed_light` | Build+PostFrame组合轻负载 |
| | Mixed中负载 | `mixed_medium` | Build+PostFrame组合中负载 |
| | Mixed重负载 | `mixed_heavy` | Build+PostFrame组合重负载 |

### 负载类型详解

#### 1. Build负载（帧内）
- **执行时机**: 在`Widget.build()`方法中
- **影响**: 直接影响UI线程的帧构建时间
- **模拟场景**: 复杂的业务逻辑计算、数据处理

#### 2. Paint负载（帧内-GPU）
- **执行时机**: 在`CustomPainter.paint()`方法中
- **影响**: 产生GPU负载，影响绘制性能
- **模拟场景**: 复杂图形绘制、动画效果、特效

#### 3. PostFrame负载（帧间）
- **执行时机**: 在`addPostFrameCallback()`中
- **影响**: 在帧渲染完成后执行，影响帧间隔
- **模拟场景**: 后台数据同步、缓存处理

#### 4. Mixed负载（混合）
- **组合方式**: Build负载(50%) + PostFrame负载(50%)
- **影响**: 同时影响帧内和帧间性能
- **模拟场景**: 真实复杂应用的综合负载

## APK 版本对照表

| 应用名称 | Flutter 版本 | 渲染模式 | 包名 | 应用名 |
|----------|-------------|----------|------|-------|
| Flu-V319-Surface | 3.19 (Skia) | SurfaceView | `com.example.friendscircle.v19` | 朋友圈V19 |
| Flu-V319-Texture | 3.19 (Skia) | TextureView | `com.example.friendscircle.v19.textureview` | 朋友圈V19-TextureView |
| Flu-V327-Surface | 3.27 (Impeller) | SurfaceView | `com.example.friendscircle.v27` | 朋友圈V27 |
| Flu-V327-Texture | 3.27 (Impeller) | TextureView | `com.example.friendscircle.v27.textureview` | 朋友圈V27-TextureView |
| Flu-V329-Surface | 3.29 (Impeller+融合) | SurfaceView | `com.example.friendscircle.v29` | 朋友圈V29 |
| Flu-V329-Texture | 3.29 (Impeller+融合) | TextureView | `com.example.friendscircle.v29.textureview` | 朋友圈V29-TextureView |

## ADB 快速启动

```bash
# 格式
adb shell am start -n <包名>/.MainActivity -e "load" "<负载类型>"

# 示例：启动 3.27 SurfaceView + Build Heavy
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "build_heavy"

# 示例：启动 3.29 TextureView + Paint Heavy
adb shell am start -n com.example.friendscircle.v29.textureview/.MainActivity -e "load" "paint_heavy"
```

## 项目结构

```
FriendsCircle_Flutter/
├── README.md                   # 英文文档
├── README_CN.md               # 中文文档
├── build_release.sh           # 完整构建脚本
├── install_apks.sh            # 批量安装脚本
├── quick_launch.sh            # 快速启动脚本
├── .github/workflows/         # GitHub Actions CI/CD
├── 3.19_SurfaceView/         # Flutter 3.19 (Skia + SurfaceView)
├── 3.19_TextureView/         # Flutter 3.19 (Skia + TextureView)
├── 3.27_SurfaceView/         # Flutter 3.27 (Impeller + SurfaceView)
├── 3.27_TextureView/         # Flutter 3.27 (Impeller + TextureView)
├── 3.29_SurfaceView/         # Flutter 3.29 (Impeller + 主线程融合 + SurfaceView)
├── 3.29_TextureView/         # Flutter 3.29 (Impeller + 主线程融合 + TextureView)
└── apk-release/              # APK输出目录
```

## 代码架构

```
lib/
├── main.dart                    # 应用入口，支持ADB深层链接
├── constants.dart               # 常量定义（13种负载类型、颜色等）
├── data/
│   └── data_center.dart         # 数据中心（测试数据生成）
├── utils/
│   ├── load_calculator.dart     # 负载计算工具类
│   └── asset_generator.dart     # 资源生成工具
├── models/                      # 数据模型
├── screens/
│   ├── home_screen.dart         # 主页（负载类型选择）
│   └── unified_load_screen.dart # 统一负载测试屏幕
└── widgets/
    ├── paint_load_painter.dart  # Paint负载CustomPainter
    ├── post_item.dart           # 帖子组件
    └── ...                      # 其他UI组件
```

## 构建说明

### 使用 FVM 管理多版本 Flutter

```bash
# 安装 FVM
brew install fvm

# 安装 Flutter 版本
fvm install 3.19.0
fvm install 3.27.0
fvm install 3.29.0

# 每个项目已配置对应的 Flutter 版本
# 直接运行构建脚本即可
./build_release.sh
```

## 负载参数配置

### Build负载迭代次数
| 级别 | 迭代次数 |
|-----|---------|
| 轻 | 10 |
| 中 | 2,000 |
| 重 | 20,000 |

### Paint负载图形数量
| 级别 | 图形数量 | 路径点数 | 阴影 | 模糊 |
|-----|---------|---------|-----|-----|
| 轻 | 50 | 10 | ❌ | ❌ |
| 中 | 200 | 50 | ✅ | ❌ |
| 重 | 800 | 200 | ✅ | ✅ |

### PostFrame负载迭代次数
| 级别 | 迭代次数 |
|-----|---------|
| 轻 | 5,000 |
| 中 | 50,000 |
| 重 | 200,000 |

### Mixed负载组合
| 级别 | Build迭代 | PostFrame迭代 |
|-----|----------|--------------|
| 轻 | 5 | 2,500 |
| 中 | 1,000 | 25,000 |
| 重 | 10,000 | 100,000 |

## 相关项目

- [Friends-Circle-Demo-Apks-For-Power-and-Performance-Test](https://github.com/Gracker/Friends-Circle-Demo-Apks-For-Power-and-Performance-Test) - AOSP原生实现版本

## 许可证

MIT License
