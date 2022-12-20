import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/localstring/LocaleConfig.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_pool.dart';
import 'package:epikwallet/model/nodepool/PoolObj.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/jsonform/base/jf_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class NodePoolAddOwnerView extends BaseWidget {
  PoolObj pool;

  NodePoolAddOwnerView({this.pool});

  @override
  BaseWidgetState<BaseWidget> getState() {
    return NodePoolAddOwnerViewState();
  }
}

class NodePoolAddOwnerViewState extends BaseWidgetState<NodePoolAddOwnerView> with TickerProviderStateMixin {
  String ownerid = "";
  String signature_source = "";
  String hexAddress = "";
  String signature = "";

  @override
  void initStateConfig() {
    super.initStateConfig();
    // viewSystemUiOverlayStyle = DeviceUtils.system_bar_main.copyWith(systemNavigationBarColor: ResColor.b_4);
    setAppBarVisible(false);
    setTopBarVisible(false);
    resizeToAvoidBottomPadding = true;

    Uint8List keylist = utf8.encode(AccountMgr().currentAccount.epik_EPK_address);
    hexAddress = hex.encode(keylist);
    // dlog("hexAddress = $hexAddress");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(RSID.npmv_1.text);
  }

  @override
  Widget buildWidget(BuildContext context) {
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
            top: getAppBarHeight() + getTopBarHeight(),
            bottom: 0,
            child: SingleChildScrollView(
              child: getEdteItems(),
            ),
          ),
          // Positioned(
          //   left: 0,
          //   right: 0,
          //   bottom: 0,
          //   child: bottomBar(),
          // ),
        ],
      ),
    );
  }

  // Widget bottomBar() {
  //   Widget view = Container(
  //     width: double.infinity,
  //     padding: EdgeInsets.fromLTRB(30, 10, 30, 10 + MediaQuery.of(context).padding.bottom),
  //     decoration: BoxDecoration(
  //       color: ResColor.b_4,
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: LoadingButton(
  //             margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
  //             padding: EdgeInsets.only(bottom: 1),
  //             height: 40,
  //             gradient_bg: ResColor.lg_1,
  //             color_bg: Colors.transparent,
  //             disabledColor: Colors.transparent,
  //             bg_borderradius: BorderRadius.circular(4),
  //             text: RSID.confirm.text,
  //             textstyle: TextStyle(
  //               color: Colors.white,
  //               fontSize: LocaleConfig.currentIsZh() ? 17 : 14,
  //               fontWeight: FontWeight.bold,
  //             ),
  //             onclick: (lbtn) {
  //               onClickAdd();
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  //   return view;
  // }

  Widget getEdteItems() {
    List<Widget> items = [];

    items.add(Text(
      "OwnerID",
      style: TextStyle(
        fontSize: 18,
        color: Colors.white,
      ),
    ));

    items.add(
      JfText(
        data: ownerid,
        autofocus: true,
        maxLines: 1,
        hint: RSID.npaov_1.text,//"请输入OwnerID",
        maxLength: 40,
        fontsize: 16,
        regexp: r"^f[a-zA-Z0-9]*$",
        onChanged: (text, classtype) {
          ownerid = text.toString().trim();
          setState(() {
            signature_source = "epik wallet sign $ownerid $hexAddress";
          });
        },
      ),
    );

    bool hasownerid = StringUtils.isNotEmpty(ownerid) && RegExpUtil.re_epik_address.hasMatch(ownerid);

    if (hasownerid) {
      items.add(Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
        padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: const Color(0xff424242),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              signature_source,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            LoadingButton(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              padding: EdgeInsets.only(bottom: 1),
              height: 30,
              gradient_bg: ResColor.lg_1,
              color_bg: Colors.transparent,
              disabledColor: Colors.transparent,
              bg_borderradius: BorderRadius.circular(4),
              text: RSID.copy.text,
              textstyle: TextStyle(
                color: Colors.white,
                fontSize: LocaleConfig.currentIsZh() ? 17 : 14,
                // fontWeight: FontWeight.bold,
              ),
              onclick: (lbtn) {
                if (StringUtils.isNotEmpty(signature_source)) {
                  DeviceUtils.copyText(signature_source);
                  showToast(RSID.copied.text);
                }
              },
            ),
          ],
        ),
      ));

      items.add(Text(
        RSID.npaov_2.text,//"复制上面的命令在节点服务器上执行，并将签名结果填到下面后点击确定。",
        style: TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      ));

      items.add(Container(height: 20));

      items.add(Text(
        RSID.npaov_3.text,//"Owner签名数据",
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ));

      items.add(
        JfText(
          data: signature,
          autofocus: false,
          maxLines: -1,
          hint: RSID.npaov_4.text,//"请输入Owner签名数据",
          maxLength: 999,
          fontsize: 16,
          onChanged: (text, classtype) {
            setState(() {
              signature = text.toString().trim();
            });
          },
        ),
      );

      bool hassignature = StringUtils.isNotEmpty(signature);
      items.add(
        LoadingButton(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          padding: EdgeInsets.only(bottom: 1),
          height: 40,
          gradient_bg: hassignature ?ResColor.lg_1: ResColor.lg_7,
          color_bg: Colors.transparent,
          disabledColor: Colors.transparent,
          bg_borderradius: BorderRadius.circular(4),
          text: RSID.confirm.text,
          textstyle: TextStyle(
            color: Colors.white,
            fontSize: LocaleConfig.currentIsZh() ? 17 : 14,
            fontWeight: FontWeight.bold,
          ),
          onclick: hassignature?(lbtn) {
            onClickAdd();
          }:null,
        ),
      );
    }



    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 200),
      margin: EdgeInsets.fromLTRB(30, 45, 30, 100),
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

  bool checkParams() {
    if (StringUtils.isEmpty(ownerid)) {
      showToast(RSID.npaov_1.text);//"请输入OwnerID");
      return false;
    }
    if (StringUtils.isEmpty(signature)) {
      showToast(RSID.npaov_4.text);//"请输入Owner签名数据");
      return false;
    }
    return true;
  }

  onClickAdd() {
    if (checkParams() != true) return;

    closeInput();

    BottomDialog.simpleAuth(context, AccountMgr().currentAccount.password, (value) async {
      showLoadDialog("", backClose: false, touchOutClose: false);

      HttpJsonRes hjr = await ApiPool.pool_addOwner(
        OwnerID: ownerid,
        Signature: signature,
      );

      closeLoadDialog();

      if (hjr.code == 0) {
        showToast(RSID.npaov_5.text);//"已添加"); //创建成功
        widget.pool.Owners.add(ownerid);
        finish(true);
      } else {
        showToast(hjr.msg);
      }
    });
  }
}
