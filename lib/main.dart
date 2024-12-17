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
import 'package:flex_color_scheme/flex_color_scheme.dart';
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

// 创建一个 GlobalKey 用于导航
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

    // 监听未登录事件
    eventBus.on<UserUnauthorizedEvent>().listen((event) {
      print("检测到登录失效事件");
      Fluttertoast.showToast(msg: "登录失效，请重新登录");
      navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.red, // 设置导航栏颜色
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: FlexThemeData.light(
        surface: Colors.white, // Ensure surfaces are white
        background: Colors.white, // Explicit background color
        colors: const FlexSchemeColor(
          primary: Color(0xff00a99d),
          primaryContainer: Color(0xffa5d6a7),
          secondary: Color(0xff00695c),
          tertiary: Color(0xff004d40),
          tertiaryContainer: Color(0xff59b1a1),
          error: Color(0xffb00020),
        ),
        dialogBackground: Colors.white,
        textTheme: GoogleFonts.notoSansAdlamTextTheme(
          Theme.of(context).textTheme,
        ),
        usedColors: 1,
        blendLevel: 7,
        appBarElevation: 5.5,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          blendTextTheme: true,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
        ),
        useMaterial3ErrorColors: true,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
      ),
      darkTheme: FlexThemeData.dark(
        surface: Colors.black, // 设置背景颜色为黑色
        background: Colors.black, // 显式背景颜色为黑色
        colors: const FlexSchemeColor(
          primary: Color(0xff80cbc4),
          primaryContainer: Color(0xff004d40),
          secondary: Color(0xff80cbc4),
          secondaryContainer: Color(0xff00695c),
          tertiary: Color(0xff4db6ac),
          tertiaryContainer: Color(0xff05514a),
          appBarColor: Color(0xff004d40),
          error: Color(0xffcf6679),
        ),

        scaffoldBackground: Colors.black, // 主屏幕背景颜色为黑色
        textTheme: GoogleFonts.notoSansAdlamTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.white, // 设置字体颜色为浅色
                displayColor: Colors.white, // 设置显示文字颜色为浅色
              ),
        ),
        // iconTheme: const IconThemeData(color: Colors.white), // 设置图标颜色为浅色
        usedColors: 1,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 15,
        appBarElevation: 2,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
        ),
        useMaterial3ErrorColors: true,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
      ),
      themeMode: ThemeMode.light,
      onGenerateRoute: onGenerateRoute,
      home: SplashScreen(),
      navigatorKey: navigatorKey, // 使用 GlobalKey
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
