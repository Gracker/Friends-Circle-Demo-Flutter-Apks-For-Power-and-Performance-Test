import 'package:flutter/material.dart';
import '../constants.dart';
import 'base_load_screen.dart';

/// 轻负载屏幕
class LightLoadScreen extends BaseLoadScreen {
  const LightLoadScreen({
    Key? key,
    required int loadType,
  }) : super(key: key, loadType: loadType);

  @override
  State<LightLoadScreen> createState() => _LightLoadScreenState();
}

class _LightLoadScreenState extends BaseLoadScreenState<LightLoadScreen> {
  // 轻负载屏幕特有的逻辑可以在这里实现
} 