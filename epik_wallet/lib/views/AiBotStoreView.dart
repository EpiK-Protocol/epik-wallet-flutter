import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/base/buildConfig.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/LocaleConfig.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/AIBotLatestMgr.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_AIBot.dart';
import 'package:epikwallet/logic/loader/DL_TepkLoginToken.dart';
import 'package:epikwallet/logic/loader/DataLoader.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/model/AIBotApp.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/ClickUtil.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/aibot/AIBotOrdersView.dart';
import 'package:epikwallet/views/mainview.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:epikwallet/widget/text/diff_scale_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AiBotStoreView extends BaseInnerWidget {
  AiBotStoreView(Key key) : super(key: key) {}

  @override
  BaseInnerWidgetState<BaseInnerWidget> getState() {
    return AiBotStoreViewState();
  }

  @override
  int setIndex() {
    return 3;
  }
}

class AiBotStoreViewState extends BaseInnerWidgetState<AiBotStoreView> with TickerProviderStateMixin {
  //所有AIbot列表
  List<AIBotApp> bots = [];

  //最近用过的bot列表
  List<AIBotApp> bots_latest = [];

  List<AIBotBanner> banners = [];

  int page = 0;
  int pagesize = 50;
  bool isLoading = false;
  bool hasMore = false;

  bool get isFirstPage {
    return page == 0;
  }

  ListPageDefState _ListPageDefState;

  Timer timerRefreshPoint;

  /// 自动定时刷新未读
  autoRefreshPoint() {
    dlog("autoRefreshPoint");
    // 周期性定时刷新未读
    if (timerRefreshPoint != null && timerRefreshPoint.isActive) {
      timerRefreshPoint.cancel();
    }
    dlog("autoRefreshPoint first");
    loadPoint();
    // loadBotBalance();
    timerRefreshPoint = Timer.periodic(Duration(seconds: 30), (timer) {
      dlog("autoRefreshPoint timer");
      loadPoint();
      // loadBotBalance();
    });
  }

  @override
  void initStateConfig() {
    super.initStateConfig();
    navigationColor = ResColor.b_2;
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);
    isTopFloatWidgetShow = true;

    _ListPageDefState = ListPageDefState(null, onClick: onClickListPageDefState);

    //启动
    if (timerRefreshPoint == null) {
      autoRefreshPoint();
      dlog("start timer timerRefreshPoint=$timerRefreshPoint  init");
    }

    if (ApiAIBot.TESTNET) {
      ApiAIBot.loginToTest(AccountMgr().currentAccount).then((Map<String, String> tokenmap) {
        if (tokenmap != null) {
          AccountMgr().currentAccount.test_wallet_id = tokenmap["id"]; //6557f446-a035-5d22-86e4-1c245d1d3f1f
          AccountMgr().currentAccount.test_wallet_token = tokenmap["token"];
          refresh();
        }
      });
    }
  }

  void onClickListPageDefState() {
    switch (_ListPageDefState?.type) {
      case ListPageDefStateType.EMPTY:
        onClickEmptyWidget();
        break;
      case ListPageDefStateType.ERROR:
        onClickErrorWidget();
        break;
      case ListPageDefStateType.LOADING:
        break;
    }
  }

  @override
  void onCreate() {
    eventMgr.add(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventcallback_refresh);
    eventMgr.add(EventTag.AI_BOT_POINT_UPDATE, eventcallback_point);
    refresh();
  }

  @override
  void dispose() {
    eventMgr.remove(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventcallback_refresh);
    eventMgr.remove(EventTag.AI_BOT_POINT_UPDATE, eventcallback_point);
    super.dispose();
  }

  void eventcallback_refresh(arg) {
    AccountMgr()?.currentAccount?.test_wallet_id = null;
    AccountMgr()?.currentAccount?.test_wallet_token = null;
    botbalanceMap = {};
    refresh();
  }

  eventcallback_point(arg) {
    if (arg != AccountMgr()?.currentAccount) return;
    setState(() {});
  }

  SwiperController swipercontroller = SwiperController();

  void onResume() {
    super.onResume();
    swipercontroller?.startAutoplay();
    dlog("onResume startAutoplay");
  }

  ///页面被覆盖,暂停
  void onPause() {
    super.onPause();
    swipercontroller?.stopAutoplay();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state != AppLifecycleState.resumed) {
      if (timerRefreshPoint != null && timerRefreshPoint.isActive) {
        timerRefreshPoint.cancel();
      }
      timerRefreshPoint = null;
      dlog("cancel timer timerRefreshPoint=$timerRefreshPoint");
    } else {
      if (timerRefreshPoint == null) {
        autoRefreshPoint();
        dlog("start timer timerRefreshPoint=$timerRefreshPoint");
      }
    }
  }

  refresh() async {
    isLoading = true;
    page = 0;

    dlog("ListPageDefStateType.LOADING");
    if (bots == null || bots.length == 0) {
      _ListPageDefState.type = ListPageDefStateType.LOADING;
    }

    loadPoint();
    // loadBotBalance();

    ApiAIBot.getRechargeConfig();

    //加载banner数据
    List<AIBotBanner> _banners = await ApiAIBot.getBanners();

    //加载bot列表
    HttpJsonRes hjr_list = await ApiAIBot.getAibotList(page, pagesize);

    if (_banners != null) {
      banners = _banners;
    }

    dataCallback(hjr_list?.jsonMap);
  }

  void loadPoint() {
    WalletAccount wa = AccountMgr()?.currentAccount;
    // dlog("loadPoint  1 wa?.isCompleteWallet =${wa?.isCompleteWallet }");
    if (wa?.isCompleteWallet == true) {
      // dlog("loadPoint  2");
      DL_TepkLoginToken.getEntity().getTokenOnline(false,
          (DataLoader dataloader, errCode, msg, p, ps, List pagedata) async {
        if (DL_TepkLoginToken.getEntity().hasToken()) {
          loadBotBalance();

          await EpikWalletUtils.requestAiBotPoint(wa);
          dlog("point = ${wa.aibot_point}");
        }
      });
    }
  }

  Map<String, String> botbalanceMap = {};

  void loadBotBalance() async {
    Map<String, String> _botbalanceMap = null;

    WalletAccount wa = AccountMgr()?.currentAccount;
    if (wa?.isCompleteWallet == true) {
      String wallet_id = wa.mining_id;
      if (ApiAIBot.TESTNET && StringUtils.isNotEmpty(wa.test_wallet_id)) {
        wallet_id = wa.test_wallet_id;
      }
      _botbalanceMap = await ApiAIBot.getBotBalanceList(wallet_id);
    }

    if (_botbalanceMap != null) {
      botbalanceMap = _botbalanceMap;
      setState(() {});
    }
  }

  // 返回账号点数
  num getPointsNum() {
    return AccountMgr()?.currentAccount?.aibot_point;
  }

  // 点数价格
  String getPointPriceStr() {
    return "1";
  }

  double top_expansion_height = 70;

  @override
  Widget getTopFloatWidget() {
    Widget cardview = null;
    if (AccountMgr()?.currentAccount?.isCompleteWallet == true) {
      cardview = Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            // child: Text(
            //   "${StringUtils.formatNumAmount(getPointsNum())}",
            //   style: TextStyle(
            //     fontSize: 30,
            //     color: Colors.white,
            //     fontFamily: "DIN_Condensed_Bold",
            //     // fontWeight: FontWeight.bold,
            //   ),
            // ),
            child: DiffScaleText(
              text: "${StringUtils.formatNumAmount(getPointsNum())}",
              textStyle: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontFamily: "DIN_Condensed_Bold",
              ),
            ),
          ),
          Text(
            RSID.main_abv_3.replace([getPointPriceStr()]),
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              // fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      cardview = LoadingButton(
        margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
        width: 160,
        height: 40,
        gradient_bg: ResColor.lg_5,
        color_bg: Colors.transparent,
        disabledColor: Colors.transparent,
        bg_borderradius: BorderRadius.circular(4),
        text: "Full wallet required.",
        //RSID.main_bv_15.text,
        textstyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        onclick: (lbtn) {
          eventMgr.send(EventTag.CHANGE_MAINVIEW_INDEX, main_subviewTypes.indexOf(MainSubViewType.WALLETVIEW));
        },
      );
    }

    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      height: getTopBarHeight() + getAppBarHeight() + top_expansion_height + 52,
      child: Column(
        children: [
          Container(
            height: getTopBarHeight() + getAppBarHeight() + top_expansion_height,
            decoration: BoxDecoration(
              gradient: ResColor.lg_1,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: <Widget>[
                getTopBar(),
                getAppBar(),
                Container(
                  height: top_expansion_height,
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: cardview,
                ),
              ],
            ),
          ),
          Container(
            height: 52,
            // child: getTabbar(),
          ),
        ],
      ),
    );
  }

  ///导航栏 appBar 可以重写
  Widget getAppBar() {
    bool haswalletid = AccountMgr()?.currentAccount?.hasMiningID();
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      child: Column(
        children: <Widget>[
          Container(
            height: BaseFuntion.appbarheight_def,
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Row(
              children: <Widget>[
                Text(
                  RSID.main_abv_2.text,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                if (haswalletid)
                  InkWell(
                    onTap: () {
                      //  充值
                      onClickRecharge();
                    },
                    child: Container(
                      height: double.infinity,
                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            RSID.main_abv_4.text, //"充值",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            height: double.infinity,
                            padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
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
                Container(
                  width: 10,
                ),
                if (haswalletid)
                  InkWell(
                    onTap: () {
                      //   历史记录
                      onClickHistory();
                    },
                    child: Container(
                      height: double.infinity,
                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            RSID.main_abv_5.text, //"历史",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            height: double.infinity,
                            padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWidget(BuildContext context) {
    Widget widget = null;
    // if (_AiBotPageState == AiBotPageState.needwallet) {
    //   widget = Container(
    //     alignment: Alignment.center,
    //     child: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       children: <Widget>[
    //         Text(
    //           ResString.get(context, RSID.main_bv_7), //"需要有钱包才能进行",
    //           style: TextStyle(
    //             color: Colors.white70,
    //             fontSize: 20,
    //           ),
    //         ),
    //         Container(
    //           height: 10,
    //         ),
    //         FlatButton(
    //           highlightColor: Colors.white24,
    //           splashColor: Colors.white24,
    //           onPressed: () {
    //             eventMgr.send(EventTag.CHANGE_MAINVIEW_INDEX, main_subviewTypes.indexOf(MainSubViewType.WALLETVIEW));
    //           },
    //           child: Text(
    //             ResString.get(context, RSID.main_bv_8), //"去创建钱包",
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
    //         )
    //       ],
    //     ),
    //   );
    // } else if (_AiBotPageState == AiBotPageState.needfullwallet) {
    //   widget = Container(
    //     alignment: Alignment.center,
    //     child: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       children: <Widget>[
    //         Text(
    //           ResString.get(context, RSID.main_bv_15), //"需要完整的钱包",
    //           style: TextStyle(
    //             color: Colors.white60,
    //             fontSize: 18,
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // } else if (_AiBotPageState == null) {
    //   widget = Container();
    // }

    widget = new ListPage(
      bots ?? [],
      headerList: ["banners", "latest", "all_bots", _ListPageDefState],
      headerCreator: (context, position) {
        if (position == 0) {
          //banner
          return bannersBuild(context);
        } else if (position == 1) {
          //最近使用
          return getLatestView();
        } else if (position == 2) {
          if (bots == null || bots.length <= 0) return Container();
          return Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(0, 10, getScreenWidth() * 0.33, 0),
            padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
            decoration: BoxDecoration(
              gradient: ResColor.lg_6,
            ),
            child: Text(
              RSID.main_abv_13.text, //"All AI Bots",
              style: TextStyle(
                fontSize: 14,
                color: ResColor.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else {
          return stateHeaderWidgetBuild(context, position);
        }
      },
      itemWidgetCreator: (context, position) {
        // return InkWell(
        //   onTap: () => onItemClick(position),
        //   child: itemWidgetBuild(context, position),
        // );
        return Container(
          child: Material(
            color: ResColor.b_2,
            child: InkWell(
              highlightColor: ResColor.white_10,
              splashColor: ResColor.white_10,
              onTap: () => onItemClick(position),
              child: itemWidgetBuild(context, position),
            ),
          ),
        );
      },
      pullRefreshCallback: _pullRefreshCallback,
      needLoadMore: needLoadMore,
      onLoadMore: onLoadMore,
      // key: key_scroll,
    );

    return Container(
      padding: EdgeInsets.fromLTRB(0, getTopBarHeight() + getAppBarHeight() + top_expansion_height, 0, 0),
      child: widget,
    );
  }

  Widget getLatestView() {
    // if (bots.length > 5) bots_latest = [bots[2], bots[4], bots[0]];
    // bots_latest= List.from(bots.reversed);

    if (bots_latest == null || bots_latest.length <= 0) return Container();

    double size = 50;

    double ss = (getScreenWidth() - 10) / 6 - 10;
    size = ss;

    // int l  = (getScreenWidth()/(size+10)).floor().toInt();
    // print("getLatestView = $l  ${getScreenWidth()}");

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
                RSID.main_abv_6.text,
                style: TextStyle(
                  fontSize: 14,
                  color: ResColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              // 折叠
            },
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: BoxConstraints(
                minWidth: getScreenWidth(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: bots_latest.map((bot) {
                  Widget botview = Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        top: 0,
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: bot.icon,
                            width: size,
                            height: size,
                            fit: BoxFit.contain,
                            placeholder: (context, url) {
                              return Container(
                                color: ResColor.b_5,
                              );
                            },
                            errorWidget: (context, url, error) {
                              return Container(
                                color: ResColor.b_5,
                                child: Icon(
                                  Icons.broken_image,
                                  size: 24,
                                  color: ResColor.black_80,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (bot.pinned)
                        Positioned(
                          left: 0,
                          top: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(60),
                              border: Border.fromBorderSide(
                                BorderSide(
                                  color: Color(0xffd0a14a), //Color(0xfffdd89a),// ResColor.o_1,//
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );

                  return InkWell(
                    onTap: () {
                      setState(() {
                        aibotlatestmgr.add(bot);
                        aibotlatestmgr.save();
                      });
                      gotoBotWebView(bot);
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                      child: Container(
                        width: size,
                        height: size,
                        child: botview,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget itemWidgetBuild(BuildContext context, int position) {
    AIBotApp bot = bots[position];
    bool isend = bot == bots.last;
    String balance = botbalanceMap["${bot.id}"] ?? "";

    if (bot.pinned) {
      return itemWidgetBuildPinned(context, position);
    }

    String des = "";
    if (LocaleConfig.currentIsZh()) {
      des = bot.description;
    } else {
      des = bot.description_en;
    }

    return Container(
      // height: 65,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(20, 0, 10, 0),
                  width: 60,
                  height: 60,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Positioned(
                        left: 0,
                        top: 0,
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: bot.icon,
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                            placeholder: (context, url) {
                              return Container(
                                // color: ResColor.white_10,
                                color: ResColor.b_5,
                              );
                            },
                            errorWidget: (context, url, error) {
                              return Container(
                                // color: ResColor.white_10,
                                color: ResColor.b_5,
                                child: Icon(
                                  Icons.broken_image,
                                  size: 24,
                                  color: ResColor.black_80,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wrap(
                      //   crossAxisAlignment: WrapCrossAlignment.center,
                      //   children: [
                      //     Text(
                      //       bot.name + "asdfasdfasdfasdfasdfasdfasdfasdfagsdfgsdfgsdfg",
                      //       style: TextStyle(
                      //         fontSize: 14,
                      //         color: ResColor.white,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //     if (StringUtils.isNotEmpty(balance))
                      //       Text(
                      //         " (Balance:$balance)",
                      //         style: TextStyle(
                      //           color: Colors.white,
                      //           fontSize: 12,
                      //         ),
                      //       ),
                      //   ],
                      // ),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: ResColor.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: bot.name,
                            ),
                            if (StringUtils.isNotEmpty(balance) && balance != "0")
                              TextSpan(
                                text: " (Credits:$balance)",
                                style: TextStyle(
                                  color: ResColor.o_1,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (StringUtils.isNotEmpty(des))
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                          child: Text(
                            des,
                            style: TextStyle(
                              fontSize: 10,
                              color: ResColor.white,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(width: 15)
              ],
            ),
          ),
          // Positioned(
          //   top: -8,
          //   right: -8,
          //   width: 30,
          //   height: 30,
          //   child: Banner(
          //     message: "🔥9999",
          //     color: ResColor.progress,
          //     textStyle: TextStyle(
          //       color: Colors.white,
          //       fontSize: 10,
          //     ),
          //     textDirection: TextDirection.ltr,
          //     location: BannerLocation.topEnd,
          //   ),
          // ),
          if (bot.hot > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 2, 15, 2),
                constraints: BoxConstraints(minWidth: 60),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xffF28955), Color(0x00F28955)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), topLeft: Radius.circular(8)),
                ),
                child: Text(
                  "🔥 " + bot.hot.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
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
  }

  Widget itemWidgetBuildPinned(BuildContext context, int position) {
    AIBotApp bot = bots[position];
    bool isend = bot == bots.last;
    String balance = botbalanceMap["${bot.id}"] ?? "";

    String des = "";
    if (LocaleConfig.currentIsZh()) {
      des = bot.description;
    } else {
      des = bot.description_en;
    }

    return Container(
      // height: 65,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
            decoration: BoxDecoration(
              gradient: ResColor.lg_8,
            ),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(20, 0, 10, 0),
                  width: 60,
                  height: 60,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Positioned(
                        left: 0,
                        top: 0,
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: bot.icon,
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                            placeholder: (context, url) {
                              return Container(
                                color: ResColor.b_5,
                              );
                            },
                            errorWidget: (context, url, error) {
                              return Container(
                                color: ResColor.b_5,
                                child: Icon(
                                  Icons.broken_image,
                                  size: 24,
                                  color: ResColor.black_80,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        left: -1,
                        top: -1,
                        right: -1,
                        bottom: -1,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(60),
                            border: Border.fromBorderSide(
                              BorderSide(
                                color: Color(0xffd0a14a), //Color(0xfffdd89a),// ResColor.o_1,//
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Positioned(
                      //     left: 0,
                      //     right: 0,
                      //     bottom: -8,
                      //     child: Container(
                      //       alignment: Alignment.center,
                      //       child: Container(
                      //         width: 36,
                      //         height: 16,
                      //         alignment: Alignment.center,
                      //         decoration: BoxDecoration(
                      //           gradient: ResColor.lg_5,
                      //           borderRadius: BorderRadius.circular(20),
                      //         ),
                      //         child: Text(
                      //           RSID.mani_abv_24.text,//"置顶",
                      //           style: TextStyle(
                      //             color: Colors.white,
                      //             fontSize: 10,
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      // ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: ResColor.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: bot.name,
                            ),
                            if (StringUtils.isNotEmpty(balance) && balance != "0")
                              TextSpan(
                                text: " (Credits:$balance)",
                                style: TextStyle(
                                  color: ResColor.o_1,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (StringUtils.isNotEmpty(des))
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                          child: Text(
                            des,
                            style: TextStyle(
                              fontSize: 10,
                              color: ResColor.white,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(width: 15)
              ],
            ),
          ),
          if (bot.hot > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 2, 15, 2),
                constraints: BoxConstraints(minWidth: 60),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xffF28955), Color(0x00F28955)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), topLeft: Radius.circular(8)),
                ),
                child: Text(
                  "🔥 " + bot.hot.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
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
  }

  Widget bannersBuild(BuildContext context) {
    if (banners?.length <= 0) return Container();

    double padding_lr = 15;
    double padding_b = 15;

    return Container(
      width: double.infinity,
      height: (getScreenWidth() - padding_lr * 2) / 2 + padding_b * 2,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Swiper(
        itemCount: banners?.length,
        autoplay: true,
        autoplayDelay: 5000,
        // scale: 2,
        controller: swipercontroller,
        onIndexChanged: (value) {
          // print("banner $value");
        },
        pagination: SwiperPagination(
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.fromLTRB(0, 0, 0, 2),
          builder: DotSwiperPaginationBuilder(size: 6, activeSize: 6, activeColor: ResColor.o_1),
        ),
        itemBuilder: (BuildContext context, int index) {
          AIBotBanner banner = banners[index];

          Widget bannerview = Container(
            width: double.infinity,
            height: (getScreenWidth() - padding_lr * 2) / 2,
            padding: EdgeInsets.all(padding_lr),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: CachedNetworkImage(
                      imageUrl: banner.image,
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
                    ),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      // color: ResColor.white_20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0x66ffffff), Color(0x00ffffff)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Text(
                        banner.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: ResColor.black_80, //Color(0x28000000),
                              offset: Offset(0, 0),
                              blurRadius: 6,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

          return InkWell(
            child: bannerview,
            onTap: () {
              if (StringUtils.isNotEmpty(banner.url) &&
                  (banner.url.startsWith("http://") || banner.url.startsWith("https://"))) {
                if (banner.outside) {
                  ViewGT.openOutUrl(banner.url);
                } else {
                  ViewGT.showGeneralWebView(context, banner.title ?? "", banner.url);
                }
              }
            },
          );
        },
      ),
    );
  }

  Widget stateHeaderWidgetBuild(BuildContext context, int position) {
    try {
      return ListPageDefStateWidgetHeader.getWidgetHeader(_ListPageDefState);
    } catch (e) {
      print(e);
    }
    return Container();
  }

  void onItemClick(int position) async {
    AIBotApp bot = bots[position];

    setState(() {
      aibotlatestmgr.add(bot);
      aibotlatestmgr.save();
    });

    gotoBotWebView(bot);
  }

  void gotoBotWebView(AIBotApp bot) async {

    // 点击item 跳转bot webview
    if (AccountMgr()?.currentAccount?.hasMiningID()) {
      if (ApiAIBot.TESTNET) {
        // test todo
        if (AccountMgr().currentAccount.test_wallet_id == null ||
            AccountMgr().currentAccount.test_wallet_token == null) {
          showLoadDialog("");
          Map<String, String> tokenmap = await ApiAIBot.loginToTest(AccountMgr().currentAccount);
          if (tokenmap != null) {
            AccountMgr().currentAccount.test_wallet_id = tokenmap["id"];
            AccountMgr().currentAccount.test_wallet_token = tokenmap["token"];
          }
          closeLoadDialog();
        }
        ViewGT.showAIBotWebView(context, bot,
                wallet_id: AccountMgr().currentAccount.test_wallet_id,
                wallet_token: AccountMgr().currentAccount.test_wallet_token)
            .then((value) {
          loadBotBalance();
        });
      } else {
        ViewGT.showAIBotWebView(context, bot).then((value) {
          loadBotBalance();
        });
      }
    } else {
      showToast(RSID.main_bv_15.text);
    }
  }

  void onClickErrorWidget() {
    refresh();
  }

  void onClickEmptyWidget() {
    refresh();
  }

  void onClickRecharge() {
    //充值
    if (ClickUtil.isFastDoubleClick()) return;

    BottomDialog.showAiBotPointRechargeDialog(context, AccountMgr().currentAccount, ApiAIBot.ai_bot_recharge_config,
        (bool ok_transfer, bool ok_recharge, CurrencySymbol cs, String txhash, String error) async {
      await Future.delayed(Duration(milliseconds: 500));

      dlog("ok_transfer=$ok_transfer  ok_recharge=$ok_recharge  cs=${cs.symbol}  txhash=$txhash  error=$error");
      if (ok_transfer && ok_recharge) {
        //充值成功
        MessageDialog.showMsgDialog(
          appContext,
          title: RSID.main_abv_7.text,
          msg: RSID.main_abv_20.text,
          btnLeft: RSID.confirm.text,
          onClickBtnLeft: (dialog) {
            dialog.dismiss();
          },
          onDismiss: (dialog) {
            Future.delayed(Duration(milliseconds: 250)).then((value) {
              onClickHistory();
            });
          },
        );
      } else if (ok_transfer && ok_recharge != true) {
        //转账成功 但是上报失败
        showToast("Recharge error, please try to claim Point with transaction record.", length: Toast.LENGTH_LONG);
        BottomDialog.showAiBotPointClaimDialog(cs, txhash, null);
      } else if (ok_transfer != true && ok_recharge != true) {
        // 转账失败 也没上报
        MessageDialog.showMsgDialog(
          appContext,
          title: RSID.cwv_11.text,
          msg: error ?? "",
          btnLeft: RSID.confirm.text,
          onClickBtnLeft: (dialog) {
            dialog.dismiss();
          },
        );
      }
    });
  }

  void onClickHistory() {
    //历史
    if (ClickUtil.isFastDoubleClick()) return;

    ViewGT.showView(context, AIBotOrdersView());
  }

  dataCallback(Map<String, dynamic> retmap) {
    List data = null;
    if (retmap != null) data = retmap["data"];
    if (data != null) {
      // 请求成功
      if (isFirstPage) {
        bots.clear();

        // todo test
        // if(BuildConfig.isDebug)
        // {
        //   AIBotApp aibotapp  = AIBotApp();
        //   aibotapp.id=22;
        //   aibotapp.name="Comic to Human Master";
        //   aibotapp.icon="https://cdn.epik-protocol.io/DAuqfa4ikx8m2MpP598z3hkv1eBzHDLiL8XgFswM752x";
        //   aibotapp.description="漫改真人";
        //   aibotapp.description_en="Comic to Human";
        //   // aibotapp.url="http://192.168.31.203:62638/#/?type=cartoon_realistic";
        //   aibotapp.url="https://bot.epik-protocol.io/bot-avator/#/?type=cartoon_realistic";
        //   bots.add(aibotapp);
        // }
      }

      List<AIBotApp> _bots = JsonArray.parseList(data, (json) => AIBotApp.fromJson(json));
      bots.addAll(_bots);

      if (data.length >= pagesize) {
        hasMore = true;
        page += 1;
      } else {
        hasMore = false;
      }
      _ListPageDefState.type = bots.length > 0 ? null : ListPageDefStateType.EMPTY;
    } else {
      showToast(ResString.get(context, RSID.request_failed)); //"请求失败);
      if (isFirstPage) {
        _ListPageDefState.type = ListPageDefStateType.ERROR;
      }
    }

    if (bots != null && bots.length > 0) {
      aibotlatestmgr.updata(bots);
      aibotlatestmgr.save();
      bots_latest = aibotlatestmgr.data;
    }

    closeStateLayout();
    isLoading = false;
    return;
  }

  Future<void> _pullRefreshCallback() async {
    if (isLoading) {
      return;
    }
    await refresh();
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

    //加载bot列表
    HttpJsonRes hjr_list = await ApiAIBot.getAibotList(page, pagesize);
    dataCallback(hjr_list?.jsonMap);

    return hasMore;
  }
}
