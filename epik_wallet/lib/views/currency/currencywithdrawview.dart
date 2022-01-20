import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/LocalAddressMgr.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/CurrencyAsset.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';

// 提币  转出
class CurrencyWithdrawView extends BaseWidget {
  WalletAccount walletaccount;
  CurrencyAsset currencyAsset;

  CurrencyWithdrawView(this.walletaccount, this.currencyAsset);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _CurrencyWithdrawViewState();
  }
}

class _CurrencyWithdrawViewState extends BaseWidgetState<CurrencyWithdrawView> {
  String from_address = "";

  String to_address = "";
  TextEditingController _controllerToAddress;

  String amount = "";
  double amount_d = 0;
  TextEditingController _controllerAmount;

  @override
  void initStateConfig() {
//    setAppBarTitle("${widget.currencyAsset.cs.symbol}转账");

    EpikWalletUtils.getHdTransferGas(widget.currencyAsset.cs);

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
    eventMgr.add(EventTag.SCAN_QRCODE_RESULT, eventcallback_qrcode);
    eventMgr.add(EventTag.UPLOAD_SUGGESTGAS, eventcallback_gas);
  }

  @override
  void dispose() {
    eventMgr.remove(EventTag.SCAN_QRCODE_RESULT, eventcallback_qrcode);
    eventMgr.remove(EventTag.UPLOAD_SUGGESTGAS, eventcallback_gas);
    super.dispose();
  }

  eventcallback_qrcode(arg) {
    String text = StringUtils.parseString(arg, null);
    if (text != null) {
      setState(() {
        to_address = text;
        _controllerToAddress = null;
      });
    }
  }

  eventcallback_gas(arg) {
    setState(() {});
  }

  Color bgcolor = ResColor.main.withOpacity(0.1);

  @override
  Widget buildWidget(BuildContext context) {
    List<Widget> views = [];

    views.add(
      Container(
        padding: EdgeInsets.fromLTRB(20, 40, 20, 5),
        child: Text(
          ResString.get(context, RSID.cwv_1), //"转出地址",
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ),
    );

    views.add(
      Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Text(
          from_address,
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
          ),
        ),
      ),
    );

    if (_controllerToAddress == null) _controllerToAddress = new TextEditingController(text: to_address);
    views.add(
      Container(
        width: double.infinity,
        // height: 77,
        constraints: BoxConstraints(
          minHeight: 67,
        ),
        margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _controllerToAddress,
                      keyboardType: TextInputType.text,
                      //获取焦点时,启用的键盘类型
                      maxLines: null,
                      //1,
                      // 输入框最大的显示行数
//              maxLength: 20, //允许输入的字符长度/ 右下角有数量提示
                      maxLengthEnforced: true,
                      //是否允许输入的字符长度超过限定的字符长度
                      obscureText: false,
                      //是否是密码
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExpUtil.re_noChs)],
                      // 这里限制长度 不会有数量提示
                      decoration: InputDecoration(
                        // 以下属性可用来去除TextField的边框
                        // border: InputBorder.none,
                        // errorBorder: InputBorder.none,
                        // focusedErrorBorder: InputBorder.none,
                        border: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        // enabledBorder: const UnderlineInputBorder(
                        //   borderRadius: BorderRadius.zero,
                        //   borderSide: BorderSide(
                        //     color: ResColor.white_20,
                        //     width: 1,
                        //   ),
                        // ),
                        // focusedBorder: const UnderlineInputBorder(
                        //   borderRadius: BorderRadius.zero,
                        //   borderSide: BorderSide(
                        //     color: ResColor.white,
                        //     width: 1,
                        //   ),
                        // ),
                        contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 20),

//                      contentPadding: EdgeInsets.symmetric(vertical: 8.5),
//                         hintText: RSID.cwv_2.text,
//                         //"接收地址"
//                         hintStyle:
//                             TextStyle(color: ResColor.white_50, fontSize: 14),
                        labelText: RSID.cwv_2.text,
                        //"接收地址",
                        labelStyle: TextStyle(color: ResColor.white, fontSize: 17),
                      ),
                      cursorWidth: 2.0,
                      //光标宽度
                      cursorRadius: Radius.circular(2),
                      //光标圆角弧度
                      cursorColor: Colors.white,
                      //光标颜色
                      style: TextStyle(fontSize: 17, color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          to_address = _controllerToAddress.text.trim();
                        });
                      },
                      onSubmitted: (value) {
                        setState(() {
                          to_address = _controllerToAddress.text.trim();
                        });
                      }, // 是否隐藏输入的内容
                    ),
                  ),
                ],
              ),
            ),
            (StringUtils.isEmpty(to_address))
                ? Container()
                : SizedBox(
                    width: 40,
                    height: 67,
                    child: IconButton(
                      onPressed: () {
                        to_address = "";
                        _controllerToAddress = null;
                        setState(() {});
                      },
                      padding: EdgeInsets.all(0),
                      icon: Icon(Icons.clear_rounded),
                      color: Colors.white,
                      iconSize: 14,
                    ),
                  ),
            InkWell(
              onTap: () {
                onClickScan();
              },
              child: Container(
                width: 40,
                height: 62,
                padding: EdgeInsets.all(9),
                child: Image.asset("assets/img/ic_scan_2.png"),
              ),
            ),
            InkWell(
              onTap: () {
                onClickAddress();
              },
              child: Container(
                width: 26,
                height: 62,
                padding: EdgeInsets.all(1),
                child: Icon(
                  Icons.location_pin,
                  size: 24,
                  color: Color(0xffb1b2b3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    views.add(Container(
      height: 1,
      width: double.infinity,
      color: ResColor.white_20,
      margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
    ));

    if (_controllerAmount == null) _controllerAmount = new TextEditingController(text: amount);

    views.add(
      Container(
        width: double.infinity,
        height: 67,
        // constraints: BoxConstraints(
        //   minHeight: 67,
        // ),
        margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _controllerAmount,
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
                        // 以下属性可用来去除TextField的边框
                        // border: InputBorder.none,
                        // errorBorder: InputBorder.none,
                        // focusedErrorBorder: InputBorder.none,
                        border: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        // enabledBorder: const UnderlineInputBorder(
                        //   borderRadius: BorderRadius.zero,
                        //   borderSide: BorderSide(
                        //     color: ResColor.white_20,
                        //     width: 1,
                        //   ),
                        // ),
                        // focusedBorder: const UnderlineInputBorder(
                        //   borderRadius: BorderRadius.zero,
                        //   borderSide: BorderSide(
                        //     color: ResColor.white,
                        //     width: 1,
                        //   ),
                        // ),
                        contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 20),

//                      contentPadding: EdgeInsets.symmetric(vertical: 8.5),
//                         hintText: RSID.cwv_2.text,
//                         //"接收地址"
//                         hintStyle:
//                             TextStyle(color: ResColor.white_50, fontSize: 14),
                        labelText: RSID.cwv_4.text,
                        labelStyle: TextStyle(color: ResColor.white, fontSize: 17),
                      ),
                      cursorWidth: 2.0,
                      //光标宽度
                      cursorRadius: Radius.circular(2),
                      //光标圆角弧度
                      cursorColor: Colors.white,
                      //光标颜色
                      style: TextStyle(fontSize: 17, color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          amount = _controllerAmount.text.trim();
                        });
                      },
                      onSubmitted: (value) {
                        setState(() {
                          amount = _controllerAmount.text.trim();
                        });
                      }, // 是否隐藏输入的内容
                    ),
                  ),
                ],
              ),
            ),
            (StringUtils.isEmpty(amount))
                ? Container()
                : SizedBox(
                    width: 40,
                    height: 67,
                    child: IconButton(
                      onPressed: () {
                        amount = "";
                        _controllerAmount = null;
                        setState(() {});
                      },
                      padding: EdgeInsets.all(0),
                      icon: Icon(Icons.clear_rounded),
                      color: Colors.white,
                      iconSize: 14,
                    ),
                  ),
            LoadingButton(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              color_bg: Colors.transparent,
              disabledColor: Colors.transparent,
              height: 20,
              width: 40,
              text: RSID.cwv_5.text,
              //全部
              textstyle: TextStyle(
                color: ResColor.o_1,
                fontSize: 12,
              ),
              bg_borderradius: BorderRadius.circular(4),
              side: BorderSide(
                color: ResColor.o_1,
                width: 1,
              ),
              onclick: (lbtn) {
                amount = widget.currencyAsset.balance ?? "0";

                if (widget.currencyAsset.cs == CurrencySymbol.ETH) {
                  //eth转账 gas就是eth 所以全部金额 要减掉gas
                  try {
                    double _a = StringUtils.parseDouble(amount, 0);
                    // double _gas = widget?.walletaccount?.eth_suggestGas_d ?? 0;
                    double _gas = EpikWalletUtils.hdgasMap[widget.currencyAsset.cs]?.gas_d ?? 0;
                    _a -= _gas;
                    if (_a < 0) _a = 0;
                    amount = StringUtils.formatNumAmount(_a, point: 18, supply0: false).replaceAll(",", "");
                    // print("$amount");
                  } catch (e) {
                    print(e);
                  }
                } else if (widget.currencyAsset.cs == CurrencySymbol.EPK) {
                  try {
                    double _a = StringUtils.parseDouble(amount, 0);
                    double _gas = widget?.walletaccount?.epik_gas_transfer ?? 0;
                    _a -= _gas;
                    if (_a < 0) _a = 0;
                    amount = StringUtils.formatNumAmount(_a, point: 18, supply0: false).replaceAll(",", "");
                    // print("$amount");
                  } catch (e) {
                    print(e);
                  }
                }

                _controllerAmount = null;
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
    views.add(Container(
      height: 1,
      width: double.infinity,
      color: ResColor.white_20,
      margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
    ));

    views.add(
      Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(20, 11, 20, 0),
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
      ),
    );

    if (widget.currencyAsset.networkType == CurrencySymbol.EPK) {
      views.add(
        Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(20, 5, 20, 0),
          child: Text(
            RSID.cwv_13.text + widget.walletaccount.epik_gas_transfer_format + "EPK",
            textAlign: TextAlign.end,
            style: TextStyle(
              color: ResColor.white_40,
              fontSize: 14,
            ),
          ),
        ),
      );
    } else if (widget.currencyAsset.networkType == CurrencySymbol.ETH|| widget.currencyAsset.networkType == CurrencySymbol.BNB) {
      String gas = EpikWalletUtils.hdgasMap[widget.currencyAsset.cs]?.gas ?? "--";
      String symbol = widget.currencyAsset.networkType.symbol;
      views.add(
        Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(20, 5, 20, 0),
          child: Text(
            ResString.get(context, RSID.cwv_7, replace: [gas])+symbol,
            //"手续费 : ${widget.walletaccount.eth_suggestGas} eth",
            textAlign: TextAlign.end,
            style: TextStyle(
              color: ResColor.white_40,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    views.add(
      LoadingButton(
        margin: EdgeInsets.fromLTRB(30, 40, 30, 20),
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
          onClickWithdraw();
        },
      ),
    );

    // views.add(Container(
    //   width: double.infinity,
    //   height: 44,
    //   margin: EdgeInsets.fromLTRB(20, 50, 20, 20),
    //   child: FlatButton(
    //     highlightColor: Colors.white24,
    //     splashColor: Colors.white24,
    //     onPressed: () {
    //       onClickWithdraw();
    //     },
    //     child: Text(
    //       ResString.get(context, RSID.confirm), //"确定",
    //       style: TextStyle(
    //         color: Colors.white,
    //         fontSize: 16,
    //       ),
    //     ),
    //     color: Color(0xff393E45),
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.all(Radius.circular(22)),
    //     ),
    //   ),
    // ));

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
        constraints: BoxConstraints(
          minHeight: getScreenHeight() - BaseFuntion.topbarheight - BaseFuntion.appbarheight_def,
        ),
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
          Positioned(left: 0, right: 0, bottom: 0, top: getAppBarHeight() + getTopBarHeight(), child: sv),
        ],
      ),
    );
  }

  onClickScan() {
    ViewGT.showQrcodeScanView(context);
  }

  //todo selete address
  onClickAddress() {
    String symbol = widget.currencyAsset.cs.codename;
    List<LocalAddressObj> data = localaddressmgr?.datamap[symbol];
    if (data == null || data.length <= 0) {
      showToast(RSID.no_address_available.text);
      return;
    }
    BottomDialog.showAddressSeleteDialog(context, data, (LocalAddressObj lao) {
      eventMgr.send(EventTag.SCAN_QRCODE_RESULT, lao.address.trim());
    });
  }

  bool checkParams() {
    closeInput();

    to_address = _controllerToAddress.text.trim();
    dlog("to_address = $to_address");
    amount = _controllerAmount.text.trim();
    dlog("amount = $amount");
    amount_d = StringUtils.parseDouble(amount, 0);
    dlog("amount_d = $amount_d");

    if (StringUtils.isEmpty(to_address)) {
      showToast(ResString.get(context, RSID.cwv_8)); //"请填入接收地址");
      return false;
    }

    if (StringUtils.isEmpty(amount)) {
      showToast(ResString.get(context, RSID.cwv_9)); //"请输入金额");
      return false;
    }

    if (amount_d == 0) {
      showToast(ResString.get(context, RSID.cwv_10)); //"转账金额不能是0");
      return false;
    }

    if (widget.currencyAsset.networkType == CurrencySymbol.EPK) {
      // EPK
      if (widget.currencyAsset.getBalanceDouble() < widget.walletaccount.epik_gas_transfer + amount_d) {
        showToast(RSID.cwv_14.text); //余额不足
        return false;
      }
    } else if (widget.currencyAsset.networkType == CurrencySymbol.ETH) {
      //ETH
      if (widget.currencyAsset.cs == CurrencySymbol.ETH) {
        double _gas = EpikWalletUtils.hdgasMap[widget.currencyAsset.cs]?.gas_d ?? 0;
        if (widget.currencyAsset.getBalanceDouble() < _gas + amount_d) {
          showToast(RSID.cwv_14.text); //余额不足
          return false;
        }
      } else {
        // USDT EPK-ERC20等 eth上的token
        if (widget.currencyAsset.getBalanceDouble() < amount_d) {
          showToast(RSID.cwv_14.text); //余额不足
          return false;
        }
      }
    }

    return true;
  }

  onClickWithdraw() {
    print("widget.currencyAsset.cs.isToken=${widget.currencyAsset.cs.isToken}");

    if (!checkParams()) return;

    BottomDialog.showPassWordInputDialog(
      context,
      widget.walletaccount.password,
      (password) {
        //点击确定回调 , 已验证密码, 并且已关闭dialog

        showLoadDialog(
          "",
          touchOutClose: false,
          backClose: false,
          onShow: () {
            if (widget.currencyAsset.cs == CurrencySymbol.EPK) {
              doWithdraw_epik();
            } else {
              doWithdraw_hd();
            }
          },
        );
      },
    );
  }

  doWithdraw_epik() async {
    ResultObj result = await widget.walletaccount.epikWallet.send(to_address, amount);
    closeLoadDialog();

    if (result?.isSuccess != true) {
      // showToast(result?.errorMsg ?? ResString.get(context, RSID.cwv_11)); //"转账失败");
      String err = "";
      if (StringUtils.isNotEmpty(result.errorMsg)) {
        err = "ERROR: ${result.errorMsg}";
      } else {
        err = ResString.get(context, RSID.cwv_11); //"转账失败");
      }
      MessageDialog.showMsgDialog(
        context,
        title: ResString.get(context, RSID.cwv_11),
        msg: err,
        btnLeft: ResString.get(context, RSID.confirm),
        onClickBtnLeft: (dialog) {
          dialog.dismiss();
        },
      );
      return;
    }

    dlog("doWithdraw_epik result=${result?.data}");
    String cid = result?.data;

    MessageDialog.showMsgDialog(
      context,
      title: ResString.get(context, RSID.withdraw),
      // "转账",
      // msg: ResString.get(context, RSID.cwv_12),
      // //"操作成功!",
      // btnLeft: ResString.get(context, RSID.confirm),
      // //"确定",
      // onDismiss: (dialog) {
      //   finish();
      // },
      // onClickBtnLeft: (dialog) {
      //   dialog.dismiss();
      // },
      msg: "${RSID.minerview_18.text}\n$cid",
      //交易已提交
      btnLeft: RSID.minerview_19.text,
      //"查看交易",
      btnRight: RSID.isee.text,
      onDismiss: (dialog) {
        Future.delayed(Duration(milliseconds: 100)).then((value) => finish());
      },
      onClickBtnLeft: (dialog) {
        // dialog.dismiss();
        lookEpkCid(cid);
      },
      onClickBtnRight: (dialog) {
        dialog.dismiss();
      },
    );
  }

  doWithdraw_hd() async {
    ResultObj<String> result =
        await EpikWalletUtils.hdTransfer(widget.walletaccount, widget.currencyAsset.cs, to_address, amount);

    closeLoadDialog();

    if (!result.isSuccess) {
      String err = "";
      if (StringUtils.isNotEmpty(result.errorMsg)) {
        err = "ERROR: ${result.errorMsg}";
      } else {
        err = ResString.get(context, RSID.cwv_11); //"转账失败");
      }
      MessageDialog.showMsgDialog(
        context,
        title: ResString.get(context, RSID.cwv_11),
        msg: err,
        btnLeft: ResString.get(context, RSID.confirm),
        onClickBtnLeft: (dialog) {
          dialog.dismiss();
        },
      );
      return;
    }

    dlog("doWithdraw_hd result=${result?.data}");
    String txhash = result?.data;

    MessageDialog.showMsgDialog(
      context,
      title: ResString.get(context, RSID.withdraw),
      // "转账",
      // msg: ResString.get(context, RSID.cwv_12),
      // // "操作成功!",
      // btnLeft: ResString.get(context, RSID.confirm),
      // //"确定",
      // onDismiss: (dialog) {
      //   finish();
      // },
      // onClickBtnLeft: (dialog) {
      //   dialog.dismiss();
      // },
      msg: "${RSID.minerview_18.text}\n$txhash",
      //交易已提交
      btnLeft: RSID.minerview_19.text,
      //"查看交易",
      btnRight: RSID.isee.text,
      onDismiss: (dialog) {
        Future.delayed(Duration(milliseconds: 100)).then((value) => finish());
      },
      onClickBtnLeft: (dialog) {
        // dialog.dismiss();
        lookEthTxhash(txhash);
      },
      onClickBtnRight: (dialog) {
        dialog.dismiss();
      },
    );
  }

  ///查看eth交易
  lookEthTxhash(String txhash) {
    String url = ServiceInfo.ether_tx_web + txhash;
    ViewGT.showGeneralWebView(
      context,
      RSID.usolv_3.text, //"详情",
      url,
    );
  }

  ///查看epik交易
  lookEpkCid(String cid) {
    String url = ServiceInfo.epik_msg_web + cid; // 需要epk浏览器地址
    ViewGT.showGeneralWebView(
      context,
      RSID.usolv_3.text, //"详情",
      url,
    );
  }
}
