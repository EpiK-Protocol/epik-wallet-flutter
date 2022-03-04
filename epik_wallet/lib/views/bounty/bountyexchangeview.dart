import 'dart:math';

import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_bounty.dart';
import 'package:epikwallet/logic/loader/DL_TepkLoginToken.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/bounty/bountyexchangerecordlistview.dart';
import 'package:epikwallet/views/bounty/bountyrewardrecordlistview.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/text/TextEllipsisMiddle.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as ensv;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';

class BountyExchangeView extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> getState() {
    return BountyExchangeViewState();
  }
}

class BountyExchangeViewState extends BaseWidgetState<BountyExchangeView>
    with TickerProviderStateMixin {
  ScrollController scrollController = new ScrollController();

  TabController _tabController;
  int pageIndex = 0;
  int _selectedIndex_lest = -1;

  TextEditingController _tec_from;
  String text_from = "";
  double amount_form = 0;

  Key key_0 = GlobalKey();
  Key key_1 = GlobalKey();

  @override
  void initStateConfig() {
    super.initStateConfig();
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);
    isTopFloatWidgetShow = true;

    _tabController =
        new TabController(initialIndex: pageIndex, length: 2, vsync: this);
    _tabController.addListener(() {
      // tabbar 监听
      setState(() {
        _selectedIndex_lest = pageIndex;
        pageIndex = _tabController.index;
      });
//      print("tabbar indexIsChanging -> ${_tabController.indexIsChanging}");
    });

    // 刷新积分
    ApiBounty.getBountyScore(DL_TepkLoginToken.getEntity().getToken(),
            AccountMgr().currentAccount)
        .then((currentAccount) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(ResString.get(context, RSID.bexv_1)); //"积分兑换");
  }

  //  @override
//  Widget getTopFloatWidget() {
//    return getAppBar();
//  }

  Widget buildWidget(BuildContext context) {
    if (_tec_from == null)
      // _tec_from = new TextEditingController(text: text_from);
      _tec_from = new TextEditingController.fromValue(TextEditingValue(
        text: text_from,
        selection: new TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream, offset: text_from.length),
        ),
      ));

    Widget nestedscrollview = ensv.NestedScrollView(
      innerScrollPositionKeyBuilder: () {
        if (pageIndex == 0)
          return key_0;
        else
          return key_1;
      },
      //    return NestedScrollView(
      controller: scrollController,
      // 头部-----------
      headerSliverBuilder: (context, innerScrolled) => <Widget>[
        SliverOverlapAbsorber(
          // 传入 handle 值，直接通过 `sliverOverlapAbsorberHandleFor` 获取即可
//          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          handle: ensv.NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          sliver: SliverPersistentHeader(
            delegate: BountyHeader(
              80,
              450,
              OverflowBox(
                maxHeight: 370,
                minHeight: 0,
                child: Container(
                  margin: EdgeInsets.fromLTRB(30, 45, 30, 0),
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  height: 325,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ResColor.b_2,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "${StringUtils.formatNumAmount(AccountMgr()?.currentAccount?.bounty_score ?? 0)}",
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontFamily: "DIN_Condensed_Bold",
                          height: 1,
                        ),
                      ),
                      Text(
                        ResString.get(context, RSID.main_bv_1), //"积分",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 15),
                        padding: EdgeInsets.only(left: 10, right: 10),
                        width: double.infinity,
                        height: 40,
                        decoration: BoxDecoration(
                          color: ResColor.white_20,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              ResString.get(context, RSID.bexv_18), //
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 14,
                                color: ResColor.white_80,
                              ),
                            ),
                            Expanded(
                              child: TextEm(
                                "${AccountMgr()?.currentAccount?.epik_EPK_address}", //
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ResColor.white_80,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 63,
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: TextField(
                                      controller: _tec_from,
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      //获取焦点时,启用的键盘类型
                                      maxLines: 1,
                                      // 输入框最大的显示行数
//              maxLength: 20, //允许输入的字符长度/ 右下角有数量提示
                                      maxLengthEnforced: true,
                                      //是否允许输入的字符长度超过限定的字符长度
                                      obscureText: false,
                                      //是否是密码
                                      inputFormatters: [
                                        // LengthLimitingTextInputFormatter(20),
                                        FilteringTextInputFormatter.allow(
                                            RegExpUtil.re_float),
                                      ],
                                      // 这里限制长度 不会有数量提示
                                      decoration: InputDecoration(
                                        // 以下属性可用来去除TextField的边框
                                        // border: InputBorder.none,
                                        // errorBorder: InputBorder.none,
                                        // focusedErrorBorder: InputBorder.none,
                                        border: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        enabledBorder:
                                            const UnderlineInputBorder(
                                          borderRadius: BorderRadius.zero,
                                          borderSide: BorderSide(
                                            color: ResColor.white_20,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder:
                                            const UnderlineInputBorder(
                                          borderRadius: BorderRadius.zero,
                                          borderSide: BorderSide(
                                            color: ResColor.white,
                                            width: 1,
                                          ),
                                        ),
                                        contentPadding:
                                            EdgeInsets.fromLTRB(0, 10, 40, 15),

//                      contentPadding: EdgeInsets.symmetric(vertical: 8.5),
                                        hintText: RSID.bexv_5.text,
                                        hintStyle: TextStyle(
                                            color: ResColor.white_50,
                                            fontSize: 17),
                                        labelText: RSID.bexv_21.text,
                                        labelStyle: TextStyle(
                                            color: ResColor.white,
                                            fontSize: 17),
                                      ),
                                      cursorWidth: 2.0,
                                      //光标宽度
                                      cursorRadius: Radius.circular(2),
                                      //光标圆角弧度
                                      cursorColor: Colors.white,
                                      //光标颜色
                                      style: TextStyle(
                                          fontSize: 17, color: Colors.white),
                                      onChanged: (value) {
                                        text_from = _tec_from.text.trim();
                                        amount_form = StringUtils.parseDouble(
                                            text_from, 0);
                                        onInputFrom();
                                        setState(() {});
                                      },
                                      onSubmitted: (value) {
                                        // 当用户确定已经完成编辑时触发
                                      }, // 是否隐藏输入的内容
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: (StringUtils.isEmpty(text_from))
                                  ? Container()
                                  : SizedBox(
                                      width: 40,
                                      height: 51,
                                      child: IconButton(
                                        onPressed: () {
                                          setState(
                                            () {
                                              text_from = "";
                                              _tec_from = null;
                                            },
                                          );
                                        },
                                        padding: EdgeInsets.all(0),
                                        icon: Icon(Icons.clear_rounded),
                                        color: Colors.white,
                                        iconSize: 14,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        alignment: Alignment.centerRight,
                        child: Text(
//                            "当前兑换比例：1积分 = ${StringUtils.formatNumAmount(AccountMgr()?.currentAccount?.bounty_swap_rate ?? 1)}ERC20-EPK",
//                            "当前兑换比例：${StringUtils.formatNumAmount(1 / (AccountMgr()?.currentAccount?.bounty_swap_rate ?? 1))} 积分 = 1 ERC20-EPK",
                          ResString.get(context, RSID.bexv_17, replace: [
                            StringUtils.formatNumAmount(1 /
                                (AccountMgr()
                                        ?.currentAccount
                                        ?.bounty_swap_rate ??
                                    1))
                          ]), //
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 1),
                        alignment: Alignment.centerRight,
                        child: Text(
//                            "最少兑换数量：${StringUtils.formatNumAmount(AccountMgr()?.currentAccount?.bounty_swap_min ?? 1)} 积分",
                          ResString.get(context, RSID.bexv_7, replace: [
                            "${StringUtils.formatNumAmount(AccountMgr()?.currentAccount?.bounty_swap_min ?? 1)}"
                          ]), //
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 1),
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            onClickHelp();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
//                                  "预估手续费：${StringUtils.formatNumAmount(AccountMgr()?.currentAccount?.bounty_swap_fee ?? "0")} ERC20-EPK",
//                                   ResString.get(context, RSID.bexv_8,replace: ["${StringUtils.formatNumAmount(AccountMgr()?.currentAccount?.bounty_swap_fee ?? "0")}"]),//
                                ResString.get(context, RSID.bexv_19, replace: [
                                  "${StringUtils.formatNumAmount(AccountMgr()?.currentAccount?.bounty_swap_fee ?? "0")}"
                                ]), //
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white60,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(5, 2, 0, 0),
                                child: Icon(
                                  Icons.help_outline,
                                  color: Colors.white60,
                                  size: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      LoadingButton(
                        margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                        gradient_bg: ResColor.lg_1,
                        color_bg: Colors.transparent,
                        disabledColor: Colors.transparent,
                        height: 40,
                        text: RSID.bexv_6.text,
                        //"兑换",
                        textstyle: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        bg_borderradius: BorderRadius.circular(4),
                        onclick: (lbtn) {
                          onClickExchange();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 80,
                width: double.infinity,
                color: ResColor.b_1,
                padding: EdgeInsets.fromLTRB(21, 21, 21, 21),
                child: getTabbar(),
              ),
            ),
            pinned: true,
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          ensv.NestedScrollViewInnerScrollPositionKeyWidget(
            key_0,
            Builder(
              builder: (context) {
                return BountyRewardRecordListview(0);
              },
            ),
          ),
          ensv.NestedScrollViewInnerScrollPositionKeyWidget(
            key_1,
            Builder(
              builder: (context) {
                return BountyExchangeRecordListview(1);
              },
            ),
          ),
//          Builder(
//            builder: (context) {
//              return BountyRewardRecordListview(0);
//            },
//          ),
//          Builder(
//            builder: (context) {
//              return BountyExchangeRecordListview(1);
//            },
//          ),
        ],
      ),
    );
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: getAppBarHeight() + getTopBarHeight() + 128,
            padding: EdgeInsets.fromLTRB(0, getTopBarHeight(), 0, 0),
            decoration: BoxDecoration(
              gradient: ResColor.lg_1,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            alignment: Alignment.topCenter,
            child: getAppBar(),
          ),
          Positioned(
              left: 0,
              right: 0,
              top: getAppBarHeight() + getTopBarHeight(),
              bottom: 0,
              child: nestedscrollview),
        ],
      ),
    );
  }

  // TabController tabcontroller;

  Widget getTabbar() {
    // RSID.bexv_9), //"奖励记录",
    // RSID.bexv_10), //"兑换记录",
    List<RSID> items = const [RSID.bexv_9, RSID.bexv_10];

    // if (tabcontroller == null)
    //   tabcontroller = TabController(
    //       initialIndex: pageIndex, length: items.length, vsync: this);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: ResColor.b_4,
      ),
      child: TabBar(
        tabs: items.map((rsid) {
          return Container(
            alignment: Alignment.center,
            child: Text(rsid.text),
          );
        }).toList(),
        controller: _tabController,
        isScrollable: false,
        labelPadding: EdgeInsets.fromLTRB(0, 3, 0, 0),
        labelColor: ResColor.b_1,
        labelStyle: TextStyle(
          fontSize: 17,
          color: ResColor.b_1,
          fontWeight: FontWeight.bold,
          // height: 1,
        ),
        unselectedLabelColor: ResColor.white_60,
        unselectedLabelStyle: TextStyle(
          fontSize: 17,
          color: ResColor.white_60,
          fontWeight: FontWeight.bold,
          // height: 1,
        ),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.white,
        ),
        indicatorPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 4,
        onTap: (value) {
          onClickTab(value);
        },
      ),
    );
  }

  onClickTab(int i) {
    if (pageIndex == i) return;
    setState(() {
      pageIndex = i;
      _tabController.animateTo(i);
    });
  }

  void onInputFrom() {
    // todo
  }

  void onClickExchange() {
    closeInput();

    if (amount_form == 0) {
      showToast(ResString.get(context, RSID.bexv_5)); //"请输入兑换数量");
      return;
    }

    double min = AccountMgr()?.currentAccount?.bounty_swap_min ?? 1;
    if (amount_form < min) {
//      showToast("最少兑换数量为${StringUtils.formatNumAmount(min)}积分");
      showToast(ResString.get(context, RSID.bexv_7,
          replace: [StringUtils.formatNumAmount(min)]));
      return;
    }

    BottomDialog.simpleAuth(
      context,
      AccountMgr().currentAccount.password,
      (password) {
        //点击确定回调
        showLoadDialog(
          ResString.get(context, RSID.bexv_11), //"正在提交兑换...",
          touchOutClose: false,
          backClose: false,
          onShow: () {
            ApiBounty.bountySwap(
                    DL_TepkLoginToken.getEntity().getToken(), amount_form)
                .then((hjr) {
              closeLoadDialog();
              if (hjr != null && hjr.code == 0) {
                // 请求成功
                MessageDialog.showMsgDialog(
                  context,
                  title: ResString.get(context, RSID.bexv_12),
                  //"积分兑换",
                  msg: ResString.get(context, RSID.bexv_13),
                  //"积分兑换已提交，\n请稍后刷新查看钱包余额。",
                  btnRight: ResString.get(context, RSID.confirm),
                  //"确定",
                  onClickBtnRight: (dialog) {
                    dialog.dismiss();
                  },
                );

                setState(() {
                  text_from = "";
                  amount_form = 0;
                  _tec_from.text = "";
                });

                // 刷新积分
                ApiBounty.getBountyScore(
                        DL_TepkLoginToken.getEntity().getToken(),
                        AccountMgr().currentAccount)
                    .then((currentAccount) {
                  if (mounted) setState(() {});
                });
              } else {
                // 请求失败
                showToast(hjr?.msg ??
                    ResString.get(context, RSID.request_failed)); //"请求失败");
              }
            });
          },
        );
      },
    );
  }

  void onClickHelp() {
    MessageDialog.showMsgDialog(
      context,
      title: ResString.get(context, RSID.bexv_14), // "关于手续费",
      btnRight: ResString.get(context, RSID.isee), // "知道了",
      onClickBtnRight: (dialog) {
        dialog.dismiss();
      },
      extend: Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: RichText(
          text: TextSpan(
            text:
                //ResString.get(context, RSID.bexv_15),// "「1」用积分兑换ERC20-EPK时，通过以太网转账会产生ETH手续费；\n\n「2」手续费数量是根据以太坊gas费用和Uniswap中的币价计算出要扣除多少ERC20-EPK。",
                ResString.get(context, RSID.bexv_20),
            style: TextStyle(
              color: ResColor.white_80,
              fontSize: 14.0,
              fontFamily: fontFamily_def,
            ),
          ),
        ),
      ),
    );
  }
}

class BountyHeader extends SliverPersistentHeaderDelegate {
  double _min, _max;
  Widget center;
  Widget bottom;

  BountyHeader(this._min, this._max, this.center, this.bottom);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    double alpha = 1 - shrinkOffset / (maxExtent - minExtent);
    alpha = min(max(alpha, 0), 1);

    return Container(
      color: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Positioned(
            bottom: _min,
            height: _max - _min,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: alpha,
              child: this.center,
            ),
          ),
          Align(
            alignment: FractionalOffset(0.5, 1),
            child: this.bottom,
          ),
        ],
      ),
    );
  } // 头部展示内容

  @override
  double get maxExtent => _max; // 最大高度

  @override
  double get minExtent => _min; // 最小高度

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

// 因为所有的内容都是固定的，所以不需要更新
}
