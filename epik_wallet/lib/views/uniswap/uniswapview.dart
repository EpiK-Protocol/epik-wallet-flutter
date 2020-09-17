import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/views/uniswap/uniswapexchangeview.dart';
import 'package:epikwallet/views/uniswap/uniswappoolview.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class UniswapView extends BaseWidget {
  // 可能是空
  WalletAccount walletAccount;

  UniswapView(this.walletAccount);

  BaseWidgetState<BaseWidget> getState() {
    return UniswapViewState();
  }
}

class UniswapViewState extends BaseWidgetState<UniswapView> with TickerProviderStateMixin{

  TabController _tabController;
  int pageIndex = 0;
  int _selectedIndex_lest = -1;

  @override
  void initStateConfig() {
    super.initStateConfig();
//    setAppBarTitle("Uniswap");
    setBackIconHinde();
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarHeight(60);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);
    isTopFloatWidgetShow = true;

    setAppBarRightTitle("交易记录");

    _tabController = new TabController(
        initialIndex: pageIndex, length: 2, vsync: this);
    _tabController.addListener(() {
      // tabbar 监听
      setState(() {
        _selectedIndex_lest = pageIndex;
        pageIndex = _tabController.index;
      });
      print("tabbar indexIsChanging -> ${_tabController.indexIsChanging}");
    });
  }

  @override
  void onCreate() {
    super.onCreate();
    eventMgr.add(EventTag.UPDATE_SERVER_CONFIG, eventCallback_upconfig);
  }

  @override
  void dispose() {
    eventMgr.remove(EventTag.UPDATE_SERVER_CONFIG, eventCallback_upconfig);
    super.dispose();
  }

  eventCallback_upconfig(arg)
  {
    // 钱包接口api更新 重新请求uniswapinfo
    widget?.walletAccount?.uploadUniswapInfo();
  }

  @override
  Widget getTopFloatWidget() {
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
  }


  @override
  Widget getAppBarRight({Color color}) {
    return InkWell(
      onTap: (){
        ViewGT.showUniswaporderlistView(context, widget.walletAccount);
      },
      child: super.getAppBarRight(color: color),
    );
  }

  @override
  Widget getAppBarCenter({Color color}) {
    return Container(
      height: 40,
      width: 220,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        elevation: 5,
        shadowColor: Colors.black26,
        child: Row(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: (){
                  onClickTab(0);
                },
                child: Text(
                  "兑换",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: pageIndex == 0 ? Colors.black : Colors.black54,
                    fontSize: 16,
                    fontWeight:
                    pageIndex == 0 ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: (){
                  onClickTab(1);
                },
                child:Text(
                  "资金池",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: pageIndex == 1 ? Colors.black : Colors.black54,
                    fontSize: 16,
                    fontWeight:
                    pageIndex == 1 ?FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  onClickTab(int index)
  {
    setState(() {
      pageIndex = index;
      _tabController.animateTo(index);
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, BaseFuntion.topbarheight+BaseFuntion.appbarheight, 0, 0),
      decoration: BoxDecoration(
        gradient:RadialGradient(
          colors: [Color(0xfff7e6f0),Colors.white,],
          center: Alignment.center,
          radius:1,
          tileMode: TileMode.clamp,
        ),
      ),
      child: TabBarView(
        controller: _tabController,
//        physics: new NeverScrollableScrollPhysics(), //禁止横向滑动翻页
        children: [
          UniswapExchangeView(widget.walletAccount),
          UniswapPoolView(widget.walletAccount),
        ],
      ),
    );
  }
}
