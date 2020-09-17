import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/UniswapHistoryMgr.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class UniswapPoolRemoveView extends BaseWidget {
  WalletAccount walletAccount;
  UniswapInfo uniswapinfo;

  UniswapPoolRemoveView(this.walletAccount, this.uniswapinfo);

  BaseWidgetState<BaseWidget> getState() {
    return UniswapPoolRemoveViewState();
  }
}

class UniswapPoolRemoveViewState
    extends BaseWidgetState<UniswapPoolRemoveView> {
  static Color color_btn_1 = ResColor.main_1; //Colors.pinkAccent[100];
  static Color color_btn_2 =
      color_btn_1.withOpacity(0.5); //Colors.pinkAccent[100];

  CurrencySymbol cs_A, cs_B;
  double amount_ratio = 0;
  double amount_A=0;
  double amount_B=0;

  double price_changes = 0.1;

  @override
  void initStateConfig() {
    cs_A = CurrencySymbol.EPKerc20;
    cs_B = CurrencySymbol.USDT;

    setAppBarTitle("撤回流动资金");
    print(widget.uniswapinfo.price_EPK_USDT);
    print(widget.uniswapinfo.price_USDT_EPK);

    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);
    isTopFloatWidgetShow = true;
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
    List<Widget> views = [
      Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        alignment: Alignment.centerLeft,
        child: Row(
          children: <Widget>[
            Text(
              "撤回金额",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        alignment: Alignment.center,
        child: Text(
          "${StringUtils.formatNumAmount(amount_ratio * 100, point: 2, supply0: false)}%",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 50,
            fontFamily: "DIN_Condensed_Bold",
          ),
        ),
      ),
      Container(
        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
        width: double.infinity,
        child: Slider(
          value: amount_ratio,
          // 当前滑块定位到的值
          label:
              '${StringUtils.formatNumAmount(amount_ratio * 100, point: 2, supply0: false)}%',
          onChanged: (val) {
            // 滑动监听
            setState(() {
              amount_ratio = val;
              calcAmount();
            });
          },
          onChangeStart: (val) {},
          onChangeEnd: (val) {},
          min: 0,
          max: 1,
          activeColor: color_btn_1,
          inactiveColor: color_btn_2,
        ),
      ),
      Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [0.25, 0.50, 0.75, 1.0].map((item) {
            return Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              height: 30,
              width: 50,
              child: FlatButton(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                highlightColor: Colors.white24,
                splashColor: Colors.white24,
                onPressed: () {
                  setState(() {
                    amount_ratio = item;
                    calcAmount();
                  });
                },
                child: Text(
                  "${StringUtils.formatNumAmount(item * 100, point: 0, supply0: false)}%",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                color: color_btn_1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      Container(
        width: 50,
        height: 50,
        child: Icon(Icons.arrow_downward),
      ),
      Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
        padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          border: Border.all(color: Color(0xffeeeeee), width: 0.7),
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    StringUtils.formatNumAmount(
                        amount_A,
                        point: 8,
                        supply0: false),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  "${cs_A.symbol}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Container(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    StringUtils.formatNumAmount(
                        amount_B,
                        point: 8,
                        supply0: false),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  "${cs_B.symbol}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
        child:  Text(
          "手续费 : ${widget.walletAccount.eth_suggestGas} eth",
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
            onClickRemove();
          },
          child: Text(
            "确定撤回",
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
    ];

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
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(0),
        child: Container(
          constraints: BoxConstraints(
            minHeight: getScreenHeight() -
                BaseFuntion.topbarheight -
                BaseFuntion.appbarheight_def,
          ),
          child: Column(children: [
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
                  children: views,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  calcAmount()
  {
    amount_A = widget.uniswapinfo.epk_d*widget.uniswapinfo.share_d*amount_ratio;
    amount_B = widget.uniswapinfo.usdt_d*widget.uniswapinfo.share_d*amount_ratio;
  }

  onClickRemove()
  {
    if(amount_A==0 || amount_B==0 || amount_ratio==0)
    {
      showToast("请选择要撤回的数量");
      return;
    }

    BottomDialog.showPassWordInputDialog(context, widget.walletAccount.password, (value) async{

      await Future.delayed(Duration(milliseconds: 200));

      showLoadDialog("正在提交",touchOutClose: false,backClose: false,onShow: ()async{

        String liquidity = StringUtils.formatNumAmount(widget.uniswapinfo.uni_d*amount_ratio,point: 20,supply0: false).replaceAll(",", "");
        String amountAMin= StringUtils.formatNumAmount(amount_A*(1-price_changes),point: 8,supply0: false).replaceAll(",", "");
        String amountBMin= StringUtils.formatNumAmount(amount_B*(1-price_changes),point: 8,supply0: false).replaceAll(",", "");
        String deadline = "${DateTime.now().toUtc().millisecondsSinceEpoch / 1000 + 20 * 60}";

// test
//        dlog("uniswapRemoveLiquidity amountAMin=$amountAMin amountBMin=$amountBMin liquidity=$liquidity");
//        dlog("uniswapRemoveLiquidity widget.uniswapinfo.uni_d=${widget.uniswapinfo.uni_d} amount_ratio=${amount_ratio}");
//        closeLoadDialog();
//        return;

        String ret = await widget.walletAccount.hdwallet.uniswapRemoveLiquidity(widget.walletAccount.hd_eth_address, cs_A.symbolToNetWork, cs_B.symbolToNetWork, liquidity, amountAMin, amountBMin, deadline);

        dlog("uniswapRemoveLiquidity $ret");
        closeLoadDialog();

        if (StringUtils.isNotEmpty(ret)) {

          DeviceUtils.copyText(ret);

          widget?.walletAccount?.uhMgr?.addOrder(UniswapOrder(
            hash: ret,
            state:0,// 等待
            type:2,//  撤回
            time:DateTime.now().toUtc().millisecondsSinceEpoch,///utc时间 毫秒
            token_a:cs_A.symbol,
            token_b:cs_B.symbol,
            amount_a:StringUtils.formatNumAmount(amount_A,point: 8,supply0: false).replaceAll(",", ""),
            amount_b:StringUtils.formatNumAmount(amount_B,point: 8,supply0: false).replaceAll(",", ""),
          ));
          widget?.walletAccount?.uhMgr?.save();

          MessageDialog.showMsgDialog(
            context,
            title: "撤回资金",
            msg: "已提交到以太坊\n稍后可在交易记录中查询结果",
            msgAlign: TextAlign.center,
            btnRight: "确定",
            onClickBtnRight: (dialog) async {
              dialog.dismiss();
              eventMgr.send(EventTag.UNISWAP_REMOVE,null);
              await Future.delayed(Duration(milliseconds: 200));
              finish();
            },
          );
        } else {
          showToast("请求失败,请稍后重试");
        }
      });

    });
  }
}
