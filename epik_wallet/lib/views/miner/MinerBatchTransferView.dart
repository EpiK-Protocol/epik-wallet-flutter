import 'dart:math';

import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/loading_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/LocaleConfig.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/model/CoinbaseInfo2.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';

import '../../base/_base_widget.dart';
import '../../localstring/resstringid.dart';
import '../../utils/res_color.dart';

class MTobj {
  String coinbaseid;
  String from;
  String to;
  String amount;
  double amount_d;
  CbMinerObj from_minerobj;

  String cid;
  String errorMsg;

  MTobjState state = MTobjState.stop;

  MTobj(this.coinbaseid, this.from_minerobj, this.to) {
    from = from_minerobj.ID;
    amount = from_minerobj.getMyPledge(coinbase: coinbaseid);
    amount_d = from_minerobj.getMyPledgeD(coinbase: coinbaseid);
  }
}

enum MTobjState {
  stop,
  wait,
  working,
  success,
  fail,
}

extension MTobjStateEx on MTobjState {
  IconData getIconData() {
    switch (this) {
      case MTobjState.stop:
        return null;
      case MTobjState.wait:
        return Icons.access_time;
      case MTobjState.working:
        return Icons.send;
      case MTobjState.success:
        return Icons.done;
      case MTobjState.fail:
        return Icons.error_outline;
    }
  }

  Color getColor() {
    switch (this) {
      case MTobjState.stop:
        return null;
      case MTobjState.wait:
        return ResColor.white_50;
      case MTobjState.working:
        return ResColor.o_1;
      case MTobjState.success:
        return ResColor.g_1;
      case MTobjState.fail:
        return ResColor.r_1;
    }
  }
}

class MinerBatchTransferView extends BaseWidget {
  String coinbaseid;
  List<CbMinerObj> from_minerobjlist;
  List<String> to_targetidlist;

  List<MTobj> taskList = [];

  MinerBatchTransferView(this.coinbaseid, this.from_minerobjlist, this.to_targetidlist) {
    int count = min(from_minerobjlist.length, to_targetidlist.length);

    for (int i = 0; i < count; i++) {
      MTobj mtobj = MTobj(coinbaseid, from_minerobjlist[i], to_targetidlist[i]);
      taskList.add(mtobj);
    }
  }

  @override
  BaseWidgetState<BaseWidget> getState() {
    return MinerBatchTransferViewState();
  }
}

class MinerBatchTransferViewState extends BaseWidgetState<MinerBatchTransferView> {
  @override
  void initStateConfig() {
    super.initStateConfig();
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);

    viewSystemUiOverlayStyle = DeviceUtils.system_bar_main.copyWith(systemNavigationBarColor: ResColor.b_4);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(RSID.mlv_35.text+"(${widget.taskList.length})"); //"批量转移质押");
  }

  @override
  Widget buildWidget(BuildContext context) {
    Widget view = SingleChildScrollView(
      child: Column(
        children: widget.taskList.map((mtobj) {
          return getItemView(mtobj);
        }).toList(),
      ),
    );

    Widget stack = Stack(
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
          top: getAppBarHeight() + getTopBarHeight() + 45,
          bottom: 0,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              color: ResColor.b_2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                getHeaderView(),
                Expanded(child: view),
              ],
            ),
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: stack,
          ),
          getBatchBar(),
        ],
      ),
    );
  }

  Widget getBatchBar() {
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
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: LoadingButton(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  padding: EdgeInsets.only(bottom: 1),
                  height: 40,
                  gradient_bg: ResColor.lg_3,
                  color_bg: Colors.transparent,
                  disabledColor: Colors.transparent,
                  bg_borderradius: BorderRadius.circular(4),
                  text: RSID.mlv_21.text,
                  //"转移",Transfer
                  textstyle: TextStyle(
                    color: Colors.white,
                    fontSize: LocaleConfig.currentIsZh() ? 17 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                  onclick: (lbtn) {
                    // 输入密码 然后执行任务
                    BottomDialog.simpleAuth(
                        context, AccountMgr().currentAccount.password, (value) async {
                      Future.delayed(Duration(milliseconds: 200)).then((value) {
                        startTask();
                      });
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int flex_from = 1;
  int flex_amount = 1;
  int flex_to = 1;
  double state_w = 40;

  Widget getHeaderView() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: flex_from,
            child: Text(
              "From",
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: flex_amount,
            child: Text(
              "Amount",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: flex_to,
            child: Text(
              "To",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: state_w,
            child: Text(
              "State",
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getItemView(MTobj mtobj) {
    Widget v = Container(
      width: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: flex_from,
            child: Text(
              mtobj.from,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: flex_amount,
            child: Text(
              mtobj.amount,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: flex_to,
            child: Text(
              mtobj.to,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          InkWell(
            child: Container(
              width: state_w,
              alignment: Alignment.centerRight,
              child: mtobj?.state?.getIconData() == null
                  ? null
                  : Icon(
                      mtobj.state.getIconData(),
                      color: mtobj.state.getColor(),
                      size: state_w * 0.4,
                    ),
            ),
            onTap: () {
              if (mtobj.state == MTobjState.fail || mtobj.state == MTobjState.success) {
                // 查看错误信息
                String title = "${mtobj.from} -> ${mtobj.to}";
                String msg = "amount:${mtobj.amount}";
                if (mtobj.state == MTobjState.fail) {
                  msg += "\nstate:fail\nerror:${mtobj.errorMsg}";
                } else if (mtobj.state == MTobjState.success) {
                  msg += "\nstate:success\ncid:${mtobj.cid}";
                }
                MessageDialog.showMsgDialog(
                  context,
                  title: title,
                  msg: msg,
                  msgAlign: TextAlign.center,
                  btnLeft: RSID.copy.text,
                  onClickBtnLeft: (dialog) {
                    DeviceUtils.copyText(title + "\n" + msg);
                    showToast(RSID.copied.text);
                  },
                  btnRight: RSID.isee.text,
                  onClickBtnRight: (dialog) {
                    dialog.dismiss();
                  },
                );
              }
            },
          ),
        ],
      ),
    );
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          v,
          Container(height: 10),
          Divider(
            color: ResColor.white_50,
            height: 1,
            thickness: 1,
            endIndent: 0,
            indent: 0,
          ),
        ],
      ),
    );
  }

  startTask() async {
    GlobalKey<LoadingDialogViewState> loadingkey = GlobalKey();
    LoadingDialogView loadingdialogview = LoadingDialogView(
      "",
      key: loadingkey,
    );
    LoadingDialog.showLoadDialog(context, "", backClose: false, touchOutClose: false, dialogview: loadingdialogview);

    widget.taskList.forEach((mtobj) => mtobj.state = MTobjState.wait);
    setState(() {});

    for (int i = 0; i < widget.taskList.length; i++) {
      loadingkey?.currentState?.text = "${(i + 1)}/${widget.taskList.length}";
      loadingkey?.currentState?.setState(() {});

      MTobj mtobj = widget.taskList[i];

      setState(() {
        mtobj.state = MTobjState.working;
      });

      //执行转移
      ResultObj<String> robj = await AccountMgr().currentAccount.epikWallet.minerPledgeTransfer(mtobj.from, mtobj.to, mtobj.amount);

      //todo test
      // ResultObj<String> robj = await Future.delayed(Duration(milliseconds: 200)).then((value) {
      //   return ResultObj<String>()
      //     ..code = i % 13 == 0 ? -1 : 0
      //     ..data = "0xfffffffffffffffffffasdfasdfasdfasdf"
      //     ..errorMsg = "error asdfasdfasdf asd asdf  fawfe ";
      // });

      if (robj?.isSuccess) {
        mtobj.state = MTobjState.success;
        mtobj.cid = robj.data;
      } else {
        mtobj.state = MTobjState.fail;
        mtobj.errorMsg = robj?.errorMsg;
      }
      setState(() {});
      // loadingdialogview.
    }

    LoadingDialog.cloasLoadDialog(context);

    //dialog
    int success_num=0;
    int fail_num=0;
    for(MTobj mtobj in widget.taskList)
    {
        switch(mtobj.state)
        {
          case MTobjState.stop:
            break;
          case MTobjState.wait:
            break;
          case MTobjState.working:
            break;
          case MTobjState.success:
            success_num++;
            break;
          case MTobjState.fail:
            fail_num++;
            break;
        }
    }
    String msg="${RSID.mlv_24.text}\n\nTotal: ${widget.taskList.length}\nSuccess: ${success_num}\nFail: ${fail_num}";
    MessageDialog.showMsgDialog(
      context,
      title: RSID.mlv_35.text,
      msg: msg,
      msgAlign: TextAlign.center,
      btnRight: RSID.isee.text,
      onClickBtnRight: (dialog) {
        dialog.dismiss();
      },
    );
  }

//   Widget getInputCard()
//   {
//     List<Widget> items = [];
//
//     CurrencyAsset epk = AccountMgr().currentAccount.getCurrencyAssetByCs(CurrencySymbol.EPK);
//     String balance = StringUtils.formatNumAmount(epk?.balance ?? "0",
//         supply0: false, point: 2);
//
//
//     if (_tec_id == null)
//       _tec_id = new TextEditingController.fromValue(TextEditingValue(
//         text: "",
//         selection: new TextSelection.fromPosition(
//           TextPosition(affinity: TextAffinity.downstream, offset: "".length),
//         ),
//       ));
//
//     if (_tec_amount== null)
//       _tec_amount = new TextEditingController.fromValue(TextEditingValue(
//         text: "",
//         selection: new TextSelection.fromPosition(
//           TextPosition(affinity: TextAffinity.downstream, offset: "".length),
//         ),
//       ));
//
//     items.add(Text(
//       "NodeID",
//       style: const TextStyle(
//         fontSize: 14,
//         color: Colors.white,
//         fontWeight:FontWeight.bold,
//       ),
//     ));
//
//     items.add(
//       Container(
//         height: 40,
//         margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
//         decoration: BoxDecoration(
//           color: const Color(0xff424242),
//           borderRadius: BorderRadius.circular(4),
//         ),
//         child: TextField(
//           controller: _tec_id,
//           focusNode: _fn_id,
//           keyboardType: TextInputType.text,
//           //获取焦点时,启用的键盘类型
//           maxLines: 1,
// //              maxLength: 20, //允许输入的字符长度/ 右下角有数量提示
//           obscureText: false,
//           //是否是密码
//           inputFormatters: [
//             FilteringTextInputFormatter.allow(RegExpUtil.re_azAZ09),
//           ],
//           // 这里限制长度 不会有数量提示
//           decoration: InputDecoration(
//             // 以下属性可用来去除TextField的边框
//             border: InputBorder.none,
//             errorBorder: InputBorder.none,
//             focusedErrorBorder: InputBorder.none,
//             disabledBorder: InputBorder.none,
//             enabledBorder: InputBorder.none,
//             focusedBorder: InputBorder.none,
//             contentPadding: EdgeInsets.fromLTRB(14, 0, 14, 10),
//             hintText: "f0xxxx",
//             hintStyle: TextStyle(
//               color: ResColor.white_40,
//               fontSize: 17,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           cursorWidth: 2.0,
//           //光标宽度
//           cursorRadius: Radius.circular(2),
//           //光标圆角弧度
//           cursorColor: Colors.white,
//           //光标颜色
//           style: TextStyle(
//             fontSize: 17,
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//           onChanged: (value) {
//             // setState(() {
//             //   // to_address = _controllerToAddress.text.trim();
//             // });
//           },
//           onSubmitted: (value) {
//             FocusScope.of(context).requestFocus(_fn_amount);
//           }, // 是否隐藏输入的内容
//         ),
//       ),
//     );
//     items.add(Row(
//       children: [
//         Text(
//           RSID.aompv_2.text,//"流量质押数量",
//           style: const TextStyle(
//             fontSize: 14,
//             color: Colors.white,
//             fontWeight:FontWeight.bold,
//           ),
//         ),
//         Expanded(
//           child:  Text(
//             "${balance}${RSID.minerview_16.text}",
//             textAlign: TextAlign.right,
//             style: const TextStyle(
//               fontSize: 12,
//               color: Colors.white60,
//             ),
//           ),
//         ),
//       ],
//     ));
//
//     items.add(
//       Container(
//         height: 40,
//         margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
//         decoration: BoxDecoration(
//           color: const Color(0xff424242),
//           borderRadius: BorderRadius.circular(4),
//         ),
//         child: TextField(
//           controller: _tec_amount,
//           focusNode: _fn_amount,
//           keyboardType: TextInputType.text,
//           //获取焦点时,启用的键盘类型
//           maxLines: 1,
// //              maxLength: 20, //允许输入的字符长度/ 右下角有数量提示
//           obscureText: false,
//           //是否是密码
//           inputFormatters: [
//             FilteringTextInputFormatter.allow(RegExpUtil.re_float),
//           ],
//           // 这里限制长度 不会有数量提示
//           decoration: InputDecoration(
//             // 以下属性可用来去除TextField的边框
//             border: InputBorder.none,
//             errorBorder: InputBorder.none,
//             focusedErrorBorder: InputBorder.none,
//             disabledBorder: InputBorder.none,
//             enabledBorder: InputBorder.none,
//             focusedBorder: InputBorder.none,
//             contentPadding: EdgeInsets.fromLTRB(14, 0, 14, 10),
//             hintText: "0",
//             hintStyle: TextStyle(
//               color: ResColor.white_40,
//               fontSize: 17,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           cursorWidth: 2.0,
//           //光标宽度
//           cursorRadius: Radius.circular(2),
//           //光标圆角弧度
//           cursorColor: Colors.white,
//           //光标颜色
//           style: TextStyle(
//             fontSize: 17,
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//           onChanged: (value) {
//             // setState(() {
//             //   // to_address = _controllerToAddress.text.trim();
//             // });
//           },
//           onSubmitted: (value) {
//             closeInput();
//           }, // 是否隐藏输入的内容
//         ),
//       ),
//     );
//
//     items.add(LoadingButton(
//       margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
//       padding: EdgeInsets.only(bottom: 1),
//       width: double.infinity,
//       height: 40,
//       gradient_bg: ResColor.lg_2,
//       color_bg: Colors.transparent,
//       disabledColor: Colors.transparent,
//       bg_borderradius: BorderRadius.circular(4),
//       text: RSID.aompv_3.text,//"增加流量质押",
//       textstyle: TextStyle(
//         color: Colors.white,
//         fontSize: 17,//LocaleConfig.currentIsZh() ? 12 : 12,
//         fontWeight: FontWeight.bold,
//       ),
//       onclick: (lbtn) {
//         //输入 要增加的owner质押
//         String ownerid=_tec_id.text;
//         String amount_str =_tec_amount.text;
//         onClickRetrieveAdd(ownerid,amount_str);
//       },
//     ),);
//
//     return Container(
//       width: double.infinity,
//       margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
//       padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         color: ResColor.b_2,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: items,
//       ),
//     );
//   }

}
