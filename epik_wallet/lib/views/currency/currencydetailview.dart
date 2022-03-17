import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/LocalAddressMgr.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/CurrencyAsset.dart';
import 'package:epikwallet/model/EpkOrder.dart';
import 'package:epikwallet/model/EthOrder.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/address/EditAddressView.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:epikwallet/widget/text/TextEllipsisMiddle.dart';
import 'package:epikwallet/widget/text/diff_scale_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:jazzicon/jazzicon.dart';

class CurrencyDetailView extends BaseWidget {
  CurrencyAsset currencyAsset;

  CurrencyDetailView(this.currencyAsset);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _CurrencyDetailViewState();
  }
}

class _CurrencyDetailViewState extends BaseWidgetState<CurrencyDetailView> {
  @override
  void initState() {
    super.initState();

    EpikWalletUtils.getHdTransferGas(widget.currencyAsset.cs);
  }

  ListPageDefState _ListPageDefState = ListPageDefState(null);
  List<Object> data_list_item = [];

  GlobalKey<ListPageState> key_scroll = GlobalKey();

  double header_alpha = 0;

  String balance = "　";

  ColorTween header_colortween = ColorTween(begin: Colors.white, end: Colors.black);

  LinearGradient gradient_ff = LinearGradient(
    colors: [Color(0xff2B2F35), Color(0xff1D2023)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  LinearGradient gradient_7f = LinearGradient(
    colors: [Color(0x7f2B2F35), Color(0x7f1D2023)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  LinearGradient gradient_40 = LinearGradient(
    colors: [Color(0x402B2F35), Color(0x401D2023)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  LinearGradient gradient_tab = LinearGradient(
    colors: [Color(0x7f2C3035), Color(0x7f1D1F22)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  void initStateConfig() async {
    isTopBarShow = false; //状态栏是否显示
    isAppBarShow = false; //导航栏是否显示
    isTopFloatWidgetShow = true;
    setAppBarTitle(widget.currencyAsset.symbol + " (${widget.currencyAsset.cs.networkTypeName})");
    setBackIconHinde(isHinde: false);

    await Future.delayed(Duration(milliseconds: 200));
    if (StringUtils.isNotEmpty(widget?.currencyAsset?.balance)) {
      balance = StringUtils.formatNumAmount(widget.currencyAsset.balance, point: 8, supply0: false);
    } else {
      balance = "--";
    }
  }

  @override
  Widget getAppBarRight({Color color}) {
    CurrencyAsset ca = widget?.currencyAsset;
    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 10, 0),
      width: 30,
      height: 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 30,
              height: 30,
              // padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                // color: const Color(0xff202020), //Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: ResColor.black_20, //Color(0x28000000),
                    offset: Offset(0, 0),
                    blurRadius: 2,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: ClipOval(
                child: ca?.icon_url?.startsWith("http")
                    ? CachedNetworkImage(
                        imageUrl: ca.icon_url,
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                        placeholder: (context, url) {
                          return Container(
                            color: ResColor.white_10,
                          );
                        },
                        errorWidget: (context, url, error) {
                          return Container(
                            color: ResColor.white_10,
                            child: Icon(
                              Icons.broken_image,
                              size: 24,
                              color: ResColor.black_80,
                            ),
                          );
                        },
                      )
                    : Image(
                        image: AssetImage(ca.icon_url),
                        width: 30,
                        height: 30,
                      ),
              ),
            ),
          ),
          Positioned(
            right: -1.5,
            bottom: -1.5,
            child: ca.networkType != null
                ? Container(
                    width: 15,
                    height: 15,
                    // padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      // color: const Color(0xff202020), //Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          color: ResColor.black_30, //Color(0x28000000),
                          offset: Offset(0, 0),
                          blurRadius: 1,
                          spreadRadius: 0.5,
                        )
                      ],
                    ),
                    child: Image(
                      image: AssetImage(ca.networkType.iconUrl),
                      width: 13,
                      height: 13,
                    ))
                : Container(),
          ),
        ],
      ),
    );
  }

  @override
  void onCreate() {
    super.onCreate();

    eventMgr.add(EventTag.LOCAL_ACCOUNT_LIST_CHANGE, eventCallback_account);
    eventMgr.add(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventCallback_account);

    refresh();
  }

  eventCallback_account(obj) {
    refresh();
  }

  @override
  void dispose() {
    eventMgr.remove(EventTag.LOCAL_ACCOUNT_LIST_CHANGE, eventCallback_account);
    eventMgr.remove(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventCallback_account);
    super.dispose();
  }

  @override
  Widget getTopFloatWidget() {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.only(top: getTopBarHeight()),
        child: getAppBar(),
      ),
      onTap: onTapAppBar,
    );
  }

  onTapAppBar() {
    if (key_scroll != null && !isLoading) {
      key_scroll.currentState.scrollController
          .animateTo(0, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
    }
  }

  // @override
  // Widget getAppBar() {
  //   // Color color_content = header_colortween.lerp(header_alpha);
  //   Color color_content = Colors.white;
  //
  //   return Container(
  //     height: getAppBarHeight() + getTopBarHeight(),
  //     // padding: EdgeInsets.only(top: getTopBarHeight()),
  //     width: double.infinity,
  //     // color: Colors.white.withOpacity(header_alpha),
  //     child: Stack(
  //       alignment: FractionalOffset(0, 0.5),
  //       children: <Widget>[
  //         Positioned(
  //           left: 0,
  //           right: 0,
  //           top: 0,
  //           bottom: 0,
  //           child: Opacity(
  //             opacity: header_alpha,
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 gradient: ResColor.lg_1,
  //               ),
  //             ),
  //           ),
  //         ),
  //         Positioned(
  //           left: 0,
  //           right: 0,
  //           top: getTopBarHeight(),
  //           bottom: 0,
  //           child: Stack(
  //             alignment: FractionalOffset(0, 0.5),
  //             children: [
  //               Align(
  //                 alignment: FractionalOffset(0.5, 0.5),
  //                 child: getAppBarCenter(color: color_content),
  //               ),
  //               Align(
  //                 //左边返回导航 的位置，可以根据需求变更
  //                 alignment: FractionalOffset(0, 0.5),
  //                 child: Offstage(
  //                   offstage: !isBackIconShow,
  //                   child: getAppBarLeft(color: color_content),
  //                 ),
  //               ),
  //               Align(
  //                 alignment: FractionalOffset(0.98, 0.5),
  //                 child: getAppBarRight(color: color_content),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  double header_top = 0;
  double tttt = 0;

  /// 控制滑动式 title栏透明度
  scrollCallback(ScrollController ctrl) {
//     dlog(ctrl.position.pixels);
//     setState(() {
//       if (header_top == 0) header_top = getTopBarHeight() + getAppBarHeight();
//       double t = ctrl.position.pixels;
//       tttt = t;
//       t = math.min(t, 100);
//       t = math.max(0, t);
//       header_alpha = t / 100;
//       DeviceUtils.setSystemBarStyle(header_alpha > 0.5
//           ? DeviceUtils.system_bar_dark
//           : DeviceUtils.system_bar_light);
//     });
  }

  @override
  Widget buildWidget(BuildContext context) {
    Widget view = new ListPage(
      data_list_item,
      headerList: ["header", _ListPageDefState],
      headerCreator: (context, position) {
        if (position == 0) {
          // return headerBuilder(context, position);
          return Container(
            height: 40,
          );
        } else {
          return stateHeaderWidgetBuild(context, position);
        }
      },
      itemWidgetCreator: (context, position) {
        return InkWell(
          onTap: () => onItemClick(position),
          onLongPress: () {
            if (data_list_item != null && position >= 0 && position < data_list_item.length && mounted) {
              var item = data_list_item[position];

              if (item != null) {
                if (item is EthOrder) {
                  EthOrder _EthOrder = item;
                  String address = item.isWithdraw ? item.to : item.from;
                  LocalAddressObj lao = localaddressmgr.findObjByAddress(address);
                  if (lao == null) {
                    // todo
                    // BottomDialog.showAddAddressDialog(context, (lao) {},
                    //     inputaddress: address, cs: widget.currencyAsset.cs);
                    ViewGT.showView(
                      context,
                      EditAddressView(
                        lao: LocalAddressObj()
                          ..address = address
                          ..symbol = widget.currencyAsset.cs,
                      ),
                    ).then((value) {
                      if (value != null && value is LocalAddressObj) {
                        // print(value.address);
                        localaddressmgr.add(value);
                        localaddressmgr.save();
                        setState(() {});
                      }
                    });
                  }
                } else if (item is EpkOrder) {
                  EpkOrder _TepkOrder = item;
                  String address = item.isWithdraw ? item.to : item.from;
                  LocalAddressObj lao = localaddressmgr.findObjByAddress(address);
                  if (lao == null) {
                    // todo
                    // BottomDialog.showAddAddressDialog(context, (lao) {},
                    //     inputaddress: address, cs: widget.currencyAsset.cs);
                    ViewGT.showView(
                      context,
                      EditAddressView(
                        lao: LocalAddressObj()
                          ..address = address
                          ..symbol = widget.currencyAsset.cs,
                      ),
                    ).then((value) {
                      if (value != null && value is LocalAddressObj) {
                        // print(value.address);
                        localaddressmgr.add(value);
                        localaddressmgr.save();
                        setState(() {});
                      }
                    });
                  }
                }
              }
            }
          },
          child: itemWidgetBuild(context, position),
        );
      },
      scrollCallback: scrollCallback,
      pullRefreshCallback: _pullRefreshCallback,
      needLoadMore: needLoadMore,
      onLoadMore: onLoadMore,
      key: key_scroll,
      needNoMoreTipe: false,
      // bgContainer: (view) {onLoadMore
      //   return Stack(
      //     children: <Widget>[
      //       Positioned(
      //         left: 0,
      //         right: 0,
      //         bottom: 0,
      //         height: getScreenHeight() - 10 + (tttt < 0 ? tttt : 0),
      //         child: Container(
      //           color: Colors.white,
      //         ),
      //       ),
      //       Positioned(
      //         left: 0,
      //         right: 0,
      //         top: 0,
      //         bottom: 0,
      //         child: view,
      //       ),
      //     ],
      //   );
      // },
    );

    // return Column(
    //   children: [
    //     headerBuilder(context,0),
    //     Expanded(child: view),
    //   ],
    // );
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Positioned(left: 0, bottom: 0, right: 0, top: getTopBarHeight() + getAppBarHeight() + 128, child: view),
          headerBuilder(context, 0),
        ],
      ),
    );

//     return Stack(
//       children: <Widget>[
//         Positioned(
//           left: 0,
//           top: 0,
//           right: 0,
//           height: getScreenHeight(),
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: gradient_ff,
//             ),
//           ),
//         ),
// //        Positioned(
// //          left: 0,
// //          right: 0,
// //          bottom: 0,
// //          height: getScreenHeight() / 2,
// //          child: Container(
// //            color: Color(0xfff4f5f7),
// //          ),
// //        ),
//         Positioned(
//           left: 0,
//           top: 0,
//           right: 0,
//           bottom: 0,
//           child: view,
//         ),
//       ],
//     );
  }

  Widget headerBuilder(BuildContext context, int position) {
    if (position == 0 /*&& bannerlist != null && bannerlist.length > 0*/) {
      if (header_top == 0) header_top = getTopBarHeight() + getAppBarHeight();
      double h_bg = header_top + 128;
      double h_btn = 40;
      return Container(
        padding: EdgeInsets.all(0),
        width: double.infinity,
        // color: Colors.white,
        height: h_bg + h_btn,
        child: Stack(
          children: [
            //背景内容
            Container(
              width: double.infinity,
              height: h_bg,
              padding: EdgeInsets.fromLTRB(30, header_top, 30, 0),
              decoration: BoxDecoration(
                gradient: ResColor.lg_1,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DiffScaleText(
                    text: balance,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontFamily: "DIN_Condensed_Bold",
                      height: 1,
                    ),
                  ),
                  Text(
                    "≈ \$${StringUtils.formatNumAmount(widget.currencyAsset.getUsdValue())}",
                    style: TextStyle(
                      color: ResColor.white_80,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            //悬浮按钮
            Positioned(
              left: 30,
              right: 30,
              bottom: 15,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      ViewGT.showCurrencyDepositView(context, AccountMgr().currentAccount, widget.currencyAsset.cs);
                    },
                    child: Tooltip(
                      message: RSID.deposit.text,
                      //收款
                      preferBelow: false,
                      verticalOffset: 28,
                      excludeFromSemantics: true,
                      child: Container(
                        width: 50,
                        height: 50,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: ResColor.lg_1,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Image.asset(
                          "assets/img/ic_arrow_deposit.png",
                          width: 26,
                          height: 26,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 14,
                  ),
                  InkWell(
                    onTap: () {
//                       ResString.get(context, RSID.withdraw),//"转账",
                      ViewGT.showCurrencyWithdrawView(context, AccountMgr().currentAccount, widget.currencyAsset);
                    },
                    child: Tooltip(
                      message: RSID.withdraw.text,
                      //转账
                      preferBelow: false,
                      verticalOffset: 28,
                      excludeFromSemantics: true,
                      child: Container(
                        width: 50,
                        height: 50,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: ResColor.lg_1,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Image.asset(
                          "assets/img/ic_arrow_withdraw.png",
                          width: 26,
                          height: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Container(
//               height: header_top + 106 + 54 + 8,
//               child: Stack(
//                 children: <Widget>[
//                   Align(
//                     alignment: FractionalOffset(0.5, 1),
//                     child: Container(
//                       width: double.infinity,
//                       height: 23,
//                       margin: EdgeInsets.fromLTRB(17.5, 0, 17.5, 0),
//                       decoration: BoxDecoration(
//                         gradient: gradient_40,
//                         borderRadius: BorderRadius.only(
//                           bottomLeft: Radius.circular(15),
//                           bottomRight: Radius.circular(15),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Align(
//                     alignment: FractionalOffset(0.5, 1),
//                     child: Container(
//                       width: double.infinity,
//                       height: 19,
//                       margin: EdgeInsets.fromLTRB(8.5, 0, 8.5, 4),
//                       decoration: BoxDecoration(
//                         gradient: gradient_7f,
//                         borderRadius: BorderRadius.only(
//                           bottomLeft: Radius.circular(15),
//                           bottomRight: Radius.circular(15),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Align(
//                     alignment: FractionalOffset(0.5, 1),
//                     child: Container(
//                       width: double.infinity,
//                       height: double.infinity,
//                       margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
//                       decoration: BoxDecoration(
//                         gradient: gradient_ff,
//                         borderRadius: BorderRadius.only(
//                           bottomLeft: Radius.circular(15),
//                           bottomRight: Radius.circular(15),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     margin: EdgeInsets.only(top: header_top),
//                     height: 106,
//                     width: double.infinity,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       mainAxisSize: MainAxisSize.min,
//                       children: <Widget>[
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: <Widget>[
// //                            Padding(
// //                              padding: EdgeInsets.only(top: 0, left: 5),
// //                              child: Text(
// //                                "　　",
// //                                style: TextStyle(
// //                                  color: Colors.transparent,
// //                                  fontSize: 10,
// //                                ),
// //                              ),
// //                            ),
// //                            Text(
// //                              StringUtils.formatNumAmount(widget.currencyAsset.balance,point:8,supply0: false ),
// //                              style: TextStyle(
// //                                color: Colors.white,
// //                                fontSize: 35,
// //                                fontFamily: "DIN_Condensed_Bold",
// //                              ),
// //                            ),
//                             DiffScaleText(
//                               text: balance,
//                               textStyle: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 35,
//                                 fontFamily: "DIN_Condensed_Bold",
//                               ),
//                             ),
// //                            Padding(
// //                              padding: EdgeInsets.only(top: 0, left: 5),
// //                              child: Text(
// //                                "全部",
// //                                style: TextStyle(
// //                                  color: Colors.white,
// //                                  fontSize: 10,
// //                                ),
// //                              ),
// //                            ),
//                           ],
//                         ),
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: <Widget>[
//                             Text(
//                               "\$ ${StringUtils.formatNumAmount(widget.currencyAsset.getUsdValue())}",
//                               style: TextStyle(
//                                 color: ResColor.white,
//                                 fontSize: 15,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   Positioned(
//                     left: 0,
//                     right: 0,
//                     bottom: 8,
//                     height: 54,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         gradient: gradient_tab,
//                         borderRadius: BorderRadius.only(
//                           bottomLeft: Radius.circular(15),
//                           bottomRight: Radius.circular(15),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.max,
//                         children: <Widget>[
//                           Expanded(
//                             child: Material(
//                               color: Colors.transparent,
//                               clipBehavior: Clip.antiAlias,
//                               borderRadius: BorderRadius.only(
//                                   bottomLeft: Radius.circular(15)),
//                               child: InkWell(
//                                 onTap: () {
//                                   ViewGT.showCurrencyWithdrawView(
//                                       context,
//                                       AccountMgr().currentAccount,
//                                       widget.currencyAsset);
//                                 },
//                                 child: Container(
//                                   height: double.infinity,
//                                   alignment: Alignment.center,
//                                   child: Text(
//                                     ResString.get(context, RSID.withdraw),
//                                     //"转账",
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Container(
//                             width: 1,
//                             height: 30,
//                             color: Color(0x19ffffff),
//                           ),
//                           Expanded(
//                             child: Material(
//                               color: Colors.transparent,
//                               clipBehavior: Clip.antiAlias,
//                               borderRadius: BorderRadius.only(
//                                   bottomRight: Radius.circular(15)),
//                               child: InkWell(
//                                 onTap: () {
//                                   ViewGT.showCurrencyDepositView(
//                                       context,
//                                       AccountMgr().currentAccount,
//                                       widget.currencyAsset.cs);
//                                 },
//                                 child: Container(
//                                   height: double.infinity,
//                                   alignment: Alignment.center,
//                                   child: Text(
//                                     ResString.get(context, RSID.deposit),
//                                     //"收款",
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
      );
    } else {
      return new Padding(
        padding: EdgeInsets.all(10.0),
        child: Text('$position -----header------- '),
      );
    }
  }

  Widget stateHeaderWidgetBuild(BuildContext context, int position) {
    try {
      return ListPageDefStateWidgetHeader.getWidgetHeader(_ListPageDefState);
    } catch (e) {
      print(e);
    }
    return Container();
  }

  Widget itemWidgetBuild(BuildContext context, int position) {
    if (data_list_item != null && position < data_list_item.length) {
      var item = data_list_item[position];
      if (item is EpkOrder) {
        return itemWidgetBuild_epk(item);
      } else {
        return itemWidgetBuild_eth((item as EthOrder));
      }
    } else {
      return Padding(padding: new EdgeInsets.all(10.0), child: new Text("no data $position"));
    }
  }

  Widget itemWidgetBuild_epk(EpkOrder item) {
    String title = "";
    String codestring = item.getCodeTextFilter();
    Color title_color = Colors.white60;
    if (StringUtils.isEmpty(codestring)) {
      if (StringUtils.isNotEmpty(item.actorName)) {
        // title= item.actorName;
        title = item.MethodName;
      } else {
        //  item.isWithdraw ? "转账" : "收款",
        title = ResString.get(context, item.isWithdraw ? RSID.withdraw : RSID.deposit);
        title_color = item.isWithdraw ? ResColor.r_1 : ResColor.g_1;
      }
    } else {
      title = codestring;
    }

    LocalAddressObj lao = localaddressmgr.findObjByAddress(item.isWithdraw ? item.to : item.from);

    return Container(
      width: double.infinity,
      // height: 80,
      padding: EdgeInsets.fromLTRB(20, 25, 0, 0),
      color: ResColor.b_3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                DateUtil.formatDateMs(item.time_ts * 1000, format: DataFormats.y_mo_d_h_m),
                style: TextStyle(fontSize: 14, color: Colors.white60),
              ),
              Container(
                width: 20,
              ),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: title_color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: 20,
              ),
              Text(
                item.numDirection + StringUtils.formatNumAmount(item.value_d, point: 8),
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 20,
              ),
            ],
          ),
          Container(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                // width: 40,
                padding: EdgeInsets.only(right: 5),
                child: Text(
                  item.isWithdraw ? "To:" : "From:",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ),
              if (lao != null)
                Container(
                  width: 16,
                  height: 16,
                  margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(50),
                    gradient: lao.useJazzicon ? null:lao.gradientCover,
                  ),
                  child: Stack(
                    children: [
                      if(lao.useJazzicon)
                        Jazzicon.getIconWidget(lao.jazziconData,size: 16),
                      Align(
                        alignment: FractionalOffset(0.5, 0.5),
                        child: Text(
                          lao.name,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: Colors.white, shadows: [
                            BoxShadow(
                              color: ResColor.black, //Color(0x28000000),
                              offset: Offset(0, 0),
                              blurRadius: 2,
                              spreadRadius: 2,
                            )
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: TextEm(
                  item.isWithdraw ? item.to : item.from,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ),
              Container(
                width: 12,
                margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
                child: Icon(
                  Icons.redo,
                  color: Colors.blue,
                  size: 12,
                ),
              ),
              Container(
                width: 20,
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 24),
            height: 1,
            color: ResColor.white_20,
          ),
        ],
      ),
    );
  }

  Widget itemWidgetBuild_eth(EthOrder item) {
    LocalAddressObj lao = localaddressmgr.findObjByAddress(item.isWithdraw ? item.to : item.from);
    // dlog(item.isWithdraw ? item.to : item.from);

    return Container(
      width: double.infinity,
      // height: 80,
      padding: EdgeInsets.fromLTRB(20, 25, 0, 0),
      color: ResColor.b_3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                DateUtil.formatDateMs(item.timeStamp, format: DataFormats.y_mo_d_h_m),
                style: TextStyle(fontSize: 14, color: Colors.white60),
              ),
              Container(
                width: 20,
              ),
              Text(
                item.isGas ? "Gas" : ResString.get(context, item.actionStrId),
                //item.isWithdraw ? "转账" : "收款",
                style: TextStyle(
                  fontSize: 14,
                  color: item.isWithdraw ? ResColor.r_1 : ResColor.g_1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 20,
              ),
              Expanded(
                child: Text(
                  item.isGas
                      ? ("-" + StringUtils.formatNumAmount(item.gasUsedCoin_d, point: 8))
                      : (item.numDirection + StringUtils.formatNumAmount(item.value_d, point: 8)),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: 20,
              ),
            ],
          ),
          Container(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                // width: 40,
                padding: EdgeInsets.only(right: 5),
                child: Text(
                  item.isWithdraw ? "To:" : "From:",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ),
              if (lao != null)
                Container(
                  width: 16,
                  height: 16,
                  margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(50),
                    gradient: lao.useJazzicon ? null:lao.gradientCover,
                  ),
                  child: Stack(
                    children: [
                      if(lao.useJazzicon)
                        Jazzicon.getIconWidget(lao.jazziconData,size: 16),
                      Align(
                        alignment: FractionalOffset(0.5, 0.5),
                        child: Text(
                          lao.name,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: Colors.white, shadows: [
                            BoxShadow(
                              color: ResColor.black, //Color(0x28000000),
                              offset: Offset(0, 0),
                              blurRadius:2,
                              spreadRadius: 2,
                            )
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: TextEm(
                  item.isWithdraw ? item.to : item.from,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ),
              Container(
                width: 12,
                margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
                child: Icon(
                  Icons.redo,
                  color: Colors.blue,
                  size: 12,
                ),
              ),
              Container(
                width: 20,
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 24),
            height: 1,
            color: ResColor.white_20,
          ),
        ],
      ),
    );
  }

  bool hasRefresh = false;

  // String lastTime;
  int lastEpkEndHeight = 0;
  int page = 1;
  int pageSize = 20;

  bool isLoading = false;
  bool hasMore = false;

  void refresh() {
    hasRefresh = true;

    isLoading = true;
//    setLoadingWidgetVisible(true);

    page = 0;
    // lastTime = null;
    lastEpkEndHeight = 0;
    setState(() {
      _ListPageDefState.type = ListPageDefStateType.LOADING;
    });

    // AccountMgr().currentAccount.uploadSuggestGas(); // suggest gas
    AccountMgr().currentAccount.uploadEpikGasTransfer(); // epk gas

    //交易列表
    EpikWalletUtils.getOrderList(
      AccountMgr().currentAccount,
      widget.currencyAsset.cs,
      page,
      pageSize,
      epkHeight: lastEpkEndHeight,
    ).then((data) {
      dataCallback(data);
    });

    //刷新所有币种的余额
    EpikWalletUtils.requestBalance(AccountMgr().currentAccount).then((value) {
      if (isDestory) return;
      setState(() {
        if (StringUtils.isNotEmpty(widget?.currencyAsset?.balance)) {
          balance = StringUtils.formatNumAmount(widget.currencyAsset.balance, point: 8, supply0: false);
        }
        // else {
        //   balance = "--";
        // }
      });
    });
  }

  bool get usePage {
    return widget?.currencyAsset?.cs != CurrencySymbol.EPK;
  }

  bool get isFirstPage {
    return usePage ? (page == 0) : (lastEpkEndHeight == 0);
  }

  dataCallback(Map<String, dynamic> retmap) {
    List data = retmap["list"];
    if (data != null) {
      // 请求成功
      if (isFirstPage) {
//        if (data.isEmpty) {
//          showToast("无数据");
//        }
        data_list_item.clear();
      }
      data_list_item.addAll(data);

      if (/*widget.currencyAsset.cs != CurrencySymbol.tEPK &&*/
          data.length >= pageSize) {
        hasMore = true;
        if (usePage) {
          page += 1;
        } else {
          Object lastitem = data?.last;
          if (lastitem != null && lastitem is EpkOrder) {
            // lastTime = lastitem.time; //
            lastEpkEndHeight = retmap["epkHeight"] ?? 0;
          }
        }
      } else {
        hasMore = false;
      }
      _ListPageDefState.type = data_list_item.length > 0 ? null : ListPageDefStateType.EMPTY;
    } else {
      showToast(ResString.get(context, RSID.request_failed)); //"请求失败);
      if (isFirstPage) {
        _ListPageDefState.type = ListPageDefStateType.ERROR;
      }
    }
    closeStateLayout();
    isLoading = false;
    return;
  }

  void onClickErrorWidget() {
    refresh();
  }

  void onClickEmptyWidget() {
    refresh();
  }

  Future<void> _pullRefreshCallback() async {
    if (isLoading) {
      return;
    }

    // AccountMgr().currentAccount.uploadSuggestGas();
    AccountMgr().currentAccount.uploadEpikGasTransfer();

    EpikWalletUtils.requestBalance(AccountMgr().currentAccount).then((value) {
      if (isDestory) return;
      setState(() {
        if (StringUtils.isNotEmpty(widget?.currencyAsset?.balance)) {
          balance = StringUtils.formatNumAmount(widget.currencyAsset.balance, point: 8, supply0: false);
        }
        // else {
        //   balance = "--";
        // }
      });
    });

    page = 0;
    lastEpkEndHeight = 0; //lastTime = null;
    isLoading = true;
    var data = await EpikWalletUtils.getOrderList(
      AccountMgr().currentAccount,
      widget.currencyAsset.cs,
      page,
      pageSize,
      epkHeight: lastEpkEndHeight,
    ); //lastTime: lastTime
    dataCallback(data);
  }

  /**是否需要加载更多*/
  bool needLoadMore() {
    // if (widget.currencyAsset.cs == CurrencySymbol.tEPK) {
    //   return false;
    // } else
    {
      bool ret = hasMore && !isLoading;
      dlog("needLoadMore = " + ret.toString());
      return ret;
    }
  }

  /**加载分页*/
  Future<bool> onLoadMore() async {
    if (isLoading) return true;
    dlog("onLoadMore  ");
    isLoading = true;

    Map<String, dynamic> retmap = await EpikWalletUtils.getOrderList(
      AccountMgr().currentAccount,
      widget.currencyAsset.cs,
      page,
      pageSize,
      epkHeight: lastEpkEndHeight - 1,
    ); //lastTime: lastTime

    dataCallback(retmap);

    return hasMore;
  }

  onItemClick(int postision) {
    try {
      if (data_list_item != null && postision >= 0 && postision < data_list_item.length && mounted) {
        var item = data_list_item[postision];
        if (item != null) {
          if (item is EthOrder) {
            EthOrder _EthOrder = item;
            String hash = _EthOrder.hash;
            DeviceUtils.copyText(hash);
            String url = "";
            if (widget.currencyAsset.cs.networkType == CurrencySymbol.ETH) {
              url = ServiceInfo.ether_tx_web + hash;
            } else if (widget.currencyAsset.cs.networkType == CurrencySymbol.BNB) {
              url = ServiceInfo.bsc_tx_web + hash;
            }
            ViewGT.showGeneralWebView(context, ResString.get(context, RSID.berlv_4), url);
          } else if (item is EpkOrder) {
            EpkOrder _TepkOrder = item;
            String cid = _TepkOrder.cid;
            DeviceUtils.copyText(cid);
            String url = ServiceInfo.epik_msg_web + cid;
            ViewGT.showGeneralWebView(context, ResString.get(context, RSID.berlv_4), url);
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  /// hd钱包加速交易
// onClickAccelerateTx(String txhash) {
//   BottomDialog.showEthAccelerateTx(
//     context,
//     AccountMgr().currentAccount,
//     txhash,
//     callback: (newTxHash) {
//       // if (StringUtils.isNotEmpty(newTxHash)) {}
//     },
//   );
// }

}
