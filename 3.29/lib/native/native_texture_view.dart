import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'texture_view_controller.dart';

/// 原生TextureView的Flutter封装
class NativeTextureView extends StatefulWidget {
  /// 加载类型：1-轻负载，2-中负载，3-重负载
  final int loadType;
  
  /// 子组件，将被显示在TextureView上
  final Widget child;
  
  /// 创建一个NativeTextureView
  const NativeTextureView({
    Key? key,
    required this.loadType,
    required this.child,
  }) : super(key: key);

  @override
  State<NativeTextureView> createState() => _NativeTextureViewState();
}

class _NativeTextureViewState extends State<NativeTextureView> with WidgetsBindingObserver {
  /// TextureView控制器
  final TextureViewController _controller = TextureViewController();
  
  /// 平台视图工厂ID
  static const String viewType = 'com.androidperformance.wechat_friend_flutter_demo/texture_view';
  
  /// 是否已准备好显示
  bool _isReady = false;
  
  /// 用于更新纹理的定时器
  Timer? _updateTimer;
  
  /// 连续错误计数器
  int _errorCount = 0;
  
  /// 最大允许错误次数
  static const int _maxErrorCount = 5;

  /// 创建时间戳，用于计算各阶段耗时
  final DateTime _creationTime = DateTime.now();
  
  /// 纹理ID
  int? _textureId;

  @override
  void initState() {
    super.initState();
    debugPrint('NativeTextureView: 初始化 loadType=${widget.loadType}');
    WidgetsBinding.instance.addObserver(this);
    
    // 延迟一帧启动更新，确保所有初始化完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPeriodicUpdates();
    });
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('NativeTextureView: 生命周期变化 $state');
    switch (state) {
      case AppLifecycleState.resumed:
        // 应用恢复时重新开始更新
        debugPrint('NativeTextureView: 应用恢复，重新开始更新');
        _startPeriodicUpdates();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        // 应用暂停时停止更新
        debugPrint('NativeTextureView: 应用暂停/不活跃，停止更新');
        _stopPeriodicUpdates();
        break;
      default:
        break;
    }
  }
  
  @override
  void dispose() {
    debugPrint('NativeTextureView: 销毁');
    _stopPeriodicUpdates();
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  /// 开始周期性纹理更新
  void _startPeriodicUpdates() {
    _stopPeriodicUpdates();
    
    // 计算初始化耗时
    final initDuration = DateTime.now().difference(_creationTime);
    debugPrint('NativeTextureView: 启动周期性更新，初始化耗时: ${initDuration.inMilliseconds}ms');
    
    // 降低更新频率，减少压力
    _updateTimer = Timer.periodic(const Duration(milliseconds: 100), _updateTextureCallback);
    _errorCount = 0;
  }
  
  /// 停止周期性纹理更新
  void _stopPeriodicUpdates() {
    if (_updateTimer != null) {
      debugPrint('NativeTextureView: 停止周期性更新');
      _updateTimer?.cancel();
      _updateTimer = null;
    }
  }
  
  /// 更新纹理回调
  void _updateTextureCallback(Timer timer) async {
    if (!mounted) {
      debugPrint('NativeTextureView: 组件已卸载，取消更新');
      timer.cancel();
      return;
    }
    
    if (!_isReady) {
      // 每秒打印一次未就绪状态，避免日志过多
      if (timer.tick % 10 == 0) {
        debugPrint('NativeTextureView: 等待TextureView就绪...');
      }
      return;
    }
    
    try {
      final success = await _controller.updateTexture();
      if (success) {
        // 重置错误计数
        if (_errorCount > 0) {
          debugPrint('NativeTextureView: TextureView更新恢复正常');
        }
        _errorCount = 0;
      } else if (timer.tick % 10 == 0) {
        // 每秒打印一次更新失败，避免日志过多
        debugPrint('NativeTextureView: TextureView更新返回失败');
      }
    } catch (e) {
      _errorCount++;
      debugPrint('NativeTextureView: TextureView更新异常 $_errorCount/$_maxErrorCount: $e');
      
      if (_errorCount >= _maxErrorCount) {
        debugPrint('NativeTextureView: 达到最大错误次数，暂停更新并计划重试');
        // 达到最大错误次数，暂停更新
        _stopPeriodicUpdates();
        
        // 延迟后重试
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            debugPrint('NativeTextureView: 尝试重新启动TextureView更新');
            _startPeriodicUpdates();
          }
        });
      }
    }
  }
  
  /// 当平台视图创建完成后调用
  void _onPlatformViewCreated(int viewId) {
    final creationDuration = DateTime.now().difference(_creationTime);
    debugPrint('NativeTextureView: 平台视图创建完成 viewId=$viewId, 耗时: ${creationDuration.inMilliseconds}ms');
    _controller.initMethodChannel(viewId);
    
    // 监听纹理就绪事件
    _controller.addTextureReadyListener((textureId) {
      if (mounted && textureId >= 0) {
        setState(() {
          _textureId = textureId;
          _isReady = true;
        });
        debugPrint('NativeTextureView: 收到纹理ID: $_textureId');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 创建参数
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'loadType': widget.loadType,
    };
    
    return Stack(
      children: [
        // 使用AndroidView创建原生TextureView作为渲染容器
        SizedBox.expand(
          child: AndroidView(
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onPlatformViewCreated,
          ),
        ),
        
        // 如果有纹理ID，使用Flutter的Texture组件显示原生内容
        if (_textureId != null && _isReady)
          Positioned.fill(
            child: Texture(
              textureId: _textureId!,
              filterQuality: FilterQuality.low,
            ),
          ),
        
        // 子组件
        widget.child,
      ],
    );
  }
} 