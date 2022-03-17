import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/loading_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/views/miner/Minermenu.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class MinerBatchPledgeView extends BaseWidget {
  List<String> mineridList_all;
  Map<String, MinerGroupType> groupTypeMap;

  MinerBatchPledgeView(this.mineridList_all, this.groupTypeMap);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return MinerBatchPledgeViewState();
  }
}

class MinerBatchPledgeViewState extends BaseWidgetState<MinerBatchPledgeView> {
  Map<String, bool> selectedMap = {};

  @override
  void initStateConfig() {
    super.initStateConfig();
    isTopBarShow = false;
    // selectAll(true);
    selectAllNotPledged();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(RSID.minermenu_6.text);
  }

  bool minerIsSeleted(String minerId) {
    return selectedMap[minerId] ?? false;
  }

  setMinerSelect(String minerId, bool isSelected) {
    if (isSelected) {
      selectedMap[minerId] = true;
    } else {
      selectedMap.remove(minerId);
    }
  }

  selectAll(bool isSelected) {
    if (isSelected) {
      Map<String, bool> _selectedMap = {};
      widget.mineridList_all.forEach((element) {
        _selectedMap[element] = true;
      });
      selectedMap = _selectedMap;
    } else {
      selectedMap.clear();
    }
  }

  selectAllNotPledged() {
    Map<String, bool> _selectedMap = {};
    widget.mineridList_all.forEach((element) {
      MinerGroupType groupType = widget.groupTypeMap[element];
      // print("$element  ${groupType.isPledged}");
      if (groupType?.isPledged != true) {
        _selectedMap[element] = true;
      }
    });
    selectedMap = _selectedMap;
  }

  bool get hasSelected {
    return selectedMap != null && selectedMap.length > 0;
  }

  @override
  Widget getAppBar() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: ResColor.lg_1,
      ),
      padding: EdgeInsets.only(top: getTopBarHeight()),
      child: super.getAppBar(),
    );
  }
  ///导航栏appBar中间部分 ，不满足可以自行重写
  Widget getAppBarRight({Color color}) {
    return Text(
      "${selectedMap?.length??0} / ${widget?.mineridList_all?.length}    ",
      style: TextStyle(
        fontSize: 14,
        color: color ?? appBarContentColor,
      ),
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    List<Widget> items = [];

    if (widget.mineridList_all != null && widget.mineridList_all.length > 0) {
      widget.mineridList_all.forEach((element) {
        items.add(buildItem(element));
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
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
              InkWell(
                onTap: () {
                  selectAll(true);
                  setState(() {});
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                  child: Text(
                    RSID.minermenu_7.text, //"全选",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  //todo
                  selectAll(false);
                  setState(() {});
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
                  child: Text(
                    RSID.minermenu_8.text, //"取消",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: LoadingButton(
                  height: 40,
                  // padding: EdgeInsets.fromLTRB(0, 8.5, 0, 8.5),
                  color_bg: Colors.transparent,
                  //const Color(0xff3a3a3a),
                  gradient_bg: ResColor.lg_1,
                  disabledColor: const Color(0xff3a3a3a),
                  text: RSID.minerview_1.text,
                  onclick: hasSelected
                      ? (lbtn) {
                          onClickOK();
                        }
                      : null,
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

  Widget buildItem(String minerID) {
    bool isSeleted = minerIsSeleted(minerID);
    MinerGroupType grouptype = widget.groupTypeMap[minerID];
    Widget ret = Material(
      // color: isCurrent ? Colors.transparent : Color(0xff424242),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () {
          setMinerSelect(minerID, !isSeleted);
          setState(() {});
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(15, 13, 15, 13),
          //EdgeInsets.fromLTRB(13, 13, 0, 13)
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: isSeleted
                        ? Image.asset(
                            "assets/img/ic_checkmark.png",
                            width: 20,
                            height: 20,
                          )
                        : null,
                  ),

                  Container(width: 15), //13

                  Expanded(
                    child: Text(
                      (minerID ?? "----"),
                      style: TextStyle(
                        color: ResColor.white_80, //Colors.white : ,
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
      decoration:
          // isCurrent
          //     ? BoxDecoration(
          //   color: Colors.transparent,
          //   borderRadius: BorderRadius.circular(4),
          //   border: Border.all(color: ResColor.o_1, width: 2),
          // )
          //     :
          BoxDecoration(
        color: Color(0xff424242),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  onClickOK() {
    BottomDialog.simpleAuth(
        context, AccountMgr().currentAccount.password, (value) async {
      showLoadDialog("", touchOutClose: false, backClose: false);

      List<String> minerids = List.from(selectedMap.keys);

      ResultObj<String> robj = await AccountMgr()
          .currentAccount
          .epikWallet
          .minerPledgeOneClick(minerids);

      closeLoadDialog();

      if (robj?.isSuccess) {

        MessageDialog.showMsgDialog(
          context,
          title: RSID.minermenu_6.text,//一键抵押
          msg: "${RSID.minerview_18.text}",//交易已提交
          // btnLeft: RSID.minerview_19.text,//"查看交易",
          btnRight: RSID.isee.text,
          // onClickBtnLeft: (dialog) {
          //   dialog.dismiss();
          //   String url = ServiceInfo.epik_msg_web + cid;
          //   ViewGT.showGeneralWebView(context, RSID.berlv_4.text, url);
          // },
          onClickBtnRight: (dialog) {
            dialog.dismiss();
          },
        );
      } else {
        showToast(robj?.errorMsg ?? RSID.request_failed.text);
      }
    });
  }
}
