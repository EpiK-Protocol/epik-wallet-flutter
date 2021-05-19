import 'dart:async';

import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

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
  List<String> data = [];
  String cMinerId;

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
    setAppBarTitle(action == 0 ? "选择MinerID" : "删除MinerID");
    setAppBarRightTitle(action == 0 ? "删除" : RSID.cancel.text);
  }

  @override
  void onCreate() {
    super.onCreate();
    data = List<String>.from(AccountMgr()?.currentAccount?.minerIdList ?? []);
    cMinerId = AccountMgr()?.currentAccount?.minerCurrent;
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

  @override
  Widget buildWidget(BuildContext context) {
    List<Widget> items = [];
    for (int i = 0; i < data.length; i++) {
      if (action == 0) {
        items.add(buildItem(data[i], data[i]==cMinerId));
      } else {
        items.add(buildItemDel(data[i], data[i]==cMinerId));
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
        Container(
          margin: EdgeInsets.fromLTRB(
              20, 15, 20, 10 + MediaQuery.of(context).padding.bottom),
          // height: 44,
          child: Row(
            children: <Widget>[
              if (action == 0)
                Expanded(
                  child: LoadingButton(
                    height: 40,
                    color_bg: const Color(0xff3a3a3a),
                    disabledColor: const Color(0xff3a3a3a),
                    text: "添加MinerID",
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
            ],
          ),
        ),
      ],
    );
  }

  Widget buildItem(String minerID, bool isCurrent) {
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
                  if (isCurrent)
                    Image.asset(
                      "assets/img/ic_checkmark.png",
                      width: 20,
                      height: 20,
                    ),
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
    data.remove(minerID);
    if(isCurrent)
    {
      cMinerId =  data != null && data.length > 0 ?  data[0] : null;
    }
    setState(() {
    });
  }

  onClickItem(String minerID, bool isCurrent) {
    //  选择某个ID
    cMinerId=minerID;
    setState(() {
    });
    Future.delayed(Duration(milliseconds: 100)).then((value){
      finish();
    });
  }

  void clickAdd() {
    BottomDialog.showTextInputDialog(context, "添加MinerID", "", "请输入MinerID", 50,
        (value) {
      if (StringUtils.isNotEmpty(value)) {
        data.add(value.trim());
        // AccountMgr().currentAccount.saveMinerIdList();
      }
    });
  }

  void save(){
    bool currentChenged = false;
    if (AccountMgr().currentAccount.minerCurrent != cMinerId) {
      AccountMgr().currentAccount.minerCurrent = cMinerId;
      currentChenged = true;
    }
    AccountMgr().currentAccount.minerIdList = data;
    AccountMgr().currentAccount.saveMinerIdList();

    if(currentChenged)
    {
      eventMgr.send(EventTag.MINER_CURRENT_CHENGED,true);
    }
  }
}
