// import 'package:epikwallet/base/base_inner_widget.dart';
// import 'package:epikwallet/localstring/localstringdelegate.dart';
// import 'package:epikwallet/localstring/resstringid.dart';
// import 'package:epikwallet/logic/EpikWalletUtils.dart';
// import 'package:epikwallet/logic/account_mgr.dart';
// import 'package:epikwallet/logic/api/api_testnet.dart';
// import 'package:epikwallet/main.dart';
// import 'package:epikwallet/model/MiningRank.dart';
// import 'package:epikwallet/utils/JsonUtils.dart';
// import 'package:epikwallet/utils/device/deviceutils.dart';
// import 'package:epikwallet/utils/eventbus/event_manager.dart';
// import 'package:epikwallet/utils/eventbus/event_tag.dart';
// import 'package:epikwallet/utils/http/httputils.dart';
// import 'package:epikwallet/utils/res_color.dart';
// import 'package:epikwallet/utils/string_utils.dart';
// import 'package:epikwallet/views/mainview.dart';
// import 'package:epikwallet/views/viewgoto.dart';
// import 'package:epikwallet/widget/list_view.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/widgets.dart';
//
// class MiningView extends BaseInnerWidget {
//   MiningView(Key key) : super(key: key) {}
//
//   @override
//   BaseInnerWidgetState<BaseInnerWidget> getState() {
//     return MiningViewState();
//   }
//
//   @override
//   int setIndex() {
//     return 1;
//   }
// }
//
// class MiningViewState extends BaseInnerWidgetState<MiningView> {
//   List headerList = [];
//   List<MiningRank> datalist = [];
//   GlobalKey<ListPageState> key_scroll;
//
//   /// 总奖励
//   double total_supply = 0;
//
//   /// 已发放
//   double issuance = 0;
//
//   // 已报名才有ID
//   String mining_id = "";
//
//   String mining_weixin = "";
//   String mining_platform = "";
//
//   //等待审核pending/ 已经通过confirmed/ 拒绝rejected
//   String mining_status;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   void initStateConfig() {
// //    setAppBarTitle("预挖排行");
//     isTopBarShow = true; //状态栏是否显示
//     isAppBarShow = true; //导航栏是否显示
//
//     key_scroll = GlobalKey();
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     setAppBarTitle(ResString.get(context, RSID.main_mv_1));
//   }
//
//   @override
//   void onCreate() {
//     eventMgr.add(EventTag.REFRESH_MININGVIEW, eventcallback_refresh);
//     eventMgr.add(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventcallback_refresh);
//     refresh();
//   }
//
//   @override
//   void dispose() {
//     eventMgr.remove(EventTag.REFRESH_MININGVIEW, eventcallback_refresh);
//     eventMgr.remove(
//         EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventcallback_refresh);
//
//     super.dispose();
//   }
//
//   eventcallback_refresh(arg) {
//     refresh();
//   }
//
//   bool hasRefresh = false;
//   bool isLoading = false;
//
//   refresh() {
//     hasRefresh = true;
//
//     isLoading = true;
//     setLoadingWidgetVisible(true);
//
//     String address = AccountMgr()?.currentAccount?.hd_eth_address ?? "";
//     ApiTestNet.home(address).then((httpjsonres) => jsoncallback(httpjsonres));
//   }
//
//   jsoncallback(HttpJsonRes httpjsonres) {
//     isLoading = false;
//     if (httpjsonres != null && httpjsonres.code == 0) {
//       mining_id = httpjsonres.jsonMap["id"];
//       mining_weixin = httpjsonres.jsonMap["weixin"];
//       mining_platform = httpjsonres.jsonMap["platform"];
//       mining_status =
//           httpjsonres.jsonMap["status"]; //等待审核pending/ 已经通过confirmed/ 拒绝reject
//
//       if (StringUtils.isEmpty(mining_platform))
//         mining_platform = BingAccountPlatform.WEIXIN;
//       dlog("platform = $mining_platform");
//
//       AccountMgr()?.currentAccount?.mining_id = mining_id;
//       AccountMgr()?.currentAccount?.mining_bind_account = mining_weixin;
//       AccountMgr()?.currentAccount?.mining_account_platform = mining_platform;
//
//       Map testnet = httpjsonres.jsonMap["testnet"];
//       total_supply = StringUtils.parseDouble(testnet["total_supply"], 0);
//       issuance = StringUtils.parseDouble(testnet["issuance"], 0);
//
//       List<MiningRank> temp = JsonArray.parseList<MiningRank>(
//           testnet["top_list"], (json) => MiningRank.fromJson(json));
//       datalist = temp ?? [];
//
//       if (datalist.length == 0) {
//         headerList = [ListPageDefState(ListPageDefStateType.EMPTY)];
//       } else {
//         headerList = [];
//       }
//
//       closeStateLayout();
//     } else {
//       setErrorWidgetVisible(true);
//     }
//   }
//
//   @override
//   void onClickErrorWidget() {
//     refresh();
// //    ViewGT.showMiningSignupView(context);
//   }
//
//   String amountFormat(double amount) {
//     return StringUtils.formatNumAmountLocaleUnit(amount, appContext, point: 2);
//   }
//
//   @override
//   Widget buildWidget(BuildContext context) {
//     Widget listpage = ListPage(
//       datalist,
//       headerList: headerList,
//       headerCreator: stateHeaderWidgetBuild,
//       itemWidgetCreator: (context, position) {
//         return GestureDetector(
//           onTap: () => onItemClick(position),
//           child: getRankItem(datalist[position], position),
//         );
//       },
//       pullRefreshCallback: _pullRefreshCallback,
//       key: key_scroll,
//       needNoMoreTipe: false,
//     );
//
//     return Column(children: [
//       getHeader(),
//       Expanded(
//         child: listpage,
//       ),
//     ]);
//
// //    return SingleChildScrollView(
// //      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
// //      physics: AlwaysScrollableScrollPhysics(),
// //      child: Container(
// //        child: Column(
// //          children: list,
// //        ),
// //      ),
// //    );
//   }
//
//   Widget getHeader() {
//     return Container(
//       margin: EdgeInsets.only(top: 0),
//       padding: EdgeInsets.all(15),
//       height: StringUtils.isEmpty(mining_weixin) ? 223 : 250,
//       width: double.infinity,
//       child: Card(
//         color: ResColor.main,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(Radius.circular(12.0)),
//         ),
//         clipBehavior: Clip.antiAlias,
//         //card内容按边框剪切
//         elevation: 10,
//         child: Stack(
//           children: <Widget>[
//             //背景图
//             Positioned(
//               left: 0,
//               right: 0,
//               top: 0,
//               bottom: 0,
//               child: Image(
//                 image: AssetImage("assets/img/bg_header.png"),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             //背景颜色遮罩
//             Positioned(
//               left: 0,
//               right: 0,
//               top: 0,
//               bottom: 0,
//               child: Container(
//                 color: Colors.black26,
//               ),
//             ),
//             // 总奖励 | 已发奖励
//             Positioned(
//               left: 0,
//               right: 0,
//               top: 0,
//               height: 140,
//               //173
//               child: Container(
//                 child: Row(
//                   children: <Widget>[
//                     //隐藏预挖
//                     // Expanded(
//                     //   child: Column(
//                     //     mainAxisAlignment: MainAxisAlignment.center,
//                     //     children: <Widget>[
//                     //       Text(
//                     //         ResString.get(context, RSID.main_mv_2), //"预挖总奖励",
//                     //         style: TextStyle(
//                     //           color: Colors.white,
//                     //           fontSize: 18,
//                     //         ),
//                     //       ),
//                     //       Container(height: 10),
//                     //       Text(
//                     //         amountFormat(total_supply),
//                     //         style: TextStyle(
//                     //           color: Colors.white,
//                     //           fontSize: 30,
//                     //           fontFamily: "DIN_Condensed_Bold",
//                     //         ),
//                     //       ),
//                     //       Text(
//                     //         "ERC20-EPK",
//                     //         style: TextStyle(
//                     //           color: Colors.white,
//                     //           fontSize: 10,
//                     //           fontFamily: "DIN_Condensed_Bold",
//                     //         ),
//                     //       ),
//                     //     ],
//                     //   ),
//                     // ),
//                     // Container(
//                     //   width: 2,
//                     //   height: 70,
//                     //   decoration: BoxDecoration(
//                     //     color: Colors.grey[800],
//                     //     borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                     //   ),
//                     // ),
//                     Expanded(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           Text(
//                             ResString.get(context, RSID.main_mv_3), //"已发放奖励",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                             ),
//                           ),
//                           Container(height: 10),
//                           Text(
//                             amountFormat(issuance),
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 30,
//                               fontFamily: "DIN_Condensed_Bold",
//                             ),
//                           ),
//                           Text(
//                             "ERC20-EPK",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontFamily: "DIN_Condensed_Bold",
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             // 按钮
//             getActionBtn(),
//             // 微信号
//             if (StringUtils.isNotEmpty(mining_weixin))
//               Positioned(
//                 left: 0,
//                 right: 0,
//                 bottom: 20,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 18,
//                       height: 18,
//                       margin: EdgeInsets.fromLTRB(4, 2, 4, 0),
//                       child: mining_platform == BingAccountPlatform.WEIXIN
//                           ? ImageIcon(
//                               AssetImage("assets/img/ic_wechat.png"),
//                               size: 18,
//                               color: Color(0xff88c42a),
//                             )
//                           : Image(
//                               image: AssetImage("assets/img/ic_telgram.png"),
//                               width: 18,
//                               height: 18,
//                             ),
//                     ),
//                     Text(
//                       "${mining_weixin}",
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.white54,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             // ID
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: InkWell(
//                 onTap: () {
//                   if (StringUtils.isNotEmpty(mining_id)) {
//                     DeviceUtils.copyText(mining_id);
//                     showToast(
//                         ResString.get(context, RSID.main_mv_4)); //"已复制ID");
//                   }
//                 },
//                 child: Container(
//                   height: 20,
//                   child: Text(
//                     (StringUtils.isEmpty(mining_id)) ? "" : "ID: ${mining_id}",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white54,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   double rankitem_t_w = 100;
//
//   Widget getRankItem(MiningRank data, int index) {
//     return Container(
//       padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
//       color: mining_id == data.id ? Colors.grey[100] : Colors.transparent,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Container(
//             width: 50,
//             padding: EdgeInsets.fromLTRB(0, 2, 0, 0),
//             child: Text(
//               (index + 1).toString() + ".",
//               style: TextStyle(
//                 color: index < 3 ? Colors.black : Colors.black45,
//                 fontSize: 20,
//                 fontFamily: "DIN_Condensed_Bold",
//               ),
//             ),
//           ),
//           Expanded(
//             child: Column(
//               children: <Widget>[
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Container(
//                       child: Text(
//                         ResString.get(context, RSID.main_mv_5), //"累计奖励: ",
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ),
//                     Text(
//                       StringUtils.formatNumAmount(data?.profit ?? "0",
//                           point: 2),
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     Expanded(
//                       child: Container(
//                         padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
//                         child: Text(
//                           "ERC20-EPK",
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Container(height: 5),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
// //                    Container(
// //                      child: Text(
// //                        "UUID",
// //                        style: TextStyle(
// //                          fontSize: 12,
// //                          color: Colors.black87,
// //                        ),
// //                      ),
// //                      width: rankitem_t_w,
// //                    ),
//                     Expanded(
//                       child: Text(
//                         "ID: " + (data?.id ?? "----"),
//                         softWrap: false,
//                         overflow: TextOverflow.fade,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
// //                Row(
// //                  crossAxisAlignment: CrossAxisAlignment.start,
// //                  children: <Widget>[
// //                    Container(
// //                      child: Text(
// //                        "tEPK",
// //                        style: TextStyle(
// //                          fontSize: 12,
// //                          color: Colors.black87,
// //                        ),
// //                      ),
// //                      width: rankitem_t_w,
// //                    ),
// //                    Expanded(
// //                      child: Text(
// //                        data?.epik_address ?? "----",
// //                        softWrap: false,
// //                        maxLines: 1,
// //                        overflow: TextOverflow.fade,
// //                        style: TextStyle(
// //                          fontSize: 12,
// //                          color: Colors.black87,
// //                        ),
// //                      ),
// //                    ),
// //                  ],
// //                ),
// //                Row(
// //                  crossAxisAlignment: CrossAxisAlignment.start,
// //                  children: <Widget>[
// //                    Container(
// //                      child: Text(
// //                        "ERC20-EPK",
// //                        style: TextStyle(
// //                          fontSize: 12,
// //                          color: Colors.black87,
// //                        ),
// //                      ),
// //                      width: rankitem_t_w,
// //                    ),
// //                    Expanded(
// //                      child: Text(
// //                        data?.erc20_address ?? "----",
// //                        softWrap: false,
// //                        maxLines: 1,
// //                        overflow: TextOverflow.fade,
// //                        style: TextStyle(
// //                          fontSize: 12,
// //                          color: Colors.black87,
// //                        ),
// //                      ),
// //                    ),
// //                  ],
// //                ),
//                 Container(height: 14),
//                 Divider(
//                   height: 1,
//                   thickness: 1,
//                   color: Color(0xffeeeeee),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget getActionBtn() {
//     String text = ResString.get(context, RSID.main_mv_6); //"报名";
//     bool canClick = true;
//
//     switch (mining_status) {
//       //等待审核
//       case "pending":
//         {
//           text = ResString.get(context, RSID.main_mv_7); //"审核中";
//           canClick = false;
//           break;
//         }
//       case "confirmed":
//         {
//           text = ResString.get(context, RSID.main_mv_8); //"预挖奖励";
//           canClick = true;
//           break;
//         }
//       case "rejected":
//         {
//           text = ResString.get(context, RSID.main_mv_9); // "报名已被拒绝";
//           canClick = false;
//           break;
//         }
//       default:
//         {
//           text = ResString.get(context, RSID.main_mv_6); // "报名";
//           canClick = true;
//           break;
//         }
//     }
//
//     if (canClick) {
//       return Positioned(
//         left: 90,
//         right: 90,
//         top: 120,
//         child: FlatButton(
//           highlightColor: Colors.white24,
//           splashColor: Colors.white24,
//           onPressed: () {
//             onClickAction();
//           },
//           child: Text(
//             text,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//             ),
//           ),
//           color: Color(0xff393E45),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(22)),
//           ),
//         ),
//       );
//     } else {
//       return Positioned(
//         left: 15,
//         right: 15,
//         top: 133,
//         child: Container(
//           child: Text(
//             text,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//             ),
//           ),
//         ),
//       );
//     }
//   }
//
//   onItemClick(position) {
//     //todo
//   }
//
//   onClickAction() {
//     if (AccountMgr().currentAccount == null) {
//       //没账号 切换到钱包页面
//       eventMgr.send(EventTag.CHANGE_MAINVIEW_INDEX, main_subviewTypes.indexOf(MainSubViewType.WALLETVIEW));
//       return;
//     }
//
//     switch (mining_status) {
//       case "confirmed":
//         {
//           // 预挖奖励
//           ViewGT.showMiningProfitView(context, mining_id);
//           return;
//         }
//       default:
//         {
//           // 报名
//           ViewGT.showMiningSignupView(context);
//           return;
//         }
//     }
//   }
//
//   Widget stateHeaderWidgetBuild(BuildContext context, int position) {
//     try {
//       if (headerList != null && headerList.length > 0) {
//         var obj = headerList[0];
//         if (obj is ListPageDefState) {
//           ListPageDefState state = obj;
//           return ListPageDefStateWidgetHeader.getWidgetHeader(state);
//         }
//       }
//     } catch (e) {
//       print(e);
//     }
//     return Container();
//   }
//
//   Future<void> _pullRefreshCallback() async {
//     isLoading = true;
//     String address = AccountMgr()?.currentAccount?.hd_eth_address ?? "";
//     HttpJsonRes httpjsonres = await ApiTestNet.home(address);
//     jsoncallback(httpjsonres);
//   }
// }
