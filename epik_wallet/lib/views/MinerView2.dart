import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/loading_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/LocaleConfig.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_mainnet.dart';
import 'package:epikwallet/logic/api/api_pool.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/CoinbaseInfo2.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/model/nodepool/RentNodeTransferObj.dart';
import 'package:epikwallet/utils/ClickUtil.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/utils/toast/toast.dart';
import 'package:epikwallet/views/mainview.dart';
import 'package:epikwallet/views/nodepool/NodePoolListView.dart';
import 'package:epikwallet/views/nodepool/RentNodeNeedTransferView.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:epikwallet/widget/text/TextEllipsisMiddle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../model/CoinbaseInfo.dart';
import '../utils/string_utils.dart';

///矿工
class MinerView2 extends BaseInnerWidget {
  MinerView2(Key key) : super(key: key) {}

  @override
  BaseInnerWidgetState<BaseInnerWidget> getState() {
    return MinnerViewState2();
  }

  @override
  int setIndex() {
    return 3;
  }
}

class MinnerViewState2 extends BaseInnerWidgetState<MinerView2> {

  //右上角租赁节点的开关
  bool nodepool=false;


  List<String> headerdata = ["coinbase", "node", "owner"];

  CoinbaseInfo2 coinbase;

  double balance_epk = 0;
  String balance_epk_str = "0";
  double balance_usdt = 0;
  String balance_usdt_str = "0";

  List<RentNodeTransferObj> listRentNodeTransferObj = [];

  @override
  void initStateConfig() {
    navigationColor = ResColor.b_2;
    super.initStateConfig();
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);

    // resizeToAvoidBottomPadding = true;

    // eventMgr.add(EventTag.BALANCE_UPDATE, eventmgr_callback);
    // eventMgr.add(
    //     EventTag.MINER_CURRENT_CHENGED, eventmgr_callback_chengedCurrentId);
    eventMgr.add(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventCallback_account);
    // eventMgr.add(EventTag.COINBASEINFO_UPDATE, eventmgr_callback);
    eventMgr.add(EventTag.BALANCE_UPDATE, eventCallback_balance);
    refresh();
  }

  // eventmgr_callback(arg) {
  //   setState(() {});
  // }

  eventCallback_account(obj) {
    refresh();
  }

  eventCallback_balance(obj) {
    calcBalance();
    setState(() {});
  }

  calcBalance() {
    if (AccountMgr().currentAccount != null && coinbase != null) {
      balance_epk = (coinbase?.balance?.Total_d ?? 0) + (coinbase?.pledged?.Total_d ?? 0);
      // +(coinbase?.retrieve?.Total_d ?? 0);
      // print(coinbase?.balance?.Total_d);
      // print(coinbase?.pledged?.Total_d);
      // print(coinbase?.retrieve?.Total_d);
      balance_usdt =
          (AccountMgr()?.currentAccount?.getCurrencyAssetByCs(CurrencySymbol.EPK)?.price_usd ?? 0) * balance_epk;
    } else {
      balance_epk = 0;
      balance_usdt = 0;
    }
    balance_epk_str = StringUtils.formatNumAmount(balance_epk, point: 2);
    balance_usdt_str = StringUtils.formatNumAmount(balance_usdt, point: 2);
  }

  Widget getLoadingWidget() {
    return GestureDetector(
      onTap: () {},
      child: super.getLoadingWidget(),
    );
  }

  @override
  void dispose() {
    eventMgr.remove(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventCallback_account);
    eventMgr.remove(EventTag.BALANCE_UPDATE, eventCallback_balance);
    // eventMgr.remove(EventTag.COINBASEINFO_UPDATE, eventmgr_callback);
    super.dispose();
  }

  bool isFirst = true;

  bool isLoading = false;

  bool needwallet = false;
  bool needwalletfull = false;

  refresh({bool frompull}) async {
    if (isFirst) {
      isFirst = false;
    }

    if (AccountMgr().currentAccount == null) {
      needwallet = true;
      closeStateLayout();
      isLoading = false;
      return;
    }

    if (AccountMgr().currentAccount.hasEpikWallet != true) {
      needwalletfull = true;
      closeStateLayout();
      isLoading = false;
      return;
    }

    needwallet = false;
    needwalletfull = false;

    int time_start = DateUtil.getNowDateMs();

    isLoading = true;
    proressBackgroundColor = Colors.transparent;
    if (frompull != true) setLoadingWidgetVisible(true);

    CoinbaseInfo cbi;
    try {
      String address = AccountMgr().currentAccount.epik_EPK_address;
      ResultObj<String> robj_ci = await AccountMgr().currentAccount.epikWallet.coinbaseInfo(address);
      if (robj_ci.isSuccess) {
        cbi = CoinbaseInfo.fromJson(jsonDecode(robj_ci.data));
        if (StringUtils.isNotEmpty(cbi.Coinbase)) {
          dlog("coinbaseinfo=${robj_ci.data}");
        } else {
          cbi = null;
        }
      }
    } catch (e) {
      print(e);
    }

    HttpJsonRes hjr = await ApiMainNet.getCoinbase(address: AccountMgr().currentAccount.epik_EPK_address);

    CbRetrieveAlone cbra = null;
    ResultObj<String> robj_CbRetrieveAlone =
        await AccountMgr().currentAccount.epikWallet.retrievePledgeState(AccountMgr().currentAccount.epik_EPK_address);
    print(robj_CbRetrieveAlone?.data);
    if (robj_CbRetrieveAlone?.isSuccess) {
      cbra = CbRetrieveAlone.fromJson(jsonDecode(robj_CbRetrieveAlone.data));
    }

    if (hjr?.code == 0) {
      coinbase = CoinbaseInfo2.fromJson(hjr.jsonMap);
      if (cbi != null) {
        try {
          coinbase.balance.Total = cbi.Total;
          coinbase.balance.Total_d = cbi.total_d;
          coinbase.balance.Locked = cbi.Vesting;
          coinbase.balance.Locked_d = cbi.vesting_d;
          coinbase.balance.Unlocked = cbi.Vested;
          coinbase.balance.Unlocked_d = cbi.vested_d;
        } catch (e) {
          print(e);
        }
      }

      if (cbra != null) coinbase?.retrieve?.mergeCbRetrieveAlone(cbra);
    } else {
      coinbase = null;

      //如果获取不到coinbase  就单独请求一下coinbase的id
      if (hjr?.code > 0) {
        try {
          if (cbi != null) {
            try {
              if (StringUtils.isNotEmpty(cbi.Coinbase)) {
                Map<String, dynamic> j_Coinbase = {
                  "coinbase": {"ID": cbi.Coinbase},
                  "Balance": {
                    "Total": cbi?.Total ?? "0",
                    "Locked": cbi?.Vesting ?? "0",
                    "Unlocked": cbi?.Vested ?? "0",
                  },
                };
                coinbase = CoinbaseInfo2.fromJson(j_Coinbase);
              }
            } catch (e, s) {
              print(e);
            }
          }
        } catch (e, s) {
          print(e);
        }
      }
    }

    List<RentNodeTransferObj> _listRentNodeTransferObj = [];
    HttpJsonRes hjr_rent_miner_trans = await ApiPool.myTransferList();
    if (hjr_rent_miner_trans.code == 0) {
      _listRentNodeTransferObj = JsonArray.parseList(
          JsonArray.obj2List(hjr_rent_miner_trans.jsonMap["List"]), (json) => RentNodeTransferObj.fromJson(json));
    }
    listRentNodeTransferObj = _listRentNodeTransferObj;

    calcBalance();

    int time_end = DateUtil.getNowDateMs();

    int time = time_end - time_start;
    if (time < 200) {
      dlog("delayed ${200 - time} ");
      await Future.delayed(Duration(milliseconds: 200 - time));
    }

    if (coinbase != null) {
      closeStateLayout();
    } else {
      errorBackgroundColor = Colors.transparent;
      statelayout_margin = EdgeInsets.only(top: getAppBarHeight() + getTopBarHeight());
      if (hjr?.code >= 0) {
        setErrorContent("coinbase not found");
      } else {
        setErrorContent(RSID.net_error.text);
      }
      setErrorWidgetVisible(true);
    }
    isLoading = false;
  }

  @override
  Widget buildWidget(BuildContext context) {
    Widget widget;
    if (needwallet) {
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
                eventMgr.send(EventTag.CHANGE_MAINVIEW_INDEX, main_subviewTypes.indexOf(MainSubViewType.WALLETVIEW));
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
    } else if (needwalletfull) {
      widget = Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              RSID.iwv_29.text, //"需要Epik钱包",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20,
              ),
            ),
          ],
        ),
      );
    } else if (coinbase == null) {
      // 无coinbase
    } else {
      widget = ListPage(
        [],
        headerList: headerdata,
        headerCreator: (context, position) {
          String ddd = headerdata[position];
          switch (ddd) {
            case "coinbase":
              return getHeaderCoinbase();
            case "node":
              return getHeaderNode();
            case "owner":
              return getHeaderOwner();
          }
          return Container();
        },
        itemWidgetCreator: (context, position) {
          return Container();
        },
        pullRefreshCallback: _pullRefreshCallback,
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
          if (nodepool && AccountMgr()?.currentAccount?.hasEpikWallet == true)
            InkWell(
              onTap: () {
                ViewGT.showView(context, NodePoolListView());
              },
              child: Text(
                RSID.nodepool_title.text, // "节点商店",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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

  Future<void> _pullRefreshCallback() async {
    if (isLoading) {
      return;
    }
    await refresh(frompull: true);
    return;
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

  Widget getHeaderCoinbase() {
    List<Widget> items = [];

    //  coinbase    ID:xxx   复制
    items.add(Row(
      children: [
        Expanded(
          child: Text(
            "CoinBase",
            style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          "ID: ",
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
        Text(
          coinbase?.ID ?? "--",
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
        LoadingButton(
          height: 20,
          width: 40,
          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
          padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
          // gradient_bg: ResColor.lg_1,
          color_bg: Colors.transparent,
          disabledColor: Colors.transparent,
          side: BorderSide(width: 1, color: ResColor.o_1),
          bg_borderradius: BorderRadius.circular(4),
          text: RSID.copy.text,
          //"复制",//"Copy",
          textstyle: const TextStyle(
            color: ResColor.o_1,
            fontSize: 12,
          ),
          onclick: (lbtn) {
            if (StringUtils.isNotEmpty(coinbase?.ID)) {
              DeviceUtils.copyText(coinbase?.ID);
              showToast(RSID.copied.text);
            }
          },
        ),
      ],
    ));

    items.add(Container(height: 20));

    //总资产
    items.add(Row(
      children: [
        Text(
          RSID.main_wv_6.text + ": ", //"总资产",
          style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Text(
          "${balance_epk_str ?? "--"} EPK",
          style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            "  (≈${balance_usdt_str ?? "--"}\$)",
            style: const TextStyle(fontSize: 12, color: Colors.white60, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ));

    // 总余额      锁定中
    // xxxxEPK    xxxxEPK
    // 已解锁  xxxxEPK   提现
    items.add(
      Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: const Color(0xff424242),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: getColumnKeyValue(
                      RSID.minerview2_1.text, //总余额,
                      // "${StringUtils.formatNumAmountLocaleUnit(coinbase?.balance?.Total_d ?? 0, context, point: 4, needZhUnit: false)} EPK"),
                      "${StringUtils.formatNumAmount(coinbase?.balance?.Total_d ?? 0, point: 2, supply0: false)} EPK"),
                ),
                Expanded(
                  child: getColumnKeyValue(
                      RSID.minerview2_2.text, //"锁定中",
                      // "${StringUtils.formatNumAmountLocaleUnit(coinbase?.balance?.Locked_d ?? 0, context, point: 4, needZhUnit: false)} EPK"),
                      "${StringUtils.formatNumAmount(coinbase?.balance?.Locked_d ?? 0, point: 2, supply0: false)} EPK"),
                ),
              ],
            ),
            Container(height: 15),
            Row(
              children: [
                Text(
                  RSID.minerview2_3.text + ": ", //"可提余额"
                  style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Text(
                    "${StringUtils.formatNumAmount(coinbase?.balance?.Unlocked_d ?? 0, point: 2, supply0: false)} EPK",
                    // "${StringUtils.formatNumAmountLocaleUnit(coinbaseInfo?.vested_d ?? 0, context, point: 4, needZhUnit: false)} EPK",
                    style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                // if ((coinbase?.balance?.Unlocked_d ?? 0) > 0)
                LoadingButton(
                  height: 20,
                  width: LocaleConfig.currentIsZh() ? 40 : 60,
                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
                  color_bg: Colors.transparent,
                  disabledColor: Colors.transparent,
                  side: BorderSide(
                      width: 1, color: ((coinbase?.balance?.Unlocked_d ?? 0) > 0) ? ResColor.o_1 : ResColor.white_60),
                  bg_borderradius: BorderRadius.circular(4),
                  text: RSID.minerview2_4.text,
                  // "提现", Withdraw
                  textstyle: TextStyle(
                    color: ((coinbase?.balance?.Unlocked_d ?? 0) > 0) ? ResColor.o_1 : ResColor.white_60,
                    fontSize: 12,
                  ),
                  onclick: (lbtn) {
                    if ((coinbase?.balance?.Unlocked_d ?? 0) > 0) onClickWithdrawCoinbase();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );

    items.add(Container(height: 20));

    //总算力      总质押
    //xxxx       xxxx EPK
    items.add(Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: getColumnKeyValue(
              // RSID.minerview2_5.text, (coinbase?.power?.getTotalRs() ?? "0")+" (${coinbase?.power_percent})"),
              RSID.minerview2_5.text,
              "${(coinbase?.power?.getTotalRs() ?? "0")} / ${(coinbase?.TotalPower?.RawBytePower_rs ?? "0")} (${coinbase?.power_percent})"),
        ),
        Expanded(
          child: getColumnKeyValue(
              RSID.minerview2_6.text, "${StringUtils.formatNumAmount(coinbase?.pledged?.Total_d ?? 0, point: 2)} EPK"),
          // "${StringUtils.formatNumAmountLocaleUnit(coinbase?.pledged?.Total_d ?? 0, context, point: 4, needZhUnit: false)} EPK"),
        ),
      ],
    ));

    items.add(Container(height: 20));

    //节点质押      流量质押
    //xxxx EPK        xxxx EPK
    items.add(Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: getColumnKeyValue(
              RSID.minerview2_7.text, "${StringUtils.formatNumAmount(coinbase?.pledged?.Mining_d ?? 0, point: 2)} EPK"),
          // "${StringUtils.formatNumAmountLocaleUnit(coinbase?.pledged?.Mining_d ?? 0, context, point: 4, needZhUnit: false)} EPK"),
        ),
        Expanded(
          child: getColumnKeyValue(RSID.minerview2_8.text,
              "${StringUtils.formatNumAmount(coinbase?.pledged?.Retrieve_d ?? 0, point: 2)} EPK"),
          // "${StringUtils.formatNumAmountLocaleUnit(coinbase?.pledged?.Retrieve_d ?? 0, context, point: 4, needZhUnit: false)} EPK"),
        ),
      ],
    ));

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(30, 45, 30, 10),
      padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
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

  Widget getHeaderNode() {
    List<Widget> items = [];

    //  节点数据    查看全部节点
    items.add(Row(
      children: [
        Expanded(
          child: Text(
            RSID.minerview2_9.text, //"节点数据",
            style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        InkWell(
          onTap: () {
            if (!ClickUtil.isFastDoubleClick()) {
              //  查看全部节点
              if (coinbase != null) ViewGT.showMinerListView(context, coinbase);
            }
          },
          child: Text(
            RSID.minerview2_10.text, //"查看全部节点",
            style: TextStyle(fontSize: 14, color: ResColor.o_1, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ));

    items.add(Container(height: 20));

    //节点总数      激活节点
    //xxxx         xxxx
    items.add(Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: getColumnKeyValue(
              RSID.minerview2_11.text, //"节点总数",
              "${StringUtils.formatNumAmount(coinbase?.miner?.Count ?? 0)}"),
        ),
        Expanded(
          child: getColumnKeyValue(
              RSID.minerview2_12.text, //"激活节点",
              "${StringUtils.formatNumAmount(coinbase?.miner?.Actived ?? 0)}"),
        ),
      ],
    ));

    items.add(Container(height: 20));

    //算力不足      错误节点
    //xxxx         xxxx
    items.add(Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: getColumnKeyValue(
              RSID.minerview2_13.text, //"算力不足",
              "${StringUtils.formatNumAmount(coinbase?.miner?.LowPower ?? 0)}"),
        ),
        Expanded(
          child: getColumnKeyValue(
              RSID.minerview2_14.text, //"错误节点",
              "${StringUtils.formatNumAmount(coinbase?.miner?.Error ?? 0)}"),
        ),
      ],
    ));

    items.add(Container(height: 20));

    //已质押        我的质押
    //xxxx         xxxx
    items.add(Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: getColumnKeyValue(
              RSID.minerview2_15.text, //"已质押",
              "${StringUtils.formatNumAmount(coinbase?.miner?.Pledged ?? 0)}"),
        ),
        Expanded(
          child: getColumnKeyValue(
              RSID.minerview2_16.text, //"我的质押",
              "${StringUtils.formatNumAmount(coinbase?.miner?.MyPledged ?? 0)}"),
        ),
      ],
    ));

    //提示租赁节点变更
    if (listRentNodeTransferObj != null && listRentNodeTransferObj.length > 0) {
      items.add(
        InkWell(
          onTap: () {
            ViewGT.showView(context, RentNodeNeedTransferView(coinbase,listRentNodeTransferObj));
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Badge(
              position: BadgePosition(top: 0, end: -10),
              child: Text(
                RSID.rnntv_1.text,//"租赁节点需要转移",
                style: TextStyle(
                  fontSize: 14,
                  color: ResColor.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(30, 0, 30, 10),
      padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
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

  Widget getHeaderOwner() {
    List<Widget> items = [];

    //  流量    查看Owner
    items.add(Row(
      children: [
        Expanded(
          child: Text(
            RSID.minerview2_17.text, //:"流量",
            style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        InkWell(
          onTap: () {
            if (!ClickUtil.isFastDoubleClick()) {
              //  查看owner列表
              if (coinbase != null) ViewGT.showOwnerListView(context, coinbase);
            }
          },
          child: Text(
            RSID.minerview2_18.text, //:"查看 Owner",
            style: TextStyle(fontSize: 14, color: ResColor.o_1, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ));

    items.add(Container(height: 20));
    //总流量质押 xxx epk
    items.add(Row(
      children: [
        Text(
          RSID.minerview2_19.text + ": ", //:"总流量质押",
          style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            // "${StringUtils.formatNumAmountLocaleUnit(coinbase?.retrieve?.Pledged_d ?? 0, context, point: 4, needZhUnit: false)} EPK",
            "${StringUtils.formatNumAmount(
              coinbase?.retrieve?.Total_d ?? 0,
              point: 2,
            )} EPK",
            style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ));

    items.add(Container(height: 8));
    //我的流量质押 xxx epk
    items.add(Row(
      children: [
        Text(
          RSID.minerview2_20.text + ": ", //:"我的流量质押",
          style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            // "${StringUtils.formatNumAmountLocaleUnit(coinbase?.retrieve?.Pledged_d ?? 0, context, point: 4, needZhUnit: false)} EPK",
            "${StringUtils.formatNumAmount(
              coinbase?.retrieve?.Pledged_d ?? 0,
              point: 2,
            )} EPK",
            style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ));

    // 锁定中      剩余解锁高度
    // xxxxEPK    xxxx
    // 已解锁  xxxxEPK   提现
    items.add(
      Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: const Color(0xff424242),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: getColumnKeyValue(
                      RSID.minerview2_2.text, //锁定中
                      // "${StringUtils.formatNumAmountLocaleUnit((coinbase?.retrieve_unlock_epoch ?? 0) > 0 ? (coinbase?.retrieve?.Locked_d ?? 0) : 0, context, point: 4, needZhUnit: false)} EPK"),
                      "${StringUtils.formatNumAmount((coinbase?.retrieve_unlock_epoch ?? 0) > 0 ? (coinbase?.retrieve?.Locked_d ?? 0) : 0, point: 2, supply0: false)} EPK"),
                ),
                Expanded(
                  child: getColumnKeyValue(
                      RSID.minerview_29.text, //"剩余高度",
                      "${StringUtils.formatNumAmount(coinbase?.retrieve_unlock_epoch ?? 0, point: 2, supply0: false)}"),
                ),
              ],
            ),
            Container(height: 15),
            Row(
              children: [
                Text(
                  RSID.minerview2_3.text + ": ", //"已解锁"
                  style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Text(
                    "${StringUtils.formatNumAmount((coinbase?.retrieve_unlock_epoch ?? 0) <= 0 ? (coinbase?.retrieve?.Locked_d ?? 0) : 0, point: 2, supply0: false)} EPK",
                    // "${StringUtils.formatNumAmountLocaleUnit((coinbase?.retrieve_unlock_epoch ?? 0) <= 0 ? (coinbase?.retrieve?.Locked_d ?? 0) : 0, context, point: 4, needZhUnit: false)} EPK",
                    style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                LoadingButton(
                  height: 20,
                  width: LocaleConfig.currentIsZh() ? 40 : 60,
                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
                  color_bg: Colors.transparent,
                  disabledColor: Colors.transparent,
                  side: BorderSide(
                      width: 1, color: (coinbase?.hasRetrieveUnlockEpk ?? false) ? ResColor.o_1 : ResColor.white_60),
                  bg_borderradius: BorderRadius.circular(4),
                  text: RSID.minerview2_4.text,
                  // "提现", Withdraw
                  textstyle: TextStyle(
                    color: (coinbase?.hasRetrieveUnlockEpk ?? false) ? ResColor.o_1 : ResColor.white_60,
                    fontSize: 12,
                  ),
                  onclick: (lbtn) {
                    if (coinbase?.hasRetrieveUnlockEpk ?? false) onClickRetrieveWithdraw();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(30, 0, 30, 10),
      padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
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

  Widget getColumnKeyValue(
    String key,
    String value, {
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    double centerpading = 4,
    bool textem = false,
    bool clickCopy = false,
  }) {
    Widget w = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(key, style: TextStyle(fontSize: 14, color: ResColor.white_60)),
        Container(
          height: centerpading,
        ),
        textem
            ? TextEm(value, style: TextStyle(fontSize: 14, color: ResColor.white))
            : Text(value, style: TextStyle(fontSize: 14, color: ResColor.white)),
      ],
    );
    return InkWell(
      onTap: () {
        if (clickCopy) {
          if (ClickUtil.isFastDoubleClick()) return;
          if (StringUtils.isNotEmpty(value)) {
            DeviceUtils.copyText(value);
            showToast(RSID.copied.text);
          }
        }
      },
      child: w,
    );
  }

  /// 提取coinbase收益
  onClickWithdrawCoinbase() {
    BottomDialog.simpleAuth(context, AccountMgr().currentAccount.password, (value) async {
      showLoadDialog("", touchOutClose: false, backClose: false);

      ResultObj<String> robj = await AccountMgr().currentAccount.epikWallet.coinbaseWithdraw();

      closeLoadDialog();

      if (robj?.isSuccess) {
        String cid = robj.data; //bafy2bzaceaa4fwwhrn5oqjsxe5vumlibispulwdzf4uskh4silxlfo4qh6cu6

        MessageDialog.showMsgDialog(
          context,
          title: RSID.minerview_30.text,
          //"Coinbase提取",
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

  // 赎回已解锁的流量抵押
  onClickRetrieveWithdraw() async {
    String amount = coinbase?.retrieve?.Locked ?? "0"; // 自动输入已解锁的数额
    double num = StringUtils.parseDouble(amount, 0);
    if (num <= 0) {
      ToastUtils.showToastCenter(RSID.uspav_4.text);
      return;
    }

    closeInput();

    BottomDialog.simpleAuth(context, AccountMgr().currentAccount.password, (value) async {
      LoadingDialog.showLoadDialog(context, "", touchOutClose: false, backClose: false);

      ResultObj<String> robj = await AccountMgr()
          .currentAccount
          .epikWallet
          .retrievePledgeWithdraw(amount.trim()); //widget.minerinfo.minerid,

      LoadingDialog.cloasLoadDialog(context);

      if (robj?.isSuccess) {
        String cid = robj.data; //bafy2bzaceaa4fwwhrn5oqjsxe5vumlibispulwdzf4uskh4silxlfo4qh6cu6
        setState(() {});

        MessageDialog.showMsgDialog(
          context,
          title: RSID.minerview_25.text,
          //"访问流量抵押",
          msg: "${RSID.minerview_26.text}\n$cid",
          //赎回抵押交易已提交
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
            // Future.delayed(Duration(milliseconds: 50)).then((value) {
            //   refresh();
            // });
          },
        );
      } else {
        ToastUtils.showToastCenter(robj?.errorMsg ?? RSID.request_failed.text);
      }
    });
  }
}
