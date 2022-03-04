import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_wallet.dart';
import 'package:epikwallet/model/auth/RemoteAuth.dart';
import 'package:epikwallet/utils/ClickUtil.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/text/TextEllipsisMiddle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class RemoteAuthView extends BaseWidget {
  RemoteAuth ra;

  RemoteAuthView(this.ra);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return RemoteAuthViewState();
  }
}

class RemoteAuthViewState extends BaseWidgetState<RemoteAuthView> {
  String plain_base64decode;

  @override
  void initStateConfig() {
    super.initStateConfig();
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);

    try {
      //原文解base64得bytes
      Uint8List plain_bytes = base64.decode(widget.ra.p);
      plain_base64decode = utf8.decode(plain_bytes);
    } catch (e, s) {
      print(s);
    }
  }

  @override
  void didChangeDependencies() {
    setAppBarTitle(RSID.rav_1.text); //"远程授权");
  }

  @override
  Widget buildWidget(BuildContext context) {
    List<Widget> items = [];

    items.add(getAuthCard());

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Container(
            height: getAppBarHeight() + getTopBarHeight() + 128,
            padding: EdgeInsets.fromLTRB(0, getTopBarHeight(), 0, 128),
            decoration: BoxDecoration(
              gradient: ResColor.lg_1,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: getAppBar(),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: getAppBarHeight() + getTopBarHeight() + 30,
            bottom: 0,
            child: SingleChildScrollView(
              child: Column(
                children: items,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool btn_auth_loading = false;
  bool auth_ok = false;
  String auth_msg;

  Widget getAuthCard() {
    List<Widget> items = [];

    items.add(
      Text(RSID.rav_2.text,
          style: TextStyle(fontSize: 17, color: ResColor.white)),
    );

    items.add(
      Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: const Color(0xff424242),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            getColumnKeyValue(
                RSID.rav_3.text, "${plain_base64decode ?? widget.ra.p}"),
            Container(height: 8),
            getColumnKeyValue(RSID.rav_4.text, "${widget.ra.c}"),
          ],
        ),
      ),
    );

    if (!auth_ok) {
      items.add(
        LoadingButton(
          margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
          gradient_bg: ResColor.lg_1,
          color_bg: Colors.transparent,
          disabledColor: Colors.transparent,
          height: 40,
          text: RSID.rav_5.text,
          //"确定",
          textstyle: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          bg_borderradius: BorderRadius.circular(4),
          loading: btn_auth_loading,
          onclick: (lbtn) {
            onClickAuth();
          },
        ),
      );
    } else {
      items.add(Container(
        margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
        decoration: BoxDecoration(
          // gradient: ResColor.lg_1,
          color: const Color(0xff424242),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Container(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 24,
                    color: ResColor.g_1,
                  ),
                  Container(width: 10),
                  Text(
                    RSID.rav_6.text,
                    style: TextStyle(
                      fontSize: 17,
                      color: ResColor.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if(StringUtils.isNotEmpty(auth_msg))
              Container(
                padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                child: Text(
                    auth_msg,
                  style: const TextStyle(fontSize: 14,color: ResColor.white_60),
                ),
              ),
          ],
        ),
      ));
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(30, 45, 30, 10),
      padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ResColor.b_2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    );
  }

  Widget getColumnKeyValue(
    String key,
    String value, {
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    double centerpading = 4,
    bool textem = false,
    bool clickCopy = false,
  }) {
    Widget w = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(key, style: TextStyle(fontSize: 14, color: ResColor.white_60)),
        Container(
          height: centerpading,
        ),
        textem
            ? TextEm(value,
                style: TextStyle(fontSize: 14, color: ResColor.white))
            : Text(value,
                style: TextStyle(fontSize: 14, color: ResColor.white)),
      ],
    );
    return InkWell(
      onTap: clickCopy
          ? () {
              if (ClickUtil.isFastDoubleClick()) return;
              if (StringUtils.isNotEmpty(value)) {
                DeviceUtils.copyText(value);
                showToast(RSID.copied.text);
              }
            }
          : null,
      child: w,
    );
  }

  onClickAuth() {
    BottomDialog.simpleAuth(
        context, AccountMgr().currentAccount.password, (value) async {
      setState(() {
        btn_auth_loading = true;
      });

      ApiWallet.sendRemoteAuth(widget.ra).then((hjr) {
        setState(() {
          btn_auth_loading = false;
        });

        if (hjr.code == 0) {
          setState(() {
            auth_msg = hjr.msg;
            auth_ok = true;
          });
        } else {
          // showToast(hjr.msg);
          MessageDialog.showMsgDialog(
            context,
            title: RSID.rav_7.text,
            msg: hjr.msg ?? "ERROR ${hjr.httpStatusCode}",
            btnLeft: RSID.isee.text,
            onClickBtnLeft: (dialog) {
              dialog.dismiss();
            },
          );
        }
      });
    });
  }
}
