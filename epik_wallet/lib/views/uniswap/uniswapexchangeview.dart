import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/model/CurrencyAsset.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';

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
  CurrencySymbol cs_from = CurrencySymbol.EPKerc20;
  CurrencySymbol cs_to = CurrencySymbol.USDT;

  String text_from = "";
  double amount_form = 0;
  String text_to = "0.0";
  TextEditingController _tec_from;

  Amounts calc_amounts;

  @override
  void initStateConfig() {
    super.initStateConfig();
    bodyBackgroundColor = Colors.transparent;
  }

  @override
  void onCreate() {
    super.onCreate();
    eventMgr.add(EventTag.BALANCE_UPDATE, eventCallback_balance);
  }

  eventCallback_balance(obj) {
    if (obj == widget.walletAccount) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    eventMgr.remove(EventTag.BALANCE_UPDATE, eventCallback_balance);
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(0),
      child: Container(
        constraints: BoxConstraints(
          minHeight: getScreenHeight() -
              BaseFuntion.topbarheight -
              BaseFuntion.appbarheight,
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(20, 30, 20, 0),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                elevation: 10,
                shadowColor: Colors.black26,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    getFrom(),
                    InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      onTap: () {
                        changeCurrency();
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        child: Icon(Icons.swap_vert),
                      ),
                    ),
                    getTo(),
                    Container(
                      margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
                      width: double.infinity,
                      height: 40,
                      child: FlatButton(
                        highlightColor: Colors.white24,
                        splashColor: Colors.white24,
                        onPressed: () {
                          onClickExchange();
                        },
                        child: Text(
                          "兑换",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        color: color_btn_1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color color_btn_1 = ResColor.main_1;//Colors.pinkAccent[100];

  Widget getFrom() {
    if (_tec_from == null)
      _tec_from = new TextEditingController(text: text_from);

    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        border: Border.all(color: Color(0xffeeeeee), width: 0.7),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "From",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  (widget.walletAccount != null)
                      ? "余额:${getBalance(cs_from) ?? "--"}"
                      : "",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
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
                        contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        hintText: "0.0",
                        hintStyle:
                            TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                      cursorWidth: 2.0,
                      //光标宽度
                      cursorRadius: Radius.circular(2),
                      //光标圆角弧度
                      cursorColor: Colors.black,
                      //光标颜色
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      onChanged: (value) {
                        text_from = _tec_from.text.trim();
                        amount_form = StringUtils.parseDouble(text_from, 0);
                      },
                    ),
                  ),
                ),
                Container(
                  width: 35,
                  height: 22,
                  child: OutlineButton(
                    padding: EdgeInsets.all(0),
                    highlightColor: color_btn_1.withOpacity(0.1),
                    splashColor: Colors.white24,
                    onPressed: () {
                      setState(() {
                        text_from =
                            (getBalance(cs_from) ?? "").replaceAll(",", "");
                        _tec_from.text = text_from;
                      });
                    },
                    child: Text(
                      "全部",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: color_btn_1,
                        fontSize: 12,
                      ),
                    ),
                    borderSide: BorderSide(color: color_btn_1),
                    highlightedBorderColor: color_btn_1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
                Container(
                  width: 5,
                ),
                Image(
                  image: AssetImage(cs_from.iconUrl),
                  width: 30,
                  height: 30,
                ),
                Container(
                  width: 5,
                ),
                Text(
                  cs_from.symbol,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getTo() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        border: Border.all(color: Color(0xffeeeeee), width: 0.7),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "To",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  (widget.walletAccount != null)
                      ? "余额:${getBalance(cs_to) ?? "--"}"
                      : "",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                    child: Text(
                      text_to,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ),
                Container(
                  width: 35,
                  height: 22,
                  child: OutlineButton(
                    padding: EdgeInsets.all(0),
                    highlightColor: color_btn_1.withOpacity(0.1),
                    splashColor: Colors.white24,
                    onPressed: () {
                      calcToAmount();
                    },
                    child: Text(
                      "预估",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: color_btn_1,
                        fontSize: 12,
                      ),
                    ),
                    borderSide: BorderSide(color: color_btn_1),
                    highlightedBorderColor: color_btn_1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
                Container(
                  width: 5,
                ),
                Image(
                  image: AssetImage(cs_to.iconUrl),
                  width: 30,
                  height: 30,
                ),
                Container(
                  width: 5,
                ),
                Text(
                  cs_to.symbol,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
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

    setState(() {});
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
      eventMgr.send(EventTag.CHANGE_MAINVIEW_INDEX, 1);
      return;
    }

    if (StringUtils.isEmpty(text_from)) {
      showToast("请输入${cs_from.symbol}数量");
      return;
    }

    if (amount_form == 0) {
      showToast("${cs_from.symbol}数量不能为0");
      return;
    }

    closeInput();
    showLoadDialog("", onShow: () async {
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
          });
        }
      } else {
        showToast("请求失败,请稍后重试");
      }
      closeLoadDialog();
    });
  }

  onInputFrom() {}

  onInputTo() {}

  onClickExchange() {
    if (widget?.walletAccount?.hdwallet == null) {
      eventMgr.send(EventTag.CHANGE_MAINVIEW_INDEX, 1);
      return;
    }

    if (StringUtils.isEmpty(text_from)) {
      showToast("请输入${cs_from.symbol}数量");
      return;
    }

    if (amount_form == 0) {
      showToast("${cs_from.symbol}数量不能为0");
      return;
    }

    if (calc_amounts == null || calc_amounts.AmountIn_d != amount_form) {
      showToast("需要先计算预估");
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

        showLoadDialog("正在提交兑换", onShow: () async {
          String ret =
              await widget.walletAccount.hdwallet.uniswapExactTokenForTokens(
            widget.walletAccount.hd_eth_address, //地址
            cs_from.symbolToNetWork, // from币种
            cs_to.symbolToNetWork, // to币种
            text_from.trim(), // from数量
            "${calc_amounts.AmountOut_d * 0.9}", // , // to 期望兑换到的最少数量
            "${DateTime.now().toUtc().millisecondsSinceEpoch / 1000 + 20 * 60}", // 最晚成交时间 时间戳 秒
          );

          // ret = 0xe966bbd1e089becc1d0d23bf8ae145ba3b25ad9b482dbd22b6368bca239e35e2
          print("uniswapExactTokenForTokens $ret");
//        showToast("请求失败,请稍后重试");
          closeLoadDialog();

          if (StringUtils.isNotEmpty(ret)) {

            setState(() {
              text_from="";
              _tec_from.text="";
              amount_form=0;
              text_to = "0.0";
            });

            DeviceUtils.copyText(ret);

            MessageDialog.showMsgDialog(
              context,
              title: "兑换已提交",
              msg: ret+"\n已复制",
              btnRight: "确定",
              onClickBtnRight: (dialog) {
                dialog.dismiss();
              },
            );
          } else {
            showToast("请求失败,请稍后重试");
          }
        });
      },
    );
  }
}
