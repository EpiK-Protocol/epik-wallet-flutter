import 'dart:ui';

import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_AIBot.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/AIBotApp.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

///ai bot point orders view
class AIBotOrdersView extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> getState() {
    return AIBotOrdersViewState();
  }
}

class AIBotOrdersViewState extends BaseWidgetState<AIBotOrdersView> {
  List<AIBotOrder> data = [];

  @override
  void initStateConfig() {
    super.initStateConfig();

    setTopBarVisible(false);
    setAppBarVisible(true);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);

    refresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(RSID.main_abv_5.text);
  }

  @override
  Widget getAppBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(0, getTopBarHeight(), 0, 0),
      decoration: BoxDecoration(
        gradient: ResColor.lg_1,
      ),
      child: super.getAppBar(),
    );
  }

  bool isFirst = true;

  int page = 0;
  int size = 20;
  bool hasMore = false;
  bool isLoading = false;

  String get getWalletID {
    String wallet_id = AccountMgr().currentAccount.mining_id;
    if (ApiAIBot.TESTNET && StringUtils.isNotEmpty(AccountMgr().currentAccount.test_wallet_id)) {
      wallet_id = AccountMgr().currentAccount.test_wallet_id;
    }
    return wallet_id;
  }

  refresh() async {
    if (isFirst) {
      isFirst = false;
    }

    setLoadingWidgetVisible(true);

    isLoading = true;
    page = 0;

    HttpJsonRes hjr = await ApiAIBot.getOrderList(getWalletID, page, size);

    isLoading = false;

    if (hjr?.code == 0) {
      dataCallback(hjr);
    } else {
      setErrorWidgetVisible(true);
      isLoading = false;
      return;
    }
  }

  dataCallback(HttpJsonRes hjr) {
    List<AIBotOrder> tempdata = null;
    if (hjr?.code == 0) {
      tempdata = JsonArray.parseList(JsonArray.obj2List(hjr.jsonMap["data"]), (json) => AIBotOrder.fromJson(json));
      tempdata = tempdata ?? [];
    }

    if (tempdata != null) {
      // 请求成功
      if (page == 0) {
        data.clear();
      }
      data.addAll(tempdata);

      if (tempdata.length >= size) {
        hasMore = true;
        page += 1;
      } else {
        hasMore = false;
      }

      if (page == 0 && tempdata.length == 0) {
        setEmptyWidgetVisible(true);
        isLoading = false;
        return;
      }
    } else {
      showToast(RSID.request_failed.text); //"请求失败);
      if (page == 0) {
        setErrorWidgetVisible(true);
        isLoading = false;
        return;
      }
    }
    closeStateLayout();
    isLoading = false;
    return;
  }

  Future<void> _pullRefreshCallback() async {
    if (isLoading) {
      return;
    }
    isLoading = true;

    page = 0;
    HttpJsonRes hjr = await ApiAIBot.getOrderList(getWalletID, page, size);
    if (hjr?.code == 0) {
      dataCallback(hjr);
    } else {
      setErrorWidgetVisible(true);
      isLoading = false;
      return;
    }
  }

  /**是否需要加载更多*/
  bool needLoadMore() {
    bool ret = hasMore && !isLoading;
    dlog("needLoadMore = " + ret.toString());
    return ret;
  }

  /**加载分页*/
  Future<bool> onLoadMore() async {
    if (isLoading) return true;
    dlog("onLoadMore  ");
    isLoading = true;

    //  加载分页
    HttpJsonRes hjr = await ApiAIBot.getOrderList(getWalletID, page, size);
    dataCallback(hjr);
    return hasMore;
  }

  @override
  void onClickEmptyWidget() {
    refresh();
  }

  @override
  void onClickErrorWidget() {
    refresh();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return ListPage(
      data,
      itemWidgetCreator: (context, position) {
        return InkWell(
          onTap: () => onItemClick(position),
          child: itemWidgetBuild(context, position),
        );
      },
      pullRefreshCallback: _pullRefreshCallback,
      onLoadMore: onLoadMore,
      needLoadMore: needLoadMore,
    );
  }

  itemWidgetBuild(BuildContext context, int position) {
    AIBotOrder order = data[position];

    bool isend = position >= data.length - 1;

    bool addPoint = order.type == AIBotOrderType.recharge;
    String symbol = addPoint ? "+" : "-";

    List<Widget> items = [
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "$symbol ${StringUtils.formatNumAmount(order.Amount)}",
            style: TextStyle(
              fontSize: 14,
              color: addPoint ? ResColor.g_1 : ResColor.r_1,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "  Points",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              // fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
              child: Container(
            alignment: Alignment.center,
          )),
          Text(
            "${order.created_at}",
            style: TextStyle(
              fontSize: 14,
              color: ResColor.white,
              // fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      Container(height: 6),
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Container(
            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
            alignment: Alignment.centerLeft,
            child: Text(
              "${order.title}",
              style: TextStyle(
                fontSize: 14,
                color: ResColor.white,
                // fontWeight: FontWeight.bold,
              ),
            ),
          )),
          Text(
            "${order.status.getName()}",
            style: TextStyle(
              fontSize: 14,
              color: ResColor.white,
              // fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      Container(height: 15),
      if (!isend)
        Divider(
          color: ResColor.white_20,
          height: 0.5, //WHScreenUtil.onePx(),
          thickness: 0.5, //WHScreenUtil.onePx(),
          // indent: 20,
        ),
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
      color: ResColor.b_3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ),
    );
  }

  onItemClick(int position) {}

  lookEthTxhash(String txhash) {
//    https://cn.etherscan.com/address/0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    String url = ServiceInfo.ether_tx_web + txhash;
    ViewGT.showGeneralWebView(
      context,
      RSID.usolv_3.text, //"详情",
      url,
    );
  }

  lookEpkCid(String cid) {
    String url = ServiceInfo.epik_msg_web + cid; // 需要epk浏览器地址
    ViewGT.showGeneralWebView(
      context,
      RSID.usolv_3.text, //"详情",
      url,
    );
  }
}
