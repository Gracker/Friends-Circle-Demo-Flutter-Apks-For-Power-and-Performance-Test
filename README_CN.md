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

#### Skia (3.19) - SurfaceView 模式

**架构本质：双管道并行 (Dual Pipeline)**

SurfaceView 实际上创建了两个独立的渲染管道：

- **管道 A (Flutter)**: 负责渲染实际内容
- **管道 B (Android App)**: 负责渲染窗口其余部分 (Status Bar, Nav Bar) + 定义 SurfaceView 位置和尺寸

---

**阶段一：生产阶段 (Flutter Raster Thread) - 独立路径**

```
Vsync 信号
    ↓
[1.raster] LayerTree 光栅化 → GraphicBuffer
    ↓
    BufferQueue::queueBuffer()
    (Flutter 的 ANativeWindow 直接映射到 SurfaceFlinger 的一个 Layer)
    ↓
    *** 直接提交 ***
    (不经过 Android 主线程或 RenderThread)
    ↓
    共享内存 → SurfaceFlinger 直接收收到 "Frame Available" 信号
```

---

**阶段二：挖洞阶段 (Android RenderThread - "Hole Punching")**

```
Vsync-App 信号 (并行，不阻塞)
    ↓
[RenderThread] 绘制应用窗口 UI
    ↓
    在 SurfaceView 区域绘制透明像素
    (在 App 窗口上打一个"洞")
    ↓
    Z-Order: SurfaceView (Z=-1) 在 App Window (Z=0) 后面
    ↓
    BufferQueue::queueBuffer() (带透明洞的 App 窗口)
```

---

**阶段三：系统合成阶段 (SurfaceFlinger & HWC - 零拷贝优势)**

```
[SurfaceFlinger]
    ↓
    在一个 Vsync 周期内收集多个图层：
    ├─ App Window Buffer (SurfaceView 位置为透明洞)
    └─ Flutter Surface Buffer (实际内容)
    ↓
    ╔════════════════════════════════════════════════════════════════════════════╗
    ║  *** 零拷贝 / 硬件叠加 ***                                             ║
    ║  SF → HWC: "设置图层 1 (App Window, Z=0)"                              ║
    ║         "设置图层 2 (SurfaceView, Z=-1)"                             ║
    ║  HWC: 硬件叠加合成                                                   ║
    ║  无 GPU 合成 - 显示处理器直接扫描输出                                ║
    ║  代价: 零拷贝，GPU 可完全闲置                                         ║
    ╚════════════════════════════════════════════════════════════════════════════╝
```

**时序图**:

```
┌─────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌─────────┐
│ Vsync   │    │ Flutter  │    │Buffer    │    │ Android  │    │ Surface  │    │ Display │
│ 信号    │    │ Raster   │    │ Queue    │    │ Render   │    │Flinger   │    │  (HWC)  │
└────┬────┘    └────┬─────┘    └────┬─────┘    └────┬─────┘    └────┬─────┘    └────┬─────┘
     │              │               │              │              │              │
     │ Vsync        │               │              │ Vsync        │              │
     ├─────────────>│               │              ├─────────────>│              │
     │              │               │              │              │              │
     │ *** 管道 A: Flutter 内容 *** │              │              │              │
     │              │ 光栅化到      │              │              │              │
     │              │ GraphicBuffer │              │              │              │
     │              │──────────────>│              │              │              │
     │              │               │ queueBuffer()│              │              │
     │              │               │──────────────│─────────────>│              │
     │              │               │              │ (直接到 SF)  │              │
     │              │               │              │              │              │
     │ *** 管道 B: 窗口挖洞 *** (并行) │              │              │
     │              │               │              │ 绘制 App UI  │              │
     │              │               │              ├──────────────>              │
     │              │               │              │ 绘制透明像素│              │
     │              │               │              │ 在 SurfaceView│              │
     │              │               │              │              │              │
     │              │               │              │ queueBuffer()│              │
     │              │               │              │──────────────│─────────────>│
     │              │               │              │              │              │
     │              │               │              │              │ acquireBuf()│
     │              │               │              │              │<─────────────│
     │              │               │              │              │ acquireBuf()│
     │              │               │              │              │<─────────────│
     │              │               │              │              │              │
     │              │               │              │              │ *** HWC 叠加***
     │              │               │              │              │ 图层 1: App │
     │              │               │              │              │ 图层 2: Flutter
     │              │               │              │              │─────────────>│
     │              │               │              │              │   扫描输出  │
```

**与 TextureView 的关键差异**:
- **无 GPU 拷贝**: Flutter 内容完全绕过 App 的 RenderThread
- **独立图层**: Flutter Surface 是 SurfaceFlinger 的独立图层
- **挖洞机制**: App 窗口在 SurfaceView 位置有透明区域，露出底层的 Flutter
- **硬件叠加**: HWC 不经过 GPU 合成直接叠加图层

**Trace 特征**:
- `queueBuffer` 在 `1.raster` 线程 → Flutter 内容直接到 SF
- `queueBuffer` 在 RenderThread → 带透明洞的 App 窗口
- `dequeueBuffer` 在 SurfaceFlinger → 获取两个 Buffer
- Trace 中可见 `BLASTBufferQueue_*` 符号
- **无 `updateTexImage` 或 GPU 拷贝操作**

#### TextureView 模式 (所有 Flutter 版本)

TextureView 模式因 GPU 拷贝过程而有显著开销。完整流程如下：

**阶段一：生产者阶段 (Flutter Raster Thread)**

```
Vsync 信号
    ↓
[1.raster] Skia/Impeller 光栅化 → GraphicBuffer
    ↓
    BufferQueue::queueBuffer()
    (Buffer 进入 SurfaceTexture 的 BufferQueue，状态变为 QUEUED)
    ↓
    onFrameAvailable() 回调 → 主线程 Handler
    (仅将 TextureView 标记为脏，不立即绘制)
```

**阶段二：调度阶段 (Android 主线程 - 下一个 Vsync)**

```
Vsync-App 信号 (T+16.6ms)
    ↓
[主线程] performTraversals()
    ├─ Measure
    ├─ Layout
    └─ Draw
        └─ TextureView.draw() → 创建 DisplayList RenderNode
            (指令："RenderThread，在这个坐标绘制 SurfaceTexture 的内容")
    ↓
    SyncFrame → 发送显示列表到 RenderThread
```

**阶段三：合成与 GPU 拷贝 (Android RenderThread - 性能热点)**

```
[RenderThread]
    ↓
    BufferQueue::acquireBuffer() (锁定最新可用帧)
    ↓
    SurfaceTexture.updateTexImage()
    (将 GraphicBuffer 绑定为 GL_TEXTURE_EXTERNAL_OES)
    ↓
    ╔════════════════════════════════════════════════════════════════════════════╗
    ║  *** 关键性能损耗点 ***                                                ║
    ║  drawTexture() → GPU Fragment Shader                                    ║
    ║  输入:  Flutter OES 纹理                                               ║
    ║  输出:  应用窗口 FrameBuffer                                             ║
    ║  过程:  GPU 从 OES 纹理采样 → 色域转换 (YUV→RGB)                    ║
    ║         → 写入窗口 Buffer                                               ║
    ║  代价:  GPU 算力 + 显存带宽 ("Extra GPU Copy")                           ║
    ╚════════════════════════════════════════════════════════════════════════════╝
```

**阶段四：系统合成阶段 (SurfaceFlinger)**

```
[RenderThread] queueBuffer() (完整应用窗口)
    ↓
[SurfaceFlinger]
    ↓
    BufferQueueConsumer::acquireBuffer() (应用窗口作为图层)
    ↓
    [SF 主线程] 图层合成 (包括 TextureView 图层)
    ↓
    [HWComposer / WHC] 输出到显示器
```

**时序图**:

```
┌─────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌─────────┐    ┌──────────┐
│ Vsync   │    │ Flutter  │    │Buffer    │    │ Android  │    │ Android  │    │ Surface │    │ Display  │
│ 信号    │    │ Raster   │    │ Queue    │    │  主线程   │    │ Render   │    │Flinger  │    │          │
└────┬────┘    └────┬─────┘    └────┬─────┘    └────┬─────┘    └────┬─────┘    └────┬─────┘    └────┬─────┘
     │              │               │              │              │              │              │
     │ Vsync-App    │               │              │              │              │              │
     ├─────────────>│               │              │              │              │              │
     │              │               │              │ Vsync        │              │              │
     │              │               │              ├─────────────>│              │              │
     │              │ 光栅化到      │              │              │              │              │
     │              │ GraphicBuffer │              │              │              │              │
     │              │──────────────>│              │              │              │              │
     │              │               │ queueBuffer()│              │              │              │
     │              │               │──────────────│──────────────>│              │              │
     │              │               │              │ (脏标记)     │              │              │
     │              │               │              │<──────────────│              │              │
     │              │               │              │ onFrameAvail  │              │              │
     │              │               │              │              │              │              │
     │     下一个 Vsync (T+16.6ms)    │              │              │              │              │
     ├──────────────────────────────>│              │              │              │              │
     │              │               │              │              │              │              │
     │              │               │              │ performTrav. │              │              │
     │              │               │              ├──────────────>│              │              │
     │              │               │              │              │              │              │
     │              │               │              │ 构建         │              │              │
     │              │               │              │ DisplayList  │              │              │
     │              │               │              │──────────────│─────────────>│              │
     │              │               │              │              │              │              │
     │              │               │              │              │ acquireBuf()│              │
     │              │               │              │              │<─────────────│              │
     │              │               │              │              │              │              │
     │              │               │              │              │ updateTexImage│              │
     │              │               │              │              │──────────────>              │
     │              │               │              │              │              │              │
     │              │               │              │              │ *** GPU 拷贝***│              │
     │              │               │              │              │ OES → 窗口Buf│              │
     │              │               │              │              │              │              │
     │              │               │              │              │ queueBuffer()│              │
     │              │               │              │              │─────────────>│              │
     │              │               │              │              │              │              │
     │              │               │              │              │              │ acquireBuf()│
     │              │               │              │              │              │<─────────────│
     │              │               │              │              │              │              │
     │              │               │              │              │              │ HWC 合成  │
     │              │               │              │              │              │────────────>│
```

**Trace 特征**:
- `onFrameAvailable` 在主线程 → BufferQueue 回调
- `performTraversals` 在主线程 → View 系统遍历
- `updateTexImage` 在 RenderThread → 绑定 Buffer 为 OES 纹理
- `drawTexture` / `drawRenderNode` 在 RenderThread → **GPU 拷贝操作**
- `queueBuffer` 两次：一次用于 Flutter 内容 (SurfaceTexture)，一次用于应用窗口 (BLASTBufferQueue)

**性能影响**:
- **额外 GPU 拷贝**: Fragment Shader 从 OES 纹理采样并写入窗口 FrameBuffer
- **显存带宽**: 每帧消耗额外的 GPU 纹理采样带宽
- **Vsync 延迟**: Flutter 内容可能落后一帧 (T 时刻生产，T+16.6ms 时刻消费)

#### Impeller (3.27/3.29) - SurfaceView 模式

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ Flutter App 进程                                                            │
├─────────────────────────────────────────────────────────────────────────────┤
│ [1.ui/main]     Dart 代码 → Impeller Layer 树                             │
│                      ↓                                                      │
│ [1.raster]      Impeller 渲染 → GPU 命令 (Vulkan/Metal)                   │
│                      ↓                                                      │
│                  AHardwareQueue_submit() / QueueSubmit()                  │
│                      └─ 直接 GPU 命令提交                                  │
│                      └─ 无中间 buffer queue                               │
└──────────────────────┼────────────────────────────────────────────────────┘
                       ↓ GPU 命令
┌──────────────────────┴─────────────────────────────────────────────────────┐
│ GPU (Vulkan/Metal)                                                          │
│                      ↓                                                      │
│ [HW Composer / WHC] 直接扫描输出或合成                                    │
│                      ↓                                                      │
│ Display 显示器                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Trace 特征**:
- `AHardwareQueue_submit` 或 `vkQueuePresentKHR` 在 `1.raster` 线程
- 渲染无 `queueBuffer`/`dequeueBuffer`（降低延迟）
- **关键差异**: Impeller 绕过传统 BufferQueue，直接提交到 GPU

#### Impeller (3.27/3.29) - TextureView 模式

```
与 Skia TextureView 流程相同 - TextureView 仍需走 SurfaceTexture 路径:

[1.ui/main] → Impeller 渲染 → GPU 纹理上传 → [JNIOnload] updateTexImage()
                            ↓
                   然后 View 系统 → 窗口 BLASTBufferQueue → SF → 显示
```

**注**: TextureView 模式因 OpenGL 纹理需求，无法享受 Impeller 的直接 GPU 提交优势。仍需经过完整的 View 合成流程。

### 总结表格

| 模式 | Flutter 版本 | Buffer 流转 | 关键线程 | 开销 |
|------|-------------|-------------|----------|------|
| **SurfaceView** | 3.19 (Skia) | 1.raster → BufferQueue → SF → 显示 | 1.raster, SF 主线程 | 中等 |
| **SurfaceView** | 3.27/3.29 (Impeller) | 1.raster → GPU (直接) → 显示 | 1.raster, GPU | **低** |
| **TextureView** | 所有版本 | 1.raster → GPU 纹理 → JNIOnload → View 系统 → 窗口 BufferQueue → SF | 1.raster, JNIOnload, 主线程 | **高** |

### 性能分析关键指标

在 Perfetto 中分析时，关注以下切片：

| 指标 | 3.19/3.27 (非融合) | 3.29 (融合) |
|------|-------------------|-------------|
| **帧构建时间** | 在 `1.ui` 线程的 `BuildFrame` 切片中 | 在 `main` 线程的 `BuildFrame` 切片中 |
| **JNI 开销** | `main` ↔ `1.ui` 线程间通信 | 无跨线程通信 |
| **GPU 提交** | `1.ui` → 渲染命令 → `1.raster` → SurfaceFlinger | `main` → 渲染命令 → `1.raster` → SurfaceFlinger |
| **Buffer 交换** | `1.raster` 线程上的 `queueBuffer/dequeueBuffer` (SurfaceView) | `1.raster` 线程上的 `QueueSubmit` (SurfaceView) |
| **帧间隔** | 更稳定的帧间隔 | 可能更紧凑的帧间隔 |

**注**: TextureView 模式下，无论 Flutter 版本如何，`updateTexImage` 都在 `JNIOnload` 线程调用。

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
├── shared/                     # 所有 Dart 代码和资源的单一来源
│   ├── lib/                    # 18 个 Dart 文件 (3,749 行)，通过 --dart-define 参数化
│   │   ├── main.dart
│   │   ├── constants.dart
│   │   ├── screens/
│   │   ├── data/
│   │   ├── models/
│   │   ├── utils/
│   │   └── widgets/
│   └── assets/                 # 共享头像和图片资源
├── 3.19_SurfaceView/           # Flutter 3.19 (Skia + SurfaceView)
├── 3.19_TextureView/           # Flutter 3.19 (Skia + TextureView)
├── 3.27_SurfaceView/           # Flutter 3.27 (Impeller + SurfaceView)
├── 3.27_TextureView/           # Flutter 3.27 (Impeller + TextureView)
├── 3.29_SurfaceView/           # Flutter 3.29 (Impeller + 主线程融合 + SurfaceView)
├── 3.29_TextureView/           # Flutter 3.29 (Impeller + 主线程融合 + TextureView)
├── build_release.sh            # 完整构建脚本
├── install_apks.sh             # 批量安装脚本
├── quick_launch.sh             # 快速启动脚本
├── check_env.sh                # 环境检查脚本
├── .github/workflows/          # GitHub Actions CI/CD
└── apk-release/                # APK输出目录
```

### 架构：单一源码 + 编译时配置

6 个变体共享同一份 Dart 源码（通过符号链接）：
- 每个变体的 `lib/` 和 `assets/` 均为指向 `../shared/lib` 和 `../shared/assets` 的符号链接
- 每个变体保留自己的 `pubspec.yaml`（Flutter 版本约束）和 `android/`（namespace、applicationId）
- 运行时差异通过 `--dart-define` 编译时常量参数化：

| 常量 | 说明 | 示例 |
|------|------|------|
| `FLUTTER_VERSION` | Flutter 版本标识 | `3.19`、`3.27`、`3.29` |
| `RENDER_MODE` | 渲染表面类型 | `SurfaceView`、`TextureView` |
| `PACKAGE_NAME` | Android 应用 ID | `com.example.friendscircle.v27` |

## 代码架构

```
shared/lib/
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

### 手动构建（单个变体）

```bash
cd 3.27_SurfaceView
fvm flutter build apk --release \
    --dart-define=FLUTTER_VERSION=3.27 \
    --dart-define=RENDER_MODE=SurfaceView \
    --dart-define=PACKAGE_NAME=com.example.friendscircle.v27
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
