import 'dart:ui';

import 'package:decimal/decimal.dart';
import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/loading_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/LocalAddressMgr.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/model/CurrencyAsset.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/text/TextEllipsisMiddle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:jazzicon/jazzicon.dart';

// 批量 提币  转出
class CurrencyBatchWithdrawView extends BaseWidget {
  WalletAccount walletaccount;
  CurrencyAsset currencyAsset;
  List<LocalAddressObj> addressList;

  CurrencyBatchWithdrawView(this.walletaccount, this.currencyAsset, this.addressList);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return CurrencyBatchWithdrawViewState();
  }
}

class CurrencyBatchWithdrawViewState extends BaseWidgetState<CurrencyBatchWithdrawView> {
  String from_address = "";

  String totalamount = "";
  Decimal totalamount_d = Decimal.zero;
  TextEditingController _controllerTotalAmount;

  Map<LocalAddressObj, Decimal> amount_map = {};
  Map<LocalAddressObj, String> tx_map = {};

  @override
  void initStateConfig() {
//    setAppBarTitle("${widget.currencyAsset.cs.symbol}转账");

    viewSystemUiOverlayStyle = DeviceUtils.system_bar_main.copyWith(systemNavigationBarColor: ResColor.b_4);

    isTopBarShow = false; //状态栏是否显示
    isAppBarShow = false; //导航栏是否显示
    isTopFloatWidgetShow = true;

    resizeToAvoidBottomPadding = true;

    switch (widget.currencyAsset.cs) {
      case CurrencySymbol.EPK:
        {
          from_address = widget.walletaccount.epik_EPK_address;
          break;
        }
      default:
        {
          from_address = widget.walletaccount.hd_eth_address;
        }
    }
  }

  @override
  Widget getTopFloatWidget() {
    return Padding(
      padding: EdgeInsets.only(top: getTopBarHeight()),
      child: getAppBar(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(widget.currencyAsset.cs.symbol + ResString.get(context, RSID.withdraw));
  }

  @override
  void onCreate() {
    super.onCreate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color bgcolor = ResColor.main.withOpacity(0.1);

  @override
  Widget buildWidget(BuildContext context) {
    List<Widget> views = [];

    for (LocalAddressObj lao in widget.addressList) {
      bool isLast = widget.addressList.last == lao;
      views.add(getAddressItem(lao, isLast: isLast));
    }

    Widget subgroup = Container(
      margin: EdgeInsets.fromLTRB(30, 40, 30, 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ResColor.b_3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: views,
      ),
    );

    Widget sv = SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(0),
      child: Container(
        // constraints: BoxConstraints(
        //   minHeight: getScreenHeight() - BaseFuntion.topbarheight - BaseFuntion.appbarheight_def,
        // ),
        child: Column(
          children: [subgroup],
        ),
      ),
    );

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: getAppBarHeight() + getTopBarHeight() + 128,
            decoration: BoxDecoration(
              gradient: ResColor.lg_1,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: getAppBarHeight() + getTopBarHeight(),
              child: Column(
                children: [
                  Expanded(child: sv),
                  getBatchBar(),
                ],
              )),
        ],
      ),
    );
  }

  Widget getBatchBar() {
    if (_controllerTotalAmount == null)
      _controllerTotalAmount = new TextEditingController.fromValue(TextEditingValue(
        text: totalamount,
        selection: new TextSelection.fromPosition(
          TextPosition(affinity: TextAffinity.downstream, offset: totalamount.length),
        ),
      ));

    List<Widget> views = [
      //from address
      Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: Row(
          children: [
            Text(
              "From : ", //"转出地址", RSID.cwv_1.text
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: TextEm(
                  from_address,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // total amount
      Container(
        width: double.infinity,
        height: 50,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    RSID.cbwv_1.text + " : ",
                    style: TextStyle(
                      color: ResColor.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _controllerTotalAmount,
                      keyboardType: TextInputType.text,
                      //获取焦点时,启用的键盘类型
                      maxLines: 1,
                      // 输入框最大的显示行数
//              maxLength: 20, //允许输入的字符长度/ 右下角有数量提示
                      maxLengthEnforced: true,
                      //是否允许输入的字符长度超过限定的字符长度
                      obscureText: false,
                      //是否是密码
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExpUtil.re_float)],
                      // 这里限制长度 不会有数量提示
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        hintText: RSID.cbwv_2.text,
                        // "输入总金额可以平均给所有地址",
                        hintStyle: TextStyle(color: ResColor.white_60, fontSize: 17),
                        // labelText: RSID.cbwv_1.text,
                        // labelStyle: TextStyle(color: ResColor.white, fontSize: 17),
                      ),
                      cursorWidth: 2.0,
                      //光标宽度
                      cursorRadius: Radius.circular(2),
                      //光标圆角弧度
                      cursorColor: Colors.white,
                      //光标颜色
                      style: TextStyle(
                        fontSize: 17,
                        color: ResColor.o_1,
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (value) {
                        setState(() {
                          totalamount = _controllerTotalAmount.text.trim();
                          averageAmount();
                        });
                      },
                      onSubmitted: (value) {
                        setState(() {
                          totalamount = _controllerTotalAmount.text.trim();
                          averageAmount();
                        });
                      }, // 是否隐藏输入的内容
                    ),
                  ),
                ],
              ),
            ),
            (StringUtils.isEmpty(totalamount))
                ? Container()
                : SizedBox(
                    width: 40,
                    height: 67,
                    child: IconButton(
                      onPressed: () {
                        totalamount = "";
                        _controllerTotalAmount = null;
                        setState(() {});
                      },
                      padding: EdgeInsets.all(0),
                      icon: Icon(Icons.clear_rounded),
                      color: Colors.white,
                      iconSize: 14,
                    ),
                  ),
          ],
        ),
      ),
      Container(
        height: 1,
        width: double.infinity,
        color: ResColor.white_20,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      ),
      //balance
      Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(0, 11, 0, 0),
        child: Text(
          RSID.usev_4.text +
              " " +
              (StringUtils.isNotEmpty(widget.currencyAsset.balance) ? widget.currencyAsset.balance : "--") +
              " " +
              widget.currencyAsset.symbol,
          textAlign: TextAlign.end,
          style: TextStyle(
            color: ResColor.white_40,
            fontSize: 14,
          ),
        ),
      )
    ];

    // if (widget.currencyAsset.networkType == CurrencySymbol.EPK) {
    //   views.add(
    //     Container(
    //       width: double.infinity,
    //       margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
    //       child: Text(
    //         RSID.cwv_13.text + widget.walletaccount.epik_gas_transfer_format + "EPK",
    //         textAlign: TextAlign.end,
    //         style: TextStyle(
    //           color: ResColor.white_40,
    //           fontSize: 14,
    //         ),
    //       ),
    //     ),
    //   );
    // } else if (widget.currencyAsset.networkType == CurrencySymbol.ETH ||
    //     widget.currencyAsset.networkType == CurrencySymbol.BNB) {
    //   views.add(
    //     Container(
    //       width: double.infinity,
    //       margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
    //       child: Text(
    //         "Gas : ${widget.walletaccount.eth_suggestGas} ${widget.currencyAsset.networkType.symbol}",
    //         textAlign: TextAlign.end,
    //         style: TextStyle(
    //           color: ResColor.white_40,
    //           fontSize: 14,
    //         ),
    //       ),
    //     ),
    //   );
    // }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ResColor.b_4,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: true,
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...views,
              //btn
              LoadingButton(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 5),
                gradient_bg: ResColor.lg_1,
                color_bg: Colors.transparent,
                disabledColor: Colors.transparent,
                height: 40,
                text: RSID.confirm.text,
                //"确定",
                textstyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                bg_borderradius: BorderRadius.circular(4),
                onclick: (lbtn) {
                  onClickBatchWithdraw();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getAddressItem(LocalAddressObj lao, {bool isLast = false}) {
    bool isCurrent = AccountMgr().currentAccount.hd_eth_address.toLowerCase() == lao.address.toLowerCase() ||
        AccountMgr().currentAccount.epik_EPK_address.toLowerCase() == lao.address.toLowerCase();
    Decimal amount = amount_map[lao] ?? Decimal.zero;

    String tx = tx_map[lao];

    Widget item = Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(50),
                  gradient: lao.useJazzicon ? null:lao.gradientCover,
                ),
                child: Stack(
                  children: [
                    if(lao.useJazzicon)
                      Jazzicon.getIconWidget(lao.jazziconData,size: 24),
                  ],
                ),
              ),
              Text(
                lao.name,
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              Container(width: 5),
              Expanded(
                child: TextEm(
                  lao.address,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              if (isCurrent)
                Container(
                  height: 20,
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: ResColor.o_1, width: 1, style: BorderStyle.solid)),
                  child: Text(
                    "Self",
                    style: TextStyle(fontSize: 12, color: ResColor.o_1, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          Container(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Amount : ",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  "${amount}", //${widget.currencyAsset.symbol}
                  style: TextStyle(fontSize: 17, color: ResColor.o_1),
                ),
              ),
              Icon(
                Icons.edit,
                size: 17,
                color: ResColor.white_60,
              ),
            ],
          ),
          if (isCurrent) Text(RSID.alv_withdraw_to_self.text, style: TextStyle(fontSize: 12, color: ResColor.white_60)),
          if(tx!=null)
            Text(tx, style: TextStyle(fontSize: 12, color: ResColor.white_60)),
          Container(
            height: 10,
          ),
          if (!isLast)
            Divider(
              height: 1,
              thickness: 1,
              color: ResColor.white_60,
            ),
        ],
      ),
    );
    return InkWell(
      child: item,
      onTap: () {
        closeInput();
        BottomDialog.showTextInputDialogMultiple(
          context: context,
          title: lao.name,
          objlist: [
            TextInputConfigObj()
              ..oldText = amount.toString()
              ..hint = RSID.mlv_27.text //请输入数量
              ..maxLength = 99
              ..inputFormatters = [FilteringTextInputFormatter.allow(RegExpUtil.re_float)]
              ..keyboardType = TextInputType.numberWithOptions(decimal: true),
          ],
          callback: (datas) {
            // Decimal amount = amount_map[lao] ?? Decimal.zero;
            if (datas != null && datas.length > 0) {
              amount_map[lao] = Decimal.tryParse(datas[0]) ?? Decimal.zero;
              calcTotalAmoount();
              setState(() {});
            }
          },
        );
      },
    );
  }

  bool checkParams() {
    closeInput();

    totalamount = _controllerTotalAmount.text.trim();
    dlog("amount = $totalamount");
    // totalamount_d = StringUtils.parseDouble(totalamount, 0);
    totalamount_d = Decimal.tryParse(totalamount) ?? 0;
    dlog("amount_d = $totalamount_d");

    if (StringUtils.isEmpty(totalamount)) {
      showToast(ResString.get(context, RSID.cwv_9)); //"请输入金额");
      return false;
    }

    if (totalamount_d == 0) {
      showToast(ResString.get(context, RSID.cwv_10)); //"转账金额不能是0");
      return false;
    }

    amount_map.forEach((lao, decimal) {
      if (decimal <= Decimal.zero) {
        showToast(lao.name + " " + ResString.get(context, RSID.cwv_10)); //"转账金额不能是0");
        return false;
      }
    });

    return true;
  }

  averageAmount() {
    // String ta = StringUtils.isNotEmpty(totalamount)? totalamount : "0";
    totalamount_d = Decimal.tryParse(totalamount) ?? Decimal.zero;
    Decimal count = Decimal.fromInt(widget.addressList.length);
    Decimal ave = totalamount_d / count;
    widget.addressList.forEach((lao) {
      amount_map[lao] = ave;
    });
  }

  calcTotalAmoount() {
    Decimal total = Decimal.zero;
    widget.addressList.forEach((lao) {
      Decimal ddd = amount_map[lao];
      total += ddd;
    });
    totalamount_d = total;
    totalamount = totalamount_d.toString();
    _controllerTotalAmount = null;
  }

  onClickBatchWithdraw() {
    //todo
    if (!checkParams()) return;

    BottomDialog.simpleAuth(
      context,
      widget.walletaccount.password,
      (password) {
        //点击确定回调 , 已验证密码, 并且已关闭dialog

        startWithdraw();
        // showLoadDialog(
        //   "",
        //   touchOutClose: false,
        //   backClose: false,
        //   onShow: () {
        //     if (widget.currencyAsset.cs == CurrencySymbol.EPK) {
        //       doWithdraw_epik();
        //     } else {
        //       doWithdraw_hd();
        //     }
        //   },
        // );
      },
    );
  }

  startWithdraw() async {
    GlobalKey<LoadingDialogViewState> loadingkey = GlobalKey();
    LoadingDialogView loadingdialogview = LoadingDialogView(
      "",
      key: loadingkey,
    );
    LoadingDialog.showLoadDialog(context, "0/${widget.addressList.length}", backClose: false, touchOutClose: false, dialogview: loadingdialogview);

    for (int i = 0; i < widget.addressList.length; i++) {
      LocalAddressObj lao = widget.addressList[i];
      Decimal amount = amount_map[lao] ?? Decimal.zero;

      bool isCurrent = AccountMgr().currentAccount.hd_eth_address.toLowerCase() == lao.address.toLowerCase() ||
          AccountMgr().currentAccount.epik_EPK_address.toLowerCase() == lao.address.toLowerCase();

      if(!isCurrent)
      {
        if (widget.currencyAsset.cs == CurrencySymbol.EPK) {
          String tx = await doWithdraw_epik(lao, amount);
          tx_map[lao] = tx;
        } else {
          String tx = await doWithdraw_hd(lao, amount);
          tx_map[lao] = tx;
        }
        setState(() {});
      }

      loadingkey?.currentState?.text = "${(i+1)}/${widget.addressList.length}";
      loadingkey?.currentState?.setState(() {});
    }
    LoadingDialog.cloasLoadDialog(context);

    MessageDialog.showMsgDialog(
      context,
      title: RSID.minerview_18.text,
      // msg: "",
      msgAlign: TextAlign.center,
      btnRight: RSID.isee.text,
      onClickBtnRight: (dialog) {
        dialog.dismiss();
      },
    );
  }

  Future<String> doWithdraw_epik(LocalAddressObj lao, Decimal amount) async {
    String to_address = lao.address;
    ResultObj result = await widget.walletaccount.epikWallet.send(to_address, amount.toString());

    String cid = result?.data;

    return cid;
  }

  Future<String> doWithdraw_hd(LocalAddressObj lao, Decimal amount) async {
    String to_address = lao.address;
    ResultObj<String> result =
        await EpikWalletUtils.hdTransfer(widget.walletaccount, widget.currencyAsset.cs, to_address, amount.toString());
    String txhash = result?.data;
    return txhash;
  }
}
