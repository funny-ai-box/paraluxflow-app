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
    // 设置系统UI样式
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
          seedColor: const Color(0xFF00A99D),
          brightness: Brightness.light,
        ),

        // 自定义颜色
        primaryColor: const Color(0xFF00A99D),

        // 背景颜色
        scaffoldBackgroundColor: Colors.white,

        // 字体主题
        textTheme: GoogleFonts.notoSansTextTheme(
          ThemeData.light().textTheme,
        ).copyWith(
          displayLarge: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
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
          foregroundColor: Color(0xFF00A99D),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),

        // 卡片主题
        cardTheme: const CardTheme(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
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
            borderSide: const BorderSide(color: Color(0xFF00A99D), width: 2),
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
          ),
        ),

        // 图标主题
        iconTheme: const IconThemeData(
          color: Color(0xFF00A99D),
          size: 24,
        ),
      ),

      // 深色主题
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A99D),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.notoSansTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.black,
          foregroundColor: Color(0xFF80CBC4),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shadowColor: Colors.black26,
          color: Colors.grey.shade900,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade900,
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
            borderSide: const BorderSide(color: Color(0xFF80CBC4), width: 2),
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
