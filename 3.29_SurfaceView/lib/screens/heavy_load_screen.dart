import 'package:flutter/material.dart';
import '../constants.dart';
import 'base_load_screen.dart';

/// 重负载屏幕
class HeavyLoadScreen extends BaseLoadScreen {
  const HeavyLoadScreen({
    Key? key,
    required int loadType,
  }) : super(key: key, loadType: loadType);

  @override
  State<HeavyLoadScreen> createState() => _HeavyLoadScreenState();
}

class _HeavyLoadScreenState extends BaseLoadScreenState<HeavyLoadScreen> {
  // 重负载屏幕特有的逻辑可以在这里实现
} 