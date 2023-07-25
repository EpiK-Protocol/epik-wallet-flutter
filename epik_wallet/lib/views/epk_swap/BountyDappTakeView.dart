import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_dapp.dart';
import 'package:epikwallet/model/Dapp.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/text/diff_scale_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';

class BountyDappTakeView extends BaseWidget {
  Dapp dapp;

  BountyDappTakeView(this.dapp);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return BountyDappTakeViewState();
  }
}

class BountyDappTakeViewState extends BaseWidgetState<BountyDappTakeView> {
  SystemUiOverlayStyle oldSystemUiOverlayStyle;

  String balance = "   ";

  @override
  void initStateConfig() {
    super.initStateConfig();

    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);
    resizeToAvoidBottomPadding = true;
    isTopFloatWidgetShow = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(widget.dapp.name);

    Future.delayed(Duration(milliseconds: 10)).then((value) {
      if (StringUtils.isNotEmpty(widget?.dapp?.dappInfo?.epk)) {
        balance = StringUtils.formatNumAmount(widget?.dapp?.dappInfo?.epk_d,
            point: 8, supply0: false);
      } else {
        balance = "--";
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget getTopFloatWidget() {
    return getAppBar();
  }

  @override
  Widget getAppBar() {
    return Container(
      height: getAppBarHeight() + getTopBarHeight(),
      padding: EdgeInsets.only(top: getTopBarHeight()),
      width: double.infinity,
      color: Colors.transparent,
      child: Stack(
        alignment: FractionalOffset(0, 0.5),
        children: <Widget>[
          Align(
            alignment: FractionalOffset(0.5, 0.5),
            child: getAppBarCenter(color: Colors.white),
          ),
          Align(
            //左边返回导航 的位置，可以根据需求变更
            alignment: FractionalOffset(0, 0.5),
            child: Offstage(
              offstage: !isBackIconShow,
              child: getAppBarLeft(color: Colors.white),
            ),
          ),
          Align(
            alignment: FractionalOffset(0.98, 0.5),
            child: getAppBarRight(color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget getAppBarCenter({Color color}) {
    return Container(
      padding: EdgeInsets.only(left: 50, right: 50),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: widget.dapp.icon,
                fit: BoxFit.cover,
                placeholder: (context, url) {
                  return Stack(
                    alignment: FractionalOffset(0.5, 0.5),
                    children: <Widget>[
                      SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white10)),
                      )
                    ],
                  );
                },
                errorWidget: (context, url, error) {
                  return Container(color: Colors.white54);
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 5),
            constraints: BoxConstraints(
              maxWidth: getScreenWidth() - 140,
            ),
            child: Text(
              widget.dapp.name ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: appBarCenterTextSize,
                color: color ?? appBarContentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///导航栏appBar中间部分 ，不满足可以自行重写
  Widget getAppBarRight({Color color}) {
    return InkWell(
      onTap: () {
        ViewGT.showBountyDappTakeRecordView(context, widget.dapp);
      },
      child: Text(
        RSID.bdtrv_1.text, //"领取记录",
        style: TextStyle(
          fontSize: 14,
          color: color ?? appBarContentColor,
        ),
      ),
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    List<Widget> items = [
      headerBuilder(),
    ];

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // header card
          Container(
            width: double.infinity,
            height: getAppBarHeight() + getTopBarHeight() + 128,
            padding: EdgeInsets.only(top: getTopBarHeight()),
            decoration: BoxDecoration(
              gradient: ResColor.lg_1,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // getAppBar(),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: getAppBarHeight() + getTopBarHeight(),
            bottom: 0,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(30, 40, 30, 40),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ResColor.b_3,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: items,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double header_top = 0;

  Widget headerBuilder() {
    List<Widget> items = [];

    if (_tec_amount == null)
      _tec_amount = new TextEditingController.fromValue(TextEditingValue(
        text: text_amount,
        selection: new TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream, offset: text_amount.length),
        ),
      ));

    Widget input = Row(
      children: [
        // Text(
        //   "领取数量：",
        //   style: TextStyle(
        //     color: ResColor.black_80,
        //     fontSize: 16,
        //   ),
        // ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                height: 55,
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                      height: 33,
                      child: TextField(
                        controller: _tec_amount,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        maxLines: 1,
                        obscureText: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExpUtil.re_float)
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
                          contentPadding: EdgeInsets.fromLTRB(0, -15, 0, 12),
                          // hintText: ResString.get(context, RSID.bexv_5),
                          //"请输入兑换数量",
                          hintText: ((widget?.dapp?.dappInfo?.min_d??0) > 0)
                              ? (RSID.bdtv_15.text +
                                  (widget?.dapp?.dappInfo?.min ?? "0"))
                              : (RSID.bdtv_1.text +
                                  (widget?.dapp?.dappInfo?.fee ?? "0")),
                          // "数量需要大于" + (widget?.dapp?.dappInfo?.min ?? "0"),
                          hintStyle:
                              TextStyle(color: Colors.white60, fontSize: 17),
                          labelText: RSID.bdtv_2.text,
                          //"领取数量",
                          labelStyle:
                              TextStyle(fontSize: 17, color: Colors.white),
                        ),
                        cursorWidth: 2.0,
                        //光标宽度
                        cursorRadius: Radius.circular(2),
                        //光标圆角弧度
                        cursorColor: Colors.white,
                        //光标颜色
                        style: TextStyle(fontSize: 17, color: Colors.white),
                        onChanged: (value) {
                          text_amount = _tec_amount.text.trim();
                          amount = StringUtils.parseDouble(text_amount, 0);
                        },
                      ),
                    )),
                    // max
                    InkWell(
                      onTap: () {
                        _tec_amount = null;
                        text_amount = widget.dapp?.dappInfo?.epk ?? "0";
                        amount = StringUtils.parseDouble(text_amount, 0);
                        setState(() {});
                      },
                      child: Text(
                        " Max ",
                        style: TextStyle(
                          color: ResColor.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 0.5,
                thickness: 0.5,
                color: ResColor.white_20,
              ),
            ],
          ),
        ),
      ],
    );

    items.add(
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          DiffScaleText(
            text: widget?.dapp?.dappInfo != null ? balance : "--",
            textStyle: TextStyle(
              color: ResColor.o_1,
              fontSize: 30,
              fontFamily: "DIN_Condensed_Bold",
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 7, left: 8),
            child: Text(
              "AIEPK",
              style: TextStyle(
                color: ResColor.white_80,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    items.add(Container(
      margin: EdgeInsets.only(top: 12),
      width: double.infinity,
      height: 0.5,
      decoration: BoxDecoration(
        gradient: ResColor.lg_4,
      ),
    ));

    items.add(input);

    items.add(Container(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            RSID.bdtv_3.text, //"手续费: ",
            style: TextStyle(
              color: ResColor.white_60,
              fontSize: 11,
            ),
          ),
          Container(
            constraints: BoxConstraints(
              maxWidth: 200,
            ),
            child: Text(
              (widget?.dapp?.dappInfo?.fee ?? "0") + " AIEPK",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ResColor.white_60,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    ));

    if (StringUtils.isNotEmpty(widget?.dapp?.dappInfo?.account))
      items.add(Container(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              RSID.bdtv_4.text, //"账号: ",
              style: TextStyle(
                color: ResColor.white_60,
                fontSize: 11,
              ),
            ),
            Container(
              constraints: BoxConstraints(
                maxWidth: 200,
              ),
              child: Text(
                widget?.dapp?.dappInfo?.account ?? "--",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ResColor.white_60,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ));

    if (StringUtils.isNotEmpty(widget?.dapp?.dappInfo?.name))
      items.add(Container(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              RSID.bdtv_5.text, //"名称: ",
              style: TextStyle(
                color: ResColor.white_60,
                fontSize: 11,
              ),
            ),
            Container(
              constraints: BoxConstraints(
                maxWidth: 200,
              ),
              child: Text(
                widget?.dapp?.dappInfo?.name ?? "--",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ResColor.white_60,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ));

    if (StringUtils.isNotEmpty(widget?.dapp?.dappInfo?.id))
      items.add(Container(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "ID: ",
              style: TextStyle(
                color: ResColor.white_60,
                fontSize: 11,
              ),
            ),
            Container(
              constraints: BoxConstraints(
                maxWidth: 300,
              ),
              child: Text(
                widget?.dapp?.dappInfo?.id ?? "--",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ResColor.white_60,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ));

    items.add(
      LoadingButton(
        margin: EdgeInsets.fromLTRB(0, 30, 0, 10),
        height: 40,
        gradient_bg: ResColor.lg_1,
        color_bg: Colors.transparent,
        disabledColor: Colors.transparent,
        progress_color: Colors.white,
        progress_size: 20,
        padding: EdgeInsets.all(0),
        bg_borderradius: BorderRadius.circular(4),
        text: RSID.bdtv_6.text,
        //"确认领取",
        textstyle: const TextStyle(
          color: ResColor.white,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
        loading: loading,
        onclick: (lbtn) {
          closeInput();
          // 提交领取请求
          onClickTake();
        },
      ),
    );
    items.add(
      Text(
        RSID.bdtv_7.text, //"确认领取后会提交领取申请，审核通过后会发放EPK到您当前的钱包",
        style: TextStyle(
          color: ResColor.white_60,
          fontSize: 11,
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: items,
    );
  }

  TextEditingController _tec_amount;
  String text_amount = "";
  double amount = 0;

  bool loading = false;

  onClickTake() async {
    if (amount < (widget?.dapp?.dappInfo?.min_d ?? 0)) {
      //"最小数量为"
      showToast(RSID.bdtv_15.text + (widget?.dapp?.dappInfo?.min ?? "0"));
      return;
    }

    if (amount <= (widget?.dapp?.dappInfo?.fee_d ?? 0)) {
      //"数量需要大于"
      showToast(RSID.bdtv_1.text + (widget?.dapp?.dappInfo?.fee ?? "0"));
      return;
    }

    if (loading) return;

    loading = true;
    setState(() {});

    HttpJsonRes hjr = await ApiDapp.withdrawEpk(
        widget.dapp.api_host,
        text_amount,
        widget.dapp.getDappToken(),
        AccountMgr()?.currentAccount?.epik_EPK_address);
    if (hjr?.code == 0) {
      text_amount = "";
      amount = 0;
      _tec_amount = null;
      setState(() {});
      MessageDialog.showMsgDialog(
        context,
        title: RSID.bdtv_8.text, //"领取EPK",
        msg: RSID.bdtv_9.text, //"已提交领取申请，审核通过后将发放到您当前钱包，请在领取记录中查看。",
        btnRight: RSID.isee.text,
        onClickBtnRight: (dialog) {
          dialog.dismiss();
        },
      );
    } else {
      showToast(hjr?.msg ?? RSID.request_failed.text);
    }

    loading = false;
    setState(() {});
  }
}
