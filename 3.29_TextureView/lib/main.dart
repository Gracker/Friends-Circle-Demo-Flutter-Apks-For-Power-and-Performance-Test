import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'screens/home_screen.dart';
import 'screens/unified_load_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set app orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar color
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Get initial load type
  const platform = MethodChannel('app.channel.shared.data');
  String? initialLoad;
  try {
    initialLoad = await platform.invokeMethod('getInitialLoad');
  } catch (e) {
    // If retrieval fails, use default value
    initialLoad = null;
  }

  // Parse load type
  final loadType = Constants.parseLoadType(initialLoad);
  
  Widget homeWidget;
  if (loadType >= 0) {
    // Valid load type, go directly to test screen
    homeWidget = UnifiedLoadScreen(loadType: loadType);
  } else {
    // Invalid or unspecified, show home page
    homeWidget = const HomeScreen();
  }

  runApp(MyApp(home: homeWidget));
}

class MyApp extends StatelessWidget {
  final Widget home;
  const MyApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter V3.29 Performance Test Demo (TextureView)',
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
