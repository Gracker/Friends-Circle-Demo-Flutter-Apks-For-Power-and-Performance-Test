import 'package:flutter/material.dart';
import '../constants.dart';
import 'base_load_screen.dart';

/// 中负载屏幕
class MediumLoadScreen extends BaseLoadScreen {
  const MediumLoadScreen({
    Key? key,
    required int loadType,
  }) : super(key: key, loadType: loadType);

  @override
  State<MediumLoadScreen> createState() => _MediumLoadScreenState();
}

class _MediumLoadScreenState extends BaseLoadScreenState<MediumLoadScreen> {
  // 中负载屏幕特有的逻辑可以在这里实现
} 