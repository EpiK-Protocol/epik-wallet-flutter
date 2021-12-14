import 'dart:ui';

import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_wallet.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/logic/loader/DL_TepkLoginToken.dart';
import 'package:epikwallet/model/Erc20ToEpkSwapRecord.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

///erc20 兑换成 epk 的记录列表
class Erc20ToEpkRecordView extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> getState() {
    return Erc20ToEpkRecordViewState();
  }
}

class Erc20ToEpkRecordViewState extends BaseWidgetState<Erc20ToEpkRecordView> {
  List<Erc20ToEpkSwapRecord> data = [];

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
    setAppBarTitle(RSID.eerv_1.text); //"EPK兑换记录");
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

  int eth_height = 0;
  int epik_epoch = 0;
  int epik_pending = 0;
  int eth_pending = 0;

  int page = 0;
  int size = 20;
  bool hasMore = false;
  bool isLoading = false;

  refresh() async {
    if (isFirst) {
      isFirst = false;
    }

    setLoadingWidgetVisible(true);

    isLoading = true;
    page = 0;
    HttpJsonRes hjr = await ApiWallet.swapRecords(
      DL_TepkLoginToken.getEntity().getToken(),
      AccountMgr().currentAccount.hd_eth_address,
      AccountMgr().currentAccount.epik_EPK_address,
      page: page,
      size: size,
    );
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
    List<Erc20ToEpkSwapRecord> tempdata = null;
    if (hjr?.code == 0) {
      tempdata = JsonArray.parseList(JsonArray.obj2List(hjr.jsonMap["list"]),
              (json) => Erc20ToEpkSwapRecord.fromJson(json));
      tempdata = tempdata ?? [];

      if(page==0)
      {
        eth_height = StringUtils.parseInt(hjr.jsonMap["eth_height"], 0);
        epik_epoch = StringUtils.parseInt(hjr.jsonMap["epik_epoch"], 0);
        epik_pending = StringUtils.parseInt(hjr.jsonMap["epik_pending"], 0);
        eth_pending = StringUtils.parseInt(hjr.jsonMap["eth_pending"], 0);
      }
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
    HttpJsonRes hjr = await ApiWallet.swapRecords(
      DL_TepkLoginToken.getEntity().getToken(),
      AccountMgr().currentAccount.hd_eth_address,
      AccountMgr().currentAccount.epik_EPK_address,
      page: page,
      size: size,
    ); //await ApiWallet.Erc2EpkSwapRecords();
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
    HttpJsonRes hjr = await ApiWallet.swapRecords(
      DL_TepkLoginToken.getEntity().getToken(),
      AccountMgr().currentAccount.hd_eth_address,
      AccountMgr().currentAccount.epik_EPK_address,
      page: page,
      size: size,
    );
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
    Erc20ToEpkSwapRecord record = data[position];

    bool isend = position >= data.length - 1;

    bool failed = record.swapstatus == SwapStatus.failed;

    List<Widget> items = [
      Container(
        padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${record.amount}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: ResColor.white,
                      height: 1,
                    ),
                  ),
                  Text(
                    "${record.cs_from.symbol}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: ResColor.white_60,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  // padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Icon(
                    Icons.arrow_right_alt_outlined,
                    size: 17,
                    color: ResColor.white,
                  ),
                ),
                Container(
                  width: 0,
                  height: 16,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: -100,
                        top: 0,
                        child: Container(
                          width: 200,
                          child: Text(
                            "Fee: ${record.fee}${record.cs_from.symbol}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: ResColor.white_60,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${record.amount_actual}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: ResColor.white,
                      height: 1,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${record.cs_to.symbol}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: ResColor.white_60,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      if (StringUtils.isNotEmpty(record.erc20_tx_hash) ||
          StringUtils.isNotEmpty(record.epik_cid))
        record.is2Epik
            ? Row(
                children: [
                  Expanded(
                    child: StringUtils.isNotEmpty(record.erc20_tx_hash)
                        ? InkWell(
                            onTap: () {
                              lookEthTxhash(record.erc20_tx_hash);
                            },
                            child: Text(
                              RSID.eerv_2.text, //"转出交易",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: ResColor.white_60,
                                decoration: TextDecoration.underline,
                              ),
                            ))
                        : Container(),
                  ),
                  Container(width: 60),
                  Expanded(
                    child: StringUtils.isNotEmpty(record.epik_cid)
                        ? InkWell(
                            onTap: () {
                              lookEpkCid(record.epik_cid);
                            },
                            child: Text(
                              RSID.eerv_3.text, // "转入交易",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: ResColor.white_60,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                        : Container(),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: StringUtils.isNotEmpty(record.epik_cid)
                        ? InkWell(
                            onTap: () {
                              lookEpkCid(record.epik_cid);
                            },
                            child: Text(
                              RSID.eerv_2.text, //"转出交易",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: ResColor.white_60,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                        : Container(),
                  ),
                  Container(width: 60),
                  Expanded(
                    child: StringUtils.isNotEmpty(record.erc20_tx_hash)
                        ? InkWell(
                            onTap: () {
                              lookEthTxhash(record.erc20_tx_hash);
                            },
                            child: Text(
                              RSID.eerv_3.text, //"转入交易",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: ResColor.white_60,
                                decoration: TextDecoration.underline,
                              ),
                            ))
                        : Container(),
                  ),
                ],
              ),
      Container(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Row(
          children: [
            Text(
              record.created_at_dt == null
                  ? ""
                  : DateUtil.formatDate(record.created_at_dt,
                      format: DataFormats.full),
              style: TextStyle(
                fontSize: 14,
                color: ResColor.white_60,
              ),
            ),
            Expanded(
              child: Container(),
            ),
            InkWell(
              onTap: failed
                  ? () {
                      MessageDialog.showMsgDialog(
                        context,
                        title: RSID.eerv_4.text,
                        //"失败原因",
                        msg: record.err_message,
                        btnLeft: RSID.isee.text,
                        onClickBtnLeft: (dialog) {
                          dialog.dismiss();
                        },
                        btnRight: RSID.eerv_5.text,
                        // "重试提交兑换",
                        onClickBtnRight: (dialog) {
                          dialog.dismiss();
                          onClickRetrySwapTx(record);
                        },
                      );
                    }
                  : null,
              child: Row(
                children: [
                  if (failed)
                    Padding(
                      padding: EdgeInsets.only(right: 2),
                      child: Icon(
                        Icons.info_outline,
                        size: 14,
                        color: ResColor.r_1, //ResColor.white,
                      ),
                    ),
                  Text(
                    "${record?.swapstatus?.getName() ?? record?.status}${record.getPendingProgressString(eth_height, epik_epoch, eth_pending, epik_pending)}",
                    style: TextStyle(
                      fontSize: 14,
                      color: failed
                          ? ResColor.r_1
                          : (record.swapstatus == SwapStatus.success
                              ? ResColor.g_1
                              : ResColor.white),
                      // height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Container(height: 14.5),
      if (!isend)
        Divider(
          color: ResColor.white_20,
          height: 0.5, //WHScreenUtil.onePx(),
          thickness: 0.5, //WHScreenUtil.onePx(),
          indent: 20,
        ),
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
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

  onClickRetrySwapTx(Erc20ToEpkSwapRecord record) async {
    showLoadDialog("");
    HttpJsonRes hjr = await ApiWallet.retrySwapTx(
        record.id, DL_TepkLoginToken.getEntity().getToken());
    closeLoadDialog();
    if (hjr?.code == 0) {
      showToast(RSID.eerv_6.text); //"已重新提交");
    } else {
      showToast(hjr.msg);
    }
  }
}
