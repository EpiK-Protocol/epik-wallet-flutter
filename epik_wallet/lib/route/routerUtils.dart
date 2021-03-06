//import 'package:aiinvestment/base/buildConfig.dart';
//import 'package:aiinvestment/route/router_application.dart';
//import 'package:aiinvestment/web/webpage.dart';
//import 'package:fluro/fluro.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//
///// 路由跳转 中转处
//class Nav {
//  static Future nav(BuildContext context, String path,
//      {bool replace = false,
//      bool clearStack = false,
//      TransitionType transition,
//      Duration transitionDuration = const Duration(milliseconds: 250),
//      RouteTransitionsBuilder transitionBuilder}) {
//    if (path == null || path.isEmpty) {
//      if (BuildConfig.isDebug) {
//        throw "empty path";
//      }
//    }
//    if (checkIsNativePath(path)) {
//      return Navigator.of(context)
//          .push(MaterialPageRoute(builder: (context) => (WebViewPage(path))));
//    } else {
//      return Application.router.navigateTo(context, path,
//          replace: replace,
//          clearStack: clearStack,
//          transition: transition,
//          transitionDuration: transitionDuration,
//          transitionBuilder: transitionBuilder);
//    }
//  }
//
//  ///判断是否是原生的路由 路径，是的话则需要 调原生跳转
//  static bool checkIsNativePath(String path) {
//    return (path.startsWith("http://") || path.startsWith("https://")) ||
//        (path.startsWith("native://"));
//  }
//}
