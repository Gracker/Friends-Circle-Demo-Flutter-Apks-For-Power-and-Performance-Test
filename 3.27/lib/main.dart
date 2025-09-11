import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'screens/home_screen.dart';
import 'screens/light_load_screen.dart';
import 'screens/medium_load_screen.dart';
import 'screens/heavy_load_screen.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 设置应用方向为竖屏
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 设置状态栏颜色
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 获取初始路由
  const platform = MethodChannel('app.channel.shared.data');
  final String? initialLoad = await platform.invokeMethod('getInitialLoad');

  Widget homeWidget = const HomeScreen();
  if (initialLoad == 'light') {
    homeWidget = const LightLoadScreen(loadType: Constants.LOAD_TYPE_LIGHT);
  } else if (initialLoad == 'medium') {
    homeWidget = const MediumLoadScreen(loadType: Constants.LOAD_TYPE_MEDIUM);
  } else if (initialLoad == 'heavy') {
    homeWidget = const HeavyLoadScreen(loadType: Constants.LOAD_TYPE_HEAVY);
  }

  runApp(MyApp(home: homeWidget));
}

class MyApp extends StatelessWidget {
  final Widget home;
  const MyApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter V3.27 朋友圈性能功耗测试 Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(Constants.COLOR_PRIMARY),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(Constants.COLOR_PRIMARY),
          foregroundColor: Colors.white,
        ),
      ),
      home: home,
    );
  }
}
