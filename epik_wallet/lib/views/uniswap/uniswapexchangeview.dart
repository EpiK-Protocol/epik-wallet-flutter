import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/model/CurrencyAsset.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
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
  String text_to = "0.0";
  TextEditingController _tec_from;

  /// 价格 epkerc20/usdt
  double price_epkerc20_usdt = 365.781;

  /// 价格 usdt/epkerc20
  double price_usdt_epkerc20 = 0.00274123;

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
                          //todo
                        },
                        child: Text(
                          "兑换",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        color:color_btn_1,
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

  Color color_btn_1 = Colors.pinkAccent[100];

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
                      ? "余额:${getBalance(cs_from)??"--"}"
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
                        text_from = (getBalance(cs_from)??"").replaceAll(",", "");
                        _tec_from.text=text_from;
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
                      ? "余额:${getBalance(cs_to)??"--"}"
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

    String old_text_from = text_from;
    text_from = text_to;
    text_to = old_text_from;

    _tec_from.text = text_from;

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

  calcToAmount()
  {
    if(widget.walletAccount!=null){
        double amount_from = double.parse(text_from)??0;
        double amount_to = 0;
        if(cs_from == CurrencySymbol.EPKerc20)
        {
          amount_to = amount_from*price_usdt_epkerc20;
        }else{
          amount_to = amount_from*price_epkerc20_usdt;
        }
        text_to = StringUtils.formatNumAmount(amount_to,point: 8,supply0: false).replaceAll(",", "");
        setState(() {
        });
    }
  }

  onInputFrom() {}

  onInputTo() {}
}
