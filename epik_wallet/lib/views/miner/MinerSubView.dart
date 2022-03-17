import 'dart:convert';

import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/model/MinerInfo.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/miner/MinerPledgeAddView.dart';
import 'package:epikwallet/views/miner/MinerPledgeWithdrawView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

enum MinerSubpageType {
  pledge, //抵押
  withdraw, //撤回,
}

extension MinerSubpageTypeEx on MinerSubpageType {
  String getName() {
    switch (this) {
      case MinerSubpageType.pledge:
        return RSID.minerview_1
            .text; //"抵押"; //ResString.get(appContext, RSID.bts_5); //"全部";
      case MinerSubpageType.withdraw:
        return RSID.minerview_2
            .text; //"赎回"; //ResString.get(appContext, RSID.bts_6); //"社群";
      default:
        return "";
    }
  }
}

class MinerSubView extends BaseInnerWidget {
  String minerid;
  double topPadding=0;
  MinerSubView(this.minerid,this.topPadding);

  @override
  BaseInnerWidgetState<BaseInnerWidget> getState() {
    return MinerSubViewState();
  }

  @override
  int setIndex() {
    return 0;
  }
}

class MinerSubViewState extends BaseInnerWidgetState<MinerSubView>
    with TickerProviderStateMixin {
  // MinerStateType _MinerStateType;
  String minerid;

  MinerInfo minerInfo;

  // int pageIndex = 0;
  MinerSubpageType _MinerSubpageType = MinerSubpageType.pledge;
  TabController tabcontroller;

  bool isFirst = true;

  bool isLoading = false;

  @override
  void initStateConfig() {
    // navigationColor = ResColor.b_2;
    super.initStateConfig();
    minerid = widget.minerid;
    setTopBarVisible(false);
    setAppBarVisible(false);
    bodyBackgroundColor = Colors.transparent;
    // setAppBarBackColor(Colors.transparent);
    // setTopBarBackColor(Colors.transparent);

    // resizeToAvoidBottomPadding = true;

    // eventMgr.add(EventTag.BALANCE_UPDATE, eventmgr_callback);
    // eventMgr.add(
    //     EventTag.MINER_CURRENT_CHENGED, eventmgr_callback_chengedCurrentId);
    // eventMgr.add(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventCallback_account);

    refresh();
  }

  refresh() async {
    if (isFirst) {
      isFirst = false;
    }

    // await AccountMgr().currentAccount.getMinerListOnline();
    // AccountMgr().currentAccount.loadMinerIdList();

    if (StringUtils.isEmpty(widget.minerid)) {
      // _MinerStateType = MinerStateType.needminerid;
      closeStateLayout();
      isLoading = false;
      return;
    }

    isLoading = true;
    proressBackgroundColor = Colors.transparent;
    setLoadingWidgetVisible(true);

    EpikWalletUtils.requestBalance(AccountMgr().currentAccount); //刷钱包余额

    minerid = widget.minerid;

    MinerInfo mi;
    ResultObj<String> robj = await AccountMgr()
        .currentAccount
        .epikWallet
        .minerInfo(minerid); //请求minerinfo
    if (robj?.isSuccess) {
      // print("minerinfo" + robj.data);
      mi = MinerInfo.fromJson(jsonDecode(robj.data));
      mi?.minerid = minerid;
    } else {
      // showToast(robj.errorMsg);
    }

    if (mi != null) {
      minerInfo = mi;
      // _MinerStateType = MinerStateType.subpage;
      closeStateLayout();
    } else {
      // _MinerStateType = null;
      errorBackgroundColor = Colors.transparent;
      statelayout_margin =
          EdgeInsets.only(top: BaseFuntion.appbarheight_def + BaseFuntion.topbarheight);
      loaderror=robj.errorMsg;
      setErrorWidgetVisible(true);
    }
    isLoading = false;
  }

  String loaderror = null;

  ///暴露的错误页面方法，可以自己重写定制
  Widget getErrorWidget() {
    return Container(
      //错误页面中心可以自己调整
      margin: statelayout_margin,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      color: errorBackgroundColor,//Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: InkWell(
        onTap: () {
          onClickErrorWidget();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              padding: EdgeInsets.fromLTRB(30, 50, 30, 50),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black87,
              ),
              child: Text(StringUtils.isNotEmpty(loaderror)?loaderror:RSID.request_failed_retry_click.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: ResColor.white,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onClickErrorWidget() {
    // print("onClickErrorWidget");
    refresh();
  }

  Future<void> _pullRefreshCallback() async {
    if (isLoading) {
      return;
    }
    isLoading = true;
    // proressBackgroundColor = Colors.transparent;
    // setLoadingWidgetVisible(true);

    AccountMgr().currentAccount.getCoinbaseInfo();

    EpikWalletUtils.requestBalance(AccountMgr().currentAccount); //请求钱包余额

    minerid = widget.minerid;

    MinerInfo mi;
    ResultObj<String> robj = await AccountMgr()
        .currentAccount
        .epikWallet
        .minerInfo(minerid); //请求minerinfo
    if (robj?.isSuccess) {
      dlog("minerinfo" + robj.data);
      mi = MinerInfo.fromJson(jsonDecode(robj.data));
      mi?.minerid = minerid;
    }

    if (mi != null) {
      minerInfo = mi;
      // _MinerStateType = MinerStateType.subpage;
      closeStateLayout();
    } else {
      // _MinerStateType = null;
      errorBackgroundColor = Colors.transparent;
      setErrorWidgetVisible(true);
    }
    isLoading = false;
  }

  @override
  Widget buildWidget(BuildContext context) {
    // if (minerInfo == null) {
    //   return Container();
    // }

    List<Widget> items = [
      Container(height: widget.topPadding),
      // getMinerCard1(),
      getMinerCard2(),
      getPledgeCard(),
    ];
    Widget sv = SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          minHeight: getScreenHeight() - getTopBarHeight() - getAppBarHeight(),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items,
        ),
      ),
    );
    return RefreshIndicator(
      displacement: 40,
      color: ResColor.progress,
      onRefresh: _pullRefreshCallback,
      child: sv,
//      key: key_refresh,
    );
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

  Widget getMinerCard2() {
    List<Widget> items = [
      getRowText("NodeID", minerid),
      getRowText("Owner", minerInfo?.owner ?? "--"),
      getRowText(
          RSID.minerview_6.text, //"当前算例",
          minerInfo==null ? "--":"${minerInfo.mining_power_s} / ${minerInfo.total_power_s} (${minerInfo.power_percent})"),
      getRowText(
          RSID.minerview_10.text, //"矿工基础抵押",
          minerInfo==null ? "--": "${StringUtils.formatNumAmount(minerInfo.mining_pledged, point: 8, supply0: false)} EPK"),
      getRowText(
          RSID.minerview_11.text, //"我的基础抵押",
          minerInfo==null ? "--": "${StringUtils.formatNumAmount(minerInfo.my_mining_pledge, point: 8, supply0: false)} EPK"),
      getRowText(
          RSID.minerview_12.text, //"流量抵押余额",
          minerInfo==null ? "--":"${StringUtils.formatNumAmount(minerInfo.retrieve_balance, point: 8, supply0: false)} EPK"),
      getRowText(
          RSID.minerview_28.text, //"我的流量抵押",
          minerInfo==null ? "--": "${StringUtils.formatNumAmount(minerInfo.my_retrieve_pledge_d, point: 8, supply0: false)} EPK"),
      getRowText(
          RSID.minerview_13.text, //"流量抵押锁定",
          minerInfo==null ? "--": "${StringUtils.formatNumAmount(minerInfo.retrieve_locked, point: 8, supply0: false)} EPK"),

      Container(height: 20),
      LinearPercentIndicator(
        // width: double.infinity,
        lineHeight: 5,
        animation: true,
        animationDuration: 200,
        animateFromLastPercent: true,
        // restartAnimation: true,
        percent: minerInfo?.getRetrievePercent() ?? 0,
        center: Text(""),
        padding: EdgeInsets.only(left: 2.5, right: 2.5),
        backgroundColor: ResColor.white_20,
        linearStrokeCap: LinearStrokeCap.roundAll,
        // progressColor: const Color(0xff57B836),
        linearGradient: ResColor.lg_1,
      ),
      Container(height: 10),
      getRowText(
          RSID.minerview_14.text,
          /*"当日访问流量",*/
          minerInfo==null ? "--": "${minerInfo.getRetrieveNumerator()} / ${minerInfo.getRetrieveDenominator()}"),
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
          initialIndex: MinerSubpageType.values.indexOf(_MinerSubpageType),
          length: items.length,
          vsync: this);
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

  Widget getSubpage() {
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
    switch (_MinerSubpageType) {
      case MinerSubpageType.pledge:
        return MinerPledgeAddView(minerInfo);
      case MinerSubpageType.withdraw:
        return MinerPledgeWithdrawView(minerInfo);
    }
    return Container();
  }
}
