import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class Sizes {
  static Orientation get orientation => ScreenUtil().orientation;
  static double get screenWidth => ScreenUtil().screenWidth;
  static double get size3 => ScreenUtil().screenWidth / 3;
  static double get size4 => ScreenUtil().screenWidth / 4;
  static double get size5 => ScreenUtil().screenWidth / 5;
  static double get size7 => ScreenUtil().screenWidth / 7;
  static double get size9 => ScreenUtil().screenWidth / 9;
  static double get size10 => ScreenUtil().screenWidth / 10;
  static double get size12 => ScreenUtil().screenWidth / 12;
  static double get space25 => ScreenUtil().screenWidth / 25;
  static double get space50 => ScreenUtil().screenWidth / 50;
  static double get screenHeight => ScreenUtil().screenHeight;
  static double get statusBarHeight => ScreenUtil().statusBarHeight;
  static double get topBarHeight => ScreenUtil().setHeight(130);
  static double get navBarHeight => ScreenUtil().setHeight(150);
  static double get topSumHeight => ScreenUtil().statusBarHeight + topBarHeight;
  static double get contentHeight => ScreenUtil().screenHeight - ScreenUtil().statusBarHeight - topBarHeight;
}