import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// TextureView渲染的Flutter组件
/// 
/// 这个组件使用AndroidView来桥接原生的TextureView，
/// 并配置使用TextureView渲染模式而不是默认的SurfaceView
class TextureViewWidget extends StatelessWidget {
  final Widget child;
  final Map<String, dynamic>? creationParams;

  const TextureViewWidget({
    super.key,
    required this.child,
    this.creationParams,
  });

  @override
  Widget build(BuildContext context) {
    // 目前作为包装器使用，直接返回child
    // 实际的TextureView渲染在Android原生层处理
    return child;
  }
}

/// TextureView桥接管理器
/// 
/// 负责管理Flutter与原生TextureView之间的通信
class TextureViewBridge {
  static const MethodChannel _channel = MethodChannel('texture_view_bridge');

  /// 初始化TextureView
  static Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize');
      debugPrint('TextureView bridge initialized');
    } on PlatformException catch (e) {
      debugPrint('Failed to initialize TextureView bridge: ${e.message}');
    }
  }

  /// 更新TextureView内容
  static Future<void> updateContent(Map<String, dynamic> content) async {
    try {
      await _channel.invokeMethod('updateContent', content);
    } on PlatformException catch (e) {
      debugPrint('Failed to update TextureView content: ${e.message}');
    }
  }

  /// 设置TextureView属性
  static Future<void> setProperty(String key, dynamic value) async {
    try {
      await _channel.invokeMethod('setProperty', {
        'key': key,
        'value': value,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to set TextureView property: ${e.message}');
    }
  }

  /// 获取TextureView属性
  static Future<dynamic> getProperty(String key) async {
    try {
      return await _channel.invokeMethod('getProperty', {'key': key});
    } on PlatformException catch (e) {
      debugPrint('Failed to get TextureView property: ${e.message}');
      return null;
    }
  }
}