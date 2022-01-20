// import 'package:epikwallet/base/_base_widget.dart';
// import 'package:epikwallet/localstring/localstringdelegate.dart';
// import 'package:epikwallet/localstring/resstringid.dart';
// import 'package:epikwallet/logic/EpikWalletUtils.dart';
// import 'package:epikwallet/logic/UniswapHistoryMgr.dart';
// import 'package:epikwallet/logic/api/serviceinfo.dart';
// import 'package:epikwallet/utils/device/deviceutils.dart';
// import 'package:epikwallet/views/viewgoto.dart';
// import 'package:epikwallet/widget/list_view.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
//
// class UniswaporderlistView extends BaseWidget {
//   WalletAccount walletAccount;
//
//   UniswaporderlistView(this.walletAccount);
//
//   BaseWidgetState<BaseWidget> getState() {
//     return UniswaporderlistViewState();
//   }
// }
//
// class UniswaporderlistViewState extends BaseWidgetState<UniswaporderlistView> {
//   List<UniswapOrder> data = [];
//
//   void initStateConfig() {
//     super.initStateConfig();
// //    setAppBarTitle("交易记录");
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     setAppBarTitle(ResString.get(context, RSID.usolv_1));
//   }
//
//   void onCreate() {
//     super.onCreate();
//     refresh();
//   }
//
//   refresh() {
//     data = widget.walletAccount.uhMgr.orderList ?? [];
//     if (data.length == 0) {
//       setEmptyWidgetVisible(true);
//       return;
//     }
//
//     Future.delayed(Duration(milliseconds: 200)).then((value) {
//       showLoadDialog("", onShow: () {
//         widget.walletAccount.uhMgr.requestStateAll().then((_) {
//           closeLoadDialog();
//           if (mounted) setState(() {});
//         });
//       });
//     });
//   }
//
//   @override
//   void onClickEmptyWidget() {
//     super.onClickEmptyWidget();
//     refresh();
//   }
//
//   @override
//   Widget buildWidget(BuildContext context) {
//     return ListPage(
//       data,
//       itemWidgetCreator: (context, position) {
//         return GestureDetector(
//           onTap: () => onItemClick(position),
//           child: getItem(data[position]),
//         );
//       },
//       pullRefreshCallback: _pullRefreshCallback,
//       needNoMoreTipe: false,
//     );
//   }
//
//   Widget getItem(UniswapOrder uorder) {
//     return Container(
//       padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
//       child: Column(
//         children: <Widget>[
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Expanded(
//                 child: Column(
//                   children: <Widget>[
//                     Container(
//                       width: double.infinity,
//                       child: Text(
//                         uorder.getInfo(),
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ),
//                     Container(height: 5),
//                     Container(
//                       width: double.infinity,
//                       child: Text(
//                         ResString.get(context, RSID.usolv_2)+uorder.getTime(),//"提交时间：${uorder.getTime()}",
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ),
//                     Container(height: 5),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Expanded(
//                           child: Text(
//                             "txhash:${uorder.hash}",
//                             softWrap: true,
//                             maxLines: 2,
//                             overflow: TextOverflow.fade,
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ),
//                         Container(
//                           width: 12,
//                           margin: EdgeInsets.fromLTRB(5, 3, 0, 0),
//                           child: Icon(
//                             Icons.redo,
//                             color: Colors.blue,
//                             size: 12,
//                           ),
//                         )
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 width: 24,
//                 margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
//                 child: Icon(
//                   uorder.getStateIcon(),
//                   color: uorder.getStateIconColor(),
//                   size: 24,
//                 ),
//               ),
//             ],
//           ),
//           Container(height: 14),
//           Divider(
//             height: 1,
//             thickness: 1,
//             color: Color(0xffeeeeee),
//           ),
//         ],
//       ),
//     );
//   }
//
//   onItemClick(int position) {
//     String hash = data[position].hash;
//     DeviceUtils.copyText(hash);
// //    https://cn.etherscan.com/address/0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
//     String url = ServiceInfo.ether_tx_web+hash;
//     ViewGT.showGeneralWebView(
//       context,
//       ResString.get(context, RSID.usolv_3),//"详情",
//       url,
//     );
//   }
//
//   Future<void> _pullRefreshCallback() async {
//     await widget.walletAccount.uhMgr.requestStateAll();
//     setState(() {});
//   }
// }
