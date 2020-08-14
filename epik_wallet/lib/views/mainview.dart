import 'dart:io';

import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/model/Upgrade.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/screen/screen_util.dart';
import 'package:epikwallet/views/epikview.dart';
import 'package:epikwallet/views/walletmenu.dart';
import 'package:epikwallet/views/walletview.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MainView extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> getState() {
    return _MainViewState();
  }
}

class _MainViewState extends BaseWidgetState<MainView> {
  int currentIndex = 0;
  int lastIndex = -1;

  final GlobalKey<ScaffoldState> key_scaffold = GlobalKey();
  List<GlobalKey<BaseInnerWidgetState>> keyList;

  // 子页面
  List<BaseInnerWidget> subViews;

  @override
  void initState() {
    isTopBarShow = false; //状态栏是否显示
    isAppBarShow = false; //导航栏是否显示
    super.initState();

    keyList = <GlobalKey<BaseInnerWidgetState>>[
      GlobalKey(),
      GlobalKey(),
    ];

    subViews = <BaseInnerWidget>[
      WalletView(keyList[0]),
      EpikView(keyList[1]),
    ];
  }

  //上次点击时间
  DateTime lastPopTime;

  @override
  Widget buildWidget(BuildContext context) {
    WHScreenUtil.initUtil(context);

    Scaffold scaffold = Scaffold(
      key: key_scaffold,
      body: IndexedStack(
        index: currentIndex,
        children: subViews,
      ),
//      bottomNavigationBar: BottomNavigationBar(
//        backgroundColor: Colors.white,
//        items: getBottomNavigationBarItems(),
//        currentIndex: currentIndex,
//        selectedItemColor: Color(0xff000000),
//        unselectedItemColor: Color(0xff999999),
//        onTap: _onItemTapped,
//        type: BottomNavigationBarType.fixed,
//        selectedFontSize: 11,
//        unselectedFontSize: 11,
//        iconSize: 21,
//      ),
      endDrawer: Drawer(
        child: WalletMenu(),
      ),
      endDrawerEnableOpenDragGesture: false,
    );
    return scaffold;

//    return WillPopScope(
//      onWillPop: () async {
//
//        if(closeRightDrawer())
//          return;
//
//        if (lastPopTime == null ||
//            DateTime.now().difference(lastPopTime) > Duration(seconds: 1)) {
//          //两次点击间隔超过1秒则重新计时
//          lastPopTime = DateTime.now();
//          ToastUtils.showToast("再按一次退出");
//          return new Future.value(false);
//        }
//        return new Future.value(true);
//      },
//      child:scaffold,
//    );
  }

  List<BottomNavigationBarItem> getBottomNavigationBarItems() {
    // 导航按钮
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.account_balance_wallet),
        title: Text('钱包'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.bubble_chart),
        title: Text('EPIK'),
      ),
    ];
  }

  openRightDrawer() {
    if (!key_scaffold.currentState.isEndDrawerOpen) {
      key_scaffold.currentState.openEndDrawer();
    }
  }

  bool closeRightDrawer() {
    if (key_scaffold.currentState.isEndDrawerOpen) {
      Navigator.pop(context);
      return true;
    }
    return false;
  }

  @override
  void onCreate() {
    dlog("onCreate");
    DeviceUtils.setSystemBarStyle(DeviceUtils.system_bar_dark);

    eventMgr.add(EventTag.CHANGE_MAINVIEW_INDEX, eventCallback);
    eventMgr.add(EventTag.MAIN_RIGHT_DRAWER, eventCallback_rightdrawer);

    checkUpgrade();
  }

  eventCallback(obj) {
    int index = -1;
    if (obj != null && obj is int) index = obj;
    if (index >= 0 && index < subViews.length) {
      _onItemTapped(index);
    }
  }

  eventCallback_rightdrawer(obj) {
    if (obj == true) {
      openRightDrawer();
    } else {
      closeRightDrawer();
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
  }

  void _onItemTapped(int index) {
    setState(() {
      lastIndex = currentIndex;
      currentIndex = index;

      for (int i = 0; i < keyList.length; i++) {
        GlobalKey<BaseInnerWidgetState> key = keyList[i];
        if (index == i) {
          key.currentState.onResume();
        } else {
          key.currentState.onPause();
        }
      }
    });
  }

  @override
  void dispose() {
    eventMgr.remove(EventTag.CHANGE_MAINVIEW_INDEX, eventCallback);
    eventMgr.remove(EventTag.MAIN_RIGHT_DRAWER, eventCallback_rightdrawer);

    super.dispose();
  }

  checkUpgrade() async {
// 检测升级
//    try {
//      HttpJsonRes httpjsonres = await ApiUpgrade.getUpgrade();
//      if (httpjsonres == null ||
//          httpjsonres.code != 0 ||
//          httpjsonres.jsonMap == null) return;
//
//      Map json = Platform.isAndroid
//          ? httpjsonres.jsonMap["android"]
//          : httpjsonres.jsonMap["ios"];
//      Upgrade upgrade = Upgrade.fromJson(json);
//      await upgrade.checkVersion();
//
//      if (upgrade.needUpgrade) {
//        showUpgradeDialog(upgrade);
//      }
//    } catch (e) {
//      print(e);
//    }
  }

//  showUpgradeDialog(Upgrade upgrade) {
//    showMsgDialog(MsgDialogModel(
//        title: "版本升级提示",
//        message: upgrade.description,
//        negativeText: upgrade.needRequired ? null : "取消",
//        positiveText: "升级",
//        needCloseBtn: !upgrade.needRequired,
//        // 强制升级没有关闭
//        onCloseEvent: () {
//          if (!upgrade.needRequired) {
//            showMsgDialog(null);
//          }
//        },
//        onPositivePressEvent: () {
//          if (!upgrade.needRequired) {
//            showMsgDialog(null);
//          }
//          if (Platform.isAndroid) {
//            // 外部下载
//            canLaunch(upgrade.upgrade_url).then((value) {
//              if (value) {
//                launch(upgrade.upgrade_url).then((value) {
//                  print(
//                      "upgrade launch = $value  url = ${upgrade.upgrade_url}");
//                });
//              }
//            });
//          } else if (Platform.isIOS) {
//            // todo  去苹果商店
//            String url = "http://itunes.apple.com/cn/lookup?id=项目包名";
//            canLaunch(url).then((value) {
//              if (value) {
//                launch(url);
//              }
//            });
//          }
//        }));
//  }
}
