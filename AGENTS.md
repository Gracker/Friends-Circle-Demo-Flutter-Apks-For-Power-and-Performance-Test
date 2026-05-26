# AGENTS.md

本文件面向 Codex、Claude、Gemini、Copilot 等 AI coding agent。作用范围是整个仓库，除非子目录中出现更近的 `AGENTS.md` 并覆盖本文件。

## 工作原则

- 每次修改都要先从整体架构理解问题，不要为了局部通过而 hardcode。
- 默认自主推进。只有存在真正歧义、会影响发布结果或可能覆盖用户已有改动时，才停下来向用户确认。
- 修改前先看 `git status --short --branch`，不要回滚或覆盖不属于本次任务的改动。
- 对非平凡代码任务使用 `Plan -> Review -> Revise -> Execute`：先列出方案，再用只读 review 或结构化自审检查架构、边界和遗漏风险，然后再改代码。
- 代码改动完成后、提交前运行 `/simplify`。如果当前环境没有该命令，做一次等价的手动 simplify pass，并在最终说明里写清楚。

## 仓库架构

这是用于性能和功耗测试的 Flutter 朋友圈 demo。仓库同时维护 6 个可安装 APK 变体，用来比较 Flutter 版本、渲染表面和线程模型：

| 目录 | Flutter | 渲染/线程模型 | 包名 |
| --- | --- | --- | --- |
| `3.19_SurfaceView/` | `3.19.0` | Skia + SurfaceView | `com.example.friendscircle.v19` |
| `3.19_TextureView/` | `3.19.0` | Skia + TextureView | `com.example.friendscircle.v19.textureview` |
| `3.27_SurfaceView/` | `3.27.0` | Impeller + SurfaceView | `com.example.friendscircle.v27` |
| `3.27_TextureView/` | `3.27.0` | Impeller + TextureView | `com.example.friendscircle.v27.textureview` |
| `3.29_SurfaceView/` | `3.29.0` | Impeller + main thread merger + SurfaceView | `com.example.friendscircle.v29` |
| `3.29_TextureView/` | `3.29.0` | Impeller + main thread merger + TextureView | `com.example.friendscircle.v29.textureview` |

关键结构：

- 六个变体的 `lib` 都是指向 `shared/lib` 的 symlink，`assets` 都是指向 `shared/assets` 的 symlink。
- App 业务逻辑、负载逻辑、列表行为、UI 行为优先改 `shared/lib`，不要在单个变体目录里复制一份 Dart 代码。
- 只有版本、Android 工程、FVM 配置、包名、签名和渲染模式相关内容才应落在各 `3.xx_*` 目录。
- `apk-release/` 中的 6 个 release APK 是发布产物，只有重新打包 release 时才更新。

## 负载与滚动语义

性能测试语义必须在所有 Flutter 版本中保持一致：

- 按压拖动、手指仍在屏幕上的 manual drag 区间：不执行任何额外 Build、Paint、PostFrame 或 Mixed synthetic load。
- 手指释放后的 ballistic/inertial scroll 区间：才允许按概率和帧间隔执行 synthetic load。
- idle 区间：立即停止 synthetic load。

相关入口：

- `shared/lib/screens/unified_load_screen.dart`：滚动阶段识别和向 `LoadCalculator` 写入阶段。
- `shared/lib/utils/load_calculator.dart`：Build/PostFrame/Mixed 负载概率、帧间隔和惯性阶段 gating。
- `shared/lib/widgets/paint_load_painter.dart`：Paint load 渲染开销入口，也必须遵守滚动阶段 gating。
- `README.md` 和 `README_CN.md` 的 Scroll Awareness 描述需要与代码语义同步。

不要把某个 Flutter 版本特殊化成不同负载语义。版本差异用于比较引擎和渲染路径，不用于改变测试定义。

## 构建与发布规则

- 使用 FVM 管理 Flutter 版本，不要随意运行 `flutter upgrade` 或修改 `.fvm/fvm_config.json`。
- 本地完整 release 构建命令：

```bash
./build_release.sh
```

- 该命令应生成并更新：
  - `apk-release/friends_circle_v19sv_release.apk`
  - `apk-release/friends_circle_v19tv_release.apk`
  - `apk-release/friends_circle_v27sv_release.apk`
  - `apk-release/friends_circle_v27tv_release.apk`
  - `apk-release/friends_circle_v29sv_release.apk`
  - `apk-release/friends_circle_v29tv_release.apk`
- 单变体手工构建时必须带上正确的 dart define，例如：

```bash
cd 3.27_SurfaceView
fvm flutter build apk --release \
  --dart-define=FLUTTER_VERSION=3.27 \
  --dart-define=RENDER_MODE=SurfaceView \
  --dart-define=PACKAGE_NAME=com.example.friendscircle.v27
```

- 推送到 `main` 会触发 `.github/workflows/flutter-ci-cd.yml`，CI 会按 6 个 matrix 构建并创建 `auto-build-YYYYMMDD-HHMMSS` GitHub Release。
- 如果改了 Flutter 版本、包名、变体目录或 release 脚本，必须同步更新 README、CI workflow、安装脚本提示和 APK 命名说明。

## 验证命令

文档-only 修改：

```bash
git diff --check
```

Dart 或共享逻辑修改：

```bash
dart format shared/lib
cd 3.19_SurfaceView && fvm flutter analyze
cd ../3.27_SurfaceView && fvm flutter analyze --no-fatal-infos --no-fatal-warnings
cd ../3.29_SurfaceView && fvm flutter analyze --no-fatal-infos --no-fatal-warnings
```

Release 或 APK 相关修改：

```bash
./build_release.sh
```

然后确认 6 个 `apk-release/*.apk` 都存在，并用 `aapt dump badging` 或等价工具确认包名没有串版本。

Trace regression 相关修改：

```bash
./build_debug.sh
./install_debug_apks.sh
adb shell am start -n com.example.friendscircle.v27/.MainActivity -e "load" "build_heavy"
adb shell perfetto -o /data/misc/perfetto-traces/friends_flutter_trace.perfetto-trace -t 10s sched freq idle am wm gfx view binder_driver hal dalvik camera input res memory
adb pull /data/misc/perfetto-traces/friends_flutter_trace.perfetto-trace ./friends_flutter_trace.perfetto-trace
```

当前仓库没有独立的自动 trace regression analyzer。涉及负载、滚动、渲染或线程语义的改动，至少要用同一设备、同一 APK 变体、同一 load type 采集 trace，并在最终说明里记录测试组合、是否观察到按压拖动无负载、惯性滚动有负载。

## Git 与发布

- 提交前再次检查 `git status --short` 和 `git diff --stat`。
- 推送前先 `git fetch origin`，确认没有落后远端。
- 如果本次修改包含 release APK，提交信息要明确是代码改动还是 release artifact 更新。
- 推送后检查 GitHub Actions 是否启动；如果任务目标包含发布 release，需要等 CI release 成功并确认 tag/release 名称。

## 禁止事项

- 不要在 6 个变体目录里分别改同一份 Dart 业务逻辑。
- 不要提交 `build/`、`.dart_tool/`、本地 `local.properties` 或临时 trace 文件。
- 不要把 `apk-debug/` 当作 release 产物提交。
- 不要改变 package id、Flutter 版本或渲染模式而不更新构建脚本和 CI matrix。
- 不要声称 trace regression 通过，除非实际采集并检查了 trace。
