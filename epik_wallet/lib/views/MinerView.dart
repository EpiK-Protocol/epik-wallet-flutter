import 'dart:async';
import 'dart:ui';

import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/LocaleConfig.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/CoinbaseInfo.dart';
import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/utils/toast/toast.dart';
import 'package:epikwallet/views/mainview.dart';
import 'package:epikwallet/views/miner/MinerSubView.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/jsonform/base/jf_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

enum MinerStateType { needwallet, needminerid, subpage }

///矿工
class MinerView extends BaseInnerWidget {
  MinerView(Key key) : super(key: key) {}

  @override
  BaseInnerWidgetState<BaseInnerWidget> getState() {
    return MinnerViewState();
  }

  @override
  int setIndex() {
    return 3;
  }
}

class MinnerViewState extends BaseInnerWidgetState<MinerView> {
  MinerStateType _MinerStateType;

  String minerid_input;

  List<String> mineridList = [];

  CoinbaseInfo get coinbaseInfo {
    return AccountMgr()?.currentAccount?.coinbaseinfo;
  }

  @override
  void initStateConfig() {
    navigationColor = ResColor.b_2;
    super.initStateConfig();
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);

    // resizeToAvoidBottomPadding = true;

    eventMgr.add(EventTag.BALANCE_UPDATE, eventmgr_callback);
    eventMgr.add(
        EventTag.MINER_CURRENT_CHENGED, eventmgr_callback_chengedCurrentId);
    eventMgr.add(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventCallback_account);
    eventMgr.add(EventTag.COINBASEINFO_UPDATE, eventmgr_callback);
    refresh();
  }

  eventmgr_callback(arg) {
    setState(() {});
  }

  eventmgr_callback_chengedCurrentId(arg) {
    // 在菜单里 切换了页面index
    if (arg == true) {
      dlog("eventmgr_callback_chengedCurrentId  a");
      List<String> tempList =
          AccountMgr().currentAccount.getAllMinerList() ?? [];
      if (tempList?.toString() != mineridList?.toString()) {
        dlog("eventmgr_callback_chengedCurrentId  b");
        Future.delayed(Duration(milliseconds: 50)).then((value) {
          refresh();
        });
      } else if (controller != null) {
        dlog("eventmgr_callback_chengedCurrentId  c");
        Future.delayed(Duration(milliseconds: 5)).then((value) {
          try {
            int index =
                mineridList.indexOf(AccountMgr()?.currentAccount?.minerCurrent);
            if (index >= 0) {
              controller.animateToPage(index,
                  duration: Duration(milliseconds: 300), curve: Curves.ease);
            }
          } catch (e) {
            print(e);
          }
        });
      }
    } else {
      //列表有编辑
      dlog("eventmgr_callback_chengedCurrentId  f");
      Future.delayed(Duration(milliseconds: 50)).then((value) {
        refresh();
      });
    }
  }

  eventCallback_account(obj) {
    mineridList = null;
    controller = null;
    _MinerStateType = null;
    refresh();
  }

  Widget getLoadingWidget() {
    return GestureDetector(
      onTap: () {},
      child: super.getLoadingWidget(),
    );
  }

  @override
  void dispose() {
    eventMgr.remove(EventTag.BALANCE_UPDATE, eventmgr_callback);
    eventMgr.remove(
        EventTag.MINER_CURRENT_CHENGED, eventmgr_callback_chengedCurrentId);
    eventMgr.remove(
        EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventCallback_account);
    eventMgr.remove(EventTag.COINBASEINFO_UPDATE, eventmgr_callback);
    super.dispose();
  }

  bool isFirst = true;

  bool isLoading = false;

  refresh() async {
    if (isFirst) {
      isFirst = false;
    }

    if (AccountMgr().currentAccount == null) {
      _MinerStateType = MinerStateType.needwallet;
      closeStateLayout();
      isLoading = false;
      return;
    }

    int time_start = DateUtil.getNowDateMs();

    isLoading = true;
    proressBackgroundColor = Colors.transparent;
    setLoadingWidgetVisible(true);

    dlog("getMinerListOnline");
    await AccountMgr().currentAccount.getMinerListOnline();

    dlog("loadMinerIdList");
    AccountMgr().currentAccount.loadMinerIdList();

    mineridList = AccountMgr().currentAccount.getAllMinerList() ?? [];
    dlog("mineridList =${mineridList.length}");

    dlog("getCoinbaseInfo");
    await AccountMgr().currentAccount.getCoinbaseInfo();

    int time_end = DateUtil.getNowDateMs();

    int time = time_end - time_start;
    if (time < 200) {
      dlog("delayed ${200 - time} ");
      await Future.delayed(Duration(milliseconds: 200 - time));
    }

    if (mineridList == null || mineridList?.length == 0) {
      _MinerStateType = MinerStateType.needminerid;
      closeStateLayout();
    } else if (coinbaseInfo != null) {
      _MinerStateType = MinerStateType.subpage;

      if (controller != null) {
        try {
          int index =
              mineridList.indexOf(AccountMgr()?.currentAccount?.minerCurrent);
          dlog("controller animateToPage index=$index");
          if (index != controller.page) {
            dlog("controller animateToPage index ${controller.page}");
            Future.delayed(Duration(milliseconds: 50)).then((value) {
              if (index >= 0) {
                controller.animateToPage(index,
                    duration: Duration(milliseconds: 300), curve: Curves.ease);
              }
            });
          }
        } catch (e) {
          print(e);
        }
      }

      closeStateLayout();
    } else {
      _MinerStateType = null;
      errorBackgroundColor = Colors.transparent;
      statelayout_margin =
          EdgeInsets.only(top: getAppBarHeight() + getTopBarHeight());
      if(coinbaseInfo==null)
      {
        setErrorContent("coinbase not found");
      }else{
        setErrorContent(RSID.net_error.text);
      }
      setErrorWidgetVisible(true);
    }
    isLoading = false;
  }

  @override
  Widget buildWidget(BuildContext context) {
    dlog("buildwidget ${_MinerStateType}");
    Widget widget;
    if (_MinerStateType == MinerStateType.needwallet) {
      widget = Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              RSID.main_bv_7.text, //"需要有钱包才能进行",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            Container(
              height: 10,
            ),
            FlatButton(
              highlightColor: Colors.white24,
              splashColor: Colors.white24,
              onPressed: () {
                eventMgr.send(EventTag.CHANGE_MAINVIEW_INDEX,
                    main_subviewTypes.indexOf(MainSubViewType.WALLETVIEW));
              },
              child: Text(
                RSID.main_bv_8.text, //"去创建钱包",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              color: Color(0xff393E45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(22)),
              ),
            )
          ],
        ),
      );
    } else if (_MinerStateType == MinerStateType.needminerid) {
      widget = Column(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(30, 110, 30, 40),
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: ResColor.b_2,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                JfText(
                  data: "",
                  autofocus: false,
                  maxLines: 1,
                  // hint: "请输入MinerID",
                  label: RSID.minerview_3.text,
                  //"请输入MinerID",
                  regexp: r'(\d|[a-z]|[A-Z])+',
                  onChanged: (text, classtype) {
                    minerid_input = text.toString().trim();
                  },
                ),
                LoadingButton(
                  margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                  gradient_bg: ResColor.lg_1,
                  color_bg: Colors.transparent,
                  disabledColor: Colors.transparent,
                  height: 40,
                  text: RSID.minerview_4.text,
                  //"添加",
                  textstyle: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  bg_borderradius: BorderRadius.circular(4),
                  onclick: (lbtn) {
                    if (StringUtils.isEmpty(minerid_input)) {
                      showToast(RSID.minerview_3.text); //"请输入MinerID");
                      return;
                    }
                    closeInput();
                    AccountMgr().currentAccount.minerIdList.add(minerid_input);
                    AccountMgr().currentAccount.saveMinerIdList();
                    refresh();
                  },
                ),
              ],
            ),
          ),
        ],
      );
    } else if (_MinerStateType == MinerStateType.subpage) {
      widget = Column(
        children: [
          Expanded(child: getPageView()),
        ],
      );
    }

    if (widget == null) widget = Container();

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Container(
            height: getAppBarHeight() + getTopBarHeight() + 128,
            padding: EdgeInsets.fromLTRB(0, getTopBarHeight(), 0, 128),
            decoration: BoxDecoration(
              gradient: ResColor.lg_1,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: getAppbar(),
          ),
          if (coinbaseInfo != null)
            Positioned(
              left: 0,
              right: 0,
              top: getAppBarHeight() + getTopBarHeight(),
              bottom: 0,
              child: getCoinBaseInfoView(),
            ),
          Positioned(
            left: 0,
            right: 0,
            top: getAppBarHeight() + getTopBarHeight(),
            bottom: 0,
            child: widget,
          ),
        ],
      ),
    );
  }

  Widget getAppbar() {
    return Container(
      width: double.infinity,
      height: getAppBarHeight(),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              RSID.minerview_5.text, // "存储矿工",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if ((coinbaseInfo?.vested_d ?? 0) > 0)
            InkWell(
              onTap: () {
                // 提取coinbase
                onClickWithdrawCoinbase();
              },
              child: Container(
                height: double.infinity,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      RSID.minerview_30.text, // "Coinbase提取",
                      style: TextStyle(
                        fontSize: LocaleConfig.currentIsZh() ? 14 : 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Container(
                    //   padding: EdgeInsets.fromLTRB(10, 2, 0, 0),
                    //   child: Image.asset(
                    //     "assets/img/ic_arrow_right_1.png",
                    //     width: 7,
                    //     height: 11,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          // 菜单// todo
          if (mineridList != null && mineridList.length > 0)
            InkWell(
              onTap: () {
                //  菜单
                closeInput();
                eventMgr.send(EventTag.MAIN_RIGHT_DRAWER_MINER, true);
              },
              child: Container(
                height: double.infinity,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Icon(
                    Icons.menu,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void onClickErrorWidget() {
    refresh();
  }

  void onClickEmptyWidget() {
    refresh();
  }

  Widget getRowText(String left, String right,
      {TextStyle leftstyle = const TextStyle(
        fontSize: 14,
        color: ResColor.white, // ResColor.white_60,
      ),
      TextStyle rightstyle = const TextStyle(
        fontSize: 14,
        color: ResColor.white,
      ),
      EdgeInsetsGeometry margin = const EdgeInsets.fromLTRB(0, 0, 0, 7)}) {
    return Container(
      margin: margin,
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: leftstyle,
            ),
          ),
          Text(
            right,
            style: rightstyle,
          ),
        ],
      ),
    );
  }

  Widget getCoinBaseInfoView() {
    List<Widget> items = [
      // getRowText("CoinBase", minerInfo.coin_base ?? ""),
      // getRowText(RSID.minerview_7.text,//"账户余额",
      //     "${StringUtils.formatNumAmount(minerInfo.getBalance(), point: 8, supply0: false)}"),
      // getRowText(RSID.minerview_8.text,//"锁定余额",
      //     "${StringUtils.formatNumAmount(minerInfo.vesting, point: 8, supply0: false)}"),
      // getRowText(RSID.minerview_9.text,//"可提余额",
      //     "${StringUtils.formatNumAmount(minerInfo.available_balance, point: 8, supply0: false)}"),
      getRowText("CoinBase", coinbaseInfo?.Coinbase ?? "--"),
      getRowText(
          RSID.minerview_7.text, //"账户余额",
          "${StringUtils.formatNumAmount(coinbaseInfo?.total_d ?? 0, point: 8, supply0: false)} EPK"),
      getRowText(
          RSID.minerview_8.text, //"锁定余额",
          "${StringUtils.formatNumAmount(coinbaseInfo?.vesting_d ?? 0, point: 8, supply0: false)} EPK"),
      getRowText(
          RSID.minerview_9.text, //"可提余额",
          "${StringUtils.formatNumAmount(coinbaseInfo?.vested_d ?? 0, point: 8, supply0: false)} EPK"),
    ];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
      // padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(20),
      //   color: ResColor.b_2,
      // ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ),
    );
  }

  onClickWithdrawCoinbase() {
    BottomDialog.showPassWordInputDialog(
        context, AccountMgr().currentAccount.password, (value) async {
      showLoadDialog("", touchOutClose: false, backClose: false);

      ResultObj<String> robj =
          await AccountMgr().currentAccount.epikWallet.coinbaseWithdraw();

      closeLoadDialog();

      if (robj?.isSuccess) {
        String cid = robj
            .data; //bafy2bzaceaa4fwwhrn5oqjsxe5vumlibispulwdzf4uskh4silxlfo4qh6cu6

        MessageDialog.showMsgDialog(
          context,
          title: RSID.minerview_30.text,//"Coinbase提取",
          msg: "${RSID.minerview_18.text}\n$cid",
          //交易已提交
          btnLeft: RSID.minerview_19.text,
          //"查看交易",
          btnRight: RSID.isee.text,
          onClickBtnLeft: (dialog) {
            dialog.dismiss();
            String url = ServiceInfo.epik_msg_web + cid;
            ViewGT.showGeneralWebView(context, RSID.berlv_4.text, url);
          },
          onClickBtnRight: (dialog) {
            dialog.dismiss();
          },
        );
      } else {
        ToastUtils.showToastCenter(robj?.errorMsg ?? RSID.request_failed.text);
      }
    });
  }

  PageController controller;

  // TabController tabcontroller;

  Widget getPageView() {
    int itemCount = mineridList?.length ?? 0;
    if (itemCount == 0) return Container();

    if (controller == null) {
      dlog("ee minerCurrent=${AccountMgr()?.currentAccount?.minerCurrent}");
      if (StringUtils.isEmpty(AccountMgr()?.currentAccount?.minerCurrent)) {
        AccountMgr().currentAccount.minerCurrent = mineridList[0];
        dlog("ff minerCurrent=${AccountMgr()?.currentAccount?.minerCurrent}");
      }
      String currentminerid = AccountMgr().currentAccount.minerCurrent;
      dlog("gg minerCurrent=${AccountMgr()?.currentAccount?.minerCurrent}");
      int index = mineridList.indexOf(currentminerid);
      controller = PageController(initialPage: index);
      dlog("controller index=$index  currentminerid=$currentminerid");

      // tabcontroller = TabController(initialIndex: index,length:itemCount,vsync: this);
    }

    return PageView.builder(
      itemCount: itemCount,
      controller: controller,
      onPageChanged: (value) {
        String currentminerid = mineridList[value];
        AccountMgr().currentAccount.minerCurrent = currentminerid;
        AccountMgr().currentAccount.saveMinerIdList();
        dlog("onPageChanged index=$value  currentminerid=$currentminerid");
      },
      itemBuilder: (context, index) {
        // subview构造 //todo
        return MinerSubView(mineridList[index], 110);
      },
    );
  }
}
