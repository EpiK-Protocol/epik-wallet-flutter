import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_dapp.dart';
import 'package:epikwallet/model/Dapp.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
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

    isTopBarShow = false; //状态栏是否显示
    isAppBarShow = false; //导航栏是否显示
    isTopFloatWidgetShow = true;
    setBackIconHinde(isHinde: false);

    oldSystemUiOverlayStyle = DeviceUtils.system_bar_current;
    DeviceUtils.setSystemBarStyle(DeviceUtils.system_bar_light);
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
    if (oldSystemUiOverlayStyle != null)
      DeviceUtils.setSystemBarStyle(oldSystemUiOverlayStyle);
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
              borderRadius: BorderRadius.circular(2),
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
        "领取记录",
        style: TextStyle(
          fontSize: 15,
          color: color ?? appBarContentColor,
        ),
      ),
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    List<Widget> items = [
      headerBuilder(),
      getStep_amount(),
    ];

    return SingleChildScrollView(
      child: Column(
        children: items,
      ),
    );
  }

  double header_top = 0;

  Widget headerBuilder() {
    if (header_top == 0) header_top = getTopBarHeight() + getAppBarHeight();

    List<Widget> items = [
      Container(height: header_top),
    ];

    // items.add(Row(
    //   mainAxisSize: MainAxisSize.min,
    //   children: [
    //     // icon
    //     Card(
    //       child: Container(
    //         width: 60,
    //         height: 60,
    //         child: ClipRRect(
    //           borderRadius: BorderRadius.circular(8),
    //           child: CachedNetworkImage(
    //             imageUrl: widget.dapp.icon,
    //             fit: BoxFit.cover,
    //             placeholder: (context, url) {
    //               return Stack(
    //                 alignment: FractionalOffset(0.5, 0.5),
    //                 children: <Widget>[
    //                   SizedBox(
    //                     width: 20,
    //                     height: 20,
    //                     child: CircularProgressIndicator(
    //                         valueColor: AlwaysStoppedAnimation(Colors.white10)),
    //                   )
    //                 ],
    //               );
    //             },
    //             errorWidget: (context, url, error) {
    //               return Container(color: Colors.white54);
    //             },
    //           ),
    //         ),
    //       ),
    //       color: Colors.transparent,
    //       shadowColor: ResColor.white_80,
    //       elevation: 5,
    //     ),
    //     Container(width: 15),
    //     // app 名
    //     Container(
    //       constraints: BoxConstraints(
    //         maxWidth: 200,
    //       ),
    //       child: Text(
    //         widget.dapp.name,
    //         maxLines: 2,
    //         overflow: TextOverflow.ellipsis,
    //         style: TextStyle(
    //           color: Colors.white,
    //           fontSize: 20,
    //           fontWeight: FontWeight.bold,
    //         ),
    //       ),
    //     ),
    //   ],
    // ));

    if (widget?.dapp?.dappInfo != null) {
      items.add(Container(
        margin: EdgeInsets.only(top: 30, bottom: 30),
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(bottom: 7),
              child: Text(
                " EPK ",
                style: TextStyle(
                  color: Colors.transparent,
                  fontSize: 14,
                ),
              ),
            ),
            DiffScaleText(
              text: balance,
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 35,
                fontFamily: "DIN_Condensed_Bold",
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 7),
              child: Text(
                " EPK ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ));

      items.add(Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "手续费: ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            Container(
              constraints: BoxConstraints(
                maxWidth: 200,
              ),
              child: Text(
                (widget?.dapp?.dappInfo?.fee ?? "0") + " EPK",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ));

      if (StringUtils.isNotEmpty(widget?.dapp?.dappInfo?.account))
        items.add(Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "账号: ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
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
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ));

      if (StringUtils.isNotEmpty(widget?.dapp?.dappInfo?.name))
        items.add(Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "名称: ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
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
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ));

      if (StringUtils.isNotEmpty(widget?.dapp?.dappInfo?.id))
        items.add(Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "ID: ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
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
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ));

      items.add(Container(
        height: 15,
      ));
    }

    return Container(
      color: ResColor.main,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ),
    );
  }

  TextEditingController _tec_amount;
  String text_amount = "";
  double amount = 0;

  /// 发起领取
  Widget getStep_amount() {
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
        Text(
          "领取数量：",
          style: TextStyle(
            color: ResColor.black_80,
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 33,
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
                          contentPadding: EdgeInsets.fromLTRB(0, -15, 0, 0),
                          // hintText: ResString.get(context, RSID.bexv_5),
                          //"请输入兑换数量",
                          hintText:
                              "数量需要大于" + (widget?.dapp?.dappInfo?.fee ?? "0"),
                          hintStyle:
                              TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                        cursorWidth: 2.0,
                        //光标宽度
                        cursorRadius: Radius.circular(2),
                        //光标圆角弧度
                        cursorColor: Colors.blue,
                        //光标颜色
                        style: TextStyle(fontSize: 16, color: Colors.black),
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
                        amount=0;
                        setState(() {});
                      },
                      child: Text(
                        " Max ",
                        style: TextStyle(
                          color: ResColor.black_80,
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
                color: ResColor.main,
              ),
            ],
          ),
        ),
      ],
    );

    Widget items = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "领取EPK",
          style: TextStyle(
            color: ResColor.black,
            fontSize: 18,
          ),
        ),
        Container(
          height: 10,
        ),
        input,
        Container(
          height: 10,
        ),
        Text(
          "确认领取后会提交领取申请，审核通过后会发放EPK到您当前的钱包",
          style: TextStyle(
            color: ResColor.black,
            fontSize: 12,
          ),
        ),
        LoadingButton(
          margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
          height: 44,
          color_bg: ResColor.main,
          disabledColor: ResColor.main,
          progress_color: Colors.white,
          progress_size: 20,
          padding: EdgeInsets.all(0),
          text: "确认领取",
          textstyle: const TextStyle(
            color: ResColor.white,
            fontSize: 15,
          ),
          loading: loading,
          onclick: (lbtn) {
            closeInput();
            // 提交领取请求
            onClickTake();
          },
        ),
      ],
    );

    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
      // padding: EdgeInsets.all(15),
      width: double.infinity,
      // child: Card(
      //   color: ResColor.white,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.all(Radius.circular(12.0)),
      //   ),
      //   elevation: 10,
      //   shadowColor: ResColor.black_30,
      //   child: Container(
      //     padding: EdgeInsets.all(15),
      //     child: items,
      //   ),
      // ),
      child: items,
    );
  }


  bool loading=false;

  onClickTake() async {
    if (amount <= (widget?.dapp?.dappInfo?.fee_d ?? 0)) {
      showToast("数量需要大于" + (widget?.dapp?.dappInfo?.fee ?? "0"));
      return;
    }

    if(loading)
      return;

    loading= true;
    setState(() {

    });

    HttpJsonRes hjr = await ApiDapp.withdrawEpk(
        widget.dapp.api_host, text_amount, widget.dapp.getDappToken(),AccountMgr()?.currentAccount?.epik_EPK_address);
    if (hjr?.code == 0) {
      text_amount="";
      amount=0;
      _tec_amount = null;
      setState(() {

      });
      MessageDialog.showMsgDialog(
        context,
        title: "领取EPK",
        msg: "已提交领取申请，审核通过后将发放到您当前钱包，请在领取记录中查看。",
        btnRight: RSID.isee.text,
        onClickBtnRight: (dialog) {
          dialog.dismiss();
        },
      );
    } else {
      showToast(hjr?.msg ?? RSID.request_failed.text);
    }

    loading= false;
    setState(() {

    });
  }
}
