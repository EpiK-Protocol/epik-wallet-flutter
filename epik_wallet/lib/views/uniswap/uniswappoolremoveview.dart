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
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
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
  double amount_A = 0;
  double amount_B = 0;

  double price_changes = 0.1;

  @override
  void initStateConfig() {
    cs_A = CurrencySymbol.EPKerc20;
    cs_B = CurrencySymbol.USDT;

//    setAppBarTitle("撤回流动资金");
    print(widget.uniswapinfo.price_EPK_USDT);
    print(widget.uniswapinfo.price_USDT_EPK);

    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);
    isTopFloatWidgetShow = true;
    resizeToAvoidBottomPadding = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(ResString.get(context, RSID.usprv_1));
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
      // Container(
      //   padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      //   alignment: Alignment.centerLeft,
      //   child: Row(
      //     children: <Widget>[
      //       Text(
      //         ResString.get(context, RSID.usprv_2), //"撤回金额",
      //         style: TextStyle(
      //           color: Colors.white,
      //           fontSize: 17,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      Container(
        padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
        alignment: Alignment.center,
        child: Text(
          "${StringUtils.formatNumAmount(amount_ratio * 100, point: 2, supply0: false)}%",
          style: TextStyle(
            color:ResColor.o_1,// Colors.white,
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
          activeColor: ResColor.o_1,
          inactiveColor: ResColor.white,
        ),
      ),
      Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [0.25, 0.50, 0.75, 1.0].map((item) {
            return LoadingButton(
                height: 20,
                width: 40,
              bg_borderradius: BorderRadius.circular(4),
              // gradient_bg: ResColor.lg_1,
              color_bg: Colors.transparent,
              disabledColor: Colors.transparent,
              side: BorderSide(color: ResColor.o_1,width: 1),
              text: "${StringUtils.formatNumAmount(item * 100, point: 0, supply0: false)}%",
              textstyle: TextStyle(
                color: ResColor.o_1,
                fontSize: 11,
              ),
              onclick: (lbtn) {
                  setState(() {
                    amount_ratio = item;
                    calcAmount();
                  });
              },
            );

          }).toList(),
        ),
      ),
      Container(
        width: 50,
        height: 50,
        child: Icon(Icons.arrow_downward,color: ResColor.o_1,),
      ),
      Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
        // padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
        width: double.infinity,
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.all(Radius.circular(15.0)),
        //   border: Border.all(color: Color(0xffeeeeee), width: 0.7),
        // ),
        child: Column(
          children: <Widget>[
            Row(
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
                          image: AssetImage(cs_A.iconUrl),
                          width: 30,
                          height: 30,
                        ),
                      ),
                      Positioned(
                          right: -1.5,
                          bottom: -1.5,
                          child: Image(
                            image: AssetImage(cs_A.networkType.iconUrl),
                            width: 13,
                            height: 13,
                          )),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    StringUtils.formatNumAmount(amount_A,
                        point: 8, supply0: false),
                    style: TextStyle(
                      color: ResColor.white,
                      fontSize: 17,
                    ),
                  ),
                ),
                Text(
                  "${cs_A.symbol}",
                  style: TextStyle(
                    color: ResColor.white_60,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            Container(height: 8),
            Divider(
              height: 1,
              thickness: 1,
              indent: 0,
              endIndent: 0,
              color: ResColor.white_20,
            ),
            Container(height: 20),
            Row(
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
                          image: AssetImage(cs_B.iconUrl),
                          width: 30,
                          height: 30,
                        ),
                      ),
                      Positioned(
                          right: -1.5,
                          bottom: -1.5,
                          child: Image(
                            image: AssetImage(cs_B.networkType.iconUrl),
                            width: 13,
                            height: 13,
                          )),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    StringUtils.formatNumAmount(amount_B,
                        point: 8, supply0: false),
                    style: TextStyle(
                      color: ResColor.white,
                      fontSize: 17,
                    ),
                  ),
                ),
                Text(
                  "${cs_B.symbol}",
                  style: TextStyle(
                    color: ResColor.white_60,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            Container(height: 8),
            Divider(
              height: 1,
              thickness: 1,
              indent: 0,
              endIndent: 0,
              color: ResColor.white_20,
            ),
          ],
        ),
      ),
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
              "${widget.walletAccount.eth_suggestGas}"+ " ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            Text(
              "ETH", //手续费改为
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
        height: 40,
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(20, 20, 20, 40),
        bg_borderradius: BorderRadius.circular(4),
        gradient_bg: ResColor.lg_1,
        color_bg: Colors.transparent,
        disabledColor: Colors.transparent,
        text: RSID.usprv_3.text, //"确定撤回",
        textstyle: TextStyle(
          color: Colors.white,
          fontSize: 17,
        ),
        onclick: (lbtn) {
          onClickRemove();
        },
      ),

    ];

    Widget child = SingleChildScrollView(
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
            decoration: BoxDecoration(
              color:ResColor.b_3,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: Column(
              children: views,
            ),
          ),
        ]),
      ),
    );


    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // header card
          Container(
            width: double.infinity,
            height: getAppBarHeight() +
                getTopBarHeight() +
                128,
            padding: EdgeInsets.only(top: getTopBarHeight()),
            decoration: BoxDecoration(
              gradient: ResColor.lg_1,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                getAppBar(),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: getAppBarHeight() + getTopBarHeight(),
            bottom: 0,
            child: child,
          ),
        ],
      ),
    );
  }

  calcAmount() {
    amount_A =
        widget.uniswapinfo.epk_d * widget.uniswapinfo.share_d * amount_ratio;
    amount_B =
        widget.uniswapinfo.usdt_d * widget.uniswapinfo.share_d * amount_ratio;
  }

  onClickRemove() {
    if (amount_A == 0 || amount_B == 0 || amount_ratio == 0) {
      showToast(ResString.get(context, RSID.usprv_4)); //("请选择要撤回的数量");
      return;
    }

    BottomDialog.showPassWordInputDialog(context, widget.walletAccount.password,
        (value) async {
      await Future.delayed(Duration(milliseconds: 200));

      showLoadDialog(
        ResString.get(context, RSID.uspav_5),//"正在提交",
        touchOutClose: false,
        backClose: false,
        onShow: () async {
          String liquidity = StringUtils.formatNumAmount(
                  widget.uniswapinfo.uni_d * amount_ratio,
                  point: 20,
                  supply0: false)
              .replaceAll(",", "");
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

// test
//        dlog("uniswapRemoveLiquidity amountAMin=$amountAMin amountBMin=$amountBMin liquidity=$liquidity");
//        dlog("uniswapRemoveLiquidity widget.uniswapinfo.uni_d=${widget.uniswapinfo.uni_d} amount_ratio=${amount_ratio}");
//        closeLoadDialog();
//        return;

          ResultObj<String> ret = await widget.walletAccount.hdwallet
              .uniswapRemoveLiquidity(
                  widget.walletAccount.hd_eth_address,
                  cs_A.symbolToNetWork,
                  cs_B.symbolToNetWork,
                  liquidity,
                  amountAMin,
                  amountBMin,
                  deadline);

          dlog("uniswapRemoveLiquidity ${ret?.data}");
          closeLoadDialog();

          if (StringUtils.isNotEmpty(ret?.data)) {
//          DeviceUtils.copyText(ret?.data);

            widget?.walletAccount?.uhMgr?.addOrder(UniswapOrder(
              hash: ret?.data,
              state: 0,
              // 等待
              type: 2,
              //  撤回
              time: DateTime.now().toUtc().millisecondsSinceEpoch,

              ///utc时间 毫秒
              token_a: cs_A.symbol,
              token_b: cs_B.symbol,
              amount_a: StringUtils.formatNumAmount(amount_A,
                      point: 8, supply0: false)
                  .replaceAll(",", ""),
              amount_b: StringUtils.formatNumAmount(amount_B,
                      point: 8, supply0: false)
                  .replaceAll(",", ""),
            ));
            widget?.walletAccount?.uhMgr?.save();

            MessageDialog.showMsgDialog(
              context,
              title: ResString.get(context, RSID.usprv_2),
              //"撤回资金",
              msg: ResString.get(context, RSID.usev_12),
              //"已提交到以太坊\n稍后可在交易记录中查询结果",
              msgAlign: TextAlign.center,
              btnRight: ResString.get(context, RSID.confirm),
              //"确定",
              onClickBtnRight: (dialog) async {
                dialog.dismiss();
                eventMgr.send(EventTag.UNISWAP_REMOVE, null);
                await Future.delayed(Duration(milliseconds: 200));
                finish();
              },
            );
          } else {
            showToast(ret?.errorMsg ??
                ResString.get(
                    context, RSID.request_failed_retry)); //"请求失败,请稍后重试");
          }
        },
      );
    });
  }
}
