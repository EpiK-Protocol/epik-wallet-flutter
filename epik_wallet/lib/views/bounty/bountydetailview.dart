// import 'dart:async';
// import 'dart:ui';
//
// import 'package:epikwallet/base/_base_widget.dart';
// import 'package:epikwallet/base/common_function.dart';
// import 'package:epikwallet/dialog/message_dialog.dart';
// import 'package:epikwallet/localstring/localstringdelegate.dart';
// import 'package:epikwallet/localstring/resstringid.dart';
// import 'package:epikwallet/logic/account_mgr.dart';
// import 'package:epikwallet/logic/api/api_bounty.dart';
// import 'package:epikwallet/logic/loader/DL_TepkLoginToken.dart';
// import 'package:epikwallet/main.dart';
// import 'package:epikwallet/model/BountyTask.dart';
// import 'package:epikwallet/model/BountyTaskUser.dart';
// import 'package:epikwallet/utils/device/deviceutils.dart';
// import 'package:epikwallet/utils/eventbus/event_manager.dart';
// import 'package:epikwallet/utils/eventbus/event_tag.dart';
// import 'package:epikwallet/utils/res_color.dart';
// import 'package:epikwallet/utils/string_utils.dart';
// import 'package:epikwallet/views/viewgoto.dart';
// import 'package:epikwallet/widget/LoadingButton.dart';
// import 'package:epikwallet/widget/text/diff_scale_text.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
//
// class BountyDetailView extends BaseWidget {
//   BountyTask bountyTask;
//
//   BountyDetailView(this.bountyTask);
//
//   BaseWidgetState<BaseWidget> getState() {
//     return BountyDetailViewState();
//   }
// }
//
// class BountyDetailViewState extends BaseWidgetState<BountyDetailView> {
//   bool isAdmin = false;
//
//   List<BountyTaskUser> userlist = [];
//
//   String title = ""; // "任务详情";
//   String title_2 = "";
//   bool useTitle2 = false;
//   double header_top = 0;
//   ScrollController _ScrollController;
//
//   @override
//   void initStateConfig() {
//     super.initStateConfig();
//
//     setTopBarVisible(false);
//     setAppBarVisible(false);
//
//     viewSystemUiOverlayStyle = DeviceUtils.system_bar_main
//         .copyWith(systemNavigationBarColor: ResColor.b_4);
//
//     if (widget.bountyTask.title.length > 16) {
//       title_2 = widget.bountyTask.title.trim().substring(0, 16) + "…";
//     } else {
//       title_2 = widget.bountyTask.title;
//     }
//
//     _ScrollController = ScrollController();
//     _ScrollController.addListener(() {
//       if (header_top == 0) header_top = 45.0 + 20 + 20;
//       bool _useTitle2 = _ScrollController.position.pixels >= header_top;
//       if (_useTitle2 != useTitle2) {
//         setState(() {
//           useTitle2 = _useTitle2;
//         });
//       }
//     });
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     title = ResString.get(context, RSID.bdv_1); //"任务详情";
//   }
//
//   ///导航栏appBar中间部分 ，不满足可以自行重写
//   Widget getAppBarCenter({Color color}) {
//     return Container(
//       padding: EdgeInsets.only(left: 40, right: 40),
//       alignment: Alignment.center,
//       width: double.infinity,
//       child: DiffScaleText(
//         text: useTitle2 ? title_2 : title,
//         textStyle: TextStyle(
//           color: Colors.white,
//           fontSize: 18,
//           fontWeight: FontWeight.w400,
//           fontFamily: fontFamily_def,
//         ),
//       ),
// //      Text(
// //        title,
// //        textAlign: TextAlign.center,
// //        softWrap: false,
// //        overflow: TextOverflow.ellipsis,
// //        style: TextStyle(
// //          fontSize: 18,
// //          color: Colors.black,
// //        ),
// //      ),
//     );
//   }
//
//   @override
//   void onCreate() {
//     super.onCreate();
//     eventMgr.add(EventTag.BOUNTY_EDITED_USER_LIST, eventcallback_edited);
//     refresh();
//   }
//
//   @override
//   void dispose() {
//     closeRefreshCountdown();
//     eventMgr.remove(EventTag.BOUNTY_EDITED_USER_LIST, eventcallback_edited);
//     super.dispose();
//   }
//
//   eventcallback_edited(arg) async {
//     userlist = BountyTaskUser.parseLinesData(widget.bountyTask.result);
//     setState(() {});
//   }
//
//   refresh() {
//     setLoadingWidgetVisible(true);
//     ApiBounty.getBountyInfo(
//             DL_TepkLoginToken.getEntity().getToken(), widget.bountyTask.id)
//         .then((httpjsonres) async {
//       if (httpjsonres != null && httpjsonres.code == 0) {
//         Map<String, dynamic> j_record = httpjsonres.jsonMap["task"];
//         if (j_record != null && j_record.length > 0) {
//           widget.bountyTask.parseJson(j_record);
//           userlist = BountyTaskUser.parseLinesData(widget.bountyTask.result);
//           closeStateLayout();
//
//           // if (userlist == null || userlist.isEmpty) //todo test
//           // {
//           //   userlist.add(BountyTaskUser("asdjfoaff", "0.0000000"));
//           //   userlist.add(BountyTaskUser("Chengyu612", "78.1234567890"));
//           // }
//
//           if (widget.bountyTask.status == BountyStateType.PUBLICITY &&
//               widget.bountyTask.getCountdownTimeNum() > 0) {
//             startRefreshCountdown();
//           } else {
//             closeRefreshCountdown();
//           }
//           return;
//         }
//       }
//       setErrorWidgetVisible(true);
//     });
//
//     // 是否是管理员
//     isAdmin =
//         widget.bountyTask.admin == AccountMgr()?.currentAccount?.mining_id;
//   }
//
//   Timer timerCountdown;
//   bool hasCountdownRefresh = false;
//
//   startRefreshCountdown() {
//     if (timerCountdown != null && timerCountdown.isActive) {
//       timerCountdown.cancel();
//     }
//     if (widget.bountyTask.status == BountyStateType.PUBLICITY)
//       timerCountdown = Timer.periodic(Duration(seconds: 1), (timer) {
//         if (widget.bountyTask.getCountdownTimeNum() <= 0) {
//           closeRefreshCountdown();
//           if (hasCountdownRefresh == false) {
//             hasCountdownRefresh = true;
//             refresh();
//           }
//         } else {
//           setState(() {});
//         }
//       });
//   }
//
//   closeRefreshCountdown() {
//     if (timerCountdown != null && timerCountdown.isActive) {
//       timerCountdown.cancel();
//     }
//     timerCountdown = null;
//   }
//
//   @override
//   Widget buildWidget(BuildContext context) {
//     List<Widget> views = [
//       Padding(
//         padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
//         child: Text(
//           widget?.bountyTask?.title ?? "",
//           style: TextStyle(
//               color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
//         ),
//       ),
//       Padding(
//         padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
//         child: Row(
//           children: [
//             Text(
//               "${ResString.get(context, RSID.bdv_2)} ",
//               //奖励区间
//               style: TextStyle(
//                 color: ResColor.white_80,
//                 fontSize: 14,
//               ),
//             ),
//             Text(
//               "${widget?.bountyTask?.reward}",
//               //奖励区间
//               style: TextStyle(
//                   color: ResColor.o_1,
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//       getHtmlView(),
//       Container(
//         height: 20,
//       ),
//     ];
//
//     if (userlist != null && userlist.length > 0) {
//       // 虚线分割线
//       // views.add(
//       //   Container(
//       //     height: 10,
//       //     alignment: Alignment.center,
//       //     child: DashLineWidget(
//       //       width: double.infinity,
//       //       height: 1,
//       //       dashWidth: 10,
//       //       dashHeight: 0.5,
//       //       spaceWidth: 5,
//       //       color: ResColor.white_20,
//       //       margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
//       //     ),
//       //   ),
//       // );
//       //
//       // //奖励分配公示
//       // views.add(
//       //   Container(
//       //     padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
//       //     width: double.infinity,
//       //     child: Row(
//       //       mainAxisAlignment: MainAxisAlignment.center,
//       //       children: [
//       //         Container(
//       //           height: 2,
//       //           width: 60,
//       //           decoration: BoxDecoration(
//       //             gradient: LinearGradient(
//       //               colors: [ResColor.white_20, Colors.transparent],
//       //               begin: Alignment.centerRight,
//       //               end: Alignment.centerLeft,
//       //             ),
//       //           ),
//       //         ),
//       //         Text(
//       //           ResString.get(context, RSID.bdv_3), //" 奖励分配公示 ",
//       //           style: TextStyle(
//       //             color: Colors.white,
//       //             fontSize: 14,
//       //           ),
//       //         ),
//       //         Container(
//       //           height: 2,
//       //           width: 60,
//       //           decoration: BoxDecoration(
//       //             gradient: LinearGradient(
//       //               colors: [ResColor.white_20, Colors.transparent],
//       //               begin: Alignment.centerLeft,
//       //               end: Alignment.centerRight,
//       //             ),
//       //           ),
//       //         ),
//       //       ],
//       //     ),
//       //   ),
//       // );
//
//       views.addAll(userlist.map((item) => getUserItem(item)).toList());
//     }
//
//     views.add(Container(height: 30));
//
//     Widget w1 = SingleChildScrollView(
//       controller: _ScrollController,
//       padding: EdgeInsets.fromLTRB(30, 45, 30, 45),
//       child: Container(
//         constraints: BoxConstraints(
//           minHeight: getScreenHeight() -
//               BaseFuntion.topbarheight -
//               BaseFuntion.appbarheight_def,
//         ),
//         decoration: BoxDecoration(
//           color: ResColor.b_3,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         padding: EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: views,
//         ),
//       ),
//     );
//
//     double top = getAppBarHeight() + getTopBarHeight();
//
//     String countdown = widget?.bountyTask?.getCountdownString();
//     // countdown = "1天 01:12:34";
//
//     return Column(
//       children: [
//         Expanded(
//           child: Stack(
//             children: [
//               // 顶部背景
//               Positioned(
//                 left: 0,
//                 top: 0,
//                 right: 0,
//                 height: top + 128,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: ResColor.lg_1,
//                     borderRadius:
//                         BorderRadius.vertical(bottom: Radius.circular(20)),
//                   ),
//                   child: Column(
//                     children: [
//                       getTopBar(),
//                       getAppBar(),
//                     ],
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 0,
//                 top: top,
//                 right: 0,
//                 bottom: 0,
//                 child: w1,
//               ),
//               // Positioned(
//               //   left: 0,
//               //   right: 0,
//               //   bottom: 0,
//               //   child: Container(
//               //     height: 10,
//               //     decoration: BoxDecoration(
//               //       gradient: const LinearGradient(
//               //         colors: [Color(0x10ffffff), Color(0x00ffffff)],
//               //         begin: Alignment.bottomCenter,
//               //         end: Alignment.topCenter,
//               //       ),
//               //     ),
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//         SafeArea(
//           top: false,
//           bottom: true,
//           left: false,
//           right: false,
//           child: Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: ResColor.b_4,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//             ),
//             child: Row(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.only(right: 10),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         RSID.bdv_4.text, //任务状态:
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: ResColor.white_60,
//                         ),
//                       ),
//                       Container(height: 4),
//                       Text(
//                         widget?.bountyTask?.status.getName(), //可认领 公式中 已完成
//                         style: TextStyle(
//                           fontSize: 17,
//                           color: ResColor.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: StringUtils.isEmpty(countdown)
//                       ? Container()
//                       : Padding(
//                           padding: EdgeInsets.only(right: 10),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(
//                                 RSID.bdv_12.text, ////剩余:
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   color: ResColor.white_60,
//                                 ),
//                               ),
//                               Container(height:4),
//                               Text(
//                                 countdown,
//                                 style: TextStyle(
//                                   fontSize: 17,
//                                   color: ResColor.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                 ),
//                 if (isAdmin == true &&
//                     widget.bountyTask.status != BountyStateType.END)
//                   LoadingButton(
//                     height: 40,
//                     width: null,
//                     padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
//                     margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
//                     bg_borderradius: BorderRadius.circular(4),
//                     color_bg: const Color(0xff424242),
//                     disabledColor: const Color(0xff424242),
//                     text: RSID.bdv_13.text,
//                     textstyle: TextStyle(
//                       color: Colors.white,
//                       fontSize: 17,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     onclick: (lbtn) {
//                       ViewGT.showBountyEditView(context, widget?.bountyTask);
//                     },
//                   ),
//                 getContactView(),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget getHtmlView() {
//     HtmlWidget htmlwidget = HtmlWidget(
//       widget?.bountyTask?.content ?? ResString.get(context, RSID.content_empty),
//       //"无详情",
//       webView: true,
//       onTapUrl: (url) {
//         if (StringUtils.isEmpty(url)) return;
//         ViewGT.openOutUrl(url);
//       },
//       textStyle: TextStyle(
//         fontSize: 16,
//         height: 1.5,
//         color: Colors.white,
//       ),
//       // config: HtmlWidgetConfig(
//       //   bodyPadding: const EdgeInsets.fromLTRB(15, 15, 15, 0), //内容边距
//       //   textStyle: TextStyle(
//       //     fontSize: 16,
//       //     height: 1.5,
//       //     color: Color(0xff666666),
//       //   ), // 默认文本样式
//       //   onTapUrl: (url) {
//       //     if (StringUtils.isEmpty(url)) return;
//       //     ViewGT.openOutUrl(url);
//       //   },
// //        builderCallback: (meta, e) {
// //          if (e.localName == "a") {
// //            String url = e.attributes["href"];
// //            if (StringUtils.isNotEmpty(url) && !url.startsWith("http")) {
// //              e.attributes["href"] = ServiceInfo.HOST + url;
// //              print("builderCallback---href fix ->" + e.attributes["href"]);
// //            }
// //          }else if(e.localName == "img") {
// //            String url = e.attributes["src"];
// //            if (StringUtils.isNotEmpty(url) && !url.startsWith("http")) {
// //              e.attributes["src"] = ServiceInfo.HOST + url;
// //              print("builderCallback---href fix ->" + e.attributes["src"]);
// //            }
// //          }
// //          return meta;
// //        },
// //       ),
//     );
//
//     return Container(
//       padding: const EdgeInsets.fromLTRB(0, 0, 0, 0), //内容边距
//       child: htmlwidget,
//     );
//   }
//
//   Widget getContactView() {
//
//     String text1 = "";
//     switch (widget?.bountyTask?.status) {
//       case BountyStateType.PUBLICITY:
//         text1 = ResString.get(context, RSID.bdv_14); // "申诉
//         break;
//       case BountyStateType.END:
//         text1 = ResString.get(context, RSID.bdv_15); // "感谢
//         break;
//       case BountyStateType.AVAILABLE:
//       default:
//         text1 = ResString.get(context, RSID.bdv_16); //"认领
//         break;
//     }
//
//
//     return LoadingButton(
//       height: 40,
//       width: null,
//       padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
//       bg_borderradius: BorderRadius.circular(4),
//       gradient_bg: ResColor.lg_1,
//       color_bg: widget?.bountyTask?.status == BountyStateType.AVAILABLE
//           ? Colors.transparent
//           : const Color(0xff424242),
//       disabledColor: widget?.bountyTask?.status == BountyStateType.AVAILABLE
//           ? Colors.transparent
//           : const Color(0xff424242),
//       text: text1,
//       textstyle: TextStyle(
//         color: Colors.white,
//         fontSize: 17,
//         fontWeight: FontWeight.bold,
//       ),
//       onclick: (lbtn) {
//
//         String text = "";
//         switch (widget?.bountyTask?.status) {
//           case BountyStateType.PUBLICITY:
//             text = ResString.get(context, RSID.bdv_6); // "申诉方式: ";
//             break;
//           case BountyStateType.END:
//             text = ResString.get(context, RSID.bdv_7); // "感谢方式: ";
//             break;
//           case BountyStateType.AVAILABLE:
//           default:
//             text = ResString.get(context, RSID.bdv_8); //"认领方式: ";
//             break;
//         }
//         String wechat = widget?.bountyTask?.admin_weixin;
//         // "联系负责人微信 " + wechat;
//
//         MessageDialog.showMsgDialog(context,
//         title: text,
//           msg: ResString.get(context, RSID.bdv_9) + wechat,
//         btnRight: RSID.confirm.text,
//           onClickBtnRight: (dialog) {
//             dialog.dismiss();
//             DeviceUtils.copyText(wechat);
//             showToast(ResString.get(context, RSID.bdv_10)); //"负责人微信已复制");
//             ViewGT.openOutUrl("weixin://");
//           },
//         );
//
//
//       },
//     );
//
//     // return Container(
//     //   padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
//     //   width: double.infinity,
//     //   height: 40,
//     //   child: FlatButton(
//     //     highlightColor: Colors.white24,
//     //     splashColor: Colors.white24,
//     //     onPressed: () {
//     //       DeviceUtils.copyText(wechat);
//     //       showToast(ResString.get(context, RSID.bdv_10)); //"负责人微信已复制");
//     //       ViewGT.openOutUrl("weixin://");
//     //     },
//     //     child: Text(
//     //       text,
//     //       textAlign: TextAlign.center,
//     //       style: TextStyle(
//     //         color: Colors.white,
//     //         fontSize: 16,
//     //       ),
//     //     ),
//     //     color: ResColor.b_2,
//     //     shape: RoundedRectangleBorder(
//     //       borderRadius: BorderRadius.all(Radius.circular(20)),
//     //     ),
//     //   ),
//     // );
//   }
//
//   Widget getUserItem(BountyTaskUser user) {
//     return Container(
//       padding: EdgeInsets.fromLTRB(10, 13, 10, 13),
//       margin: EdgeInsets.fromLTRB(0, 0, 0, 6),
//       decoration: BoxDecoration(
//         color: ResColor.white_20,
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   user.userid,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: ResColor.white_80,
//                   ),
//                 ),
//               ),
//               Text(
//                 ResString.get(context, RSID.bdv_11, replace: [user.amount_str]),
//                 //"+ ${user.amount_str} 积分",
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: ResColor.o_1,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
