import 'dart:ui';

import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//import 'package:umeng_analytics_plugin/umeng_analytics_plugin.dart';

import 'NavigatorManger.dart';
import 'common_function.dart';

abstract class BaseWidget extends StatefulWidget {
  @override
  BaseWidgetState createState() {
    return getState();
  }

  BaseWidgetState getState();
}

abstract class BaseWidgetState<T extends BaseWidget> extends State<T>
    with WidgetsBindingObserver, BaseFuntion {
  final GlobalKey<ScaffoldState> key_ScaffoldState = GlobalKey();


//  bool isAndroid = Platform.isAndroid;

  bool _onResumed = false; //
  bool _onPause = false; //

  @override
  void initState() {
    initBaseCommon(this);
    dlog("basewidget --- initState ---" + getWidgetName());
    NavigatorManger().addWidget(this);
    WidgetsBinding.instance.addObserver(this);
    initStateConfig();
    onCreate();
    if (mounted) {}
    super.initState();

//    UmengAnalyticsPlugin.pageStart(getWidgetName());
  }

  void initStateConfig() {}

  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void deactivate() {
//    log("----buildbuild---deactivate");
    //
    if (NavigatorManger().isSecondTop(this)) {
      if (!_onPause) {
        onPause();
        _onPause = true;
      } else {
        onResume();
        _onPause = false;
      }
    } else if (NavigatorManger().isTopPage(this)) {
      if (!_onPause) {
        onPause();
      }
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
//    log("------buildbuild---build");
    if (!_onResumed) {
      //
      if (NavigatorManger().isTopPage(this)) {
        _onResumed = true;
        onResume();
      }
    }
    return Scaffold(
      key: key_ScaffoldState,
      body:getBaseView(context),
      resizeToAvoidBottomInset: resizeToAvoidBottomPadding, //keyboard
    );
  }

  SystemUiOverlayStyle viewSystemUiOverlayStyle=DeviceUtils.system_bar_light;
  SystemUiOverlayStyle oldSystemUiOverlayStyle;

  @override
  void onCreate() {
    super.onCreate();

    oldSystemUiOverlayStyle = DeviceUtils.system_bar_current;
    DeviceUtils.setSystemBarStyle(viewSystemUiOverlayStyle);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    onDestory();
    WidgetsBinding.instance.removeObserver(this);
    _onResumed = false;
    _onPause = false;

    //
    NavigatorManger().removeWidget(this);

//    UmengAnalyticsPlugin.pageEnd(getWidgetName());

    if (oldSystemUiOverlayStyle != null)
      DeviceUtils.setSystemBarStyle(oldSystemUiOverlayStyle);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    if (state == AppLifecycleState.resumed) {
      //on resume
      if (NavigatorManger().isTopPage(this)) {
        onForeground();
        onResume();
      }
    } else if (state == AppLifecycleState.paused) {
      //onpause
      if (NavigatorManger().isTopPage(this)) {
        onBackground();
        onPause();
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  closeInput() {
    try {
      FocusScope.of(context).requestFocus(new FocusNode());
      dlog("closeInput");
    } catch (e) {
      print(e);
    }
  }

  @override
  void onPause() {
    // TODO: implement onPause
    dlog("onPause");
  }

  @override
  void onResume() {
    // TODO: implement onResume
    dlog("onResume");
    // DeviceUtils.changeNavigationColor(navigationColor);
  }



}

