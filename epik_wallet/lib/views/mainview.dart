import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/Upgrade.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/screen/screen_util.dart';
import 'package:epikwallet/utils/sp_utils/sp_utils.dart';
import 'package:epikwallet/utils/toast/toast.dart';
import 'package:epikwallet/views/AiBotStoreView.dart';
import 'package:epikwallet/views/ExpertView.dart';
import 'package:epikwallet/views/MinerView2.dart';
import 'package:epikwallet/views/miner/Minermenu.dart';
import 'package:epikwallet/views/walletmenu.dart';
import 'package:epikwallet/views/walletview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MainView extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> getState() {
    return _MainViewState();
  }

}

enum MainSubViewType {
  // MININGVIEW,
  WALLETVIEW,
  // TRANSACTIONVIEW,
  // BOUNTYVIEW,
  THINKTANKVIEW,
  MINNER,
  AIBOTSTORE,
}

List<MainSubViewType> main_subviewTypes = [];

class _MainViewState extends BaseWidgetState<MainView> {
  int currentIndex = 0;
  int lastIndex = -1;

  final GlobalKey<ScaffoldState> key_scaffold = GlobalKey();
  List<GlobalKey<BaseInnerWidgetState>> keyList;

  // 子页面
  // List<BaseInnerWidget> subViews;
  List<Widget> subViews;

  @override
  void initState() {
    isTopBarShow = false; //状态栏是否显示
    isAppBarShow = false; //导航栏是否显示
    viewSystemUiOverlayStyle = DeviceUtils.system_bar_main;

    resizeToAvoidBottomPadding = true;

    navigationColor = ResColor.b_2;
    super.initState();

    Future.delayed(Duration(milliseconds: 200)).then((value) {
      // 恢复顶部状态栏和底部按钮栏
      // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top, SystemUiOverlay.bottom]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    });

    main_subviewTypes = [
      // MainSubViewType.MININGVIEW,
      MainSubViewType.WALLETVIEW,
      MainSubViewType.MINNER,
      // MainSubViewType.TRANSACTIONVIEW,
      MainSubViewType.THINKTANKVIEW,
      // MainSubViewType.BOUNTYVIEW,
      if (SpUtils.getBool("main_bot", defValue: true)) MainSubViewType.AIBOTSTORE,
    ];

    currentIndex = main_subviewTypes.indexOf(MainSubViewType.WALLETVIEW);

    keyList = <GlobalKey<BaseInnerWidgetState>>[];

    subViews = <Widget>[]; //<BaseInnerWidget>[];

    main_subviewTypes.forEach((subtype) {
      final GlobalKey<BaseInnerWidgetState> key = GlobalKey();

      switch (subtype) {
        // case MainSubViewType.MININGVIEW:
        //   subViews.add(MiningView(key));
        //   return;
        case MainSubViewType.WALLETVIEW:
          subViews.add(WalletView(key));
          keyList.add(key);
          return;
        // case MainSubViewType.TRANSACTIONVIEW:
        //   subViews.add(TransactionView(key));
        //   return;
        // case MainSubViewType.BOUNTYVIEW:
        //   subViews.add(BountyView(key));
        //   return;
        case MainSubViewType.THINKTANKVIEW:
          subViews.add(ExpertView(key));
          keyList.add(key);
          return;
        case MainSubViewType.MINNER:
          subViews.add(MinerView2(key));
          keyList.add(key);
          return;
        case MainSubViewType.AIBOTSTORE:
          subViews.add(AiBotStoreView(key));
          keyList.add(key);
          return;
      }
    });
  }

  //上次点击时间
  DateTime lastPopTime;

  @override
  Widget buildWidget(BuildContext context) {
    WHScreenUtil.initUtil(context);

    Scaffold scaffold = Scaffold(
      key: key_scaffold,
      resizeToAvoidBottomInset: resizeToAvoidBottomPadding,
      backgroundColor: Colors.transparent,
      // body: Column(
      //   children: [
      //     Expanded(
      //       child: IndexedStack(
      //         index: currentIndex,
      //         children: subViews,
      //       ),
      //     ),
      //     getDarkBottomNavigationBar(),
      //   ],
      // ),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            bottom: 40,
            child: IndexedStack(
              index: currentIndex,
              children: subViews,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: getDarkBottomNavigationBar(),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: rightDrawerType == 0 ? WalletMenu() : MinerMenu(),
      ),
      endDrawerEnableOpenDragGesture: false,
    );
//    return scaffold;

    return WillPopScope(
      onWillPop: () async {
        if (closeRightDrawer()) return new Future.value(false);

        if (lastPopTime == null || DateTime.now().difference(lastPopTime) > Duration(seconds: 1)) {
          //两次点击间隔超过1秒则重新计时
          lastPopTime = DateTime.now();
//          ToastUtils.showToast("再按一次退出");
          ToastUtils.showToast(ResString.get(context, RSID.doubleclickquit));
          return new Future.value(false);
        }
        return new Future.value(true);
      },
      child: scaffold,
    );
  }

  List<BottomNavigationBarItem> getBottomNavigationBarItems() {
    // 导航按钮

    List<BottomNavigationBarItem> ret = [];

    main_subviewTypes.forEach((subtype) {
      switch (subtype) {
        // case MainSubViewType.MININGVIEW:
        //   ret.add(BottomNavigationBarItem(
        //     icon: Icon(Icons.bubble_chart),
        //     label: ResString.get(context, RSID.mainview_1), //'挖矿',
        //   ));
        //   break;
        case MainSubViewType.WALLETVIEW:
          ret.add(BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: ResString.get(context, RSID.mainview_2), //'钱包',
          ));
          break;
        // case MainSubViewType.TRANSACTIONVIEW:
        //   ret.add(BottomNavigationBarItem(
        //     icon: Icon(OMIcons.swapHorizontalCircle),
        //     label: ResString.get(context, RSID.mainview_3), //'交易',
        //   ));
        //   break;
        // case MainSubViewType.BOUNTYVIEW:
        //   ret.add(BottomNavigationBarItem(
        //     icon: Icon(OMIcons.assignmentTurnedIn),
        //     label: ResString.get(context, RSID.mainview_4), //'赏金', 活动
        //   ));
        //   break;
        case MainSubViewType.THINKTANKVIEW:
          ret.add(BottomNavigationBarItem(
            icon: Icon(Icons.school), //insights awesome psychology
            label: ResString.get(context, RSID.mainview_5), //'智库', 专家
          ));
          break;
        case MainSubViewType.MINNER:
          ret.add(BottomNavigationBarItem(
            icon: Icon(Icons.bubble_chart),
            label: ResString.get(context, RSID.mainview_6), //'矿工',
          ));
          break;
        case MainSubViewType.AIBOTSTORE:
          ret.add(BottomNavigationBarItem(
            icon: Icon(Icons.bubble_chart), // TODO
            label: ResString.get(context, RSID.mainview_7), //'矿工',
          ));
          break;
      }
    });

    return ret;
  }

  Widget getDarkBottomNavigationBar() {
    // if (AccountMgr().currentAccount == null)
    //   return Container();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ResColor.b_2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [ResColor.shadow_main_bar],
      ),
      child: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: getDarkBottomNavigationBarItems(),
          ),
        ),
      ),
    );
  }

  List<Widget> getDarkBottomNavigationBarItems() {
    // 导航按钮

    Widget buildItem({MainSubViewType type, String img_n, String img_s, String label}) {
      int index = main_subviewTypes.indexOf(type);
      bool seleted = currentIndex == index;
      return InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          //todo
          _onItemTapped(index);
        },
        child: Stack(
          children: [
            if (seleted)
              Align(
                alignment: FractionalOffset(0.5, 0),
                child: Container(
                  margin: EdgeInsets.only(top: 2),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff333333),
                        Color(0x00333333),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            Align(
              alignment: FractionalOffset(0.5, 0),
              child: Container(
                width: 30,
                height: 30,
                margin: EdgeInsets.only(top: 7),
                child: Image.asset(
                  seleted ? img_s : img_n,
                  width: 30,
                  height: 30,
                ),
              ),
            ),
            Align(
              alignment: FractionalOffset(0.5, 0),
              child: Container(
                margin: EdgeInsets.only(top: 42),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: seleted
                      ? const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )
                      : const TextStyle(
                          fontSize: 11,
                          color: Color(0xff999999),
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    ;

    List<Widget> ret = [];

    main_subviewTypes.forEach((subtype) {
      String img_n;
      String img_s;
      String label;
      switch (subtype) {
        // case MainSubViewType.MININGVIEW:
        //   ret.add(BottomNavigationBarItem(
        //     icon: Icon(Icons.bubble_chart),
        //     label: ResString.get(context, RSID.mainview_1), //'挖矿',
        //   ));
        //   break;
        case MainSubViewType.WALLETVIEW:
          img_n = "assets/img/ic_main_menu_wallet_n.png";
          img_s = "assets/img/ic_main_menu_wallet_s.png";
          label = ResString.get(context, RSID.mainview_2); //'钱包',
          break;
        // case MainSubViewType.TRANSACTIONVIEW:
        //   ret.add(BottomNavigationBarItem(
        //     icon: Icon(OMIcons.swapHorizontalCircle),
        //     label: ResString.get(context, RSID.mainview_3), //'交易',
        //   ));
        //   break;
        // case MainSubViewType.BOUNTYVIEW:
        //   img_n = "assets/img/ic_main_menu_bounty_n.png";
        //   img_s = "assets/img/ic_main_menu_bounty_s.png";
        //   label = ResString.get(context, RSID.mainview_4); //'赏金', 活动
        //   break;
        case MainSubViewType.THINKTANKVIEW:
          img_n = "assets/img/ic_main_menu_expert_n.png";
          img_s = "assets/img/ic_main_menu_expert_s.png";
          label = ResString.get(context, RSID.mainview_5); //'智库', 专家
          break;
        case MainSubViewType.MINNER:
          // img_n="assets/img/ic_main_menu_minner_n.png";
          // img_s="assets/img/ic_main_menu_minner_s.png";
          img_n = "assets/img/ic_main_menu_swap_n.png";
          img_s = "assets/img/ic_main_menu_swap_s.png";
          label = ResString.get(context, RSID.mainview_6); //'矿工',
          break;
        case MainSubViewType.AIBOTSTORE:
          img_n = "assets/img/ic_main_menu_aibots_n.png";
          img_s = "assets/img/ic_main_menu_aibots_s.png";
          label = ResString.get(context, RSID.mainview_7); //AI Bots
          break;
      }
      ret.add(Expanded(
          child: buildItem(
        type: subtype,
        img_n: img_n,
        img_s: img_s,
        label: label,
      )));
    });

    return ret;
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
    super.onCreate();
    dlog("onCreate");
    eventMgr.add(EventTag.CHANGE_MAINVIEW_INDEX, eventCallback);
    eventMgr.add(EventTag.MAIN_RIGHT_DRAWER, eventCallback_rightdrawer);
    eventMgr.add(EventTag.MAIN_RIGHT_DRAWER_MINER, eventCallback_rightdrawer_miner);

    checkUpgrade();
  }

  eventCallback(obj) {
    int index = -1;
    if (obj != null && obj is int) index = obj;
    if (index >= 0 && index < subViews.length) {
      _onItemTapped(index);
    }
  }

  /// 0 钱包菜单  1 矿机菜单
  int rightDrawerType = 0;

  eventCallback_rightdrawer(obj) {
    if (obj == true) {
      rightDrawerType = 0;
      setState(() {
        openRightDrawer();
      });
    } else {
      closeRightDrawer();
    }
  }

  eventCallback_rightdrawer_miner(obj) {
    if (obj == true) {
      rightDrawerType = 1;
      setState(() {
        openRightDrawer();
      });
    } else {
      closeRightDrawer();
    }
  }

  @override
  void onPause() {
    super.onPause();
  }

  @override
  void onResume() {
    super.onResume();
    dlog("onResume");
  }

  ///app切回到后台
  void onBackground() {
    super.onBackground();
    if (keyList != null)
      for (int i = 0; i < keyList.length; i++) {
        GlobalKey<BaseInnerWidgetState> key = keyList[i];
        key.currentState.onBackground();
      }
  }

  ///app切回到前台
  void onForeground() {
    super.onForeground();
    if (keyList != null)
      for (int i = 0; i < keyList.length; i++) {
        GlobalKey<BaseInnerWidgetState> key = keyList[i];
        key.currentState.onForeground();
      }
  }

  void _onItemTapped(int index) {
    // if (index == 2) {
    //   if (AccountMgr().currentAccount == null) {
    //     index = 1;
    //   }
    // }

    if (AccountMgr().currentAccount == null) {
      int page_wallet = main_subviewTypes.indexOf(MainSubViewType.WALLETVIEW);
      if (index != page_wallet) {
        index = page_wallet;
      }
    }

    closeInput();

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
    eventMgr.remove(EventTag.MAIN_RIGHT_DRAWER_MINER, eventCallback_rightdrawer_miner);

    super.dispose();
  }

  checkUpgrade() async {
    // 检测升级
    try {
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
      if (ServiceInfo.upgrade != null) {
        log("checkUpgrade");
        Upgrade upgrade = ServiceInfo.upgrade;
        await upgrade.checkVersion();
        if (upgrade.needUpgrade) {
          showUpgradeDialog(upgrade);
        }
      } else {
        log("checkUpgrade ServiceInfo.upgrade = null");
      }
    } catch (e) {
      print(e);
    }
  }

  showUpgradeDialog(Upgrade upgrade) {
    MessageDialog.showMsgDialog(
      context,
      title: ResString.get(context, RSID.upgrade_tip),
      //"版本升级提示",
      msg: upgrade.description,
      msgAlign: TextAlign.center,
      btnLeft: upgrade.needRequired ? null : ResString.get(context, RSID.upgrade_cancel),
      // "取消",
      btnRight: ResString.get(context, RSID.upgrade_confirm),
      //"升级",
      touchOutClose: !upgrade.needRequired,
      backClose: !upgrade.needRequired,
      onClickBtnLeft: (dialog) {
        dialog.dismiss();
      },
      onClickBtnRight: (dialog) {
        if (!upgrade.needRequired) {
          dialog.dismiss();
        }
        if (Platform.isAndroid) {
          // 外部下载
          canLaunchUrlString(upgrade.upgrade_url).then((value) {
            if (value) {
              launchUrlString(upgrade.upgrade_url).then((value) {
                print("upgrade launch = $value  url = ${upgrade.upgrade_url}");
              });
            }
          });
        } else if (Platform.isIOS) {
          canLaunchUrlString(upgrade.upgrade_url).then((value) {
            if (value) {
              launchUrlString(upgrade.upgrade_url).then((value) {
                print("upgrade launch = $value  url = ${upgrade.upgrade_url}");
              });
            }
          });
          // todo  去苹果商店
//        String url = "http://itunes.apple.com/cn/lookup?id=项目包名";
//        canLaunch(url).then((value) {
//          if (value) {
//            launch(url);
//          }
//        });
        }
      },
    );
  }
}
