import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/api/api_dapp.dart';
import 'package:epikwallet/model/Dapp.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/utils/toast/toast.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DappBountyItem extends StatefulWidget {
  Dapp dapp;

  DappBountyItem(this.dapp);

  @override
  State<StatefulWidget> createState() {
    return DappBountyItemState();
  }
}

class DappBountyItemState extends State<DappBountyItem> {
  @override
  void initState() {
    super.initState();

    refresh();
  }



  refresh() {
    if (widget.dapp.hasDappToken()) {
      //  有token
      // if (widget.dapp.dappInfo == null) {
      // 需要加载info
      loadInfo();
      // }
    }
  }

  bool loading = false;
  int loadcode = 0;
  loadInfo() async {
    loading = true;
    if (mounted) setState(() {});

    // 需要加载info
    loadcode = await widget.dapp.loadDappinfo();

    loading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];

    items.add(Row(
      children: [
        // icon
        Container(
          width: 50,
          height: 50,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: widget.dapp.icon,
              fit: BoxFit.cover,
              placeholder: (context, url) {
                return Stack(
                  alignment: FractionalOffset(0.5, 0.5),
                  children: <Widget>[
                    SizedBox(
                      width: 20,
                      height: 20,
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
        Container(width: 10),
        // app 名
        Expanded(
          child: Text(
            widget.dapp.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Container(width: 10),

        getTokenbtn(),
      ],
    ));

    if (widget?.dapp?.dappInfo != null) {
      items.add(Container(
        height: 10,
      ));

      if (StringUtils.isNotEmpty(widget?.dapp?.dappInfo?.account))
        items.add(Container(
          padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                RSID.bdtv_4.text,//"账号: ",
                style: TextStyle(
                  color: ResColor.white_60,
                  fontSize: 11,
                ),
              ),
              Expanded(
                child: Text(
                  widget?.dapp?.dappInfo?.account ?? "--",
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                RSID.bdtv_5.text,//"名称: ",
                style: TextStyle(
                  color: ResColor.white_60,
                  fontSize: 11,
                ),
              ),
              Expanded(
                child: Text(
                  widget?.dapp?.dappInfo?.name ?? "--",
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ID: ",
                style: TextStyle(
                  color: ResColor.white_60,
                  fontSize: 11,
                ),
              ),
              Expanded(
                child: Text(
                  widget?.dapp?.dappInfo?.id ?? "--",
                  style: TextStyle(
                    color: ResColor.white_60,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ));

      items.add(Container(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "AIEPK: ",
              style: TextStyle(
                color: ResColor.white_60,
                fontSize: 11,
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  widget?.dapp?.dappInfo?.epk ?? "--",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: "DIN_Condensed_Bold",
                  ),
                ),
              ),
            ),
            if (widget.dapp.dappInfo!=null)
            LoadingButton(
              width: 50,
              height: 30,
              gradient_bg: ResColor.lg_1,
              color_bg: Colors.transparent,
              disabledColor: Colors.transparent,
              bg_borderradius: BorderRadius.circular(4),
              text: RSID.bdtv_10.text,//"领取",
              textstyle: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              onclick: (lbtn) {
                ViewGT.showBountyDappTakeView(context, widget.dapp);
              },
            ),
          ],
        ),
      ));
    }

    return Container(
      margin: EdgeInsets.fromLTRB(30, 0, 30, 20),
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ResColor.b_3,
        borderRadius: BorderRadius.circular(20),
      ),
      child:   Column(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ),
    );
  }

  getTokenbtn() {
    if (!widget.dapp.hasDappToken() || loading)
      return LoadingButton(
        width: 50,
        height: 30,
        gradient_bg: ResColor.lg_1,
        color_bg: Colors.transparent,
        disabledColor: Colors.transparent,
        text: RSID.bdtv_11.text,//"绑定",
        textstyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
          // fontWeight: FontWeight.bold,
        ),
        bg_borderradius: BorderRadius.circular(4),
        progress_size: 18,
        progress_color: Colors.white,
        loading: loading,
        onclick: (lbtn) {
          BottomDialog.showTextInputDialog(
              context, widget.dapp.name, "", RSID.bdtv_12.text,/*"请输入Dapp的令牌"*/ 999, (value) {
            if (StringUtils.isNotEmpty(value)) {
              widget.dapp.setDappToken(value);
              // setState(() {
              // });
              loadInfo();
              if(loadcode==401)
              {
                ToastUtils.showToastCenter("Error 401 unauthorized");
              }
            }
          });
        },
      );
    else
      return LoadingButton(
        width: 50,
        height: 30,
        // gradient_bg: ResColor.lg_1,
        color_bg:const Color(0xff424242),
        disabledColor: const Color(0xff424242),
        text: RSID.bdtv_13.text,//"解绑",
        textstyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
          // fontWeight: FontWeight.bold,
        ),
        bg_borderradius: BorderRadius.circular(4),
        progress_size: 18,
        progress_color: Colors.white,
        // loading: loading,
        onclick: (lbtn) {
         MessageDialog.showMsgDialog(context,
         title: RSID.tip.text,
           msg: RSID.bdtv_14.replace(["${widget.dapp.name}"]),//"您确定要解绑${widget.dapp.name}账号的Token吗？",
           btnLeft: RSID.cancel.text,
           btnRight: RSID.confirm.text,
           onClickBtnLeft: (dialog) {
             dialog.dismiss();
           },
           onClickBtnRight: (dialog) {
             dialog.dismiss();
             widget.dapp.dappInfo=null;
             widget.dapp.setDappToken("");
             if(mounted)
             {
               setState(() {
               });
             }
           },
         );

        },
      );
  }
}
