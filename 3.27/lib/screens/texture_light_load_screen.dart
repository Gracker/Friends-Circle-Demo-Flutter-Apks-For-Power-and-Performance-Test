import 'package:flutter/material.dart';
import '../constants.dart';
import 'texture_base_load_screen.dart';

/// 使用TextureView实现的轻负载测试屏幕
class TextureLightLoadScreen extends TextureBaseLoadScreen {
  const TextureLightLoadScreen({Key? key})
      : super(key: key, loadType: Constants.LOAD_TYPE_LIGHT);

  @override
  State<TextureLightLoadScreen> createState() => _TextureLightLoadScreenState();
}

class _TextureLightLoadScreenState extends TextureBaseLoadScreenState<TextureLightLoadScreen> {
  // 轻负载测试屏幕特有的逻辑可以在这里实现
} 