import 'dart:io';

import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/utils/CupertinoLocalizationsDelegate.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/sp_utils/sp_utils.dart';
import 'package:epikwallet/utils/toast/toast.dart';
import 'package:epikwallet/views/mainview.dart';
import 'package:epikwallet/views/splashview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:umeng_analytics_plugin/umeng_analytics_plugin.dart';

final String fontFamily_def = "Miui-Light";

void main() {
  runApp(MyApp());

  if (Platform.isAndroid) {
    //沉浸式状态栏
    //写在组件渲染之后，是为了在渲染后进行设置赋值，覆盖状态栏，写在渲染之前对MaterialApp组件会覆盖这个值。
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatefulWidget {
  MyApp() {
//    final router = Router();
//    Routes.configureRoutes(router);
//    Application.router = router;
  }

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  //上次点击时间
  DateTime lastPopTime;

  bool hasDataInit = false;

  @override
  void initState() {
    initOrder().then((v) {
      setState(() {
        hasDataInit = true;
      });
    });
  }

  Future<void> initOrder() async {
    await SpUtils().init();
    await AccountMgr().load();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //隐藏debug标签
//      navigatorObservers: [AppAnalysis()],//umeng自动统计
      color: ResColor.main,
      theme: ThemeData(
        fontFamily: fontFamily_def, // 统一指定应用的字体。
        platform: TargetPlatform.iOS, // ios 有手势返回  右侧滑入新页面
        backgroundColor: Colors.white,
        unselectedWidgetColor: Colors.grey,
      ),
//      onGenerateRoute: Application.router.generator,
      title: 'EpiK Portal',
//      theme: ThemeData(
//        primarySwatch: Colors.blue,
//      ),
      localizationsDelegates: [
        CupertinoLocalizationsDelegate(),
//        FallbackCupertinoLocalisationsDelegate(),
        //此处 国际化
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        //此处 国际化
        const Locale('zh', 'CH'),
        const Locale('en', 'US'),
      ],

//      home: MainView(),
      home: WillPopScope(
        onWillPop: () async {
          if (lastPopTime == null ||
              DateTime.now().difference(lastPopTime) > Duration(seconds: 1)) {
            //两次点击间隔超过1秒则重新计时
            lastPopTime = DateTime.now();
            ToastUtils.showToast("再按一次退出");
            return new Future.value(false);
          }
          return new Future.value(true);
        },
//        child: MainView(),
        child: hasDataInit
            ? SplashView()
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
              ),
      ),
      builder: (context, widget) {
        return MediaQuery(
          //设置文字大小不随系统设置改变
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: widget,
        );
      },
    );
  }
}
