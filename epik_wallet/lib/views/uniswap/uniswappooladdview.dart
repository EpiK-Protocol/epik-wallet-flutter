import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/UniswapHistoryMgr.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/widget/DashLineWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';

class UniswapPoolAddView extends BaseWidget {
  WalletAccount walletAccount;
  UniswapInfo uniswapinfo;

  UniswapPoolAddView(this.walletAccount, this.uniswapinfo);

  BaseWidgetState<BaseWidget> getState() {
    return UniswapPoolAddViewState();
  }
}

class UniswapPoolAddViewState extends BaseWidgetState<UniswapPoolAddView> {
  Color color_btn_1 = ResColor.main_1; //Colors.pinkAccent[100];

  CurrencySymbol cs_A, cs_B;

  String text_A = "";
  String text_B = "";
  double amount_A = 0;
  double amount_B = 0;
  TextEditingController _tec_A, _tec_B;

  double price_changes = 0.1;

  ///价格波动 10%

  @override
  void initStateConfig() {
    cs_A = CurrencySymbol.EPKerc20;
    cs_B = CurrencySymbol.USDT;

//    setAppBarTitle("注入流动资金");
    print(widget.uniswapinfo.price_EPK_USDT);
    print(widget.uniswapinfo.price_USDT_EPK);

    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);
    isTopFloatWidgetShow = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(ResString.get(context, RSID.uspv_1));
  }

  @override
  Widget getTopFloatWidget() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Column(
        children: <Widget>[
          getTopBar(),
          getAppBar(),
        ],
      ),
    );
  }

  Widget buildWidget(BuildContext context) {
    if (_tec_A == null) _tec_A = new TextEditingController(text: text_A);
    if (_tec_B == null) _tec_B = new TextEditingController(text: text_B);

    Widget child = SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(0),
      child: Container(
        constraints: BoxConstraints(
          minHeight: getScreenHeight() -
              BaseFuntion.topbarheight -
              BaseFuntion.appbarheight_def,
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
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                              child: TextField(
                                controller: _tec_A,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                maxLines: 1,
                                maxLengthEnforced: true,
                                obscureText: false,
                                inputFormatters: [
                                  WhitelistingTextInputFormatter(
                                      RegExpUtil.re_float)
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
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  hintText: "0.0",
                                  hintStyle: TextStyle(
                                      color: Colors.black54, fontSize: 16),
                                ),
                                cursorWidth: 2.0,
                                //光标宽度
                                cursorRadius: Radius.circular(2),
                                //光标圆角弧度
                                cursorColor: Colors.black,
                                //光标颜色
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black87),
                                onChanged: (value) {
                                  text_A = _tec_A.text.trim();
                                  amount_A = StringUtils.parseDouble(text_A, 0);
                                  onInputA();
                                },
                              ),
                            ),
                          ),
                          Container(
                            width: 5,
                          ),
                          Text(
                            cs_A.symbol,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.black54,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                              child: TextField(
                                controller: _tec_B,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                maxLines: 1,
                                maxLengthEnforced: true,
                                obscureText: false,
                                inputFormatters: [
                                  WhitelistingTextInputFormatter(
                                      RegExpUtil.re_float)
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
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  hintText: "0.0",
                                  hintStyle: TextStyle(
                                      color: Colors.black54, fontSize: 16),
                                ),
                                cursorWidth: 2.0,
                                //光标宽度
                                cursorRadius: Radius.circular(2),
                                //光标圆角弧度
                                cursorColor: Colors.black,
                                //光标颜色
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black87),
                                onChanged: (value) {
                                  text_B = _tec_B.text.trim();
                                  amount_B = StringUtils.parseDouble(text_B, 0);
                                  onInputB();
                                },
                              ),
                            ),
                          ),
                          Container(
                            width: 5,
                          ),
                          Text(
                            cs_B.symbol,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Text(
                        ResString.get(context, RSID.uspav_1, replace: [
                          StringUtils.formatNumAmount(price_changes * 100,
                              point: 2, supply0: false)
                        ]),
                        //"当前为预估价格，如果价格波动超过${StringUtils.formatNumAmount(price_changes * 100, point: 2, supply0: false)}%，您的交易将会撤销。",
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    DashLineWidget(
                      width: double.infinity,
                      height: 1,
                      dashWidth: 10,
                      dashHeight: 0.5,
                      spaceWidth: 5,
                      color: color_btn_1,
                      margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Text(
                        ResString.get(context, RSID.uspav_2,
                            replace: [widget.walletAccount.eth_suggestGas]),
//                        "手续费 : ${widget.walletAccount.eth_suggestGas} eth",

                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(20, 5, 20, 0),
                      child: Text(
                        "1 ${cs_A.symbol} = ${StringUtils.formatNumAmount(widget.uniswapinfo.price_USDT_EPK, point: 8, supply0: false)} ${cs_B.symbol}",
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(20, 5, 20, 0),
                      child: Text(
                        "1 ${cs_B.symbol} = ${StringUtils.formatNumAmount(widget.uniswapinfo.price_EPK_USDT, point: 8, supply0: false)} ${cs_A.symbol}",
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
                      width: double.infinity,
                      height: 40,
                      child: FlatButton(
                        highlightColor: Colors.white24,
                        splashColor: Colors.white24,
                        onPressed: () {
                          onClickAdd();
                        },
                        child: Text(
                          ResString.get(context, RSID.uspav_3), //"确定注入",
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

    return Container(
      padding: EdgeInsets.fromLTRB(
          0, BaseFuntion.topbarheight + BaseFuntion.appbarheight_def, 0, 0),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Color(0xfff7e6f0),
            Colors.white,
          ],
          center: Alignment.center,
          radius: 1,
          tileMode: TileMode.clamp,
        ),
      ),
      child: child,
    );
  }

  onInputA() {
    amount_B = amount_A * widget.uniswapinfo.price_USDT_EPK;
    text_B = StringUtils.formatNumAmount(amount_B, point: 8, supply0: false)
        .replaceAll(",", "");
    _tec_B.text = text_B;
  }

  onInputB() {
    amount_A = amount_B * widget.uniswapinfo.price_EPK_USDT;
    text_A = StringUtils.formatNumAmount(amount_A, point: 8, supply0: false)
        .replaceAll(",", "");
    _tec_A.text = text_A;
  }

  onClickAdd() {
    if (amount_A == 0 || amount_B == 0) {
      showToast(ResString.get(context, RSID.uspav_4)); //"请输入数量");
      return;
    }

    closeInput();

    BottomDialog.showPassWordInputDialog(context, widget.walletAccount.password,
        (value) async {
      await Future.delayed(Duration(milliseconds: 200));

      showLoadDialog(
        ResString.get(context, RSID.uspav_5),//"正在提交",
        touchOutClose: false,
        backClose: false,
        onShow: () async {
          String amountAMin = StringUtils.formatNumAmount(
                  amount_A * (1 - price_changes),
                  point: 8,
                  supply0: false)
              .replaceAll(",", "");
          String amountBMin = StringUtils.formatNumAmount(
                  amount_B * (1 - price_changes),
                  point: 8,
                  supply0: false)
              .replaceAll(",", "");
          String deadline =
              "${DateTime.now().toUtc().millisecondsSinceEpoch / 1000 + 20 * 60}";
          ResultObj<String> ret = await widget.walletAccount.hdwallet
              .uniswapAddLiquidity(
                  widget.walletAccount.hd_eth_address,
                  cs_A.symbolToNetWork,
                  cs_B.symbolToNetWork,
                  text_A,
                  text_B,
                  amountAMin,
                  amountBMin,
                  deadline);

          dlog("uniswapAddLiquidity ${ret?.data}");
          closeLoadDialog();

          if (StringUtils.isNotEmpty(ret?.data)) {
//         DeviceUtils.copyText(ret);

            widget?.walletAccount?.uhMgr?.addOrder(UniswapOrder(
              hash: ret?.data,
              state: 0,
              // 等待
              type: 1,
              //  注入
              time: DateTime.now().toUtc().millisecondsSinceEpoch,

              ///utc时间 毫秒
              token_a: cs_A.symbol,
              token_b: cs_B.symbol,
              amount_a: text_A,
              amount_b: text_B,
            ));
            widget?.walletAccount?.uhMgr?.save();

            setState(() {
              amount_B = 0;
              text_B = "0";
              _tec_B.text = text_B;
              amount_A = 0;
              text_A = "0";
              _tec_A.text = text_A;
            });

            MessageDialog.showMsgDialog(
              context,
              title:ResString.get(context, RSID.uspav_6),// "注入资金",
              msg: ResString.get(context, RSID.usev_12),//"已提交到以太坊\n稍后可在交易记录中查询结果",
              msgAlign: TextAlign.center,
              btnRight:ResString.get(context, RSID.confirm),// "确定",
              onClickBtnRight: (dialog) async {
                dialog.dismiss();
                eventMgr.send(EventTag.UNISWAP_ADD, null);
                await Future.delayed(Duration(milliseconds: 200));
                finish();
              },
            );
          } else {
            showToast(ret?.errorMsg ?? ResString.get(context, RSID.request_failed_retry));//"请求失败,请稍后重试");
          }
        },
      );
    });
  }
}
