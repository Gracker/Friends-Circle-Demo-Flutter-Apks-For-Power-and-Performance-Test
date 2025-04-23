import 'package:flutter/material.dart';
import '../constants.dart';
import 'texture_base_load_screen.dart';

/// 使用TextureView实现的重负载测试屏幕
class TextureHeavyLoadScreen extends TextureBaseLoadScreen {
  const TextureHeavyLoadScreen({Key? key})
      : super(key: key, loadType: Constants.LOAD_TYPE_HEAVY);

  @override
  State<TextureHeavyLoadScreen> createState() => _TextureHeavyLoadScreenState();
}

class _TextureHeavyLoadScreenState extends TextureBaseLoadScreenState<TextureHeavyLoadScreen> {
  // 重负载测试屏幕特有的逻辑可以在这里实现
} 