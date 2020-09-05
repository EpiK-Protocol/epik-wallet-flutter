import 'package:epikwallet/base/_base_widget.dart';
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
import 'package:epikwallet/views/viewgoto.dart';
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
    setAppBarTitle("${widget.currencyAsset.cs.symbol}转账");
    resizeToAvoidBottomPadding = true;

    switch (widget.currencyAsset.cs) {
      case CurrencySymbol.tEPK:
        {
          from_address = widget.walletaccount.epik_tEPK_address;
          break;
        }
      default:
        {
          from_address = widget.walletaccount.hd_eth_address;
        }
    }
  }

  SystemUiOverlayStyle oldSystemUiOverlayStyle;

  @override
  void onCreate() {
    super.onCreate();

    oldSystemUiOverlayStyle = DeviceUtils.system_bar_current;
    DeviceUtils.setSystemBarStyle(DeviceUtils.system_bar_dark);
    eventMgr.add(EventTag.SCAN_QRCODE_RESULT, eventcallback_qrcode);
  }

  @override
  void dispose() {
    if (oldSystemUiOverlayStyle != null)
      DeviceUtils.setSystemBarStyle(oldSystemUiOverlayStyle);
    eventMgr.remove(EventTag.SCAN_QRCODE_RESULT, eventcallback_qrcode);
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

  Color bgcolor = ResColor.main.withOpacity(0.1);

  @override
  Widget buildWidget(BuildContext context) {
    List<Widget> views = [];

    /// 转出地址
    views.add(Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: bgcolor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "转出地址",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          Container(
            height: 10,
          ),
          Text(
            from_address,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ));

    if (_controllerToAddress == null)
      _controllerToAddress = new TextEditingController(text: to_address);

    /// 接收地址
    views.add(Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: EdgeInsets.fromLTRB(15, 0, 0, 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: bgcolor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 50,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "接收地址",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    onClickScan();
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    padding: EdgeInsets.all(15),
                    child: ImageIcon(
                      AssetImage("assets/img/ic_scan.png"),
                      color: Colors.lightBlue,
                      size: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
            constraints: BoxConstraints(
              minWidth: double.infinity,
              minHeight: 15,
              maxHeight: 100,
            ),
            child: TextField(
              controller: _controllerToAddress,
              keyboardType: TextInputType.text,
              maxLines: null,
              maxLengthEnforced: true,
              obscureText: false,
              //是否是密码
              inputFormatters: [
                WhitelistingTextInputFormatter(RegExpUtil.re_noChs)
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
                hintText: "输入地址、长按粘贴地址或点扫描二维码",
                hintStyle: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              cursorWidth: 2.0,
              //光标宽度
              cursorRadius: Radius.circular(2),
              //光标圆角弧度
              cursorColor: Colors.black,
              //光标颜色
              style: TextStyle(fontSize: 16, color: Colors.black),
              onChanged: (value) {
                to_address = _controllerToAddress.text.trim();
              },
              onSubmitted: (value) {
                to_address = _controllerToAddress.text.trim();
              }, // 是否隐藏输入的内容
            ),
          ),
        ],
      ),
    ));

    if (_controllerAmount == null)
      _controllerAmount = new TextEditingController(text: amount);

    /// 金额
    views.add(Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: EdgeInsets.fromLTRB(15, 0, 0, 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: bgcolor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 50,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "转账金额",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      amount = widget.currencyAsset.balance ?? "0";
                      _controllerAmount = null;
                    });
                  },
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.all(15),
                    child: Text(
                      "全部",
                      style: TextStyle(
                        color: Colors.lightBlue,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
            child: TextField(
              controller: _controllerAmount,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              maxLines: 1,
              maxLengthEnforced: true,
              obscureText: false,
              //是否是密码
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
                hintText: "输入金额",
                hintStyle: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              cursorWidth: 2.0,
              //光标宽度
              cursorRadius: Radius.circular(2),
              //光标圆角弧度
              cursorColor: Colors.black,
              //光标颜色
              style: TextStyle(fontSize: 16, color: Colors.black),
              onChanged: (value) {
                amount = _controllerAmount.text.trim();
              },
              onSubmitted: (value) {
                amount = _controllerAmount.text.trim();
              }, // 是否隐藏输入的内容
            ),
          ),
        ],
      ),
    ));

    views.add(Container(
      width: double.infinity,
      height: 44,
      margin: EdgeInsets.fromLTRB(20, 50, 20, 20),
      child: FlatButton(
        highlightColor: Colors.white24,
        splashColor: Colors.white24,
        onPressed: () {
          onClickWithdraw();
        },
        child: Text(
          "确定",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        color: Color(0xff393E45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(22)),
        ),
      ),
    ));

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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: views,
        ),
      ),
    );
  }

  onClickScan() {
    ViewGT.showQrcodeScanView(context);
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
      showToast("请填入接收地址");
      return false;
    }

    if (StringUtils.isEmpty(amount)) {
      showToast("请输入金额");
      return false;
    }

    if (amount_d == 0) {
      showToast("转账金额不能是0");
      return false;
    }

    return true;
  }

  onClickWithdraw() {
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
            if (widget.currencyAsset.cs == CurrencySymbol.tEPK) {
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
    String result =
        await widget.walletaccount.epikWallet.send(to_address, amount);
    closeLoadDialog();

    if (StringUtils.isEmpty(result)) {
      showToast("转账失败");
      return;
    }

    dlog("doWithdraw_epik result=$result");
    MessageDialog.showMsgDialog(
      context,
      title: "转账",
      msg: "操作成功!",
      btnLeft: "确定",
      onDismiss: (dialog) {
        finish();
      },
      onClickBtnLeft: (dialog) {
        dialog.dismiss();
      },
    );
  }

  doWithdraw_hd() async {
    String result = null;
    if (widget.currencyAsset.cs == CurrencySymbol.ETH) {
      result = await widget.walletaccount.hdwallet
          .transfer(from_address, to_address, amount);
    } else {
      result = await widget.walletaccount.hdwallet.transferToken(from_address,
          to_address, widget.currencyAsset.cs.symbolToNetWork, amount);
    }
    closeLoadDialog();

    if (StringUtils.isEmpty(result)) {
      showToast("转账失败");
      return;
    }

    dlog("doWithdraw_hd result=$result");
    MessageDialog.showMsgDialog(
      context,
      title: "转账",
      msg: "操作成功!",
      btnLeft: "确定",
      onDismiss: (dialog) {
        finish();
      },
      onClickBtnLeft: (dialog) {
        dialog.dismiss();
      },
    );
  }
}
