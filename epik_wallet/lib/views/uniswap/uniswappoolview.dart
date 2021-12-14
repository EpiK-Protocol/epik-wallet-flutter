import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:epikwallet/localstring/resstringid.dart';

class UniswapPoolView extends BaseInnerWidget {
  // 可能是空
  WalletAccount walletAccount;

  UniswapPoolView(this.walletAccount);

  @override
  BaseInnerWidgetState<BaseInnerWidget> getState() {
    return UniswapPoolViewState();
  }

  @override
  int setIndex() {
    return 0;
  }
}

class UniswapPoolViewState extends BaseInnerWidgetState<UniswapPoolView> {
  UniswapInfo uniswapinfo;

  static Color color_btn_1 = ResColor.main_1; //Colors.pinkAccent[100];

  static Color color_btn_2 = color_btn_1.withOpacity(1);

  @override
  void initStateConfig() {
    super.initStateConfig();
    bodyBackgroundColor = Colors.transparent;

    setAppBarHeight(60);
  }

  @override
  void onCreate() {
    super.onCreate();

    eventMgr.add(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventcallback_account);
    eventMgr.add(EventTag.UNISWAP_ADD, eventcallback_add_remove);
    eventMgr.add(EventTag.UNISWAP_REMOVE, eventcallback_add_remove);
    eventMgr.add(EventTag.UPLOAD_UNISWAPINFO, eventcallback_uniswapinfo);

    refresh();
  }

  @override
  void dispose() {
    eventMgr.remove(
        EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventcallback_account);
    eventMgr.remove(EventTag.UNISWAP_ADD, eventcallback_add_remove);
    eventMgr.remove(EventTag.UNISWAP_REMOVE, eventcallback_add_remove);
    eventMgr.remove(EventTag.UPLOAD_UNISWAPINFO, eventcallback_uniswapinfo);
    super.dispose();
  }

  eventcallback_account(arg) async {
    await Future.delayed(Duration(milliseconds: 1000));
    refresh();
  }

  eventcallback_add_remove(arg) {
    refresh();
  }

  eventcallback_uniswapinfo(arg) {
    loading = false;
    this.uniswapinfo = arg;
    dlog("uniswapinfo share=${uniswapinfo?.Share} UNI=${uniswapinfo?.UNI}");
    setState(() {});
  }

  bool loading = false;

  refresh() {
    dlog("refresh walletAccount=${widget.walletAccount.account}");

    if (loading) return;

    if (widget.walletAccount != null) {
      setState(() {
        loading = true;
      });

//      HdWallet _hdwallet = widget?.walletAccount?.hdwallet;
//      _hdwallet
//          .uniswapinfo(widget.walletAccount.hd_eth_address)
//          .then((uniswapinfo) {
//        loading = false;
//        if (_hdwallet == widget?.walletAccount?.hdwallet) {
//          this.uniswapinfo = uniswapinfo;
//          dlog("uniswapinfo share=${uniswapinfo.Share} UNI=${uniswapinfo.UNI}");
//        }
//        setState(() {});
//      });
      widget.walletAccount.uploadUniswapInfo();
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(0),
      child: Container(
        constraints: BoxConstraints(
          minHeight: getScreenHeight(), //- BaseFuntion.topbarheight - BaseFuntion.appbarheight_def,
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(30, 45, 30, 0),
              padding: EdgeInsets.fromLTRB(20, 15, 20, 25),
              decoration: BoxDecoration(
                color: ResColor.b_3,
                borderRadius:BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            ResString.get(context, RSID.uspv_2), //"资金池信息",
                            style: TextStyle(
                                color: Colors.white, fontSize: 17),
                          ),
                        ),
                        InkWell(
                          borderRadius:
                          BorderRadius.all(Radius.circular(15.0)),
                          onTap: () {
                            refresh();
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            padding: EdgeInsets.fromLTRB(5, 5, 7,7),
                            child: Icon(
                              Icons.refresh_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  getUserLiquidity(),
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
  }

  Widget getUserLiquidity() {
    Widget child = null;
    if (widget.walletAccount == null) {
      child = Text(
        ResString.get(context, RSID.uspv_4), //"请先登录钱包",
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
        ),
      );
    } else if (loading) {
      child = Container(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: new AlwaysStoppedAnimation<Color>(ResColor.progress),
        ),
      );
    } else if (uniswapinfo == null) {
      child = Text(
        ResString.get(context, RSID.request_failed), //"请求失败",
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
        ),
      );
    } else {
      child = Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  ResString.get(context, RSID.uspv_5,
                      replace: [CurrencySymbol.EPKerc20.symbol]),
                  //"池中${CurrencySymbol.EPKerc20.symbol}:",
                  style: TextStyle(
                    color: ResColor.white_60,
                    fontSize: 14,
                  ),
                ),
                Expanded(
                  child: Text(
                    StringUtils.formatNumAmount(
                        StringUtils.parseDouble(uniswapinfo.EPK, 0),
                        point: 8,
                        supply0: false),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            Container(height: 7),
            Row(
              children: <Widget>[
                Text(
                  ResString.get(context, RSID.uspv_5,
                      replace: [CurrencySymbol.USDT.symbol]),
                  //"池中${CurrencySymbol.USDT.symbol}:",
                  style: TextStyle(
                    color: ResColor.white_60,
                    fontSize: 14,
                  ),
                ),
                Expanded(
                  child: Text(
                    StringUtils.formatNumAmount(
                        StringUtils.parseDouble(uniswapinfo.USDT, 0),
                        point: 8,
                        supply0: false),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            Container(height: 7),
            Row(
              children: <Widget>[
                Text(
                  ResString.get(context, RSID.uspv_6), //"您所占份额:",
                  style: TextStyle(
                    color: ResColor.white_60,
                    fontSize: 14,
                  ),
                ),
                Expanded(
                  child: Text(
                    StringUtils.formatNumAmount(
                            StringUtils.parseDouble(uniswapinfo.Share, 0) * 100,
                            point: 8,
                            supply0: false) +
                        "%",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            Container(height: 7),
            Row(
              children: <Widget>[
                Text(
                  ResString.get(context, RSID.uspv_7), //"最后交易时间:",
                  style: TextStyle(
                    color: ResColor.white_60,
                    fontSize: 14,
                  ),
                ),
                Expanded(
                  child: Text(
                    DateUtil.formatDate(
                        DateTime.fromMillisecondsSinceEpoch(
                                uniswapinfo.LastBlockTime,
                                isUtc: true)
                            .toLocal(),
                        format: DataFormats.full),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            Container(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child : LoadingButton(
                    height: 40,
                    width: null,
                    bg_borderradius: BorderRadius.circular(4),
                    gradient_bg: ResColor.lg_2,
                    color_bg: Colors.transparent,
                    disabledColor: Colors.transparent,
                    text: RSID.uspv_8.text, //"注入",
                    textstyle: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                    onclick: (lbtn) {
                      onClickAdd();
                    },
                  ),
                ),
                Container(width: 10),
                Expanded(
                  // child: Container(
                  //   margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  //   height: 40,
                  //   child: FlatButton(
                  //     highlightColor: Colors.white24,
                  //     splashColor: Colors.white24,
                  //     onPressed: () {
                  //       onClickRemove();
                  //     },
                  //     child: Text(
                  //       ResString.get(context, RSID.uspv_9), //"撤回",
                  //       textAlign: TextAlign.center,
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 16,
                  //       ),
                  //     ),
                  //     color: color_btn_2,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.all(Radius.circular(6)),
                  //     ),
                  //   ),
                  // ),
                  child : LoadingButton(
                    height: 40,
                    width: null,
                    bg_borderradius: BorderRadius.circular(4),
                    gradient_bg: ResColor.lg_5,
                    color_bg: Colors.transparent,
                    disabledColor: Colors.transparent,
                    text: RSID.uspv_9.text, //"撤回",
                    textstyle: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                    onclick: (lbtn) {
                      onClickRemove();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 157,
      ),
      alignment: Alignment.center,
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.all(Radius.circular(15.0)),
      //   border: Border.all(color: Color(0xffeeeeee), width: 0.7),
      // ),
      child: child,
    );
  }

  onClickAdd() {
    if (widget.walletAccount == null) {
      showToast(ResString.get(context, RSID.uspv_10)); //"需要先登录钱包");
      return;
    }

    if (uniswapinfo == null) {
      showToast(ResString.get(context, RSID.uspv_11)); //"缺少资金池信息");
      return;
    }

    ViewGT.showUniswapPoolAddView(context, widget.walletAccount, uniswapinfo);
  }

  onClickRemove() {
    if (widget.walletAccount == null) {
      showToast(ResString.get(context, RSID.uspv_10)); //"需要先登录钱包");
      return;
    }

    if (uniswapinfo?.Share == "0") {
      showToast(ResString.get(context, RSID.uspv_12)); //"您没有可撤回的资金");
      return;
    }

    ViewGT.showUniswapPoolRemoveView(
        context, widget.walletAccount, uniswapinfo);
  }

  onClickReadme() {
//    final String address = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    final String address = "0xDaF88906aC1DE12bA2b1D2f7bfC94E9638Ac40c4";

    final TapGestureRecognizer recognizer_1 = TapGestureRecognizer();
    final TapGestureRecognizer recognizer_2 = TapGestureRecognizer();

    final YYDialog yydialog = MessageDialog.showMsgDialog(
      context,
      title: ResString.get(context, RSID.uspv_13), //"EpiK提醒您",
      btnRight: ResString.get(context, RSID.isee), // "知道了",
      onClickBtnRight: (dialog) {
        dialog.dismiss();
      },
      extend: Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: RichText(
          text: TextSpan(
            text: ResString.get(context, RSID.uspv_15_1),
            // "「1」本页资金池交易是基于Uniswap的ERC20-EPK与USDT的流动性支持\n\n「2」底层部署在以太坊公链上，兑换及资金池操作均会产生ETH手续费，操作前请确保钱包有足够的ETH。\n\n「3」官方智能合约地址为：",
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
                text:
                    ResString.get(context, RSID.uspv_15_2), // "\n\n「4」新手操作说明请点击",
              ),
              TextSpan(
                text: ResString.get(context, RSID.uspv_15_3), //"这里",
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
      ViewGT.showGeneralWebView(
        context,
        ResString.get(context, RSID.uspv_14), //"合约",
        "https://cn.etherscan.com/address/${address}",
      );
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
}
