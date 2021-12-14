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

class TransactionView extends BaseInnerWidget {
  TransactionView(Key key) : super(key: key) {}

  @override
  BaseInnerWidgetState<BaseInnerWidget> getState() {
    return TransactionViewState();
  }

  @override
  int setIndex() {
    return 1;
  }
}

class TransactionViewState extends BaseInnerWidgetState<TransactionView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void initStateConfig() {
//    setTopBarVisible(true);
//    setAppBarVisible(true);
//    setAppBarTitle("交易");

    setTopBarVisible(false);
    setAppBarVisible(false);
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
    if (AccountMgr().currentAccount == null) {
      return Text(
        ResString.get(context, RSID.main_tv_1), //"请先登录钱包",
      );
    }

    // 暂时把uniswap嵌入到这里显示
    return UniswapView(AccountMgr().currentAccount);

//    return Column(
//      mainAxisSize: MainAxisSize.min,
//      children: <Widget>[
//        getLinechart(),
//        InkWell(
//          onTap: () {
//            onClickUniswap();
//          },
//          child: Container(
//            margin: EdgeInsets.fromLTRB(30, 0, 30, 30),
//            width: double.infinity,
//            height: 50,
//            child: Card(
//              color: Colors.white,
//              shape: RoundedRectangleBorder(
//                borderRadius: BorderRadius.all(Radius.circular(20.0)),
//              ),
//              elevation: 10,
//              shadowColor: Colors.black54,
//              child: Row(
//                children: <Widget>[
////                   Container(
////                     width: 40,
////                     height: 40,
////                     margin: EdgeInsets.all(20),
////                     decoration: BoxDecoration(
////                       color: Color(0xff1a1c1f),
////                       shape: BoxShape.circle,
////                     ),
////                     child: Icon(
////                       Icons.add_circle,
////                       size: 26,
////                       color: Color(0xfff0f0f0),
////                     ),
////                   ),
//                  Expanded(
//                    child: Text(
//                      "Uniswap",
//                      textAlign: TextAlign.center,
//                      style: TextStyle(
//                        color: Colors.black,
//                        fontSize: 16,
//                        fontWeight: FontWeight.w600,
//                      ),
//                    ),
//                  ),
////                   Icon(
////                     Icons.chevron_right,
////                     color: Colors.black,
////                     size: 20,
////                   ),
////                   Container(width: 15),
//                ],
//              ),
//            ),
//          ),
//        ),
////        InkWell(
////          onTap: () {
////            onClickMining();
////          },
////          child: Container(
////            margin: EdgeInsets.fromLTRB(30, 0, 30, 30),
////            width: double.infinity,
////            height: 70,
////            child: Card(
////              color: Colors.white,
////              shape: RoundedRectangleBorder(
////                borderRadius: BorderRadius.all(Radius.circular(40.0)),
////              ),
////              elevation: 10,
////              shadowColor: Colors.black54,
////              child: Row(
////                children: <Widget>[
//////                   Container(
//////                     width: 40,
//////                     height: 40,
//////                     margin: EdgeInsets.all(20),
//////                     decoration: BoxDecoration(
//////                       color: Color(0xff1a1c1f),
//////                       shape: BoxShape.circle,
//////                     ),
//////                     child: Icon(
//////                       Icons.add_circle,
//////                       size: 26,
//////                       color: Color(0xfff0f0f0),
//////                     ),
//////                   ),
////                  Expanded(
////                    child: Text(
////                      "流动性挖矿",
////                      textAlign: TextAlign.center,
////                      style: TextStyle(
////                        color: Colors.black,
////                        fontSize: 16,
////                        fontWeight: FontWeight.w600,
////                      ),
////                    ),
////                  ),
//////                   Icon(
//////                     Icons.chevron_right,
//////                     color: Colors.black,
//////                     size: 20,
//////                   ),
//////                   Container(width: 15),
////                ],
////              ),
////            ),
////          ),
////        ),
//      ],
//    );
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
