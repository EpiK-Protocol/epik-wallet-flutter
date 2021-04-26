import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

/// 安卓和ios设备信息获取类，相关信息 可见文章 https://blog.csdn.net/weixin_34389926/article/details/88834125
class DeviceUtils {
  //系统标记类
  static bool isDebug = !bool.fromEnvironment("dart.vm.product");
  static bool isAndroid = Platform.isAndroid;
  static bool isIos = Platform.isIOS;

  IosDeviceInfo iosDeviceInfo;

  AndroidDeviceInfo androidDeviceInfo;

  static DeviceUtils _deviceManger = DeviceUtils._internal();

  factory DeviceUtils() {
    return _deviceManger;
  }

  DeviceUtils._internal();

  Future initPlatInfo() async {
    DeviceInfoPlugin deviceInfo = new DeviceInfoPlugin();
    if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfo.iosInfo;
    } else if (Platform.isAndroid) {
      androidDeviceInfo = await deviceInfo.androidInfo;
    }
  }

  String getSystemModel() {
    return "LON-AL00";
    if (isAndroid) {
      if (androidDeviceInfo != null) {
        return androidDeviceInfo.model;
      }
    } else if (isIos) {}

    return "";
  }

  ///占位 值
  String getIMEI() {
    return "862031031508387";
    if (isAndroid) {
      if (androidDeviceInfo != null) {
        return androidDeviceInfo.id;
      }
    }
  }

  ///占位 值
  String getMacAddress() {
    if (isAndroid) {
      if (androidDeviceInfo != null) {
        return androidDeviceInfo.model;
      }
    }
  }

  String getSystemVersion() {
    if (isAndroid) {
      if (androidDeviceInfo != null) {
        return androidDeviceInfo.version.release;
      } else {
        return "9.0";
      }
    } else {
      if (iosDeviceInfo != null) {
        return iosDeviceInfo.systemVersion;
      } else {
        return "12.0";
      }
    }
  }

  ///占位 值
  String getUMengChannel() {
    return "328533";
  }

  ///占位 值
  String getDeviceId() {
    return "43920481883";
  }

  String getSystemUa() {
    if (isAndroid) {
      try {
        if (androidDeviceInfo != null) {
          return "Android_" +
              androidDeviceInfo.version.toString() +
              "_" +
              androidDeviceInfo.manufacturer +
              "_" +
              androidDeviceInfo.board +
              "_" +
              androidDeviceInfo.device +
              "_";
        }
      } catch (e) {}
      return "Android";
    } else if (isIos) {
      try {
        if (iosDeviceInfo != null) {
          return "ios_" +
              iosDeviceInfo.name +
              "-" +
              iosDeviceInfo.systemVersion;
        }
      } catch (e) {}
      return "ios";
    } else {
      return "unknow";
    }
  }

  static const SystemUiOverlayStyle system_bar_light = SystemUiOverlayStyle(
    //顶部状态栏
    statusBarColor: null,
    //Android M 6.0 api23 状态栏背景色
    statusBarIconBrightness: Brightness.light,
    //Android M 6.0 状态栏图标文字黑白
    statusBarBrightness: Brightness.dark,
    //ios 状态栏 黑白
    //底部导航栏
    systemNavigationBarColor: ResColor.b_1,//Color(0xFFffffff),
    //Android O 8.0 api26 底部虚拟按键背景色
    systemNavigationBarDividerColor:Colors.transparent,// Color(0xFFffffff),
    //Android P 9.0 api28  底部虚拟按键与app的分割线颜色
    systemNavigationBarIconBrightness:
        Brightness.light, //Android O 8.0 api26 底部虚拟按键图标黑白
  );

  static const SystemUiOverlayStyle system_bar_dark = SystemUiOverlayStyle(
    statusBarColor: null,
    //Android M 6.0 api23 状态栏背景色
    statusBarIconBrightness: Brightness.dark,
    //Android M 6.0 状态栏图标文字黑白
    statusBarBrightness: Brightness.light,
    //ios 状态栏 黑白

    systemNavigationBarColor: ResColor.b_1,//Color(0xFFffffff),
    //Android O 8.0 api26 底部虚拟按键背景色
    systemNavigationBarDividerColor: Colors.transparent,//Color(0xFFffffff),
    //Android P 9.0 api28  底部虚拟按键与app的分割线颜色
    systemNavigationBarIconBrightness:
        Brightness.light, //Android O 8.0 api26 底部虚拟按键图标黑白
  );

  static const SystemUiOverlayStyle system_bar_main = SystemUiOverlayStyle(
    statusBarColor: null,
    //Android M 6.0 api23 状态栏背景色
    statusBarIconBrightness: Brightness.light,
    //Android M 6.0 状态栏图标文字黑白
    statusBarBrightness: Brightness.dark,
    //ios 状态栏 黑白

    systemNavigationBarColor: ResColor.b_2,//Color(0xFFffffff),
    //Android O 8.0 api26 底部虚拟按键背景色
    systemNavigationBarDividerColor: Colors.transparent,//Color(0xFFffffff),
    //Android P 9.0 api28  底部虚拟按键与app的分割线颜色
    systemNavigationBarIconBrightness:
    Brightness.light, //Android O 8.0 api26 底部虚拟按键图标黑白
  );



  static SystemUiOverlayStyle system_bar_current;

  static setSystemBarStyle(SystemUiOverlayStyle style) {
    print("setSystemBarStyle ${style.systemNavigationBarColor}");
    system_bar_current = style;
    SystemChrome.setSystemUIOverlayStyle(style);
  }

  static copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  static Future<String> readClipboard() async {
    ClipboardData clipboarddata = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboarddata != null) {
      return clipboarddata.text;
    }
    return null;
  }

  ///设置android 底部系统导航栏背景色
  static changeNavigationColor(Color color, {bool animate = false}) async {
    try {
      print("changeNavigationColor");
      print(color);
      await FlutterStatusbarcolor.setNavigationBarColor(color,
          animate: animate);
    } on PlatformException catch (e) {
      debugPrint("changeNavigationColor error");
      debugPrint(e.toString());
    }
  }
}
