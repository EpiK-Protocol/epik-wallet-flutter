import 'dart:ui';

import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_AIBot.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/AiBotBill.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

///ai bot credit bills view
class AIBotBillsView extends BaseWidget {
  String url;
  Map<String, dynamic> header;

  AIBotBillsView({@required this.url, this.header});

  @override
  BaseWidgetState<BaseWidget> getState() {
    return AIBotBillsViewState();
  }
}

class AIBotBillsViewState extends BaseWidgetState<AIBotBillsView> {
  List<AiBotBill> data = [];

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
    setAppBarTitle(RSID.main_abv_23.text);
    // setAppBarTitle("Bills");
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

  int page = 1;
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

  //order 充值消费记录
  Future<HttpJsonRes> getBillList(String url, int page, int size, Map<String, dynamic> header) async {
    Map<String, dynamic> params = new Map();
    params["page"] = page;
    params["pageSize"] = size;
    HttpJsonRes hjr = await HttpUtil.instance.requestJson(true, url, params, headers: header);
    if (hjr.jsonMap != null) {
      hjr.code = hjr.jsonMap["code"] ?? hjr.code;
      hjr.msg = hjr.jsonMap["message"] ?? hjr.msg;
    }
    return hjr;
  }

  refresh() async {
    if (isFirst) {
      isFirst = false;
    }

    setLoadingWidgetVisible(true);

    isLoading = true;
    page = 1;

    // HttpJsonRes hjr = await ApiAIBot.getOrderList(getWalletID, page, size);
    HttpJsonRes hjr = await getBillList(widget.url, page, size, widget.header);
    print([hjr.code, hjr.msg, hjr.jsonMap]);
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
    print([hjr.code, hjr.msg, hjr.jsonMap]);
    List<AiBotBill> tempdata = null;
    if (hjr?.code == 0) {
      Map<String, dynamic> j_data = hjr.jsonMap["data"];
      dlog(j_data.toString());
      int total = j_data["total"];
      dlog(total.toString());
      tempdata = JsonArray.parseList(JsonArray.obj2List(j_data["list"]), (json) => AiBotBill.fromJson(json));
      tempdata = tempdata ?? [];
      dlog("tempdata size = ${tempdata.length}");
    }

    if (tempdata != null) {
      // 请求成功
      if (page == 1) {
        data.clear();
      }
      data.addAll(tempdata);

      if (tempdata.length >= size) {
        hasMore = true;
        page += 1;
      } else {
        hasMore = false;
      }

      if (page == 1 && tempdata.length == 0) {
        setEmptyWidgetVisible(true);
        isLoading = false;
        return;
      }
    } else {
      showToast(RSID.request_failed.text); //"请求失败);
      if (page == 1) {
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

    page = 1;
    // HttpJsonRes hjr = await ApiAIBot.getOrderList(getWalletID, page, size);
    HttpJsonRes hjr = await getBillList(widget.url, page, size, widget.header);
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
    AiBotBill order = data[position];

    bool isend = position >= data.length - 1;

    bool addCredit = !order.isConsume;
    String symbol = addCredit ? "+" : "-";
    String typestr = addCredit ? RSID.main_abv_21.text : RSID.main_abv_22.text;

    List<Widget> items = [
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "${order.createdAt_str}",
            style: TextStyle(
              fontSize: 14,
              color: ResColor.white_80,
              // fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            " $typestr",
            style: TextStyle(
              fontSize: 14,
              color: ResColor.white,
              // fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
              child: Container(
            alignment: Alignment.center,
          )),
          Text(
            "$symbol ${StringUtils.formatNumAmount(order.amount)}",
            style: TextStyle(
              fontSize: 14,
              color: addCredit ? ResColor.g_1 : ResColor.r_1,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Text(
          //   " Credit${(order.amount > 1 ? "s" : "")}",
          //   style: TextStyle(
          //     fontSize: 14,
          //     color: Colors.white,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
        ],
      ),
      // Container(height: 6),
      // Row(
      //   mainAxisSize: MainAxisSize.max,
      //   mainAxisAlignment: MainAxisAlignment.start,
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     Expanded(
      //         child: Container(
      //       padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
      //       alignment: Alignment.centerLeft,
      //       child: Text(
      //         "${order.item}",
      //         style: TextStyle(
      //           fontSize: 14,
      //           color: ResColor.white,
      //           // fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //     )),
      //     Text(
      //       "${order.type}",
      //       style: TextStyle(
      //         fontSize: 14,
      //         color: ResColor.white,
      //         // fontWeight: FontWeight.bold,
      //       ),
      //     ),
      //   ],
      // ),
      Container(height: 20),
      if (!isend)
        Divider(
          color: ResColor.white_20,
          height: 0.5, //WHScreenUtil.onePx(),
          thickness: 0.5, //WHScreenUtil.onePx(),
          // indent: 20,
        ),
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
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
