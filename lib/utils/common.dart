import 'dart:math';
import 'package:flutter/material.dart';

class ColorUtils {
  static Color getRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256), // 生成0到255之间的随机红色值
      random.nextInt(256), // 生成0到255之间的随机绿色值
      random.nextInt(256), // 生成0到255之间的随机蓝色值
      1, // 不透明度为1，即完全不透明
    );
  }
}
