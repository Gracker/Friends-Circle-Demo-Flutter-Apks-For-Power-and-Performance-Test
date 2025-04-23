import 'package:flutter/material.dart';
import '../constants.dart';
import 'texture_base_load_screen.dart';

/// 使用TextureView实现的中负载测试屏幕
class TextureMediumLoadScreen extends TextureBaseLoadScreen {
  const TextureMediumLoadScreen({Key? key})
      : super(key: key, loadType: Constants.LOAD_TYPE_MEDIUM);

  @override
  State<TextureMediumLoadScreen> createState() => _TextureMediumLoadScreenState();
}

class _TextureMediumLoadScreenState extends TextureBaseLoadScreenState<TextureMediumLoadScreen> {
  // 中负载测试屏幕特有的逻辑可以在这里实现
} 