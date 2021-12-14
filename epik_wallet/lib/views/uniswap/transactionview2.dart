import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/views/mainview.dart';
import 'package:epikwallet/views/uniswap/uniswapview.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:epikwallet/localstring/resstringid.dart';

class TransactionView2 extends BaseWidget {
  TransactionView2();

  @override
  BaseWidgetState<BaseWidget> getState() {
    return TransactionView2State();
  }

}

class TransactionView2State extends BaseWidgetState<TransactionView2> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void initStateConfig() {
   setAppBarTitle("");

    setTopBarVisible(false);
    setAppBarVisible(false);

    isTopFloatWidgetShow=true;
   topBarColor=Colors.transparent;
   appBarColor=Colors.transparent;
  }


  @override
  Widget getTopFloatWidget() {
    return Container(
      width: 60,
      height: getAppBarHeight(),
      margin: EdgeInsets.only(top: getTopBarHeight()),
      child: Stack(
        children: [
          Align(
            //左边返回导航 的位置，可以根据需求变更
            alignment: FractionalOffset(0, 0.5),
            child: Offstage(
              offstage: false,//!_isBackIconShow,
              child: getAppBarLeft(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onCreate() {
    super.onCreate();
    eventMgr.add(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventCallback_account);
    refresh();
  }

  eventCallback_account(obj) {
    refresh();
  }

  @override
  void dispose() {
    eventMgr.remove(
        EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventCallback_account);
    super.dispose();
  }

  refresh() {
    setState(() {});
  }

  @override
  Widget buildWidget(BuildContext context) {
    if (AccountMgr().currentAccount == null)
    {
      return Center(
        child: Text(
          ResString.get(context, RSID.main_tv_1), //"请先登录钱包",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    }

    // 暂时把uniswap嵌入到这里显示
    return UniswapView(AccountMgr().currentAccount);
  }

  Widget getLinechart() {
    return Container(
      margin: EdgeInsets.fromLTRB(30, 30, 30, 30),
      width: double.infinity,
      height: 240,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        elevation: 10,
        shadowColor: Colors.black54,
        child: null,
      ),
    );
  }

  onClickUniswap() {
    if (AccountMgr().currentAccount == null) {
      eventMgr.send(EventTag.CHANGE_MAINVIEW_INDEX,  main_subviewTypes.indexOf(MainSubViewType.WALLETVIEW));
      return;
    }

    ViewGT.showUniswapView(context, AccountMgr().currentAccount);
  }

  onClickMining() {
    // todo
  }
}
