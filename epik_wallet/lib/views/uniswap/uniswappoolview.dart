import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

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
  }

  @override
  void onCreate() {
    super.onCreate();

    eventMgr.add(EventTag.UNISWAP_ADD, eventcallback_add);

    refresh();
  }

  @override
  void dispose() {
    eventMgr.remove(EventTag.UNISWAP_ADD, eventcallback_add);
    super.dispose();
  }

  eventcallback_add(arg) {
    refresh();
  }

  bool loading = false;

  refresh() {
    if (widget.walletAccount != null) {
      setState(() {
        loading = true;
      });

      HdWallet _hdwallet = widget?.walletAccount?.hdwallet;
      _hdwallet
          .uniswapinfo(widget.walletAccount.hd_eth_address)
          .then((uniswapinfo) {
        loading = false;
        if (_hdwallet == widget?.walletAccount?.hdwallet) {
          this.uniswapinfo = uniswapinfo;
          dlog("uniswapinfo ${uniswapinfo.Share}");
        }
        setState(() {});
      });
    }
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
                          "注入流动资金",
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
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "资金池信息",
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 16),
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
                              child: Icon(
                                Icons.refresh,
                                color: Colors.black54,
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
        "请先登录钱包",
        style: TextStyle(
          color: Colors.black54,
          fontSize: 16,
        ),
      );
    } else if (loading) {
      child = Container(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: new AlwaysStoppedAnimation<Color>(color_btn_1),
        ),
      );
    } else if (uniswapinfo == null) {
      child = Text(
        "请求失败",
        style: TextStyle(
          color: Colors.black54,
          fontSize: 16,
        ),
      );
    } else {
      child = Container(
        padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  "池中${CurrencySymbol.EPKerc20.symbol}:",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
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
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            Container(height: 10),
            Row(
              children: <Widget>[
                Text(
                  "池中${CurrencySymbol.USDT.symbol}:",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
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
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            Container(height: 10),
            Row(
              children: <Widget>[
                Text(
                  "您所占份额:",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
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
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            Container(height: 10),
            Row(
              children: <Widget>[
                Text(
                  "最后交易时间:",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
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
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            Container(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    height: 40,
                    child: FlatButton(
                      highlightColor: Colors.white24,
                      splashColor: Colors.white24,
                      onPressed: () {
                        onClickAdd();
                      },
                      child: Text(
                        "注入",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      color: color_btn_2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                    ),
                  ),
                ),
                Container(width: 10),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    height: 40,
                    child: FlatButton(
                      highlightColor: Colors.white24,
                      splashColor: Colors.white24,
                      onPressed: () {
                        onClickRemove();
                      },
                      child: Text(
                        "撤回",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      color: color_btn_2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 130,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        border: Border.all(color: Color(0xffeeeeee), width: 0.7),
      ),
      child: child,
    );
  }

  onClickAdd() {
    if (widget.walletAccount == null) {
      showToast("需要先登录钱包");
      return;
    }

    if (uniswapinfo == null) {
      showToast("缺少资金池信息");
      return;
    }

    ViewGT.showUniswapPoolAddView(context, widget.walletAccount, uniswapinfo);
  }

  onClickRemove() {
    if (widget.walletAccount == null) {
      showToast("需要先登录钱包");
      return;
    }

    // todo test
//    if (uniswapinfo?.Share == "0") {
//      showToast("您没有可撤回的资金");
//      return;
//    }

    ViewGT.showUniswapPoolRemoveView(context, widget.walletAccount,uniswapinfo);
  }
}
