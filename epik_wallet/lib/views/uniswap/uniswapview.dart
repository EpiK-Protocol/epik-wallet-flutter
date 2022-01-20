// import 'dart:ui';
//
// import 'package:epikwallet/base/_base_widget.dart';
// import 'package:epikwallet/base/common_function.dart';
// import 'package:epikwallet/localstring/localstringdelegate.dart';
// import 'package:epikwallet/localstring/resstringid.dart';
// import 'package:epikwallet/logic/EpikWalletUtils.dart';
// import 'package:epikwallet/utils/eventbus/event_manager.dart';
// import 'package:epikwallet/utils/eventbus/event_tag.dart';
// import 'package:epikwallet/utils/res_color.dart';
// import 'package:epikwallet/views/uniswap/uniswapexchangeview.dart';
// import 'package:epikwallet/views/uniswap/uniswappoolview.dart';
// import 'package:epikwallet/views/viewgoto.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
//
// class UniswapView extends BaseWidget {
//   // 可能是空
//   WalletAccount walletAccount;
//
//   UniswapView(this.walletAccount);
//
//   BaseWidgetState<BaseWidget> getState() {
//     return UniswapViewState();
//   }
// }
//
// class UniswapViewState extends BaseWidgetState<UniswapView>
//     with TickerProviderStateMixin {
//   TabController _tabController;
//   int pageIndex = 0;
//   int _selectedIndex_lest = -1;
//
//   double headerbgRate = 0;
//
//   @override
//   void initStateConfig() {
//     super.initStateConfig();
//     setBackIconHinde();
//     setTopBarVisible(false);
//     setAppBarVisible(false);
//     setAppBarBackColor(Colors.transparent);
//     setTopBarBackColor(Colors.transparent);
//     isTopFloatWidgetShow = true;
//     resizeToAvoidBottomPadding = true;
//
//     // setAppBarRightTitle("交易记录");
//
//     _tabController =
//         new TabController(initialIndex: pageIndex, length: 2, vsync: this);
//     _tabController.addListener(() {
//       print(_tabController.animation.value);
//       // tabbar 监听
//       setState(() {
//         _selectedIndex_lest = pageIndex;
//         pageIndex = _tabController.index;
//       });
//       print("tabbar indexIsChanging -> ${_tabController.indexIsChanging}");
//     });
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     setAppBarTitle(ResString.get(context, RSID.usv_1));
//   }
//
//   @override
//   void onCreate() {
//     super.onCreate();
//     eventMgr.add(EventTag.UPDATE_SERVER_CONFIG, eventCallback_upconfig);
//   }
//
//   @override
//   void dispose() {
//     eventMgr.remove(EventTag.UPDATE_SERVER_CONFIG, eventCallback_upconfig);
//     super.dispose();
//   }
//
//   eventCallback_upconfig(arg) {
//     // 钱包接口api更新 重新请求uniswapinfo
//     widget?.walletAccount?.uploadUniswapInfo();
//   }
//
//   @override
//   Widget getTopFloatWidget() {
//     return Positioned(
//       left: 0,
//       right: 0,
//       top: 0,
//       height: appbarheight + BaseFuntion.topbarheight,
//       // child: ClipRect(
//       //   child: BackdropFilter(
//       //     filter: ImageFilter.blur(sigmaX:2,sigmaY: 2),
//       //     child: Column(
//       //       children: <Widget>[
//       //         getTopBar(),
//       //         getAppBar(),
//       //       ],
//       //     ),
//       //   ),
//       // ),
//       child: Column(
//         children: <Widget>[
//           getTopBar(),
//           getAppBar(),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget getAppBarRight({Color color}) {
//     return InkWell(
//       onTap: () {
//         ViewGT.showUniswaporderlistView(context, widget.walletAccount);
//       },
//       child: super.getAppBarRight(color: color),
//     );
//   }
//
//   @override
//   Widget getAppBarCenter({Color color}) {
//     List<RSID> items = [RSID.usv_2, RSID.usv_3];
//
//     return Container(
//       height: getAppBarHeight(),
//       padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
//       child: TabBar(
//         tabs: items.map((rsid) {
//           return Container(
//             alignment: Alignment.bottomCenter,
//             child: Text(rsid.text),
//           );
//         }).toList(),
//         controller: _tabController,
//         isScrollable: true,
//         labelPadding: EdgeInsets.fromLTRB(10, 0, 10, 6),
//         labelColor: Colors.white,
//         labelStyle: TextStyle(
//           fontSize: 20,
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           height: 1,
//         ),
//         unselectedLabelColor: ResColor.white_60,
//         unselectedLabelStyle: TextStyle(
//           fontSize: 14,
//           color: ResColor.white_80,
//           fontWeight: FontWeight.bold,
//           height: 1,
//         ),
//         indicator: BoxDecoration(
//           borderRadius: BorderRadius.circular(4),
//           color: Colors.white,
//         ),
//         indicatorPadding: EdgeInsets.fromLTRB(8, 40, 8, 0),
//         indicatorSize: TabBarIndicatorSize.label,
//         indicatorWeight: 4,
//         onTap: (value) {
//           onClickTab(value);
//         },
//       ),
//     );
//   }
//
//   onClickTab(int index) {
//     setState(() {
//       pageIndex = index;
//       _tabController.animateTo(index);
//     });
//   }
//
//   @override
//   Widget buildWidget(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       child: Stack(
//         children: [
//           // header card
//           Container(
//             width: double.infinity,
//             height: getAppBarHeight() +
//                 getTopBarHeight() +
//                 (40 + 128 * headerbgRate),
//             // (pageIndex == 0 ? 40 : 128),
//             padding: EdgeInsets.only(top: getTopBarHeight()),
//             decoration: BoxDecoration(
//               gradient: ResColor.lg_1,
//               borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
//             ),
//             child: Column(
//               children: [
//                 // getAppBar(),
//               ],
//             ),
//           ),
//           Positioned(
//             left: 0,
//             right: 0,
//             top: getAppBarHeight() + getTopBarHeight(),
//             bottom: 0,
//             // child: TabBarView(
//             //   controller: _tabController,
//             //   children: [
//             //     UniswapExchangeView(widget.walletAccount),
//             //     UniswapPoolView(widget.walletAccount),
//             //   ],
//             // ),
//             child: NotificationListener<ScrollNotification>(
//               onNotification: (notification) {
//                 if (notification is ScrollUpdateNotification) {
//                   ScrollUpdateNotification sun = notification;
//                   if (sun.metrics is PageMetrics) {
//                     PageMetrics pagemetrics = sun.metrics;
//                     double a = pagemetrics.extentBefore;
//                     double b = pagemetrics.extentInside;
//                     headerbgRate = b == 0 ? 0 : a / b;
//                     // dlog("$a  /  $b  = $headerbgRate ");
//                     setState(() {});
//                   }
//                 }
//               },
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   UniswapExchangeView(widget.walletAccount),
//                   UniswapPoolView(widget.walletAccount),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
