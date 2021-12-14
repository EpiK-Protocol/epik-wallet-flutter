import 'dart:async';
import 'dart:ui';

import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/model/MinerCoinbaseList.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class MinerGroupType {
  bool isCoinbase = false;
  bool isPledged = false;
  bool isLocal = false;

  MinerGroupType();
}

class MinerMenu extends BaseInnerWidget {
  @override
  BaseInnerWidgetState<BaseInnerWidget> getState() {
    return _MinerMenuState();
  }

  @override
  int setIndex() {
    return 0;
  }
}

class _MinerMenuState extends BaseInnerWidgetState<MinerMenu> {
  List<String> data_local = [];
  bool haseditlocal = false;
  String cMinerId;

  MinerCoinbaseList minerCoinbaseList;

  List<String> mineridList_all;
  Map<String, MinerGroupType> groupTypeMap;

  /// 功能模式 0选择 1删除
  int action = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void initStateConfig() {
    isTopBarShow = false; //状态栏是否显示
    isAppBarShow = false; //导航栏是否显示
    setTopBarBackColor(ResColor.b_4);
    setAppBarBackColor(ResColor.b_4);
    setAppBarContentColor(Colors.white);

    bodyBackgroundColor = ResColor.b_4;

    // setBackIconHinde(isHinde: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAction(action);
  }

  setAction(int a) {
    /// 功能模式 0选择 1删除
    action = a;
    // setAppBarTitle(action == 0 ? "选择MinerID" : "删除MinerID");
    setAppBarTitle(action == 0 ? RSID.minermenu_1.text : RSID.minermenu_2.text);
    setAppBarRightTitle(action == 0 ? RSID.minermenu_3.text : RSID.cancel.text);
  }

  @override
  void onCreate() {
    super.onCreate();
    data_local =
        List<String>.from(AccountMgr()?.currentAccount?.minerIdList ?? []);
    cMinerId = AccountMgr()?.currentAccount?.minerCurrent;

    minerCoinbaseList = AccountMgr()?.currentAccount?.minerCoinbaseList;
    mineridList_all = AccountMgr().currentAccount.getAllMinerList() ?? [];
    groupTypeMap = {};
    for (String minerid in mineridList_all) {
      groupTypeMap[minerid] = MinerGroupType()
        ..isCoinbase = minerCoinbaseList?.coinbased?.contains(minerid) ?? false
        ..isPledged = minerCoinbaseList?.pledged?.contains(minerid) ?? false
        ..isLocal = data_local?.contains(minerid) ?? false;
    }
  }

  @override
  void dispose() {
    save();
    super.dispose();
  }

  ///导航栏 appBar 可以重写
  Widget getAppBar() {
    return Container(
      height: getAppBarHeight(),
      width: double.infinity,
      color: appBarColor,
      child: Stack(
        alignment: FractionalOffset(0, 0.5),
        children: <Widget>[
          Align(
            alignment: FractionalOffset(0, 0.5),
            child: getAppBarCenter(),
          ),
          // Align(
          //   //左边返回导航 的位置，可以根据需求变更
          //   alignment: FractionalOffset(0, 0.5),
          //   child: Offstage(
          //     offstage: !_isBackIconShow,
          //     child: getAppBarLeft(),
          //   ),
          // ),
          Align(
            alignment: FractionalOffset(1, 0.5),
            child: InkWell(
              onTap: () {
                setAction(action == 0 ? 1 : 0);
              },
              child: Container(
                height: double.infinity,
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [getAppBarRight()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///导航栏appBar中间部分 ，不满足可以自行重写
  Widget getAppBarCenter({Color color}) {
    return Row(
      children: [
        Container(width: 20),
        Text(
          appBarTitle,
          style: TextStyle(
            fontSize: appBarCenterTextSize,
            color: color ?? appBarContentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget subtitle(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    List<Widget> items = [];

    //选择模式
    if (action == 0) {
      // bool hasseleted = false;
      // //在线id
      // if (minerCoinbaseList?.hasCoinbased == true) {
      //   items.add(subtitle("CoinBased"));
      //   minerCoinbaseList.coinbased.forEach((element) {
      //     if (hasseleted == false && element == cMinerId) {
      //       hasseleted = true;
      //     }
      //     items.add(buildItem(element, element == cMinerId));
      //   });
      // }
      // if (minerCoinbaseList?.haspledged == true) {
      //   items.add(subtitle("Pledged"));
      //   minerCoinbaseList.pledged.forEach((element) {
      //     if (hasseleted == false && element == cMinerId) {
      //       hasseleted = true;
      //     }
      //     items.add(buildItem(element, element == cMinerId));
      //   });
      // }
      //
      // //本地minerid
      // if (data_local != null && data_local.length > 0) {
      //   List<Widget> locals = [];
      //   for (int i = 0; i < data_local.length; i++) {
      //     if (minerCoinbaseList?.containsMinerid(data_local[i]) == true) {
      //       continue;
      //     }
      //     locals.add(buildItem(data_local[i],
      //         hasseleted == false ? data_local[i] == cMinerId : false));
      //   }
      //   if (locals.length > 0) {
      //     items.add(subtitle("Local"));
      //     items.addAll(locals);
      //   }
      // }

      if (mineridList_all != null && mineridList_all.length > 0) {
        mineridList_all.forEach((element) {
          items.add(buildItem(element, element == cMinerId));
        });
      }
    } else {
      //删除模式
      //本地minerid
      for (int i = 0; i < data_local.length; i++) {
        // if (action == 0) {
        //   items.add(buildItem(data[i], data[i] == cMinerId));
        // } else {
        items.add(buildItemDel(data_local[i], data_local[i] == cMinerId));
        // }
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        getTopBar(),
        getAppBar(),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
            children: items,
          ),
        ),
        if (action == 0)
          Container(
            margin: EdgeInsets.fromLTRB(
                20, 15, 20, 10 + MediaQuery.of(context).padding.bottom),
            // height: 44,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: LoadingButton(
                    // height: 40,
                    padding: EdgeInsets.fromLTRB(0, 8.5, 0, 8.5),
                    color_bg: const Color(0xff3a3a3a),
                    disabledColor: const Color(0xff3a3a3a),
                    text: RSID.minermenu_4.text,
                    //"添加MinerID",
                    onclick: (lbtn) {
                      clickAdd();
                    },
                    textstyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    bg_borderradius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 20,
                ),
                Expanded(
                  child: LoadingButton(
                    // height: 40,
                    padding: EdgeInsets.fromLTRB(0, 8.5, 0, 8.5),
                    color_bg: const Color(0xff3a3a3a),
                    disabledColor: const Color(0xff3a3a3a),
                    text: RSID.minermenu_6.text,
                    //"一键抵押",
                    onclick: (lbtn) {
                      ViewGT.showMinerBatchPledgeView(
                          context, mineridList_all, groupTypeMap);
                    },
                    textstyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    bg_borderradius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget buildItem(String minerID, bool isCurrent) {
    MinerGroupType grouptype = groupTypeMap[minerID];
    Widget ret = Material(
      // color: isCurrent ? Colors.transparent : Color(0xff424242),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () {
          onClickItem(minerID, isCurrent);
        },
        child: Container(
          padding: isCurrent
              ? EdgeInsets.fromLTRB(13, 13, 0, 13)
              : EdgeInsets.fromLTRB(15, 15, 0, 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      (minerID ?? "----"),
                      style: TextStyle(
                        color: isCurrent ? Colors.white : ResColor.white_80,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  if (grouptype?.isCoinbase == true)
                    Container(
                      // height: 20,
                      margin: EdgeInsets.only(left: 5),
                      padding: EdgeInsets.fromLTRB(5, 3, 5, 2),
                      decoration: BoxDecoration(
                        gradient: ResColor.lg_2,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        "Coinbase",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  if (grouptype?.isPledged == true)
                    Container(
                      // height: 20,
                      margin: EdgeInsets.only(left: 5),
                      padding: EdgeInsets.fromLTRB(5, 3, 5, 2),
                      decoration: BoxDecoration(
                        gradient: ResColor.lg_3,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        "Pledged",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  // if (isCurrent)
                  //   Image.asset(
                  //     "assets/img/ic_checkmark.png",
                  //     width: 20,
                  //     height: 20,
                  //   ),
                  Container(width: isCurrent ? 13 : 15),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: ret,
      decoration: isCurrent
          ? BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: ResColor.o_1, width: 2),
            )
          : BoxDecoration(
              color: Color(0xff424242),
              borderRadius: BorderRadius.circular(4),
            ),
    );
  }

  Widget buildItemDel(String minerID, bool isCurrent) {
    Widget ret = Material(
      // color: isCurrent ? Colors.transparent : Color(0xff424242),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () {
          onClickItemDel(minerID, isCurrent);
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(15, 11.5, 0, 11.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      (minerID ?? "----"),
                      style: TextStyle(
                        color: ResColor.white_80,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Image.asset(
                    "assets/img/ic_delete_red.png",
                    width: 30,
                    height: 30,
                  ),
                  Container(width: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: ret,
      decoration: BoxDecoration(
        color: Color(0xff424242),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  onClickItemDel(String minerID, bool isCurrent) {
    // 删除某个ID
    haseditlocal = true;
    data_local.remove(minerID);
    mineridList_all.remove(minerID);
    if (isCurrent) {
      cMinerId =
        mineridList_all != null && mineridList_all.length > 0 ? mineridList_all[0] : null;
    }
    setState(() {});
  }

  onClickItem(String minerID, bool isCurrent) {
    //  选择某个ID
    cMinerId = minerID;
    setState(() {});
    Future.delayed(Duration(milliseconds: 100)).then((value) {
      finish();
    });
  }

  void clickAdd() {
    // BottomDialog.showTextInputDialog(context, "添加MinerID", "", "请输入MinerID", 50,
    BottomDialog.showTextInputDialog(
        context, RSID.minermenu_4.text, "", RSID.minermenu_5.text, 50, (value) {
      if (StringUtils.isNotEmpty(value)) {
        data_local.add(value.trim());
        if (!mineridList_all.contains(value.trim())) {
          mineridList_all.add(value.trim());
          groupTypeMap[value] = MinerGroupType()
            ..isPledged = false
            ..isCoinbase = false
            ..isLocal = true;
        }
        haseditlocal = true;
        // AccountMgr().currentAccount.saveMinerIdList();
      }
    });
  }

  void save() {
    bool currentChenged = false;
    if (AccountMgr().currentAccount.minerCurrent != cMinerId) {
      AccountMgr().currentAccount.minerCurrent = cMinerId;
      currentChenged = true;
    }
    AccountMgr().currentAccount.minerIdList = data_local;
    AccountMgr().currentAccount.saveMinerIdList();

    if (currentChenged) {
      eventMgr.send(EventTag.MINER_CURRENT_CHENGED, true);
    } else if (haseditlocal) {
      eventMgr.send(EventTag.MINER_CURRENT_CHENGED, false);
    }
  }
}
