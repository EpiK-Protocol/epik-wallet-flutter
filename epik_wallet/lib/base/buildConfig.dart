import 'dart:io';

import 'package:flutter/foundation.dart';

class BuildConfig {
  //系统标记类
  static const bool isDebug = kReleaseMode != true;
  static bool isAndroid = Platform.isAndroid;
  static bool isIos = Platform.isIOS;
}
