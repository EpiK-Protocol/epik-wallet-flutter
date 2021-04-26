import 'dart:math' as math;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/model/CurrencyAsset.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:epikwallet/widget/text/diff_scale_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WalletView extends BaseInnerWidget {
  WalletView(Key key) : super(key: key) {}

  @override
  BaseInnerWidgetState<BaseInnerWidget> getState() {
    return _WalletViewState();
  }

  @override
  int setIndex() {
    return 0;
  }
}

class _WalletViewState extends BaseInnerWidgetState<WalletView> {
  bool has_10100 = false;

  @override
  void initState() {
    super.initState();
    navigationColor = ResColor.b_2;
  }

  String balance = "0";

  List<CurrencyAsset> data_list_item = [];

  GlobalKey<ListPageState> key_scroll;

  double header_alpha = 0;

  bool noWallet = true;

  @override
  void initStateConfig() {
    isTopBarShow = false; //状态栏是否显示
    isAppBarShow = false; //导航栏是否显示
    isTopFloatWidgetShow = false;
    // headerlist = ["header"];
    headerlist = [];
    headerlist.add("exchange_epk");
    headerlist.add("hunter_reward");
    headerlist.add("uniswap");
  }

  @override
  void onCreate() {
    super.onCreate();
    eventMgr.add(EventTag.LOCAL_ACCOUNT_LIST_CHANGE, eventCallback_account);
    eventMgr.add(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventCallback_account);
    eventMgr.add(EventTag.UPDATE_SERVER_CONFIG, eventCallback_account);
    refresh();
  }

  eventCallback_account(obj) {
    refresh();
  }

  @override
  void dispose() {
    eventMgr.remove(EventTag.LOCAL_ACCOUNT_LIST_CHANGE, eventCallback_account);
    eventMgr.remove(
        EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventCallback_account);
    eventMgr.remove(EventTag.UPDATE_SERVER_CONFIG, eventCallback_account);
    super.dispose();
  }

  // @override
  // Widget getTopFloatWidget() {
  //   return noWallet ? Container() : getAppBar();
  // }

  @override
  Widget getAppBar() {
    return Container(
      height: getAppBarHeight() + getTopBarHeight(),
      padding: EdgeInsets.only(top: getTopBarHeight()),
      width: double.infinity,
      color: Colors.transparent,
      // Colors.white.withOpacity(header_alpha),
      child: Row(
        children: [
          Container(width: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image(
              width: 30,
              height: 30,
              image: AssetImage("assets/img/ic_launcher_2.png"),
              fit: BoxFit.cover,
            ),
          ),
          Container(width: 10),
          Text(
            "EpiK ${ResString.get(context, RSID.main_wv_5)}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onClickWalletMenu,
              child: Container(
                height: double.infinity,
                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      AccountMgr().currentAccount.account,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      height: double.infinity,
                      padding: EdgeInsets.fromLTRB(15, 0, 25, 0),
                      child: Image.asset(
                        "assets/img/ic_arrow_right_1.png",
                        width: 7,
                        height: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double header_top = 0;

  /// 控制滑动式 title栏透明度
  scrollCallback(ScrollController ctrl) {
//     dlog(ctrl.position.pixels);
    setState(() {
      if (header_top == 0) header_top = getTopBarHeight() + getAppBarHeight();
      double t = ctrl.position.pixels;
      t = math.min(t, 100);
      t = math.max(0, t);
      header_alpha = t / 100;
    });
  }

  List<String> headerlist;

  @override
  Widget buildWidget(BuildContext context) {
    // noWallet=false;//todo test
    if (noWallet) {
      return getNoAccountView(context);
    }

    return Column(
      children: [
        buildTopCard(),
        Expanded(
          child: ListPage(
            data_list_item,
            headerList: headerlist,
            headerCreator: headerBuilder,
//      itemWidgetCreator: itemWidgetBuild,
            itemWidgetCreator: (context, position) {
              return Container(
                  margin: EdgeInsets.fromLTRB(0, position==0?10:0, 0, 0),
                  child:Material(
                    color: ResColor.b_2,
                    child: InkWell(
                      highlightColor: ResColor.white_10,
                      splashColor: ResColor.white_10,
                      onTap: () => onItemClick(position),
                      child: itemWidgetBuild2(context, position),
                    ),
                  ),
              );
            },
            scrollCallback: scrollCallback,
            pullRefreshCallback: _pullRefreshCallback,
//      needLoadMore: needLoadMore,
//      onLoadMore: onLoadMore,
            key: key_scroll,
            needNoMoreTipe: false,
          ),
        ),
      ],
    );
  }

  Widget buildTopCard() {
    double h1 = getTopBarHeight()+ getAppBarHeight();
    double h2 = 128;
    return Container(
      width: double.infinity,
      height: h1+h2,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      decoration: BoxDecoration(
        gradient: ResColor.lg_1,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child:
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          getAppBar(),
          InkWell(
            onTap: () {
              onClickWalletName();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  RSID.main_wv_6.text, //"总资产",
                  style: TextStyle(
                    color: ResColor.white_80,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  height: 5,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        r"$ ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: "DIN_Condensed_Bold",
                        ),
                      ),
                    ),
                    DiffScaleText(
                      text: balance,
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontFamily: "DIN_Condensed_Bold",
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "≈ " +
                          StringUtils.formatNumAmount(
                              AccountMgr().currentAccount.total_btc,
                              point: 8),
                      style: TextStyle(
                        color: ResColor.white_80,
                        fontSize: 14,
                        fontFamily: "DIN_Condensed_Bold",
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Text(
                        " BTC",
                        style: TextStyle(
                          color: ResColor.white_80,
                          fontSize: 14,
                          fontFamily: "DIN_Condensed_Bold",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget headerBuilder(BuildContext context, int position) {
    // ["header","exchange_epk","hunter_reward"]
    print("position=$position  headerlist.size=${headerlist.length}");
    switch (headerlist[position]) {
      case "exchange_epk":
        return headerItemBuild(
          localImage: "assets/img/ic_swap.png",
          text: "ERC20-EPK 兑换 EPK",
          onclick: () {
            ViewGT.showErc20ToEpkView(context);
          },
          position: position,
        );
      case "hunter_reward":
        {
          return headerItemBuild(
            localImage: "assets/img/ic_swap.png",
            text: "领取赏金猎人奖励",
            onclick: () {
              ViewGT.showTakeBountyView(context);
            },
            position: position,
          );
        }
        break;
      case "uniswap":
        {
          return headerItemBuild(
            localImage: "assets/img/256x256_App_Icon_Pink.png",
            text: "ERC20-EPK Uniswap 交易",
            onclick: () {
              ViewGT.showTransactionView2(context);
            },
            position: position,
          );
        }
        break;
    }

    return new Padding(
      padding: EdgeInsets.all(10.0),
      child: Text('$position -----header------- '),
    );
  }

  Widget headerItemBuild({
    String localImage,
    String text,
    VoidCallback onclick,
    int position,
  }) {
    bool isend = position >= headerlist.length - 1;
    return  Container(
      margin: EdgeInsets.fromLTRB(0, position==0?10:0, 0, 0),
      child: Material(
        color: ResColor.b_2,
        child: InkWell(
          highlightColor: ResColor.white_10,
          splashColor: ResColor.white_10,
          onTap: onclick,
          child:  Container(
            height: 65,
            width: double.infinity,
            // color: ResColor.b_2,
            child: Stack(
              children: [
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(20, 0, 10, 0),
                      child: ClipOval(
                        child: Image(
                          width: 30,
                          height: 30,
                          image: AssetImage(localImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 14,
                          color: ResColor.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      height: double.infinity,
                      padding: EdgeInsets.fromLTRB(15, 0, 25, 0),
                      child: Image.asset(
                        "assets/img/ic_arrow_right_1.png",
                        width: 7,
                        height: 11,
                      ),
                    ),
                  ],
                ),

                if (!isend)
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Divider(
                        height: 1/ScreenUtil.pixelRatio,
                        thickness: 1/ScreenUtil.pixelRatio,
                        indent: 20,
                        color: ResColor.white_20,
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget itemWidgetBuild(BuildContext context, int position) {
    if (data_list_item != null && position < data_list_item.length) {
      CurrencyAsset ca = data_list_item[position];
      return Container(
        height: 80,
        padding: EdgeInsets.fromLTRB(20, 0, 25, 0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // 头像
            Container(
              width: 48,
              height: 48,
//              padding: EdgeInsets.all(0.5),
//              decoration: BoxDecoration(
//                color: Colors.white,
//                borderRadius: BorderRadius.circular(15),
//                border:
//                Border.all(color: ResColor.black_10, width: 0.5),
//              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 0,
                    top: 0,
                    child: ClipOval(
                      child: ca?.icon_url?.startsWith("http")
                          ? CachedNetworkImage(
                              imageUrl: ca.icon_url,
                              width: 48,
                              height: 48,
                              fit: BoxFit.contain,
                              placeholder: (context, url) {
                                return Container(
                                  color: ResColor.black_10,
                                );
                              },
                              errorWidget: (context, url, error) {
                                return Container(
                                  color: ResColor.black_10,
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 24,
                                    color: ResColor.white_80,
                                  ),
                                );
                              },
                            )
                          : Image(
                              image: AssetImage(ca.icon_url),
                              width: 48,
                              height: 48,
                            ),
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 0,
                    child: ca.networkType != null
                        ? Container(
                            width: 15,
                            height: 15,
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
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
            ),
            Padding(
              padding: EdgeInsets.only(left: 15),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        ca.balance.isNotEmpty
                            ? StringUtils.formatNumAmount(ca.getBalanceDouble(),
                                point: 8, supply0: false)
                            : "--",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontFamily: "DIN_Condensed_Bold",
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(5, 8.5, 0, 0),
                          child: Text(
                            ca.symbol,
                            style: TextStyle(
                              fontSize: 13,
                              color: ResColor.black_60,
                              fontFamily: "DIN_Condensed_Bold",
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 3.5, 0, 0),
                        child: Text(
//                        (ca.change_usd*100).toStringAsPrecision(2)+"%",
                          (ca.change_usd > 0 ? "+" : "") +
                              StringUtils.formatNumAmount(ca.change_usd * 100,
                                  point: 2) +
                              "%",
                          style: TextStyle(
                            fontSize: 14,
                            color: ca.change_usd >= 0
                                ? Color(0xffF45C78)
                                : Color(0xff0DAC8F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "≈\$ ${StringUtils.formatNumAmount(ca.getUsdValue())}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xffCACBCF),
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Text(
                        "\$ ${StringUtils.formatNumAmount(ca.price_usd)}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xffCACBCF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
          padding: new EdgeInsets.all(10.0),
          child: new Text("no data $position"));
    }
  }

  Widget itemWidgetBuild2(
    BuildContext context, int position,
  ) {
    if (data_list_item != null && position < data_list_item.length)
    {
      bool isend = position >= data_list_item.length - 1;

      CurrencyAsset ca = data_list_item[position];

      return  Container(
        // margin: EdgeInsets.fromLTRB(0, position==0?10:0, 0, 0),
        height: 65,
        width: double.infinity,
        // color: ResColor.b_2,
        child: Stack(
          children: [
            Row(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(20, 0, 10, 0),
                  width: 30,
                  height: 30,
                  child:
                  Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Positioned(
                        left: 0,
                        top: 0,
                        child:  ClipOval(
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
                      Positioned(
                        right: -1.5,
                        bottom: -1.5,
                        child: ca.networkType != null
                            ? Container(
                            width: 15,
                            height: 15,
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: const Color(0xff202020),//Colors.white,
                              borderRadius:
                              BorderRadius.all(Radius.circular(10)),
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


                ),
                Expanded(
                  child: Text(
                    ca.symbol,
                    style: TextStyle(
                      fontSize: 14,
                      color: ResColor.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  ca.balance.isNotEmpty
                      ? StringUtils.formatNumAmount(ca.getBalanceDouble(),
                      point: 8, supply0: false)
                      : "--",
                  style: TextStyle(
                    fontSize: 14,
                    color: ResColor.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  height: double.infinity,
                  padding: EdgeInsets.fromLTRB(15, 0, 25, 0),
                  child: Image.asset(
                    "assets/img/ic_arrow_right_1.png",
                    width: 7,
                    height: 11,
                  ),
                ),
              ],
            ),
            if (!isend)
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Divider(
                    height: 1/ScreenUtil.pixelRatio,
                    thickness: 1/ScreenUtil.pixelRatio,
                    indent: 20,
                    color: ResColor.white_20,
                  )),
          ],
        ),
      );
    }else {
      return Padding(
          padding: new EdgeInsets.all(10.0),
          child: new Text("no data $position"));
    }
  }


  Widget getNoAccountView(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 106 + getTopBarHeight()),
          ),
          Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(63),
                    border:
                        Border.all(color: const Color(0xffeba544), width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(63),
                    child: Image(
                      width: 125,
                      height: 125,
                      image: AssetImage("assets/img/ic_launcher_2.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Text(
                    "EpiK Portal",
                    style: TextStyle(
                      fontSize: 20,
                      color: const Color(0xffeba544),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: <Widget>[
          //     Transform(
          //       transform: Matrix4.identity()..rotateZ(math.pi), // 旋转的角度
          //       origin: Offset(12, 12), // 旋转的中心点
          //       child: Icon(
          //         Icons.format_quote,
          //         size: 24,
          //         color: Color(0xffe5e5e5),
          //       ),
          //     ),
          //     Padding(
          //       padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
          //       child: Text(
          //         ResString.get(context, RSID.main_wv_1), //"没有钱包",
          //         style: TextStyle(
          //           fontSize: 20,
          //           color: Color(0xff1A1C1F),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          InkWell(
            onTap: () {
              ViewGT.showCreateWalletView(context);
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 100, 0, 20),
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: ResColor.lg_1,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/img/ic_add_circle.png",
                    width: 20,
                    height: 20,
                  ),
                  Container(width: 10),
                  Text(
                    RSID.main_wv_2.text, //"创建钱包",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1),
                  ),
                ],
              ),
            ),
          ),
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: <Widget>[
          //     Transform(
          //       transform: Matrix4.identity()..rotateZ(math.pi), // 旋转的角度
          //       origin: Offset(12, 12), // 旋转的中心点
          //       child: Icon(
          //         Icons.format_quote,
          //         size: 24,
          //         color: Color(0xffe5e5e5),
          //       ),
          //     ),
          //     Padding(
          //       padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
          //       child: Text(
          //         ResString.get(context, RSID.main_wv_3), //"已有钱包",
          //         style: TextStyle(
          //           fontSize: 20,
          //           color: Color(0xff1A1C1F),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          InkWell(
            onTap: () {
              ViewGT.showImportWalletView(context);
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: ResColor.lg_1,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/img/ic_import_circle.png",
                    width: 20,
                    height: 20,
                  ),
                  Container(width: 10),
                  Text(
                    RSID.main_wv_4.text, //"导入钱包",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool hasRefresh = false;

  int page = 1;
  int pageSize = 20;

  bool isLoading = false;
  bool hasMore = false;

  void refresh() {
    hasRefresh = true;

    noWallet = AccountMgr().currentAccount == null ||
        AccountMgr().account_list == null ||
        AccountMgr().account_list.isEmpty;

    if (noWallet) {
      setState(() {});
      return;
    }

    setState(() {
      dlog("refresh ${AccountMgr().currentAccount.account}");
    });

    isLoading = true;
    setLoadingWidgetVisible(true);

    EpikWalletUtils.requestBalance(AccountMgr().currentAccount).then((value) {
      isLoading = false;
      data_list_item = AccountMgr().currentAccount.currencyList;
      balance = StringUtils.formatNumAmount(
          AccountMgr().currentAccount.total_usd,
          point: 2);
      closeStateLayout();
    });
  }

  void onClickErrorWidget() {
    refresh();
  }

  void onClickEmptyWidget() {
    refresh();
  }

  Future<void> _pullRefreshCallback() async {
    await EpikWalletUtils.requestBalance(AccountMgr().currentAccount);
    setState(() {
      isLoading = false;
      data_list_item = AccountMgr().currentAccount.currencyList;
      balance = StringUtils.formatNumAmount(
          AccountMgr().currentAccount.total_usd,
          point: 2);
    });
  }

  /**是否需要加载更多*/
  bool needLoadMore() {
    bool ret = hasMore && !isLoading;
    dlog("needLoadMore = " + ret.toString());
    return ret;
  }

  /**加载分页*/
  Future<bool> onLoadMore() async {
    if (isLoading) return true;
    dlog("onLoadMore  ");
    isLoading = true;
//      HttpJsonRes res = await ApiNews.getNewsListByType(
//          page, pageSize, widget.newsTypeModel.code);
//      jsonCallback(res);

    return hasMore;
  }

  onItemClick(int postision) {
    if (data_list_item != null &&
        postision >= 0 &&
        postision < data_list_item.length &&
        mounted) {
      CurrencyAsset ca = data_list_item[postision];
      if (ca != null) {
        ViewGT.showCurrencyDetailView(context, ca);
      }
    }
  }

  onClickWalletName() {
    ViewGT.showAccountDetailView(context, AccountMgr().currentAccount);
  }

  onClickWalletMenu() {
    eventMgr.send(EventTag.MAIN_RIGHT_DRAWER, true);
  }
}
