import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lazyreader/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lazyreader/pages/splash.dart';
import 'package:lazyreader/pages/user/login.dart';
import 'package:lazyreader/utils/event_bus_util.dart';
import 'package:lazyreader/utils/http_util.dart';
import 'package:lazyreader/utils/local_storage_util.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import './routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await HttpUtil.initCookieJar();
  await LocalStorageUtil.init();
  runApp(ProviderScope(child: MyApp()));
  configLoading();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 定义主题颜色常量
const primaryColor = Color(0xFF0088CC); // 主色调：深邃的蓝色
const secondaryColor = Color(0xFF00A0E4); // 次要颜色：明亮的蓝色
const accentColor = Color(0xFF40C4FF); // 强调色：浅蓝色

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    eventBus.on<UserUnauthorizedEvent>().listen((event) {
      print("检测到登录失效事件");
      Fluttertoast.showToast(msg: "登录失效，请重新登录");
      navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        // 颜色方案
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
          secondary: secondaryColor,
          tertiary: accentColor,
        ),

        // 主色调
        primaryColor: primaryColor,

        // 背景颜色
        scaffoldBackgroundColor: Colors.white,

        // 字体主题
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.light().textTheme,
        ).copyWith(
          displayLarge: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: primaryColor,
          ),
          displayMedium: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          titleLarge: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          bodyLarge: const TextStyle(
            fontSize: 16,
            letterSpacing: 0.15,
            height: 1.5,
          ),
          bodyMedium: const TextStyle(
            fontSize: 14,
            letterSpacing: 0.25,
            height: 1.5,
          ),
        ),

        // AppBar 主题
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 2,
          backgroundColor: Colors.white,
          foregroundColor: primaryColor,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),

        // 卡片主题
        cardTheme: CardTheme(
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),

        // 输入框主题
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),

        // 按钮主题
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
        ),

        // 图标主题
        iconTheme: const IconThemeData(
          color: primaryColor,
          size: 24,
        ),
      ),

      // 深色主题
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
          secondary: secondaryColor,
          tertiary: accentColor,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF121212),
          foregroundColor: secondaryColor,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.2),
          color: const Color(0xFF1E1E1E),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: secondaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),

      themeMode: ThemeMode.light,
      onGenerateRoute: onGenerateRoute,
      home: SplashScreen(),
      navigatorKey: navigatorKey,
      builder: EasyLoading.init(),
    );
  }
}

Future<void> configLoading() async {
  EasyLoading.instance
    ..maskType = EasyLoadingMaskType.none
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..maskColor = Colors.black87
    ..displayDuration = const Duration(milliseconds: 1)
    ..userInteractions = false;
}
