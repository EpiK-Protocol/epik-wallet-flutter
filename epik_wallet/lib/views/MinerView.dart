import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/model/MinerInfo.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/mainview.dart';
import 'package:epikwallet/views/miner/MinerPledgeAddView.dart';
import 'package:epikwallet/views/miner/MinerPledgeWithdrawView.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/jsonform/base/jf_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

enum MinerStateType { needwallet, needminerid, subpage }

enum MinerSubpageType {
  pledge, //抵押
  withdraw, //撤回,
}

extension MinerSubpageTypeEx on MinerSubpageType {
  String getName() {
    switch (this) {
      case MinerSubpageType.pledge:
        return "抵押"; //ResString.get(appContext, RSID.bts_5); //"全部";
      case MinerSubpageType.withdraw:
        return "赎回"; //ResString.get(appContext, RSID.bts_6); //"社群";
      default:
        return "";
    }
  }
}

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

class MinnerViewState extends BaseInnerWidgetState<MinerView> with TickerProviderStateMixin{
  MinerStateType _MinerStateType;
  String minerid;

  String minerid_input;

  MinerInfo minerInfo;

  // int pageIndex = 0;
  MinerSubpageType _MinerSubpageType = MinerSubpageType.pledge;
  TabController tabcontroller;

  @override
  void initStateConfig() {
    navigationColor = ResColor.b_2;
    super.initStateConfig();
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);

    eventMgr.add(EventTag.BALANCE_UPDATE, eventmgr_callback);
    eventMgr.add(EventTag.MINER_CURRENT_CHENGED, eventmgr_callback_chengedCurrentId);
    eventMgr.add(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventCallback_account);

    refresh();
  }

  eventmgr_callback(arg){
    setState(() {
    });
  }


  eventmgr_callback_chengedCurrentId(arg){
    if(arg==true)
    {
      Future.delayed(Duration(milliseconds: 50)).then((value){
        refresh();
      });
    }
  }

  eventCallback_account(obj) {
    refresh();
  }

  Widget getLoadingWidget()
  {
    return GestureDetector(
      onTap: (){},
      child: super.getLoadingWidget(),
    );
  }

  @override
  void dispose() {
    eventMgr.remove(EventTag.BALANCE_UPDATE, eventmgr_callback);
    eventMgr.remove(EventTag.MINER_CURRENT_CHENGED, eventmgr_callback_chengedCurrentId);
    eventMgr.remove(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventCallback_account);
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

    AccountMgr().currentAccount.loadMinerIdList();
    minerid = AccountMgr().currentAccount.minerCurrent;
    if (StringUtils.isEmpty(minerid)) {
      _MinerStateType = MinerStateType.needminerid;
      closeStateLayout();
      isLoading = false;
      return;
    }

    isLoading = true;
    proressBackgroundColor = Colors.transparent;
    setLoadingWidgetVisible(true);

    MinerInfo mi;
    ResultObj<String> robj =
        await AccountMgr().currentAccount.epikWallet.minerInfo(minerid);
    if (robj?.isSuccess) {
      print("minerinfo" + robj.data);
      mi = MinerInfo.fromJson(jsonDecode(robj.data));
      mi?.minerid=minerid;
    }

    if (mi != null) {
      minerInfo = mi;
      _MinerStateType = MinerStateType.subpage;
      closeStateLayout();
    } else {
      _MinerStateType = null;
      errorBackgroundColor = Colors.transparent;
      setErrorWidgetVisible(true);
    }
    isLoading = false;
  }


  Future<void> _pullRefreshCallback() async {
    if (isLoading) {
      return;
    }
    isLoading = true;
    // proressBackgroundColor = Colors.transparent;
    // setLoadingWidgetVisible(true);

    EpikWalletUtils.requestBalance(AccountMgr().currentAccount);

    MinerInfo mi;
    ResultObj<String> robj =
    await AccountMgr().currentAccount.epikWallet.minerInfo(minerid);
    if (robj?.isSuccess) {
      print("minerinfo" + robj.data);
      mi = MinerInfo.fromJson(jsonDecode(robj.data));
      mi?.minerid=minerid;
    }

    if (mi != null) {
      minerInfo = mi;
      _MinerStateType = MinerStateType.subpage;
      closeStateLayout();
    } else {
      _MinerStateType = null;
      errorBackgroundColor = Colors.transparent;
      setErrorWidgetVisible(true);
    }
    isLoading=false;
  }

  @override
  Widget buildWidget(BuildContext context) {
    Widget widget;
    // _MinerStateType = MinerStateType.needminerid; //todo test
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
            margin: EdgeInsets.fromLTRB(30, 30, 30, 40),
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
                  label: "请输入MinerID",
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
                  text: "添加",
                  textstyle: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  bg_borderradius: BorderRadius.circular(4),
                  onclick: (lbtn) {
                    if (StringUtils.isEmpty(minerid_input)) {
                      showToast("请输入MinerID");
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
      List<Widget> items = [
        Container(height: 45),
        getMinerCard1(),
        getMinerCard2(),
        getPledgeCard(),
      ];
      Widget sv = SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight:
                getScreenHeight() - getTopBarHeight() - getAppBarHeight(),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items,
          ),
        ),
      );
      widget =  RefreshIndicator(
        displacement: 40,
        color: ResColor.progress,
        onRefresh: _pullRefreshCallback,
        child: sv,
//      key: key_refresh,
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
          Positioned(
            left: 0,
            right: 0,
            top: getAppBarHeight() + getTopBarHeight(),
            bottom: 0,
            child: widget,
          ),
          // if (isLoading == true)
          //   Align(
          //     alignment: FractionalOffset(0.5, 0.5),
          //     child: CircularProgressIndicator(
          //       strokeWidth: 2.0,
          //       valueColor:
          //           new AlwaysStoppedAnimation<Color>(ResColor.progress),
          //     ),
          //   ),
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
              "存储矿工",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          //  minerid 控制是否显示
          if (StringUtils.isNotEmpty(minerid))
            InkWell(
              onTap: () {
                //  菜单
                closeInput();
                eventMgr.send(EventTag.MAIN_RIGHT_DRAWER_MINER, true);
              },
              child: Container(
                height: double.infinity,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "MinerID:" + minerid,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 2, 0, 0),
                      child: Image.asset(
                        "assets/img/ic_arrow_right_1.png",
                        width: 7,
                        height: 11,
                      ),
                    ),
                  ],
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
        color: ResColor.white_60,
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

  Widget getMinerCard1() {
    List<Widget> items = [
      getRowText("当前算例",
          "${minerInfo.mining_power_s} / ${minerInfo.total_power_s} (${minerInfo.power_percent})"),
      getRowText("CoinBase", minerInfo.coin_base ?? ""),
      getRowText("账户余额",
          "${StringUtils.formatNumAmount(minerInfo.getBalance(), point: 8, supply0: false)}"),
      getRowText("锁定余额",
          "${StringUtils.formatNumAmount(minerInfo.vesting, point: 8, supply0: false)}"),
      getRowText("可提余额",
          "${StringUtils.formatNumAmount(minerInfo.available_balance, point: 8, supply0: false)}"),
    ];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(30, 0, 30, 10),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ResColor.b_2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ),
    );
  }

  Widget getMinerCard2() {
    List<Widget> items = [
      getRowText("矿工基础抵押",
          "${StringUtils.formatNumAmount(minerInfo.mining_pledged, point: 8, supply0: false)}"),
      getRowText("我的基础抵押",
          "${StringUtils.formatNumAmount(minerInfo.my_mining_pledge, point: 8, supply0: false)}"),
      getRowText("流量抵押余额",
          "${StringUtils.formatNumAmount(minerInfo.retrieve_balance, point: 8, supply0: false)}"),
      getRowText("流量抵押锁定",
          "${StringUtils.formatNumAmount(minerInfo.retrieve_locked, point: 8, supply0: false)}"),
      Container(height: 20),
      LinearPercentIndicator(
        // width: double.infinity,
        lineHeight: 5,
        animation: true,
        animationDuration: 200,
        animateFromLastPercent: true,
        // restartAnimation: true,
        percent: minerInfo.getRetrievePercent(),
        center: Text(""),
        padding: EdgeInsets.only(left: 2.5, right: 2.5),
        backgroundColor: ResColor.white_20,
        linearStrokeCap: LinearStrokeCap.roundAll,
        // progressColor: const Color(0xff57B836),
        linearGradient: ResColor.lg_1,
      ),
      Container(height: 10),
      getRowText("当日访问流量", "5Gb / 10Gb"),
    ];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(30, 0, 30, 10),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ResColor.b_2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ),
    );
  }

  Widget getPledgeCard() {
    List<Widget> items = [
      Container(
        height: 52,
        child: getTabbar(),
      ),
    getSubpage(),
    ];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(30, 0, 30, 10),
      padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ResColor.b_2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ),
    );
  }

  Widget getTabbar() {
    List<MinerSubpageType> items = MinerSubpageType.values;

    if (tabcontroller == null)
      tabcontroller = TabController(
          initialIndex: MinerSubpageType.values.indexOf(_MinerSubpageType), length: items.length, vsync: this);
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.fromLTRB(10, 0, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              tabs: items.map((tyoe) {
                return Container(
                  alignment: Alignment.bottomCenter,
                  child: Text(tyoe.getName()),
                );
              }).toList(),
              controller: tabcontroller,
              isScrollable: true,
              labelPadding: EdgeInsets.fromLTRB(10, 0, 10, 10),
              labelColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
              unselectedLabelColor: ResColor.white_60,
              unselectedLabelStyle: TextStyle(
                fontSize: 14,
                color: ResColor.white_60,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: ResColor.lg_1,
              ),
              indicatorPadding: EdgeInsets.fromLTRB(8, 42, 8, 6),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 4,
              onTap: (value) {
                onClickTab(MinerSubpageType.values[value]);
              },
            ),
          ),
        ],
      ),
    );
  }

  onClickTab(MinerSubpageType type) {
    if (_MinerSubpageType == type) return;
    _MinerSubpageType = type;
    setState(() {
//      _tabController.animateTo(index);
    });
    // 切换数据类型
    // refresh();
  }

  Widget getSubpage()
  {
    // Container(
    //   height:500,
    //   child:  TabBarView(
    //     controller: tabcontroller,
    //     children: [
    //       MinerPledgeAddView(minerInfo),
    //       MinerPledgeWithdrawView(minerInfo),
    //     ],
    //   ),
    // ),
    switch(_MinerSubpageType)
    {
      case MinerSubpageType.pledge:
       return MinerPledgeAddView(minerInfo);
      case MinerSubpageType.withdraw:
      return MinerPledgeWithdrawView(minerInfo);
    }
    return Container();
  }
}
