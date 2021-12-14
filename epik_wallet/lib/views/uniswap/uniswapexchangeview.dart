import 'dart:ui';

import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/UniswapHistoryMgr.dart';
import 'package:epikwallet/logic/api/api_wallet.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/model/CurrencyAsset.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/mainview.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_k_chart/flutter_k_chart.dart';
import 'package:flutter_k_chart/utils/data_util.dart';
import 'package:url_launcher/url_launcher.dart';

class UniswapExchangeView extends BaseInnerWidget {
  // 可能是空
  WalletAccount walletAccount;

  UniswapExchangeView(this.walletAccount);

  @override
  BaseInnerWidgetState<BaseInnerWidget> getState() {
    return UniswapExchangeViewState();
  }

  @override
  int setIndex() {
    return 0;
  }
}

class UniswapExchangeViewState
    extends BaseInnerWidgetState<UniswapExchangeView> {
  double slippage = 0.1;

  Color color_btn_1 = ResColor.main_1; //Colors.pinkAccent[100];
  Color color_btn_2 = Colors.blue;

  CurrencySymbol cs_A, cs_B;

  CurrencySymbol cs_from = CurrencySymbol.EPKerc20;
  CurrencySymbol cs_to = CurrencySymbol.USDT;

  String text_from = "";
  double amount_form = 0;
  String text_to = "";
  TextEditingController _tec_from;

  Amounts calc_amounts;

  double slippage_calc;

  @override
  void initStateConfig() {
    super.initStateConfig();
    bodyBackgroundColor = Colors.transparent;

    cs_A = CurrencySymbol.EPKerc20;
    cs_B = CurrencySymbol.USDT;

    // setAppBarHeight(60);
  }

  @override
  void onCreate() {
    super.onCreate();
    eventMgr.add(EventTag.BALANCE_UPDATE, eventCallback_balance);
    eventMgr.add(EventTag.UPLOAD_SUGGESTGAS, eventCallback);
    eventMgr.add(EventTag.UPLOAD_UNISWAPINFO, eventCallback);
    refresh();
  }

  eventCallback_balance(obj) {
    if (obj == widget.walletAccount) {
      setState(() {});
    }
  }

  eventCallback(obj) {
    setState(() {});
  }

  @override
  void dispose() {
    eventMgr.remove(EventTag.BALANCE_UPDATE, eventCallback_balance);
    eventMgr.remove(EventTag.UPLOAD_SUGGESTGAS, eventCallback);
    eventMgr.remove(EventTag.UPLOAD_UNISWAPINFO, eventCallback);
    super.dispose();
  }

  List<String> infoNames = [];

  refresh() {
    infoNames = ResString.get(appContext, RSID.usev_13).split(",");

    widget.walletAccount.uploadSuggestGas();
    widget.walletAccount.uploadUniswapInfo();

    getKlineData(7);
  }

  @override
  Widget buildWidget(BuildContext context) {
    Color exchanegBtnColor =
        (amount_form != 0 && calc_amounts != null) ? color_btn_2 : color_btn_1;
    LinearGradient exchanegBtnColor_lg =
        (amount_form != 0 && calc_amounts != null)
            ? ResColor.lg_1
            : ResColor.lg_2;
    String btn_text = (amount_form != 0 && calc_amounts != null)
        ? ResString.get(context, RSID.usv_2)
        : ResString.get(context, RSID.usev_1); //"兑换" : "预估";

    Widget scroll = SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(0),
      child: Container(
        constraints: BoxConstraints(
          minHeight:
              getScreenHeight(), //-BaseFuntion.topbarheight - BaseFuntion.appbarheight_def,
        ),
        child: Column(
          children: <Widget>[
            getKlineWidget(),
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
              color: ResColor.b_3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  getFrom(),
                  InkWell(
                    // borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    onTap: () {
                      changeCurrency();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      padding: EdgeInsets.all(10),
                      child: Image.asset(
                        "assets/img/ic_uniswap_change_currency.png",
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                  getTo(),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            ResString.get(context, RSID.usev_2, replace: [""]),
//                        "手续费 : ${StringUtils.formatNumAmount(StringUtils.parseDouble(widget.walletAccount.eth_suggestGas, 0) * 9, point: 8, supply0: false)} eth",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          StringUtils.formatNumAmount(
                                  (amount_form ?? 0) * 0.003,
                                  point: 8,
                                  supply0: false) +
                              " ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          cs_from.symbol, //手续费改为
                          style: TextStyle(
                            color: ResColor.white_60,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.fromLTRB(20, 5, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            ResString.get(context, RSID.usev_14, replace: [""]),
                            //usev_3
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          StringUtils.formatNumAmount(
                                  (slippage_calc ?? 0.01) * 100,
                                  point: 2,
                                  supply0: false) +
                              " ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "%",
                          style: TextStyle(
                            color: ResColor.white_60,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.fromLTRB(20, 5, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            RSID.usev_15.text,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  // "1 ${cs_A.symbol} = ${StringUtils.formatNumAmount(widget?.walletAccount?.uniswapinfo?.price_USDT_EPK ?? 0, point: 8, supply0: false)} ${cs_B.symbol}",
                                  StringUtils.formatNumAmount(
                                          widget?.walletAccount?.uniswapinfo
                                                  ?.price_USDT_EPK ??
                                              0,
                                          point: 8,
                                          supply0: false) +
                                      " ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "${cs_A.symbol}/ ${cs_B.symbol}",
                                  style: TextStyle(
                                    color: ResColor.white_60,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Container(height: 5),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  // "1 ${cs_B.symbol} = ${StringUtils.formatNumAmount(widget?.walletAccount?.uniswapinfo?.price_EPK_USDT ?? 0, point: 8, supply0: false)} ${cs_A.symbol}",
                                  StringUtils.formatNumAmount(
                                          widget?.walletAccount?.uniswapinfo
                                                  ?.price_EPK_USDT ??
                                              0,
                                          point: 8,
                                          supply0: false) +
                                      " ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "${cs_B.symbol}/ ${cs_A.symbol}",
                                  style: TextStyle(
                                    color: ResColor.white_60,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  LoadingButton(
                    margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
                    height: 40,
                    gradient_bg: exchanegBtnColor_lg,
                    color_bg: Colors.transparent,
                    disabledColor: Colors.transparent,
                    bg_borderradius: BorderRadius.circular(4),
                    text: btn_text,
                    //"兑换",
                    textstyle: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                    onclick: (lbtn) {
                      onClickExchange();
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(40, 35, 40, 0),
              child: InkWell(
                onTap: () {
                  onClickReadme();
                },
                child: Text(
                  ResString.get(context, RSID.uspv_3), //"使用说明(新手必读)",
                  style: TextStyle(
                    color: ResColor.white,
                    fontSize: 14,
                    // decoration: TextDecoration.underline, //下滑线
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 50,
          bottom: 0,
          child: scroll,
        ),
      ],
    );
  }

  Widget getFrom() {
    if (_tec_from == null)
      _tec_from = new TextEditingController.fromValue(TextEditingValue(
        text: text_from,
        selection: new TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream, offset: text_from.length),
        ),
      ));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 9),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "From : ${cs_from.symbol}",
                    style: TextStyle(
                      color: ResColor.white_60,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  (widget.walletAccount != null)
                      ? "${ResString.get(context, RSID.usev_4)}${getBalance(cs_from) ?? "--"}" //余额
                      : "",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                  width: 30,
                  height: 30,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Image(
                          image: AssetImage(cs_from.iconUrl),
                          width: 30,
                          height: 30,
                        ),
                      ),
                      Positioned(
                          right: -1.5,
                          bottom: -1.5,
                          child: Image(
                            image: AssetImage(cs_from.networkType.iconUrl),
                            width: 13,
                            height: 13,
                          )),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 30,
                    margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                    child: TextField(
                      controller: _tec_from,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      maxLines: 1,
                      maxLengthEnforced: true,
                      obscureText: false,
                      inputFormatters: [
                        WhitelistingTextInputFormatter(RegExpUtil.re_float)
                      ],
                      // 这里限制长度 不会有数量提示
                      decoration: InputDecoration(
                        // 以下属性可用来去除TextField的边框
                        border: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(0, -18, 0, 0),
                        hintText: "0.0",
                        hintStyle:
                            TextStyle(color: ResColor.white_60, fontSize: 14),
                      ),
                      cursorWidth: 2.0,
                      //光标宽度
                      cursorRadius: Radius.circular(2),
                      //光标圆角弧度
                      cursorColor: Colors.white,
                      //光标颜色
                      style: TextStyle(fontSize: 14, color: Colors.white),
                      onChanged: (value) {
                        text_from = _tec_from.text.trim();
                        amount_form = StringUtils.parseDouble(text_from, 0);
                        onInputFrom();
                      },
                    ),
                  ),
                ),
                LoadingButton(
                  width: 40,
                  height: 20,
                  color_bg: Colors.transparent,
                  disabledColor: Colors.transparent,
                  side: BorderSide(color: ResColor.o_1, width: 1),
                  bg_borderradius: BorderRadius.circular(4),
                  text: RSID.usev_5.text,
                  //"全部",
                  textstyle: TextStyle(
                    color: ResColor.o_1,
                    fontSize: 12,
                  ),
                  onclick: (lbtn) {
                    setState(() {
                      text_from =
                          (getBalance(cs_from) ?? "").replaceAll(",", "");
                      _tec_from.text = text_from;
                      amount_form = StringUtils.parseDouble(text_from, 0);
                      _tec_from = null;
                      onInputFrom();
                    });
                  },
                ),
              ],
            ),
          ),
          Container(height: 4),
          Divider(
            height: 1,
            thickness: 1,
            color: ResColor.white_20,
          ),
        ],
      ),
    );
  }

  Widget getTo() {
    Color calc_color =
        (calc_amounts == null && amount_form != 0) ? color_btn_2 : color_btn_1;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 9),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "To : ${cs_to.symbol}",
                    style: TextStyle(
                      color: ResColor.white_60,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  (widget.walletAccount != null)
                      ? "${ResString.get(context, RSID.usev_4)}${getBalance(cs_to) ?? "--"}" //余额:
                      : "",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                  width: 30,
                  height: 30,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Image(
                          image: AssetImage(cs_to.iconUrl),
                          width: 30,
                          height: 30,
                        ),
                      ),
                      Positioned(
                          right: -1.5,
                          bottom: -1.5,
                          child: Image(
                            image: AssetImage(cs_to.networkType.iconUrl),
                            width: 13,
                            height: 13,
                          )),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                    child: Text(
                      StringUtils.isNotEmpty(text_to)
                          ? text_to
                          : ResString.get(context, RSID.usev_6), //"需要预估数量",
                      style: TextStyle(
                          fontSize: 14,
                          color: StringUtils.isNotEmpty(text_to)
                              ? Colors.white
                              : ResColor.white_60),
                    ),
                  ),
                ),
                if (calc_amounts != null && amount_form != 0)
                  InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    onTap: () {
                      calcToAmount();
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      child: Icon(
                        Icons.refresh,
                        color: ResColor.white_60,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(height: 4),
          Divider(
            height: 1,
            thickness: 1,
            color: ResColor.white_20,
          ),
        ],
      ),
    );
  }

  changeCurrency() {
    CurrencySymbol old_from = cs_from;
    cs_from = cs_to;
    cs_to = old_from;

//    String old_text_from = text_from;
//    text_from = text_to;
//    text_to = old_text_from;
//    _tec_from.text = text_from;

    calc_amounts = null;
    text_to = "";

    setState(() {
      calcSlippage();
    });
  }

  String getBalance(CurrencySymbol cs) {
    if (widget?.walletAccount != null) {
      CurrencyAsset ca = widget?.walletAccount.getCurrencyAssetByCs(cs);
      if (ca != null) {
        return StringUtils.formatNumAmount(ca.getBalanceDouble(),
            point: 8, supply0: false);
      }
    }
    return null;
  }

  calcToAmount() {
    if (widget?.walletAccount?.hdwallet == null) {
      eventMgr.send(EventTag.CHANGE_MAINVIEW_INDEX,
          main_subviewTypes.indexOf(MainSubViewType.WALLETVIEW));
      return;
    }

    if (StringUtils.isEmpty(text_from)) {
//      showToast("请输入${cs_from.symbol}数量");
      showToast(ResString.get(context, RSID.usev_7, replace: [cs_from.symbol]));
      return;
    }

    if (amount_form == 0) {
//      showToast("${cs_from.symbol}数量不能为0");
      showToast("${cs_from.symbol}${ResString.get(context, RSID.usev_8)}");
      return;
    }

    closeInput();
    //"正在预估数量..."
    showLoadDialog(ResString.get(context, RSID.usev_9), onShow: () async {
      widget.walletAccount.uploadSuggestGas(); //预估的同时 刷新gas
      Amounts amounts = await widget.walletAccount.hdwallet
          .uniswapGetAmountsOut(
              cs_from.symbolToNetWork, cs_to.symbolToNetWork, text_from.trim());
      if (amounts != null) {
        dlog("${amounts.AmountIn} -> ${amounts.AmountOut}");
        if (amount_form == amounts.AmountIn_d ||
            text_from == amounts.AmountIn) {
          String amount_out = StringUtils.formatNumAmount(amounts.AmountOut,
              point: 8, supply0: false);
          amount_out = amount_out.replaceAll(",", "");
          amounts.AmountOut = amount_out;
          amounts.AmountOut_d = StringUtils.parseDouble(amount_out, 0);
          setState(() {
            text_to = amount_out;
            calc_amounts = amounts;
            calcSlippage();
          });
        }
      } else {
//        showToast("请求失败,请稍后重试");
        showToast(ResString.get(context, RSID.request_failed_retry));
      }
      closeLoadDialog();
    });
  }

  ///计算滑点
  calcSlippage() {
    if (widget?.walletAccount?.uniswapinfo != null && calc_amounts != null) {
      double price = calc_amounts.AmountIn_d / calc_amounts.AmountOut_d;
      double price_pool = 0;
      if (cs_from == CurrencySymbol.EPKerc20) {
        price_pool = widget.walletAccount.uniswapinfo.price_EPK_USDT;
      } else {
        price_pool = widget.walletAccount.uniswapinfo.price_USDT_EPK;
      }
      dlog("slippage_calc $price $price_pool");
      if (price != 0 && price_pool != 0) {
        double difference = price_pool - price;
        slippage_calc = (difference / price_pool).abs();
        dlog("slippage_calc = $slippage_calc ");
        return;
      }
    }
    slippage_calc = null;
  }

  onInputFrom() {
    if (calc_amounts != null && calc_amounts.AmountIn_d != amount_form) {
      calc_amounts = null;
      text_to = "";
    }
    setState(() {
      calcSlippage();
    });
  }

  onInputTo() {}

  onClickReadme() {
//    final String address = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    final String address = "0xDaF88906aC1DE12bA2b1D2f7bfC94E9638Ac40c4";

    final TapGestureRecognizer recognizer_1 = TapGestureRecognizer();
    final TapGestureRecognizer recognizer_2 = TapGestureRecognizer();

    final YYDialog yydialog = MessageDialog.showMsgDialog(
      context,
      title: ResString.get(context, RSID.uspv_13), //"EpiK提醒您",
      btnRight: ResString.get(context, RSID.isee), //"知道了",
      onClickBtnRight: (dialog) {
        dialog.dismiss();
      },
      extend: Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: RichText(
          text: TextSpan(
            text: ResString.get(context, RSID.usev_10_1),
            // "「1」本页兑换交易是基于Uniswap的ERC20-EPK与USDT交易\n\n「2」底层部署在以太坊公链上，兑换及资金池操作均会产生ETH手续费，操作前请确保钱包有足够的ETH。\n\n「3」官方智能合约地址为：",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontFamily: fontFamily_def,
            ),
            children: <TextSpan>[
              TextSpan(
                text: address,
                style: TextStyle(
                  color: ResColor.o_1,//Colors.blue,
                  fontSize: 14.0,
//                  decoration: TextDecoration.underline,
                ),
                recognizer: recognizer_1,
              ),
              TextSpan(
                text: ResString.get(
                    context, RSID.usev_10_2), //"\n\n「4」新手操作说明请点击",
              ),
              TextSpan(
                text: ResString.get(context, RSID.usev_10_3), // "这里",
                style: TextStyle(
                  color: ResColor.o_1,//Colors.blue,
                  fontSize: 14.0,
//                  decoration: TextDecoration.underline,
                ),
                recognizer: recognizer_2,
              ),
            ],
          ),
        ),
      ),
    );

    recognizer_1.onTap = () async {
      yydialog.dismiss();
      ViewGT.showGeneralWebView(context, ResString.get(context, RSID.uspv_14),
          "https://cn.etherscan.com/address/${address}");
    };

    recognizer_2.onTap = () async {
      yydialog.dismiss();
      String url = "https://shimo.im/docs/dXyqQyKTct6qxjg6/";
//      ViewGT.showGeneralWebView(context, "EpiK 钱包兑换交易手册", url);
      canLaunch(url).then((value) {
        if (value) {
          launch(url).then((value) {});
        }
      });
    };
  }

  onClickExchange() {
    if (widget?.walletAccount?.hdwallet == null) {
      eventMgr.send(EventTag.CHANGE_MAINVIEW_INDEX,
          main_subviewTypes.indexOf(MainSubViewType.WALLETVIEW));
      return;
    }

    if (StringUtils.isEmpty(text_from)) {
//      showToast("请输入${cs_from.symbol}数量");
      showToast(ResString.get(context, RSID.usev_7, replace: [cs_from.symbol]));
      return;
    }

    if (amount_form == 0) {
//      showToast("${cs_from.symbol}数量不能为0");
      showToast("${cs_from.symbol}${ResString.get(context, RSID.usev_8)}");
      return;
    }

    if (calc_amounts == null || calc_amounts.AmountIn_d != amount_form) {
//      showToast("需要先计算预估");
      calcToAmount();
      return;
    }

    closeInput();

    BottomDialog.showPassWordInputDialog(
      context,
      widget.walletAccount.password,
      (password) async {
        //点击确定回调

        await Future.delayed(Duration(milliseconds: 200));

        showLoadDialog(
          ResString.get(context, RSID.usev_11), //"正在提交到以太坊网络，请耐心等待",
          onShow: () async {
            ResultObj<String> ret =
                await widget.walletAccount.hdwallet.uniswapExactTokenForTokens(
              widget.walletAccount.hd_eth_address, //地址
              cs_from.symbolToNetWork, // from币种
              cs_to.symbolToNetWork, // to币种
              text_from.trim(), // from数量
              "${calc_amounts.AmountOut_d * (1 - slippage)}",
              // , // to 期望兑换到的最少数量
              "${DateTime.now().toUtc().millisecondsSinceEpoch / 1000 + 20 * 60}", // 最晚成交时间 时间戳 秒
            );

            // ret = 0xe966bbd1e089becc1d0d23bf8ae145ba3b25ad9b482dbd22b6368bca239e35e2
            print("uniswapExactTokenForTokens ${ret?.data}");
//        showToast("请求失败,请稍后重试");
            closeLoadDialog();

            if (StringUtils.isNotEmpty(ret?.data)) {
              widget?.walletAccount?.uhMgr?.addOrder(UniswapOrder(
                hash: ret?.data,
                state: 0,
                // 等待
                type: 0,
                // 兑换
                time: DateTime.now().toUtc().millisecondsSinceEpoch,

                ///utc时间 毫秒
                token_a: cs_from.symbol,
                token_b: cs_to.symbol,
                amount_a: text_from,
                amount_b: text_to,
              ));
              widget?.walletAccount?.uhMgr?.save();

              setState(() {
                text_from = "";
                _tec_from.text = "";
                amount_form = 0;
                text_to = "0.0";
              });

//            DeviceUtils.copyText(ret);

              MessageDialog.showMsgDialog(
                context,
                title: ResString.get(context, RSID.usv_2),
                // "兑换",
                msg: ResString.get(context, RSID.usev_12),
                //"已提交到以太坊\n稍后可在交易记录中查询结果",
                msgAlign: TextAlign.center,
                btnRight: ResString.get(context, RSID.confirm),
                //"确定",
                onClickBtnRight: (dialog) {
                  dialog.dismiss();
                },
              );
            } else {
              showToast(ret?.errorMsg ??
                  ResString.get(
                      context, RSID.request_failed_retry)); // "请求失败,请稍后重试");
            }
          },
        );
      },
    );
  }

  // kline------

  bool loadkline = false;
  List<KLineEntity> data_kline = [];

  void getKlineData(int days) async {
    loadkline = true;
    setState(() {});

    DateTime dt_end = DateTime.now();
    DateTime dt_start = dt_end.subtract(Duration(days: days));
    HttpJsonRes hjr = await ApiWallet.getUniswapEpkKline(dt_start, dt_end);

    // 服务器返回的时间是东8区时间， -8为UTC  再+本地
    int time_offset =
        (-8 + dt_end.timeZoneOffset.inHours) * Duration.secondsPerHour;
    // print("time_offset = $time_offset");

    if (hjr.code == 0 && hjr?.jsonMap?.containsKey("klines") == true) {
      List list = hjr.jsonMap["klines"];
      data_kline = JsonArray.parseList<KLineEntity>(list,
          (json) => KLineEntity.fromJson(json).setTimeOffset(time_offset));
      DataUtil.calculate(data_kline);
    }
    loadkline = false;
    setState(() {});
  }

  Widget getKlineWidget() {
    List<Widget> views = [
      Container(
        height: double.infinity,
        width: double.infinity,
        color: ResColor.b_3,
        child: KChartWidget(
          data_kline,
          isLine: false,
          mainState: MainState.NONE,
          volState: VolState.NONE,
          secondaryState: SecondaryState.NONE,
          fractionDigits: 6,
          infoNames: infoNames,
        ),
      ),
    ];

    if (loadkline) {
      views.add(BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 2, sigmaX: 2),
        child: Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            color: Colors.white10,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: new AlwaysStoppedAnimation<Color>(ResColor.progress),
            )),
      ));
    } else {
      if (data_kline == null || data_kline.length == 0) {
        views.add(
          Align(
            child: Container(
              width: 50,
              height: 50,
              child: FlatButton(
                highlightColor: Colors.white24,
                splashColor: Colors.white24,
                onPressed: () {
                  getKlineData(7);
                },
                child: Icon(
                  Icons.refresh,
                  size: 20,
                  color: color_btn_1,
                ),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  // side:BorderSide(color:Colors.lightBlueAccent[100],width: 0.1 ),
                ),
              ),
            ),
          ),
        );
      } else {
        views.add(
          Align(
            alignment: Alignment.bottomRight,
            child: InkWell(
              onTap: () {
                // getKlineData(7);
                refresh();
              },
              child: Container(
                width: 20,
                height: 20,
                margin: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                child: Icon(
                  Icons.refresh,
                  size: 14,
                  color: color_btn_1,
                ),
              ),
            ),
          ),
        );
      }
    }

    Widget content = Container(
      width: double.infinity,
      height: 200,
      child: Stack(
        children: views,
      ),
    );
    return content;
  }
}
