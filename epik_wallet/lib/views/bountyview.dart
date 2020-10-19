import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_bounty.dart';
import 'package:epikwallet/logic/loader/DL_TepkLoginToken.dart';
import 'package:epikwallet/logic/loader/DataLoader.dart';
import 'package:epikwallet/model/BountyTask.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/list_view.dart';
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
    return 3;
  }
}

enum BountyPageState {
  needwallet,
  needmining,
  bounty,
}

class BountyViewState extends BaseInnerWidgetState<BountyView> {
  int pageIndex = 0;

  BountyStateType state = null;
  BountyFilterType _DataFilterType = BountyFilterType.ALL;

  List<BountyTask> datalist = [];

  GlobalKey<ListPageState> key_scroll = GlobalKey();

  int page = 0;
  int pageSize = 20;
  bool isLoading = false;
  bool hasMore = false;

  @override
  void initStateConfig() {
    super.initStateConfig();
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
    refresh();
  }

  @override
  void dispose() {
    eventMgr.remove(
        EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventcallback_refresh);
    eventMgr.remove(EventTag.BOUNTY_EDITED_USER_LIST, eventcallback_refresh);
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

    DL_TepkLoginToken.getEntity().getTokenOnline(false,
        (DataLoader dataloader, errCode, msg, p, ps, List pagedata) {
      if (errCode == 0 && DL_TepkLoginToken.getEntity().hasToken()) {
        // 有token
        _BountyPageState = BountyPageState.bounty;
//        setAppBarVisible(true);
        this.page = 0;
        ApiBounty.getBountyTaskList(DL_TepkLoginToken.getEntity().getToken(),
                page, this.pageSize, state, _DataFilterType)
            .then((value) => dataCallback(value));

        // 刷新积分
        ApiBounty.getBountyScore(DL_TepkLoginToken.getEntity().getToken(),
                AccountMgr().currentAccount)
            .then((currentAccount) {
          if (mounted) setState(() {});
        });
      } else if (errCode < 0) {
        // 网络请求错误
        isLoading = false;
        _BountyPageState = null;
        setErrorWidgetVisible(true);
//        setAppBarVisible(true);
      } else {
        // 没有token 需要挖矿报名
        isLoading = false;
        _BountyPageState = BountyPageState.needmining;
//        setAppBarVisible(false);
        closeStateLayout();
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
        child: Column(
          children: <Widget>[
            getTopBar(),
            getAppBar(),
          ],
        ),
      );

    return Container();
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
            padding: EdgeInsets.fromLTRB(38, 0, 15, 0),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 6, 5, 0),
                  child: Text(
                    "${StringUtils.formatNumAmount(AccountMgr()?.currentAccount?.bounty_score)}",
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontFamily: "DIN_Condensed_Bold",
                    ),
                  ),
                ),
                Text(
                  "积分",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkResponse(
                    onTap: () {
                      onClickBountyExchange();
                    },
                    child: Container(
                      height: double.infinity,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "兑换",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.black,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkResponse(
                    onTap: () {
                      onClickBountyHelp();
                    },
                    child: Container(
                      height: double.infinity,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "说明",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          Icon(
                            Icons.help_outline,
                            color: Colors.black,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: BaseFuntion.appbarheight_def,
            padding: EdgeInsets.fromLTRB(20, 0, 25, 0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 40,
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black38,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                onClickTab(0);
                              },
                              child: Text(
                                "全部",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: pageIndex == 0
                                      ? Colors.black
                                      : Colors.black45,
                                  fontSize: 16,
//                                  fontWeight: pageIndex == 0
//                                      ? FontWeight.w600
//                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                onClickTab(1);
                              },
                              child: Text(
                                "可认领",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: pageIndex == 1
                                      ? Colors.black
                                      : Colors.black45,
                                  fontSize: 16,
//                                  fontWeight: pageIndex == 1
//                                      ? FontWeight.w600
//                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                onClickTab(2);
                              },
                              child: Text(
                                "已完成",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: pageIndex == 2
                                      ? Colors.black
                                      : Colors.black45,
                                  fontSize: 16,
//                                  fontWeight: pageIndex == 2
//                                      ? FontWeight.w600
//                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 15,
                ),
                Container(
                  height: 30,
                  child: PopupMenuButton<BountyFilterType>(
                    initialValue: _DataFilterType,
                    child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.fromLTRB(15, 0, 12, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              _DataFilterType.getName(),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black,
                              size: 12,
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.all(Radius.circular(22.0)),
                        )),
                    itemBuilder: (context) {
                      List<PopupMenuEntry<BountyFilterType>> ret = [];
                      BountyFilterType.values.forEach((element) {
                        ret.add(CheckedPopupMenuItem<BountyFilterType>(
                          value: element,
                          checked: _DataFilterType == element,
                          child: Text(
                            element.getName(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ));
                      });
                      return ret;
                    },
                    onSelected: (value) {
                      onSelected(value);
                    },
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
    if (_BountyPageState == BountyPageState.needwallet) {
      return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "需要有钱包才能进行",
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
                eventMgr.send(EventTag.CHANGE_MAINVIEW_INDEX, 1);
              },
              child: Text(
                "去创建钱包",
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
      return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "需要先参与挖矿报名才能进行",
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
                eventMgr.send(EventTag.CHANGE_MAINVIEW_INDEX, 0);
              },
              child: Text(
                "去报名挖矿",
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
      return Container();
    }

    Widget view = new ListPage(
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

    return Container(
      padding: EdgeInsets.fromLTRB(0,  BaseFuntion.topbarheight+90, 0, 0),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          colors: [
            Color(0xfff7e6f0),
            Colors.white,
          ],
          center: Alignment.center,
          radius: 1,
          tileMode: TileMode.clamp,
        ),
      ),
      child: view,
    );
  }

  onClickBountyExchange() {
    // 点击兑换
    ViewGT.showBountyExchangeView(context);
  }

  onClickBountyHelp() {
    //  点击帮助
    ViewGT.openOutUrl("https://shimo.im/docs/QyrgXG9vRGxhQRXt/ ");
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
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        elevation: 10,
        shadowColor: Colors.black26,
//        shadowColor: item?.status == null
//            ? Colors.black26
//            : item.status.getColorTagShadow(),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Container(height: 10),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  Container(height: 5),
                  Row(
                    children: <Widget>[
                      Text(
                        "负责人:",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      Container(
                        width: 18,
                        height: 18,
                        margin: EdgeInsets.fromLTRB(4, 2, 4, 0),
                        child: ImageIcon(
                          AssetImage("assets/img/ic_wechat.png"),
                          size: 18,
                          color: Color(0xff88c42a),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "${item.admin_weixin}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(height: 5),
                  Text(
                    "奖励区间: ${item.reward}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -8,
              right: -8,
              width: 30,
              height: 30,
              child: Banner(
                message: item.status.getName(),
                color: item.status.getColorTag(),
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textDirection: TextDirection.ltr,
                location: BannerLocation.topEnd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
