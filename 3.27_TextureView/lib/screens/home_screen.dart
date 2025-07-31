import 'package:flutter/material.dart';
import '../constants.dart';
import '../data/data_center.dart';
import 'light_load_screen.dart';
import 'medium_load_screen.dart';
import 'heavy_load_screen.dart';
import 'dart:math' as math;

/// 主页面，用于选择不同负载级别的测试
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(Constants.COLOR_BACKGROUND),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // 标题
              const Text(
                'Flutter V3.27 朋友圈性能功耗测试 Demo (TextureView)',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // 所有按钮放在同一个卡片中
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '选择负载级别',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 轻负载按钮
                      _buildLoadButton(
                        context,
                        '轻负载测试',
                        Color(Constants.COLOR_PRIMARY),
                        () => _navigateToLoadScreen(context, Constants.LOAD_TYPE_LIGHT),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 中负载按钮
                      _buildLoadButton(
                        context,
                        '中负载测试',
                        Color(Constants.COLOR_ACCENT),
                        () => _navigateToLoadScreen(context, Constants.LOAD_TYPE_MEDIUM),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 重负载按钮
                      _buildLoadButton(
                        context,
                        '重负载测试',
                        Color(Constants.COLOR_HEAVY),
                        () => _navigateToLoadScreen(context, Constants.LOAD_TYPE_HEAVY),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 应用介绍卡片
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '应用介绍',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      
                      SizedBox(height: 8),
                      
                      Text(
                        '这是一个用于测试Android平台Performance和Power的Flutter Demo App，'
                        '模拟了微信朋友圈的滑动场景，并提供了三种不同负载级别的测试界面。\n\n'
                        '应用提供三种不同负载级别的测试界面，'
                        '帮助您测试不同负载条件下的性能表现。\n\n'
                        '每次启动应用时，界面、UI和逻辑都保持一致，确保测试结果的可比性。\n\n'
                        '通过不同算法模拟不同级别的CPU和GPU负载，帮助您测试设备性能。',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 版权信息
              const Text(
                '© 2025 朋友圈性能测试应用',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF999999),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建负载按钮
  Widget _buildLoadButton(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onPressed,
  ) {
    // 获取屏幕宽度以计算按钮宽度
    double screenWidth = MediaQuery.of(context).size.width;
    // 增加按钮宽度，设置为屏幕宽度的85%
    double buttonWidth = math.max(screenWidth * 0.85 - 40, 250);
    
    return SizedBox(
      width: buttonWidth,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          // 清除缓存数据，确保每次测试都重新生成
          DataCenter().clearCachedData();
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// 导航到对应的负载测试界面
  void _navigateToLoadScreen(BuildContext context, int loadType) {
    Widget screen;
    
    // 只使用SurfaceView实现
    switch (loadType) {
      case Constants.LOAD_TYPE_LIGHT:
        screen = LightLoadScreen(loadType: loadType);
        break;
      case Constants.LOAD_TYPE_MEDIUM:
        screen = MediumLoadScreen(loadType: loadType);
        break;
      case Constants.LOAD_TYPE_HEAVY:
        screen = HeavyLoadScreen(loadType: loadType);
        break;
      default:
        screen = LightLoadScreen(loadType: Constants.LOAD_TYPE_LIGHT);
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

} 