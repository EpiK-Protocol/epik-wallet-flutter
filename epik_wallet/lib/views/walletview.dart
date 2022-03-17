import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/LocaleConfig.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/CurrencyAsset.dart';
import 'package:epikwallet/model/HomeMenuItem.dart';
import 'package:epikwallet/model/auth/RemoteAuth.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/ClickUtil.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/views/wallet/RemoteAuthView.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:epikwallet/widget/text/diff_scale_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/src/widgets/framework.dart';

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

class _WalletViewState extends BaseInnerWidgetState<WalletView> with TickerProviderStateMixin {
  int tickertiem = 500;

  bool has_10100 = false;

  @override
  void initState() {
    super.initState();
    navigationColor = ResColor.b_2;
  }

  String balance = "0";

  // List<CurrencyAsset> data_list_item = [];
  Map<CurrencySymbol, List<CurrencyAsset>> currency_group = {};
  Map<CurrencySymbol, bool> currency_group_open = {};

  GlobalKey<ListPageState> key_scroll;

  double header_alpha = 0;

  bool noWallet = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ServiceInfo.getHomeMenuList()?.forEach((element) {print("getHomeMenuList ${element.Action}");});
  }

  @override
  void initStateConfig() {
    isTopBarShow = false; //状态栏是否显示
    isAppBarShow = false; //导航栏是否显示
    isTopFloatWidgetShow = false;
    // headerlist = ["header"];
    headerlist = [];
    // headerlist.add("exchange_epk");
    // headerlist.add("hunter_reward");
    // headerlist.add("uniswap");
    // headerlist.add("testminingprofit");
    headerlist.add("grid");
  }

  @override
  void onCreate() {
    super.onCreate();
    eventMgr.add(EventTag.LOCAL_ACCOUNT_LIST_CHANGE, eventCallback_account);
    eventMgr.add(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventCallback_account);
    eventMgr.add(EventTag.UPDATE_SERVER_CONFIG, eventCallback_account);
    eventMgr.add(EventTag.BALANCE_UPDATE, eventCallback_balance);
    refresh();
  }

  eventCallback_account(obj) {
    refresh();
  }

  eventCallback_balance(obj) {
    if (AccountMgr().currentAccount != null) {
      // data_list_item = AccountMgr().currentAccount.currencyList;
      makeCurrencyGroup();
      balance = StringUtils.formatNumAmount(AccountMgr().currentAccount.total_usd, point: 2);
      setState(() {});
    }
  }

  makeCurrencyGroup() {
    // if (data_list_item?.length >= 6)
    //   currency_group = {
    //     CurrencySymbol.EPK: [data_list_item[0]],
    //     CurrencySymbol.ETH: [data_list_item[1], data_list_item[2], data_list_item[3]],
    //     CurrencySymbol.BNB: [data_list_item[4], data_list_item[5], data_list_item[6]],
    //   };

    currency_group = {};
    WalletAccount wa = AccountMgr().currentAccount;
    if (wa.hasEpikWallet) {
      currency_group[CurrencySymbol.EPK] = [wa.getCurrencyAssetByCs(CurrencySymbol.EPK)];
    }
    if (wa.hasHdWallet) {
      currency_group[CurrencySymbol.ETH] = [
        wa.getCurrencyAssetByCs(CurrencySymbol.EPKerc20),
        wa.getCurrencyAssetByCs(CurrencySymbol.ETH),
        wa.getCurrencyAssetByCs(CurrencySymbol.USDT),
      ];
      currency_group[CurrencySymbol.BNB] = [
        wa.getCurrencyAssetByCs(CurrencySymbol.EPKbsc),
        wa.getCurrencyAssetByCs(CurrencySymbol.BNB),
        wa.getCurrencyAssetByCs(CurrencySymbol.USDTbsc),
      ];
    }
  }

  @override
  void dispose() {
    eventMgr.remove(EventTag.LOCAL_ACCOUNT_LIST_CHANGE, eventCallback_account);
    eventMgr.remove(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventCallback_account);
    eventMgr.remove(EventTag.UPDATE_SERVER_CONFIG, eventCallback_account);
    eventMgr.remove(EventTag.BALANCE_UPDATE, eventCallback_balance);
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
            // "EpiK ${ResString.get(context, RSID.main_wv_5)}${ServiceInfo.TEST_DEV_NET ? " DEV" : ""}",
            "EpiK ${ServiceInfo?.serverConfig?.EPKNetwork}${ServiceInfo.TEST_DEV_NET ? " DEV" : ""}",
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
            currency_group.keys.toList(),
            headerList: headerlist,
            headerCreator: headerBuilder,
            itemWidgetCreator: listGroupBuilder,
            scrollCallback: scrollCallback,
            pullRefreshCallback: _pullRefreshCallback,
            key: key_scroll,
            needNoMoreTipe: false,
          ),
        ),
      ],
    );
  }

  Widget buildTopCard() {
    double h1 = getTopBarHeight() + getAppBarHeight();
    double h2 = 128;
    return Container(
      width: double.infinity,
      height: h1 + h2,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      decoration: BoxDecoration(
        gradient: ResColor.lg_1,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          //水印图标
          Positioned(
              left: -20,
              bottom: 20,
              width: 81,
              height: 81,
              child: Image.asset(
                "assets/img/ic_epik_watermark.png",
                color: Colors.white60,
              )),
          Column(
            children: [
              getAppBar(),
              Expanded(
                child: InkWell(
                  onTap: () {
                    onClickWalletName();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
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
                            "≈ " + StringUtils.formatNumAmount(AccountMgr().currentAccount.total_btc, point: 8),
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget headerBuilder(BuildContext context, int position) {
    // ["header","exchange_epk","hunter_reward"]
    // print("position=$position  headerlist.size=${headerlist.length}");
    switch (headerlist[position]) {
      case "grid":
        return buildMenuGrid();
    }

    return new Padding(
      padding: EdgeInsets.all(10.0),
      child: Text('$position -----header------- '),
    );
  }

  Widget listGroupBuilder(BuildContext context, int position) {
    CurrencySymbol key = currency_group.keys.toList()[position];
    List<CurrencyAsset> datalist = currency_group[key];
    bool open = currency_group_open[key] ?? true;

    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(0, 10, getScreenWidth() * 0.33, 0),
              padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
              decoration: BoxDecoration(
                gradient: ResColor.lg_6,
              ),
              child: Text(
                key.networkTypeName + (ServiceInfo.TEST_DEV_NET ? " TestNet" : ""),
                style: TextStyle(
                  fontSize: 14,
                  color: ResColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              if (ClickUtil.isFastDoubleClick()) return;
              open = !open;
              currency_group_open[key] = open;
              setState(() {});
            },
          ),
          AnimatedSizeAndFade(
            vsync: this,
            child: open
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: datalist.map((ca) {
                      bool isend = ca == datalist.last;
                      return Container(
                        child: Material(
                          color: ResColor.b_2,
                          child: InkWell(
                            highlightColor: ResColor.white_10,
                            splashColor: ResColor.white_10,
                            onTap: () => onItemClick(ca),
                            child: itemWidgetBuild2(context, ca, isend),
                          ),
                        ),
                      );
                    }).toList(),
                  )
                : Container(),
            fadeDuration: Duration(milliseconds: tickertiem),
            sizeDuration: Duration(milliseconds: tickertiem),
          ),
        ],
      ),
    );
  }

  Widget itemWidgetBuild2(
    BuildContext context,
    CurrencyAsset ca,
    bool isend,
  ) {
    if (ca != null) {
      return Container(
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
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Positioned(
                        left: 0,
                        top: 0,
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
                      Positioned(
                        right: -1.5,
                        bottom: -1.5,
                        child: ca.networkType != null
                            ? Container(
                                width: 15,
                                height: 15,
                                padding: EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: const Color(0xff202020), //Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
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
                      ? StringUtils.formatNumAmount(ca.getBalanceDouble(), point: 8, supply0: false)
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
                    height: 0.5, //1/ScreenUtil.pixelRatio,
                    thickness: 0.5, // 1/ScreenUtil.pixelRatio,
                    indent: 20,
                    color: ResColor.white_20,
                  )),
          ],
        ),
      );
    } else {
      // return Padding(padding: new EdgeInsets.all(10.0), child: new Text("no data"));
      return Container();
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
                    border: Border.all(color: const Color(0xffeba544), width: 1),
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
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, height: 1),
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
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, height: 1),
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

    noWallet =
        AccountMgr().currentAccount == null || AccountMgr().account_list == null || AccountMgr().account_list.isEmpty;

    if (noWallet) {
      setState(() {});
      return;
    }

    setState(() {
      dlog("refresh ${AccountMgr().currentAccount.account}");
    });

    isLoading = true;
    proressBackgroundColor = Colors.transparent;
    setLoadingWidgetVisible(true);

    // AccountMgr().currentAccount.uploadSuggestGas();
    AccountMgr().currentAccount.uploadEpikGasTransfer();

    EpikWalletUtils.requestBalance(AccountMgr().currentAccount).then((value) {
      isLoading = false;
      // data_list_item = AccountMgr().currentAccount.currencyList;
      makeCurrencyGroup();
      balance = StringUtils.formatNumAmount(AccountMgr().currentAccount.total_usd, point: 2);
      closeStateLayout();
    });
  }

  @override
  Widget getLoadingWidget() {
    // return InkWell(
    //   // onTap: () {
    //   //
    //   // },
    //   child:Container(
    //     width: double.infinity,
    //     height: double.infinity,
    //     padding: EdgeInsets.only(top: getTopBarHeight() + getAppBarHeight()+300),
    //     child: super.getLoadingWidget(),
    //   ),
    // );
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(top: getTopBarHeight() + getAppBarHeight() + 300),
      child: super.getLoadingWidget(),
    );
  }

  void onClickErrorWidget() {
    refresh();
  }

  void onClickEmptyWidget() {
    refresh();
  }

  Future<void> _pullRefreshCallback() async {
    await EpikWalletUtils.requestBalance(AccountMgr().currentAccount);
    // AccountMgr().currentAccount.uploadSuggestGas();
    AccountMgr().currentAccount.uploadEpikGasTransfer();
    setState(() {
      isLoading = false;
      // data_list_item = AccountMgr().currentAccount.currencyList;
      makeCurrencyGroup();
      balance = StringUtils.formatNumAmount(AccountMgr().currentAccount.total_usd, point: 2);
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

  onItemClick(CurrencyAsset ca) {
    if (mounted) {
      if (ca != null) {
        ViewGT.showCurrencyDetailView(context, ca);
      }
    }
  }

  onClickWalletName() {
    ViewGT.showAccountDetailView(context, AccountMgr().currentAccount);
  }

  onClickWalletMenu() async {
    eventMgr.send(EventTag.MAIN_RIGHT_DRAWER, true);
  }

  double gridItemHightRatio = 0;

  int gridItem_crossAxisCount = 4;

  Widget buildMenuGrid() {
    if (gridItemHightRatio == 0) {
      gridItemHightRatio = 1.0 * (getScreenWidth() - 12 * 2) / gridItem_crossAxisCount / 94; //    每个item的宽 / 高 = 比例
    }

    List<HomeMenuItem> datas = ServiceInfo.getHomeMenuList();
    if (datas != null && datas.length >= 7) {
      datas = datas.sublist(0, 7);
    }
    if (LocaleConfig.currentIsZh()) {
      datas.add(HomeMenuItem.fromJson({
        "Name": "更多",
        "Action": "more",
      }));
    } else {
      datas.add(HomeMenuItem.fromJson({
        "Name": "More",
        "Action": "more",
      }));
    }

    if (datas != null && datas.length > 0) {
      List<Widget> items = [];

      datas.forEach((hmi) {
        bool isLocalWalletSupport = hmi?.action_l?.isLocalWalletSupport(AccountMgr().currentAccount) ??
            AccountMgr().currentAccount.isSupportCurrency(hmi?.web3nettype) ??
            true;

        Widget img = hmi?.hasNetImg == true
            ? CachedNetworkImage(
                imageUrl: hmi.Icon,
                width: 50,
                height: 50,
                // fit: BoxFit.contain,
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
                image: AssetImage(hmi?.action_l?.getLocalIcon() ?? ""),
                width: 50,
                height: 50,
              );

        Widget column = Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: (hmi?.Invalid == true || isLocalWalletSupport != true)
                  ? ShaderMask(
                      shaderCallback: (bounds) {
                        return const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xff1b1b1b),//ResColor.white_90,
                            Color(0xff1b1b1b),//ResColor.black_90,
                          ],
                        ).createShader(bounds);
                      },
                      child: img,
                      blendMode: BlendMode.hue, //BlendMode.saturation, //灰度模式
                    )
                  : img,
            ),
            Text(
              hmi?.Name ?? "",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: ResColor.white_80,
              ),
            ),
          ],
        );
        Widget item = InkWell(
          onTap: () {
            if (!ClickUtil.isFastDoubleClick() && isLocalWalletSupport) {
              if (hmi?.Invalid == true) {
                showToast(RSID.main_wv_10.text);
              } else {
                onClickMenuItem(hmi);
              }
            }
          },
          child: column,
        );

        items.add(item);
      });

      return Container(
        margin: EdgeInsets.only(top: 10),
        padding: EdgeInsets.fromLTRB(12, 20, 12, 0),
        //12,20,12,0
        color: const Color(0xff1b1b1b),
        width: double.infinity,
        child: GridView.count(
          shrinkWrap: true,
          //嵌套 无限内容
          physics: NeverScrollableScrollPhysics(),
          //嵌套 无滚动
          //水平子Widget之间间距
          crossAxisSpacing: 0,
          //垂直子Widget之间间距
          mainAxisSpacing: 0,
          //GridView内边距
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          //一行的Widget数量
          crossAxisCount: gridItem_crossAxisCount,
          //子Widget宽高比例
          childAspectRatio: gridItemHightRatio,
          children: items,
        ),
      );
    }

    return null;
  }

  onClickMenuItem(HomeMenuItem hmi) async {
    if (hmi?.Action?.startsWith("http") == true) {
      if (hmi?.web3nettype != null) {
        ViewGT.showWeb3GeneralWebView(context, hmi?.Name, hmi?.Action, hmi?.web3nettype);
      } else {
        ViewGT.showGeneralWebView(context, hmi.Name, hmi?.Action);
      }
    } else if (hmi?.action_l != null) {
      switch (hmi.action_l) {
        case HomeMenuItemAction.swap:
          ViewGT.showErc20ToEpkView(context, hmi.Name);
          break;
        case HomeMenuItemAction.dapp:
          ViewGT.showTakeBountyView(context, hmi.Name);
          break;
        // case HomeMenuItemAction.uniswap:
        //   ViewGT.showTransactionView2(context);
        //   break;
        // case HomeMenuItemAction.airdrop:
        //   {
        //     String mining_id = AccountMgr()?.currentAccount?.mining_id;
        //     if (StringUtils.isEmpty(mining_id)) {
        //       showLoadDialog("");
        //       await DL_TepkLoginToken.getEntity().refreshData(false);
        //       closeLoadDialog();
        //     }
        //     mining_id = AccountMgr()?.currentAccount?.mining_id;
        //     if (StringUtils.isEmpty(mining_id)) {
        //       return;
        //     }
        //     ViewGT.showMiningProfitView(context, mining_id, hmi.Name);
        //   }
        //   break;
        case HomeMenuItemAction.scan:
          {
            //远程授权 扫码
            ViewGT.showQrcodeScanView(context).then((value) {
              RemoteAuth ra = RemoteAuth.fromString(value);
              if (ra == null) {
                showToast(RSID.qsv_2.text);
                return;
              }

              if (RemoteAuth.code_version < ra.v) {
                showToast(RSID.qsv_3.text);
                return;
              }

              if (ra.isSign) {
                //单纯远程签名 回调授权
                ViewGT.showView(context, RemoteAuthView(ra));
                // BottomDialog.showPassWordInputDialog(
                //     context, AccountMgr().currentAccount.password,
                //     (value) async {
                //   showLoadDialog("");
                //   ApiWallet.sendRemoteAuth(ra).then((hjr) {
                //     closeLoadDialog();
                //     if (hjr.code != 0) {
                //       showToast(hjr.msg);
                //     }
                //   });
                // });
              } else if (ra.isDeal) {
                // 交易签名  如扫码支付
                BottomDialog.showRemoteAuthMessageDialog(context, AccountMgr().currentAccount, ra, (value) async {
                  showLoadDialog("");

                  String message = jsonEncode(ra.m);
                  ResultObj<String> robj = await AccountMgr()
                      .currentAccount
                      .epikWallet
                      .signAndSendMessage(AccountMgr().currentAccount.epik_EPK_address, message);

                  closeLoadDialog();

                  if (robj?.isSuccess == true) {
                    String cid = robj.data;
                    MessageDialog.showMsgDialog(
                      context,
                      title: RSID.dlg_bd_5.text,
                      //"发送交易",
                      msg: "${RSID.minerview_18.text}\n$cid",
                      //交易已提交
                      btnLeft: RSID.minerview_19.text,
                      //"查看交易",
                      btnRight: RSID.isee.text,
                      onClickBtnLeft: (dialog) {
                        dialog.dismiss();
                        String url = ServiceInfo.epik_msg_web + cid;
                        ViewGT.showGeneralWebView(context, RSID.berlv_4.text, url);
                      },
                      onClickBtnRight: (dialog) {
                        dialog.dismiss();
                      },
                    );
                  } else {
                    showToast(robj?.errorMsg ?? RSID.request_failed.text);
                  }
                });
              }
            });
          }
          break;
        case HomeMenuItemAction.setting:
          onClickWalletName();
          break;
        case HomeMenuItemAction.more:
          ViewGT.showHomeMenuMoreView(context, hmi.Name);
          break;
      }
    }
  }
}
