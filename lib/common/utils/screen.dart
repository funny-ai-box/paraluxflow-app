import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
  ScreenUtil.pixelRatio       //设备的像素密度
    ScreenUtil.screenWidth      //设备宽度
    ScreenUtil.screenHeight     //设备高度
    ScreenUtil.bottomBarHeight  //底部安全区距离，适用于全面屏下面有按键的
    ScreenUtil.statusBarHeight  //状态栏高度 刘海屏会更高  单位px
    ScreenUtil.textScaleFactor //系统字体缩放比例
    
    ScreenUtil().scaleWidth  // 实际宽度的dp与设计稿px的比例
    ScreenUtil().scaleHeight // 实际高度的dp与设计稿px的比例
*/

/// 设置宽度
double duSetWidth(double width) {
  return ScreenUtil().setWidth(width);
}

/// 设置宽度
double duSetHeight(double height) {
  return ScreenUtil().setHeight(height);
}

/// 设置字体尺寸
double duSetFontSize(double fontSize) {
  return ScreenUtil().setSp(fontSize);
}

/// 导出baseurl
String getBaseUrl() {
  return 'http://127.0.0.1:8001';
}

Future<String> getTokenFromLocalStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = await prefs.getString('token') ?? '';
  return token;
}