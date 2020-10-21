import 'dart:math';

import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_bounty.dart';
import 'package:epikwallet/logic/loader/DL_TepkLoginToken.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/bounty/bountyexchangerecordlistview.dart';
import 'package:epikwallet/views/bounty/bountyrewardrecordlistview.dart';
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
    setTopBarVisible(true);
    setAppBarVisible(true);
    setTopBarBackColor(Colors.white);
    setAppBarBackColor(Colors.white);
//    isTopFloatWidgetShow = true;
    setAppBarTitle("积分兑换");

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

//  @override
//  Widget getTopFloatWidget() {
//    return getAppBar();
//  }

  Widget buildWidget(BuildContext context) {
    if (_tec_from == null)
      _tec_from = new TextEditingController(text: text_from);

    return ensv.NestedScrollView(
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
              50,
              340,
              OverflowBox(
                maxHeight: 290,
                minHeight: 0,
                child: Container(
                  margin: EdgeInsets.only(top: 0),
                  padding: EdgeInsets.all(15),
                  height: 290,
                  width: double.infinity,
                  child: Card(
                    color: ResColor.main,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    //card内容按边框剪切
                    elevation: 10,
                    child: Stack(
                      children: <Widget>[
                        //背景图片
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Image(
                            image: AssetImage("assets/img/bg_header.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        //背景颜色遮罩
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            color: Colors.black26,
                          ),
                        ),
                        //积分数量
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 25,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "　　",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                child: Text(
                                  "${StringUtils.formatNumAmount(AccountMgr()?.currentAccount?.bounty_score ?? 0)}",
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: Colors.white,
                                    fontFamily: "DIN_Condensed_Bold",
                                  ),
                                ),
                              ),
                              Text(
                                "积分",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        //兑换比例
                        Positioned(
                          left: 20,
                          right: 20,
                          top: 80,
                          child: Text(
//                            "当前兑换比例：1积分 = ${StringUtils.formatNumAmount(AccountMgr()?.currentAccount?.bounty_swap_rate ?? 1)}ERC20-EPK",
                            "当前兑换比例：${StringUtils.formatNumAmount(1 / (AccountMgr()?.currentAccount?.bounty_swap_rate ?? 1))} 积分 = 1 ERC20-EPK",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          right: 20,
                          top: 100,
                          child: Text(
                            "当前绑定微信：${AccountMgr()?.currentAccount?.mining_weixin}",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        //以太坊地址
                        Positioned(
                          left: 20,
                          right: 0,
                          top: 120,
                          child: Text(
                            "当前以太坊收币账户：${AccountMgr()?.currentAccount?.hd_eth_address}",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        // 输入框
                        Positioned(
                          left: 20,
                          right: 20,
                          top: 155,
                          height: 40,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: TextField(
                                  controller: _tec_from,
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  maxLines: 1,
                                  maxLengthEnforced: true,
                                  obscureText: false,
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter(
                                        RegExpUtil.re_float)
                                  ],
                                  // 这里限制长度 不会有数量提示
                                  decoration: InputDecoration(
                                    // 以下属性可用来去除TextField的边框
                                    border: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    hintText: "请输入兑换数量",
                                    hintStyle: TextStyle(
                                        color: Colors.white70, fontSize: 16),
                                  ),
                                  cursorWidth: 2.0,
                                  //光标宽度
                                  cursorRadius: Radius.circular(2),
                                  //光标圆角弧度
                                  cursorColor: Colors.white,
                                  //光标颜色
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                  onChanged: (value) {
                                    text_from = _tec_from.text.trim();
                                    amount_form =
                                        StringUtils.parseDouble(text_from, 0);
                                    onInputFrom();
                                  },
                                ),
                              ),
                              Container(
                                height: 30,
                                margin: EdgeInsets.fromLTRB(10, 6, 0, 0),
                                child: FlatButton(
                                  highlightColor: Colors.white24,
                                  splashColor: Colors.white24,
                                  onPressed: () {
                                    onClickExchange();
                                  },
                                  child: Text(
                                    "兑换",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  color: Color(0xff393E45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(22)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //输入框底部线条
                        Positioned(
                          left: 20,
                          right: 120,
                          top: 190,
                          height: 1,
                          child: Divider(
                            height: 0.5,
                            thickness: 0.5,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          left: 20,
                          right: 20,
                          top: 205,
                          child: Text(
                            "最少兑换数量：${StringUtils.formatNumAmount(AccountMgr()?.currentAccount?.bounty_swap_min ?? 1)} 积分",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        //手续费
                        Positioned(
                          left: 20,
                          right: 20,
                          top: 225,
                          child: InkWell(
                            onTap: () {
                              onClickHelp();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  "预估手续费：${StringUtils.formatNumAmount(AccountMgr()?.currentAccount?.bounty_swap_fee ?? "0")} ERC20-EPK",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(5, 2, 0, 0),
                                  child: Icon(
                                    Icons.help_outline,
                                    color: Colors.white70,
                                    size: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 50,
                width: 220,
                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  elevation: 6,
                  shadowColor: Colors.black45,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            onClickTab(0);
                          },
                          child: Text(
                            "奖励记录",
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
                            "兑换记录",
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
                    ],
                  ),
                ),
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
      showToast("请输入兑换数量");
      return;
    }

    double min = AccountMgr()?.currentAccount?.bounty_swap_min ?? 1;
    if (amount_form < min) {
      showToast("最少兑换数量为${StringUtils.formatNumAmount(min)}积分");
      return;
    }

    BottomDialog.showPassWordInputDialog(
      context,
      AccountMgr().currentAccount.password,
      (password) {
        //点击确定回调
        showLoadDialog(
          "正在提交兑换...",
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
                  title: "积分兑换",
                  msg: "积分兑换已提交，\n请稍后刷新查看钱包余额。",
                  btnRight: "确定",
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
                showToast(hjr?.msg ?? "请求失败");
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
      title: "关于手续费",
      btnRight: "知道了",
      onClickBtnRight: (dialog) {
        dialog.dismiss();
      },
      extend: Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: RichText(
          text: TextSpan(
            text:
                "「1」用积分兑换ERC20-EPK时，通过以太网转账会产生ETH手续费；\n\n「2」手续费数量是根据以太坊gas费用和Uniswap中的币价计算出要扣除多少ERC20-EPK。",
            style: TextStyle(
              color: Color(0xff333333),
              fontSize: 14.0,
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
      color: Colors.white,
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
