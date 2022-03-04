import 'dart:async';
import 'dart:io';

import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/buildConfig.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/LocalAuthUtils.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/Upgrade.dart';
import 'package:epikwallet/utils/CupertinoLocalizationsDelegate.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/sp_utils/sp_utils.dart';
import 'package:epikwallet/utils/toast/toast.dart';
import 'package:epikwallet/views/splashview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info/package_info.dart';
// import 'package:umeng_analytics_plugin/umeng_analytics_plugin.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';

final String fontFamily_def = "Miui-Light";

String get _CHANNEL {
  return Platform.isAndroid ? "android" : "ios";
}

String get APP_CHANNEL {
  return _CHANNEL;
}

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

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

BuildContext get appContext {
  return navigatorKey?.currentState?.overlay?.context;
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
    initOther().then((v) {
      setState(() {
        hasDataInit = true;
      });
    });
  }

  Future<void> initOther() async {
    await SpUtils().init(); // 初始化存储工具
    await DeviceUtils().initPlatInfo();
    LocalAuthUtils.checkBiometrics().then((value) {
      Dlog.p("checkBiometrics","$value");
      if(value){
        LocalAuthUtils.getAvailableBiometrics().then((bs){
          Dlog.p("getAvailableBiometrics","$bs");
        });
      }
    });
    // bool localconfig = await ServiceInfo.loadConfig(); //加载本地缓存的配置

    // HdWallet.setDebug(ServiceInfo.TEST_DEV_NET ? true : false); //20220110注掉

    // await AccountMgr().load(); // 加载钱包账户
    // if(localconfig)
    // {
    //   ServiceInfo.requestConfig(); //请求新的服务配置
    // }

    Upgrade.packageinfo = await PackageInfo.fromPlatform();

    // if(Platform.isAndroid)
    // {
    //   GeneralWebView.useWF=true;
    //   wf.WebView.platform = wf.SurfaceAndroidWebView();
    // }else{
    //   GeneralWebView.useWF=false;
    // }

    //友盟初始化 todo
//     await UmengAnalyticsPlugin.init(
//       androidKey: '5fca552abed37e4506c2b987',
//       iosKey: '5fca556019bda368eb47c630',
//       channel: Platform.isAndroid ? "android" : "ios",
//       logEnabled: BuildConfig.isDebug, // release模式下 没有日志
// //      pageCollectionMode: "AUTO", // MANUAL手动页面日志,  AUTO自动
//     );
    //友盟初始化
    UmengCommonSdk.initCommon(
      "5fca552abed37e4506c2b987",
      "5fca556019bda368eb47c630",
      APP_CHANNEL,//Platform.isAndroid ? "android" : "ios",
    );
    // 手动采集页面信息
    UmengCommonSdk.setPageCollectionModeManual();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
        // 本地字符串
        ResStringDelegate.delegate,
      ],
      supportedLocales: [
        //此处国际化顺序  按顺序优先使用
        const Locale('en', 'US'),
        const Locale('zh', 'CH'),
      ],

//      home: MainView(),
      home: WillPopScope(
        onWillPop: onWillPop,
//        child: MainView(),
        child: hasDataInit
            ? SplashView()
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
              ),
      ),
      builder: transitionBuilder,
    );
  }

  Future<bool> onWillPop() async {
    if (lastPopTime == null ||
        DateTime.now().difference(lastPopTime) > Duration(seconds: 1)) {
      //两次点击间隔超过1秒则重新计时
      lastPopTime = DateTime.now();
//            ToastUtils.showToast("再按一次退出");
      ToastUtils.showToast(ResString.get(appContext, RSID.doubleclickquit));
      return new Future.value(false);
    }
    return new Future.value(true);
    ;
  }

  Widget transitionBuilder(BuildContext context, Widget widget) {
    return MediaQuery(
      //设置文字大小不随系统设置改变
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: widget,
    );
  }
}
