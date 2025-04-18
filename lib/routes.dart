import 'package:flutter/material.dart';

import 'pages/home_screen.dart';

// import './pages/news/details.dart';

import './pages/mine/index.dart';

//配置路由,定义Map类型的routes,Key为String类型，Value为Function类型
final Map<String, Function> routes = {
  '/': (context) => HomeScreenPage(),

  '/mine': (context, {arguments}) => MineMainPage(),
};

//固定写法
var onGenerateRoute = (RouteSettings settings) {
  //String? 表示name为可空类型
  final String? name = settings.name;
  //Function? 表示pageContentBuilder为可空类型
  final Function? pageContentBuilder = routes[name];
  if (pageContentBuilder != null) {
    if (settings.arguments != null) {
      final Route route = MaterialPageRoute(
          builder: (context) =>
              pageContentBuilder(context, arguments: settings.arguments));
      return route;
    } else {
      final Route route =
          MaterialPageRoute(builder: (context) => pageContentBuilder(context));
      return route;
    }
  }
};
