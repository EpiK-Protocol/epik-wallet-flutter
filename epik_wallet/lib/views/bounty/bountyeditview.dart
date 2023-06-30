// import 'package:epikwallet/base/_base_widget.dart';
// import 'package:epikwallet/dialog/message_dialog.dart';
// import 'package:epikwallet/localstring/localstringdelegate.dart';
// import 'package:epikwallet/localstring/resstringid.dart';
// import 'package:epikwallet/logic/api/api_bounty.dart';
// import 'package:epikwallet/logic/loader/DL_TepkLoginToken.dart';
// import 'package:epikwallet/model/BountyTask.dart';
// import 'package:epikwallet/model/BountyTaskUser.dart';
// import 'package:epikwallet/utils/RegExpUtil.dart';
// import 'package:epikwallet/utils/eventbus/event_manager.dart';
// import 'package:epikwallet/utils/eventbus/event_tag.dart';
// import 'package:epikwallet/utils/res_color.dart';
// import 'package:epikwallet/utils/string_utils.dart';
// import 'package:epikwallet/widget/LoadingButton.dart';
// import 'package:epikwallet/widget/rect_getter.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/src/widgets/framework.dart';
//
// class BountyEditView extends BaseWidget {
//   BountyTask bountyTask;
//
//   BountyEditView(this.bountyTask);
//
//   BaseWidgetState<BaseWidget> getState() {
//     return BountyEditViewState();
//   }
// }
//
// class BountyEditViewState extends BaseWidgetState<BountyEditView> {
//   GlobalKey globalKey_bottom = RectGetter.createGlobalKey();
//   double bottom_h = 0;
//
//   String input_text = "";
//   TextEditingController _tec_text;
//
//   int linesCount = 0;
//   String lineNum = "1";
//
//   List<BountyTaskUser> userlist;
//   int userCount = 0;
//   double amountCount = 0;
//
//   void initStateConfig() {
// //    setAppBarTitle("编辑奖励");
//     resizeToAvoidBottomPadding = true;
//     input_text = widget?.bountyTask?.result ?? "";
//     makeLineNum();
//     onInputChange(input_text);
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     setAppBarTitle(ResString.get(context, RSID.bdv_5));
//   }
//
//   Widget buildWidget(BuildContext context) {
//     if (_tec_text == null)
// //      _tec_text = new TextEditingController(text: input_text);
//       _tec_text = new TextEditingController.fromValue(TextEditingValue(
//         text: input_text,
//         selection: new TextSelection.fromPosition(
//           TextPosition(
//               affinity: TextAffinity.downstream, offset: input_text.length),
//         ),
//       ));
//
//     return Container(
//       child: SafeArea(
//         top: false,
//         left: false,
//         right: false,
//         bottom: true,
//         child: Stack(
//           children: <Widget>[
//             // 文本编辑
//
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               bottom: bottom_h,
//               child: Container(
//                 color: ResColor.b_3,
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.all(0),
//                   child: Container(
//                     padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Container(
//                           padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
//                           child: Text(
//                             lineNum,
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: ResColor.white_80,
//                               height: 2,
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: Container(
//                             constraints: BoxConstraints(
//                               maxHeight: double.infinity,
//                               minHeight: 500.0,
//                             ),
//                             child: TextField(
//                               controller: _tec_text,
//                               maxLines: null,
//                               keyboardType: TextInputType.multiline,
//                               autofocus: false,
//                               inputFormatters: [
//                                 //WhitelistingTextInputFormatter(RegExpUtil.re_ascii_00_7f)
//                                 FilteringTextInputFormatter.allow(RegExpUtil.re_ascii_00_7f)
//                               ],
//                               decoration: InputDecoration(
//                                 // 以下属性可用来去除TextField的边框
//                                 border: InputBorder.none,
//                                 errorBorder: InputBorder.none,
//                                 focusedErrorBorder: InputBorder.none,
//                                 disabledBorder: InputBorder.none,
//                                 enabledBorder: InputBorder.none,
//                                 focusedBorder: InputBorder.none,
//                                 contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
//                                 hintText: ResString.get(context, RSID.bev_1),
//                                 //"微信号,积分数量 (请按此格式输入,逗号分隔)\n",
//                                 hintStyle: TextStyle(
//                                   fontSize: 16,
//                                   color: ResColor.white_50,
//                                   height: 2,
//                                 ),
//                               ),
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: ResColor.white_80,
//                                 height: 2,
//                               ),
//                               cursorWidth: 2.0,
//                               //光标宽度
//                               cursorRadius: Radius.circular(2),
//                               //光标圆角弧度
//                               cursorColor: ResColor.main_1,
//                               //光标颜色
//                               onChanged: (value) {
//                                 input_text = _tec_text.text;
//                                 makeLineNum();
//                                 onInputChange(input_text);
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             // 底部按钮
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: Container(
//                 width: double.infinity,
//                 child: Column(
//                   children: <Widget>[
//                     Container(
//                       height: 10,
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0x10ffffff), Color(0x00ffffff)],
//                           begin: Alignment.bottomCenter,
//                           end: Alignment.topCenter,
//                         ),
//                       ),
//                     ),
//                     RectGetter(
//                       key: globalKey_bottom,
//                       callback: (timeStamp, rect, isFirst) {
//                         // 底部计算出高度后 重新调整顶部的空白区域
//                         double h = rect?.height ?? 0;
//                         if (isFirst || h != bottom_h)
//                           setState(() {
//                             // Rect rect_comment = RectGetter.getRectFromKey(globalKey_bottom);
//                             bottom_h = h;
//                           });
//                       },
//                       child: Container(
//                         padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
//                         child: Column(
//                           children: <Widget>[
//                             // 数量
//                             Row(
//                               children: <Widget>[
//                                 Expanded(
//                                   child: Text(
//                                     ResString.get(context, RSID.bev_2) +
//                                         "${userCount}",
//                                     // "总人数\n$userCount", // todo
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                                 Container(
//                                   height: 16,
//                                   width: 1,
//                                   color: Colors.white38,
//                                 ),
//                                 Expanded(
//                                   child: Text(
//                                     ResString.get(context, RSID.bev_3) +
//                                         "${StringUtils.formatNumAmount(amountCount, point: 8, supply0: false)}", //TODO 总积分
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//
//                             // 按钮
//
//                             //编辑
//                             LoadingButton(
//                               gradient_bg: ResColor.lg_1,
//                               color_bg: Colors.transparent,
//                               disabledColor: Colors.transparent,
//                               margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
//                               width: double.infinity,
//                               height: 40,
//                               text:ResString.get(context, RSID.bev_4),
//                               //"提交奖励分配方案进行公示",
//                               textstyle: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               bg_borderradius: BorderRadius.circular(4),
//                               onclick: (lbtn) {
//                                 onClickPost();
//                               },
//                             ),
//                             // Container(
//                               // child: FlatButton(
//                               //   highlightColor: Colors.white24,
//                               //   splashColor: Colors.white24,
//                               //   onPressed: () {
//                               //     onClickPost();
//                               //   },
//                               //   child: Text(
//                               //     ResString.get(context, RSID.bev_4),
//                               //     //"提交奖励分配方案进行公示",
//                               //     textAlign: TextAlign.center,
//                               //     style: TextStyle(
//                               //       color: Colors.white,
//                               //       fontSize: 16,
//                               //     ),
//                               //   ),
//                               //   color: ResColor.main_1,
//                               //   shape: RoundedRectangleBorder(
//                               //     borderRadius:
//                               //         BorderRadius.all(Radius.circular(20)),
//                               //   ),
//                               // ),
//                             // ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   onInputChange(String inputtext) async {
//     userlist = BountyTaskUser.parseLinesData(inputtext);
//     if (userlist.length > 0) {
//       calcAmountCount();
//       setState(() {});
//     }
//   }
//
//   calcAmountCount() {
//     int _userCount = userlist.length;
//     double _amountCount = 0;
//     for (BountyTaskUser item in userlist) {
//       _amountCount += item.amount;
//     }
//     userCount = _userCount;
//     amountCount = _amountCount;
//   }
//
//   String makeLineNum() {
//     List<String> lines = (input_text ?? "").split("\n");
//     int _linesCount = lines == null ? 0 : lines.length;
//     if (_linesCount != linesCount) {
//       linesCount = _linesCount;
//       if (linesCount == 0) {
//         lineNum = "1";
//       } else {
//         lineNum = "";
//         for (int i = 1; i <= linesCount; i++) {
//           lineNum += "$i\n";
//         }
//       }
//       if (mounted) setState(() {});
//     }
//   }
//
//   onClickPost() {
//     if (userlist == null || userlist.length == 0) {
//       showToast(ResString.get(context, RSID.bev_5)); //"请输入奖励分配方案");
//       return;
//     }
//
//     MessageDialog.showMsgDialog(
//       context,
//       title: ResString.get(context, RSID.tip),
//       //"提示",
//       msg: ResString.get(context, RSID.bev_6),
//       //"您确认要提交当前奖励分配方案并进行公示吗？",
//       btnLeft: ResString.get(context, RSID.cancel),
//       // "取消",
//       btnRight: ResString.get(context, RSID.confirm),
//       //"确定",
//       onClickBtnLeft: (dialog) => dialog.dismiss(),
//       onClickBtnRight: (dialog) {
//         dialog.dismiss();
//         postData(userlist);
//       },
//     );
//   }
//
//   postData(List<BountyTaskUser> data) {
//     showLoadDialog(
//       ResString.get(context, RSID.bev_7), //"正在提交...",
//       touchOutClose: false,
//       backClose: false,
//       onShow: () async {
//         String result = BountyTaskUser.makePostData(data);
//         ApiBounty.adminSaveTaskPublicity(
//                 DL_TepkLoginToken.getEntity().getToken(),
//                 widget.bountyTask.id,
//                 result)
//             .then((httpjsonres) {
//           closeLoadDialog();
//           if (httpjsonres.code == 0) {
//             //提交成功
//             widget.bountyTask.result = result;
//             widget.bountyTask.status = BountyStateType.PUBLICITY;
//
//             showToast(ResString.get(context, RSID.bev_8)); //"奖励分配方案已提交并公示");
//
//             eventMgr.send(EventTag.BOUNTY_EDITED_USER_LIST, null);
//
//             finish();
//           } else {
//             // 提交失败
//             showToast(httpjsonres.msg ??
//                 ResString.get(context, RSID.request_failed_retry)); //"提交失败");
//           }
//         });
//       },
//     );
//   }
// }
