import 'dart:math' as math;

import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/model/CurrencyAsset.dart';
import 'package:epikwallet/model/EthOrder.dart';
import 'package:epikwallet/model/TepkOrder.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
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
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';

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
  }

  ListPageDefState _ListPageDefState = ListPageDefState(null);
  List<Object> data_list_item = [];

  GlobalKey<ListPageState> key_scroll = GlobalKey();

  double header_alpha = 0;

  String balance = "　";

  ColorTween header_colortween =
      ColorTween(begin: Colors.white, end: Colors.black);

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
    setAppBarTitle(widget.currencyAsset.symbol);
    setBackIconHinde(isHinde: false);

    await Future.delayed(Duration(milliseconds: 200));
    balance = StringUtils.formatNumAmount(widget.currencyAsset.balance,
        point: 8, supply0: false);
  }

  SystemUiOverlayStyle oldSystemUiOverlayStyle;

  @override
  void onCreate() {
    super.onCreate();

    oldSystemUiOverlayStyle = DeviceUtils.system_bar_current;
    DeviceUtils.setSystemBarStyle(DeviceUtils.system_bar_light);

    eventMgr.add(EventTag.LOCAL_ACCOUNT_LIST_CHANGE, eventCallback_account);
    eventMgr.add(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventCallback_account);

    refresh();
  }

  eventCallback_account(obj) {
    refresh();
  }

  @override
  void dispose() {
    if (oldSystemUiOverlayStyle != null)
      DeviceUtils.setSystemBarStyle(oldSystemUiOverlayStyle);
    eventMgr.remove(EventTag.LOCAL_ACCOUNT_LIST_CHANGE, eventCallback_account);
    eventMgr.remove(
        EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventCallback_account);
    super.dispose();
  }

  @override
  Widget getTopFloatWidget() {
    return InkWell(
      child: getAppBar(),
      onTap: onTapAppBar,
    );
  }

  onTapAppBar() {
    if (key_scroll != null && !isLoading) {
      key_scroll.currentState.scrollController.animateTo(0,
          duration: Duration(milliseconds: 200), curve: Curves.easeIn);
    }
  }

  @override
  Widget getAppBar() {
    Color color_content = header_colortween.lerp(header_alpha);

    return Container(
      height: getAppBarHeight() + getTopBarHeight(),
      padding: EdgeInsets.only(top: getTopBarHeight()),
      width: double.infinity,
      color: Colors.white.withOpacity(header_alpha),
      child: Stack(
        alignment: FractionalOffset(0, 0.5),
        children: <Widget>[
          Align(
            alignment: FractionalOffset(0.5, 0.5),
            child: getAppBarCenter(color: color_content),
          ),
          Align(
            //左边返回导航 的位置，可以根据需求变更
            alignment: FractionalOffset(0, 0.5),
            child: Offstage(
              offstage: !isBackIconShow,
              child: getAppBarLeft(color: color_content),
            ),
          ),
          Align(
            alignment: FractionalOffset(0.98, 0.5),
            child: getAppBarRight(color: color_content),
          ),
        ],
      ),
    );
  }

  double header_top = 0;
  double tttt = 0;

  /// 控制滑动式 title栏透明度
  scrollCallback(ScrollController ctrl) {
//     dlog(ctrl.position.pixels);
    setState(() {
      if (header_top == 0) header_top = getTopBarHeight() + getAppBarHeight();
      double t = ctrl.position.pixels;
      tttt = t;
      t = math.min(t, 100);
      t = math.max(0, t);
      header_alpha = t / 100;
      DeviceUtils.setSystemBarStyle(header_alpha > 0.5
          ? DeviceUtils.system_bar_dark
          : DeviceUtils.system_bar_light);
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    Widget view = new ListPage(
      data_list_item,
      headerList: ["header", _ListPageDefState],
      headerCreator: (context, position) {
        if (position == 0) {
          return headerBuilder(context, position);
        } else {
          return stateHeaderWidgetBuild(context, position);
        }
      },
      itemWidgetCreator: (context, position) {
        return InkWell(
          onTap: () => onItemClick(position),
          child: itemWidgetBuild(context, position),
        );
      },
      scrollCallback: scrollCallback,
      pullRefreshCallback: _pullRefreshCallback,
      needLoadMore: needLoadMore,
      onLoadMore: onLoadMore,
      key: key_scroll,
      needNoMoreTipe: false,
      bgContainer: (view) {
        return Stack(
          children: <Widget>[
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: getScreenHeight() - 10 + (tttt < 0 ? tttt : 0),
              child: Container(
                color: Colors.white,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: view,
            ),
          ],
        );
      },
    );

    return Stack(
      children: <Widget>[
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          height: getScreenHeight(),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient_ff,
            ),
          ),
        ),
//        Positioned(
//          left: 0,
//          right: 0,
//          bottom: 0,
//          height: getScreenHeight() / 2,
//          child: Container(
//            color: Color(0xfff4f5f7),
//          ),
//        ),
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          bottom: 0,
          child: view,
        ),
      ],
    );
  }

  Widget headerBuilder(BuildContext context, int position) {
    if (position == 0 /*&& bannerlist != null && bannerlist.length > 0*/) {
      if (header_top == 0) header_top = getTopBarHeight() + getAppBarHeight();
      return Container(
        padding: EdgeInsets.all(0),
        width: double.infinity,
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: header_top + 106 + 54 + 8,
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: FractionalOffset(0.5, 1),
                    child: Container(
                      width: double.infinity,
                      height: 23,
                      margin: EdgeInsets.fromLTRB(17.5, 0, 17.5, 0),
                      decoration: BoxDecoration(
                        gradient: gradient_40,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: FractionalOffset(0.5, 1),
                    child: Container(
                      width: double.infinity,
                      height: 19,
                      margin: EdgeInsets.fromLTRB(8.5, 0, 8.5, 4),
                      decoration: BoxDecoration(
                        gradient: gradient_7f,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: FractionalOffset(0.5, 1),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
                      decoration: BoxDecoration(
                        gradient: gradient_ff,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: header_top),
                    height: 106,
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
//                            Padding(
//                              padding: EdgeInsets.only(top: 0, left: 5),
//                              child: Text(
//                                "　　",
//                                style: TextStyle(
//                                  color: Colors.transparent,
//                                  fontSize: 10,
//                                ),
//                              ),
//                            ),
//                            Text(
//                              StringUtils.formatNumAmount(widget.currencyAsset.balance,point:8,supply0: false ),
//                              style: TextStyle(
//                                color: Colors.white,
//                                fontSize: 35,
//                                fontFamily: "DIN_Condensed_Bold",
//                              ),
//                            ),
                            DiffScaleText(
                              text: balance,
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 35,
                                fontFamily: "DIN_Condensed_Bold",
                              ),
                            ),
//                            Padding(
//                              padding: EdgeInsets.only(top: 0, left: 5),
//                              child: Text(
//                                "全部",
//                                style: TextStyle(
//                                  color: Colors.white,
//                                  fontSize: 10,
//                                ),
//                              ),
//                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "\$ ${StringUtils.formatNumAmount(widget.currencyAsset.getUsdValue())}",
                              style: TextStyle(
                                color: ResColor.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 8,
                    height: 54,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: gradient_tab,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              clipBehavior: Clip.antiAlias,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15)),
                              child: InkWell(
                                onTap: () {
                                  ViewGT.showCurrencyWithdrawView(
                                      context,
                                      AccountMgr().currentAccount,
                                      widget.currencyAsset);
                                },
                                child: Container(
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  child: Text(
                                    ResString.get(context, RSID.withdraw),
                                    //"转账",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: Color(0x19ffffff),
                          ),
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              clipBehavior: Clip.antiAlias,
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(15)),
                              child: InkWell(
                                onTap: () {
                                  ViewGT.showCurrencyDepositView(
                                      context,
                                      AccountMgr().currentAccount,
                                      widget.currencyAsset.cs);
                                },
                                child: Container(
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  child: Text(
                                    ResString.get(context, RSID.deposit),
                                    //"收款",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
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
      if (item is TepkOrder) {
        return itemWidgetBuild_tepk(item);
      } else {
        return itemWidgetBuild_eth((item as EthOrder));
      }
    } else {
      return Padding(
          padding: new EdgeInsets.all(10.0),
          child: new Text("no data $position"));
    }
  }

  Widget itemWidgetBuild_tepk(TepkOrder item) {
    return Container(
      width: double.infinity,
      height: 80,
      padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          // 底部分割线
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 1,
            child: Container(
              color: Color(0xffeeeeee),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Text(
              ResString.get(
                  context, item.isWithdraw ? RSID.withdraw : RSID.deposit),
              //  item.isWithdraw ? "转账" : "收款",
              style: TextStyle(
                fontSize: 15,
                color: Color(0xff333333),
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 0,
            child: Container(
              height: 20,
              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color(0xfff5f5f5),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Text(
                ResString.get(context, RSID.completed), //"已完成",
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xff999999),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 10,
            child: Text(
              (item.isWithdraw ? "-" : "+") +
                  StringUtils.formatNumAmount(item.value_d, point: 8),
              style: TextStyle(
                fontSize: 15,
                color: Color(0xff333333),
              ),
            ),
          ),
//          Positioned(
//            right: 10,
//            bottom: 10,
//            child: Text(
//              DateUtil.formatDateMs(item.created_at,
//                  format: DataFormats.y_mo_d_h_m),
//              style: TextStyle(
//                fontSize: 12,
//                color: Color(0xffAAAAAA),
//              ),
//            ),
//          ),
        ],
      ),
    );
  }

  Widget itemWidgetBuild_eth(EthOrder item) {
    return Container(
      width: double.infinity,
      // height: 80,
      padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ResString.get(context, item.actionStrId),
                  //item.isWithdraw ? "转账" : "收款",
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xff333333),
                  ),
                ),
              ),
              Container(
                height: 20,
                margin: EdgeInsets.only(right: 10),
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xfff5f5f5),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Text(
                  ResString.get(context, RSID.completed), //"已完成",
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xff999999),
                  ),
                ),
              ),
            ],
          ),
          Container(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  item.numDirection +
                      StringUtils.formatNumAmount(item.value_d, point: 8),
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xff333333),
                  ),
                ),
              ),
              Text(
                DateUtil.formatDateMs(item.timeStamp,
                    format: DataFormats.y_mo_d_h_m),
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xffAAAAAA),
                ),
              ),
            ],
          ),
          if (StringUtils.isNotEmpty(item?.hash))
            Container(
              padding: EdgeInsets.only(top: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "txhash:${item.hash}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xff333333),
                      ),
                    ),
                  ),
                  Container(
                    width: 12,
                    margin: EdgeInsets.fromLTRB(5, 3, 0, 0),
                    child: Icon(
                      Icons.redo,
                      color: Colors.blue,
                      size: 12,
                    ),
                  )
                ],
              ),
            ),
          Container(
            margin: EdgeInsets.only(top: 14),
            height: 1,
            color: Color(0xffeeeeee),
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

    isLoading = true;
//    setLoadingWidgetVisible(true);

    page = 0;
    setState(() {
      _ListPageDefState.type = ListPageDefStateType.LOADING;
    });
    EpikWalletUtils.getOrderList(AccountMgr().currentAccount,
            widget.currencyAsset.cs, page, pageSize)
        .then((data) {
      dataCallback(data);
    });
  }

  dataCallback(List data) {
    if (data != null) {
      // 请求成功
      if (page == 0) {
//        if (data.isEmpty) {
//          showToast("无数据");
//        }
        data_list_item.clear();
      }
      data_list_item.addAll(data);

      if (widget.currencyAsset.cs != CurrencySymbol.tEPK &&
          data.length >= pageSize) {
        hasMore = true;
        page += 1;
      } else {
        hasMore = false;
      }
      _ListPageDefState.type =
          data_list_item.length > 0 ? null : ListPageDefStateType.EMPTY;
    } else {
      showToast(ResString.get(context, RSID.request_failed)); //"请求失败);
      if (page == 0) {
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
    page = 0;
    isLoading = true;
    var data = await EpikWalletUtils.getOrderList(
        AccountMgr().currentAccount, widget.currencyAsset.cs, page, pageSize);
    dataCallback(data);
  }

  /**是否需要加载更多*/
  bool needLoadMore() {
    if (widget.currencyAsset.cs == CurrencySymbol.tEPK) {
      return false;
    } else {
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

    List data = await EpikWalletUtils.getOrderList(
        AccountMgr().currentAccount, widget.currencyAsset.cs, page, pageSize);

    dataCallback(data);

    return hasMore;
  }

  onItemClick(int postision) {
    try {
      if (data_list_item != null &&
          postision >= 0 &&
          postision < data_list_item.length &&
          mounted) {
        var item = data_list_item[postision];
        if (item != null) {
          if (item is EthOrder) {
            EthOrder _EthOrder = item;
            String hash = _EthOrder.hash;
            DeviceUtils.copyText(hash);
            String url = "https://cn.etherscan.com/tx/$hash";
            ViewGT.showGeneralWebView(
                context, ResString.get(context, RSID.berlv_4), url);
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  onClickWalletName() {}

  onClickWalletMenu() {
    eventMgr.send(EventTag.MAIN_RIGHT_DRAWER, true);
  }
}
