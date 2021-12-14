import 'dart:ui';

import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/dialog/PopMenuDialog.dart';
import 'package:epikwallet/localstring/LocaleConfig.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_bounty.dart';
import 'package:epikwallet/logic/loader/DL_TepkLoginToken.dart';
import 'package:epikwallet/logic/loader/DataLoader.dart';
import 'package:epikwallet/model/BountyTask.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/mainview.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:epikwallet/widget/rect_getter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/src/widgets/framework.dart';

class BountyView extends BaseInnerWidget {
  BountyView(Key key) : super(key: key) {}

  @override
  BaseInnerWidgetState<BaseInnerWidget> getState() {
    return BountyViewState();
  }

  @override
  int setIndex() {
    return 2;
  }
}

enum BountyPageState {
  needwallet,
  needmining,
  bounty,
}

class BountyViewState extends BaseInnerWidgetState<BountyView>
    with TickerProviderStateMixin {
  int pageIndex = 0;

  BountyStateType state = null;
  BountyFilterType _DataFilterType = BountyFilterType.ALL;

  List<BountyTask> datalist = [];

  GlobalKey<ListPageState> key_scroll = GlobalKey();

  int page = 0;
  int pageSize = 20;
  bool isLoading = false;
  bool hasMore = false;

  TabController tabcontroller;

  @override
  void initStateConfig() {
    super.initStateConfig();
    navigationColor = ResColor.b_2;
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);
    isTopFloatWidgetShow = true;
  }

  @override
  void onCreate() {
    eventMgr.add(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventcallback_refresh);
    eventMgr.add(EventTag.BOUNTY_EDITED_USER_LIST, eventcallback_refresh);
    eventMgr.add(EventTag.BIND_SOCIAL_ACCCOUNT, eventcallback_refresh);
    refresh();
  }

  @override
  void dispose() {
    eventMgr.remove(
        EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventcallback_refresh);
    eventMgr.remove(EventTag.BOUNTY_EDITED_USER_LIST, eventcallback_refresh);
    eventMgr.remove(EventTag.BIND_SOCIAL_ACCCOUNT, eventcallback_refresh);
    super.dispose();
  }

  eventcallback_refresh(arg) {
    refresh();
  }

  BountyPageState _BountyPageState;

  refresh() {
    if (AccountMgr().currentAccount == null) {
      _BountyPageState = BountyPageState.needwallet;
//      setAppBarVisible(false);
      closeStateLayout();
      isLoading = false;
      return;
    }

    isLoading = true;

    setLoadingWidgetVisible(true);

    // ApiTestNet.getHome().then((value) {
    //   if (value) {
    //     if (mounted) setState(() {});
    //   }
    // });

    DL_TepkLoginToken.getEntity().getTokenOnline(false,
            (DataLoader dataloader, errCode, msg, p, ps, List pagedata) async {
          if (errCode == 0 && DL_TepkLoginToken.getEntity().hasToken()) {
            // 有token
            _BountyPageState = BountyPageState.bounty;
//        setAppBarVisible(true);
            this.page = 0;
            ApiBounty.getBountyTaskList(
                DL_TepkLoginToken.getEntity().getToken(),
                page, this.pageSize, state, _DataFilterType)
                .then((value) => dataCallback(value));

            // 刷新积分
            ApiBounty.getBountyScore(DL_TepkLoginToken.getEntity().getToken(),
                AccountMgr().currentAccount)
                .then((currentAccount) {
              if (mounted) setState(() {});
            });
          } else {
            // 网络请求错误
            isLoading = false;
            _BountyPageState = null;
            setErrorWidgetVisible(true);
//        setAppBarVisible(true);
          }
        });
  }

  dataCallback(HttpJsonRes hjr) {
    List<BountyTask> data;

    if (hjr != null && hjr.code == 0) {
      // 解析数据列表
      data = JsonArray.parseList<BountyTask>(
          hjr?.jsonMap["list"] ?? [], (json) => BountyTask.fromJson(json));
    }

    if (data != null) {
      // 请求成功
      if (page == 0) {
        key_scroll?.currentState?.scrollController?.jumpTo(0);
        datalist.clear();
      }
      datalist.addAll(data);

      if (data.length >= pageSize) {
        hasMore = true;
        page += 1;
      } else {
        hasMore = false;
      }

      if (datalist.length == 0) {
        setEmptyWidgetVisible(true);
        return;
      }
    } else {
//      showToast("请求失败");
      if (page == 0) {
        setErrorWidgetVisible(true);
        return;
      }
    }
    closeStateLayout();
    isLoading = false;
    return;
  }

  @override
  Widget getTopFloatWidget() {
    if (_BountyPageState == BountyPageState.bounty)
      return Positioned(
        left: 0,
        right: 0,
        top: 0,
        height: getTopBarHeight() + getAppBarHeight() + 70 + 52,
        child: Column(
          children: [
            Container(
              height: getTopBarHeight() + getAppBarHeight() + 70,
              decoration: BoxDecoration(
                gradient: ResColor.lg_1,
                borderRadius:
                BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Column(
                children: <Widget>[
                  getTopBar(),
                  getAppBar(),
                  Container(
                    height: 70,
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Text(
                            "${StringUtils.formatNumAmount(AccountMgr()
                                ?.currentAccount?.bounty_score)}",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontFamily: "DIN_Condensed_Bold",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        InkWell(
                          onTap: () {
                            onClickBountyExchange();
                          },
                          child: Container(
                            height: double.infinity,
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  ResString.get(context, RSID.main_bv_2),
                                  //"兑换",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
            ),
            Container(
              height: 52,
              child: getTabbar(),
            ),
          ],
        ),
      );

    return Container();
  }

  GlobalKey key_btn1 = RectGetter.createGlobalKey();

  Widget getTabbar() {
    List<RSID> items = [RSID.main_bv_4, RSID.main_bv_5, RSID.main_bv_6];

    if (tabcontroller == null)
      tabcontroller = TabController(
          initialIndex: pageIndex, length: items.length, vsync: this);
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.fromLTRB(10, 0, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              tabs: items.map((rsid) {
                return Container(
                  alignment: Alignment.bottomCenter,
                  child: Text(rsid.text),
                );
              }).toList(),
              controller: tabcontroller,
              isScrollable: true,
              labelPadding: EdgeInsets.fromLTRB(10, 0, 10, 10),
              labelColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
              unselectedLabelColor: ResColor.white_60,
              unselectedLabelStyle: TextStyle(
                fontSize: 14,
                color: ResColor.white_60,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: ResColor.lg_1,
              ),
              indicatorPadding: EdgeInsets.fromLTRB(8, 42, 8, 6),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 4,
              onTap: (value) {
                onClickTab(value);
              },
            ),
          ),
          Container(
            width: 15,
          ),
          InkWell(
            onTap: () {
              Rect rect = RectGetter.getRectFromKey(key_btn1);
              PopMenuDialog.show<BountyFilterType>(
                context: context,
                rect: rect,
                datas: BountyFilterType.values,
                itemBuilder: (item, dialog) {
                  return InkWell(
                    onTap: () {
                      dialog?.dismiss();
                      onSelected(item);
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(15, 10, 20, 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: _DataFilterType == item
                                ? Image.asset(
                              "assets/img/ic_checkmark.png",
                              width: 20,
                              height: 20,
                            )
                                : null,
                          ),
                          Text(
                            item.getName(),
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: RectGetter(
              key: key_btn1,
              child: Container(
                height: 30,
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(15, 0, 12, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _DataFilterType.getName(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 12,
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: ResColor.b_4,
                  borderRadius: BorderRadius.all(Radius.circular(22.0)),
                ),
              ),
            ),
          ),
        ],
      ),
    );

//     return Container(
//       width: double.infinity,
//       height: BaseFuntion.appbarheight_def,
//       padding: EdgeInsets.fromLTRB(20, 0, 25, 0),
//       child: Row(
//         children: <Widget>[
//           Expanded(
//             child: Container(
//               height: 40,
//               child: Card(
//                 color: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(20.0)),
//                 ),
//                 elevation: 5,
//                 shadowColor: Colors.black38,
//                 child: Row(
//                   children: <Widget>[
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () {
//                           onClickTab(0);
//                         },
//                         child: Text(
//                           ResString.get(context, RSID.main_bv_4), //"全部",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color:
//                                 pageIndex == 0 ? Colors.black : Colors.black45,
//                             fontSize: 16,
// //                                  fontWeight: pageIndex == 0
// //                                      ? FontWeight.w600
// //                                      : FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () {
//                           onClickTab(1);
//                         },
//                         child: Text(
//                           ResString.get(context, RSID.main_bv_5), //"可认领",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color:
//                                 pageIndex == 1 ? Colors.black : Colors.black45,
//                             fontSize: 16,
// //                                  fontWeight: pageIndex == 1
// //                                      ? FontWeight.w600
// //                                      : FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () {
//                           onClickTab(2);
//                         },
//                         child: Text(
//                           ResString.get(context, RSID.main_bv_6), //"已完成",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color:
//                                 pageIndex == 2 ? Colors.black : Colors.black45,
//                             fontSize: 16,
// //                                  fontWeight: pageIndex == 2
// //                                      ? FontWeight.w600
// //                                      : FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Container(
//             width: 15,
//           ),
//           Container(
//             height: 30,
//             child: PopupMenuButton<BountyFilterType>(
//               initialValue: _DataFilterType,
//               child: Container(
//                   alignment: Alignment.center,
//                   padding: EdgeInsets.fromLTRB(15, 0, 12, 0),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: <Widget>[
//                       Text(
//                         _DataFilterType.getName(),
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 12,
//                         ),
//                       ),
//                       Icon(
//                         Icons.keyboard_arrow_down,
//                         color: Colors.black,
//                         size: 12,
//                       ),
//                     ],
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: BorderRadius.all(Radius.circular(22.0)),
//                   )),
//               itemBuilder: (context) {
//                 List<PopupMenuEntry<BountyFilterType>> ret = [];
//                 BountyFilterType.values.forEach((element) {
//                   ret.add(CheckedPopupMenuItem<BountyFilterType>(
//                     value: element,
//                     checked: _DataFilterType == element,
//                     child: Text(
//                       element.getName(),
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ));
//                 });
//                 return ret;
//               },
//               onSelected: (value) {
//                 onSelected(value);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
  }

  ///导航栏 appBar 可以重写
  Widget getAppBar() {
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
                  ResString.get(context, RSID.main_bv_1), //"积分",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                InkWell(
                  onTap: () {
                    onClickBountyHelp();
                  },
                  child: Container(
                    height: double.infinity,
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "Activity " + RSID.main_bv_3.text + " ", //"说明",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        Icon(
                          Icons.help_outline,
                          color: Colors.white,
                          size: 14,
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
    if (_BountyPageState == BountyPageState.needwallet) {
      widget = Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              ResString.get(context, RSID.main_bv_7), //"需要有钱包才能进行",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 20,
              ),
            ),
            Container(
              height: 10,
            ),
            FlatButton(
              highlightColor: Colors.white24,
              splashColor: Colors.white24,
              onPressed: () {
                eventMgr.send(EventTag.CHANGE_MAINVIEW_INDEX,
                    main_subviewTypes.indexOf(MainSubViewType.WALLETVIEW));
              },
              child: Text(
                ResString.get(context, RSID.main_bv_8), //"去创建钱包",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              color: Color(0xff393E45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(22)),
              ),
            )
          ],
        ),
      );
    } else if (_BountyPageState == BountyPageState.needmining) {
      widget = Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Text(
                ResString.get(context, RSID.main_bv_13),
                //RSID.main_bv_9"需要先参与挖矿报名才能进行",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 20,
                ),
              ),
            ),
            FlatButton(
              highlightColor: Colors.white24,
              splashColor: Colors.white24,
              onPressed: () {
                // ViewGT.showView(context, BindSocialAccountView());
              },
              child: Text(
                ResString.get(context, RSID.main_bv_14),
                //RSID.main_bv_10 "去报名挖矿",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              color: Color(0xff393E45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(22)),
              ),
            )
          ],
        ),
      );
    } else if (_BountyPageState == null) {
      widget = Container();
    } else {
      widget = new ListPage(
        datalist,
        itemWidgetCreator: (context, position) {
          return InkWell(
            onTap: () => onItemClick(position),
            child: itemWidgetBuild(context, position),
          );
        },
        pullRefreshCallback: _pullRefreshCallback,
        needLoadMore: needLoadMore,
        onLoadMore: onLoadMore,
        key: key_scroll,
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
          0, getTopBarHeight() + getAppBarHeight() + 70 + 52, 0, 0),
      child: widget,
    );
  }

  onClickBountyExchange() {
    // 点击兑换
    ViewGT.showBountyExchangeView(context);
  }

  onClickBountyHelp() {
    //  点击帮助
    ViewGT.openOutUrl(LocaleConfig.currentIsZh()
        ? "https://shimo.im/docs/QyrgXG9vRGxhQRXt/"
        : "https://shimo.im/docs/Wg3kJDxr8HjVrrgW/");
  }

  onClickTab(int index) {
    if (pageIndex == index) return;
    setState(() {
      pageIndex = index;
      switch (pageIndex) {
        case 2:
          state = BountyStateType.END;
          break;
        case 1:
          state = BountyStateType.AVAILABLE;
          break;
        case 0:
        default:
          state = null;
          break;
      }
//      _tabController.animateTo(index);
    });
    // 切换数据类型
    refresh();
  }

  onSelected(BountyFilterType value) {
    if (_DataFilterType == value) return;
    setState(() {
      _DataFilterType = value;
    });
    // 切换数据过滤
    refresh();
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
    page = 0;
    isLoading = true;

    // 刷新积分
    ApiBounty.getBountyScore(DL_TepkLoginToken.getEntity().getToken(),
        AccountMgr().currentAccount)
        .then((currentAccount) {
      if (mounted) setState(() {});
    });

    var data = await ApiBounty.getBountyTaskList(
        DL_TepkLoginToken.getEntity().getToken(),
        page,
        pageSize,
        state,
        _DataFilterType);
    dataCallback(data);
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

    var data = await ApiBounty.getBountyTaskList(
        DL_TepkLoginToken.getEntity().getToken(),
        page,
        pageSize,
        state,
        _DataFilterType);
    dataCallback(data);
    return hasMore;
  }

  onItemClick(int position) {
    BountyTask item = datalist[position];
    ViewGT.showBountyDetailView(context, item);
  }

  Widget itemWidgetBuild(BuildContext context, int position) {
    BountyTask item = datalist[position];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 6),
      color: ResColor.b_2,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(height: 20),
                Text(
                  "${ResString.get(context, RSID.main_bv_12)} ${item.reward}",
                  //奖励区间:
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(height: 20),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: ResColor.white_80,
                  ),
                ),
                Container(height: 10),
                InkWell(
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 20,
                        height: 20,
                        margin: EdgeInsets.fromLTRB(0, 2, 6, 0),
                        child: ImageIcon(
                          AssetImage(LocaleConfig.currentIsZh()
                              ? "assets/img/ic_wechat.png"
                              : "assets/img/ic_telegram_2.png"),
                          size: 20,
                          color: Colors.white, //Color(0xff88c42a),
                        ),
                      ),
                      Text(
                        ResString.get(context, RSID.main_bv_11), //"负责人:",
                        style: TextStyle(
                          fontSize: 12,
                          color: ResColor.white_80,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "${item.admin_weixin}",
                          style: TextStyle(
                            fontSize: 12,
                            color: ResColor.white_80,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    if (StringUtils.isNotEmpty(item?.admin_weixin)) {
                      DeviceUtils.copyText(item.admin_weixin);
                      showToast(RSID.copied.text); //"负责人微信已复制");
                    }
                  },
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
              decoration: BoxDecoration(
                gradient: ResColor.lg_2,
              ),
              child: Text(
                item.status.getName(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );

//     return Container(
//       padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
//       child: Card(
//         color: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(Radius.circular(10.0)),
//         ),
//         elevation: 10,
//         shadowColor: Colors.black26,
// //        shadowColor: item?.status == null
// //            ? Colors.black26
// //            : item.status.getColorTagShadow(),
//         clipBehavior: Clip.antiAlias,
//         child: Stack(
//           children: <Widget>[
//             Container(
//               padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Text(
//                     item.title,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.black,
//                     ),
//                   ),
//                   Container(height: 10),
//                   Text(
//                     item.description,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.black54,
//                     ),
//                   ),
//                   Container(height: 5),
//                   Row(
//                     children: <Widget>[
//                       Text(
//                         ResString.get(context, RSID.main_bv_11), //"负责人:",
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.black54,
//                         ),
//                       ),
//                       Container(
//                         width: 18,
//                         height: 18,
//                         margin: EdgeInsets.fromLTRB(4, 2, 4, 0),
//                         child: ImageIcon(
//                           AssetImage("assets/img/ic_wechat.png"),
//                           size: 18,
//                           color: Color(0xff88c42a),
//                         ),
//                       ),
//                       Expanded(
//                         child: Text(
//                           "${item.admin_weixin}",
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.black54,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Container(height: 5),
//                   Text(
//                     "${ResString.get(context, RSID.main_bv_12)} ${item.reward}",
//                     //奖励区间:
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.black54,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Positioned(
//               top: -8,
//               right: -8,
//               width: 30,
//               height: 30,
//               child: Banner(
//                 message: item.status.getName(),
//                 color: item.status.getColorTag(),
//                 textStyle: TextStyle(
//                   color: Colors.white,
//                   fontSize: 10,
//                 ),
//                 textDirection: TextDirection.ltr,
//                 location: BannerLocation.topEnd,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
  }
}
