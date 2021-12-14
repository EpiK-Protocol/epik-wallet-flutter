import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';

import 'common_function.dart';

///通常是和 viewpager 联合使用  ， 类似于Android 中的 fragment
/// 不过生命周期 还需要在容器父类中根据tab切换来完善
abstract class BaseInnerWidget extends StatefulWidget {
  int index;

  BaseInnerWidget({Key key}) : super(key: key);

  @override
  BaseInnerWidgetState createState() {
    index = setIndex();
    return getState();
  }

  ///作为内部页面 ， 设置是第几个页面 ，也就是在list中的下标 ， 方便 生命周期的完善
  int setIndex();

  BaseInnerWidgetState getState();
}

abstract class BaseInnerWidgetState<T extends BaseInnerWidget> extends State<T>
    with AutomaticKeepAliveClientMixin, BaseFuntion, WidgetsBindingObserver {
  bool isFirstLoad = true; //是否是第一次加载的标记位

  final GlobalKey<ScaffoldState> key_ScaffoldState = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    initBaseCommon(this);
    print("baseinnerwidget --- initState ---" + getWidgetName());
    setBackIconHinde();
    initStateConfig();
    onCreate();
    super.initState();
  }

  void initStateConfig() {
    setTopBarVisible(false);
    setAppBarVisible(false);
  }

  @override
  void didChangeDependencies() {
    bottomVsrtical = getVerticalMargin();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (isFirstLoad) {
      onResume();
      isFirstLoad = false;
    }

//    return Scaffold(
//      key: key_ScaffoldState,
//      body: getBaseView(context),
//    );
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: getBaseView(context),
    );
  }

  @override
  void dispose() {
    onDestory();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  ///返回作为内部页面，垂直方向 头和底部 被占用的 高度
  double getVerticalMargin() {
    return 0;
  }

  @override
  bool get wantKeepAlive => true;

  ///为了完善生命周期而特意搞得 方法 ， 手动调用 onPause 和onResume
  void changePageVisible(int index, int preIndex) {
    if (index != preIndex) {
      if (preIndex == widget.index) {
        onPause();
      } else if (index == widget.index) {
        onResume();
      }
    }
  }

  onResume()
  {
    print("onResume ${getWidgetName()}");
  }

  //新加内容
  AppLifecycleState _state;

  //新加内容
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _state = state;
    dlog("state --> : $_state");
  }

  closeInput() {
    FocusScope.of(context).requestFocus(new FocusNode());
  }
}
