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
        Card(
          child: Container(
            width: 60,
            height: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
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
          color: Colors.transparent,
          shadowColor: ResColor.white_80,
          elevation: 5,
        ),
        Container(width: 15),
        // app 名
        Expanded(
          child: Text(
            widget.dapp.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
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
                "账号: ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Expanded(
                child: Text(
                  widget?.dapp?.dappInfo?.account ?? "--",
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
          padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "名称: ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Expanded(
                child: Text(
                  widget?.dapp?.dappInfo?.name ?? "--",
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
          padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ID: ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Expanded(
                child: Text(
                  widget?.dapp?.dappInfo?.id ?? "--",
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
        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "EPK: ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
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
              width: 60,
              height: 24,
              text: "领取",
              textstyle: TextStyle(
                color: ResColor.main,
                fontSize: 12,
                // fontWeight: FontWeight.bold,
              ),
              // color_bg: Colors.transparent,
              // side: BorderSide(
              //   color: Colors.white,
              //   width: 1,
              //   style: BorderStyle.solid,
              // ),
              color_bg: Colors.white,
              onclick: (lbtn) {
                ViewGT.showBountyDappTakeView(context, widget.dapp);
              },
            ),
          ],
        ),
      ));
    }

    return Container(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
      // padding: EdgeInsets.all(15),
      width: double.infinity,
      // height: 100,
      child: Card(
        color: ResColor.main_1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        elevation: 10,
        shadowColor: ResColor.black_30,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items,
          ),
        ),
      ),
    );
  }

  getTokenbtn() {
    if (!widget.dapp.hasDappToken() || loading)
      return LoadingButton(
        width: 60,
        height: 24,
        text: "绑定",
        textstyle: TextStyle(
          color: Colors.white,
          fontSize: 12,
          // fontWeight: FontWeight.bold,
        ),
        color_bg: Colors.transparent,
        side: BorderSide(
          color: Colors.white,
          width: 1,
          style: BorderStyle.solid,
        ),
        progress_size: 18,
        progress_color: Colors.white,
        loading: loading,
        onclick: (lbtn) {
          BottomDialog.showTextInputDialog(
              context, widget.dapp.name, "", "请输入Dapp的令牌", 999, (value) {
            if (StringUtils.isNotEmpty(value)) {
              widget.dapp.setDappToken(value);
              // setState(() {
              // });
              loadInfo();
            }
          });
        },
      );
    else
      return LoadingButton(
        width: 60,
        height: 24,
        text: "解绑",
        textstyle: TextStyle(
          color: Colors.white,
          fontSize: 12,
          // fontWeight: FontWeight.bold,
        ),
        color_bg: Colors.transparent,
        side: BorderSide(
          color: Colors.white,
          width: 1,
          style: BorderStyle.solid,
        ),
        progress_size: 18,
        progress_color: Colors.white,
        // loading: loading,
        onclick: (lbtn) {
         MessageDialog.showMsgDialog(context,
         title: RSID.tip.text,
           msg: "您确定要解绑${widget.dapp.name}账号的Token吗？",
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
