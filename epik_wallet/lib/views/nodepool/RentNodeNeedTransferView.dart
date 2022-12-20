import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/localstring/LocaleConfig.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/api/api_mainnet.dart';
import 'package:epikwallet/model/CoinbaseInfo2.dart';
import 'package:epikwallet/model/nodepool/RentNodeTransferObj.dart';
import 'package:epikwallet/utils/ClickUtil.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/miner/MinerBatchTransferView.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class RentNodeNeedTransferView extends BaseWidget {
  CoinbaseInfo2 coinbase;
  List<RentNodeTransferObj> data;

  RentNodeNeedTransferView(this.coinbase,this.data);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return RentNodeNeedTransferViewState();
  }
}

class RentNodeNeedTransferViewState extends BaseWidgetState<RentNodeNeedTransferView> {
  List<RentNodeTransferObj> data;
  List<RentNodeTransferObj> data_seleted = [];

  selectAll(bool isSelected) {
    if (isSelected) {
      data_seleted = List.from(widget.data);
    } else {
      data_seleted = [];
    }
  }

  bool get hasSelected {
    return data_seleted != null && data_seleted.length > 0;
  }

  setMinerSelect(RentNodeTransferObj obj, bool isSelected) {
    if (isSelected && !data_seleted.contains(obj)) {
      data_seleted.add(obj);
    } else {
      data_seleted.remove(obj);
    }
  }

  bool hasMinerSelect(RentNodeTransferObj obj) {
    return data_seleted?.contains(obj) ?? false;
  }

  @override
  void initStateConfig() {
    super.initStateConfig();
    viewSystemUiOverlayStyle = DeviceUtils.system_bar_main.copyWith(systemNavigationBarColor: ResColor.b_4);
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);

    data = List.from(widget.data);

    //todo test
    // for (int i = 0; i < 50; i++) {
    //   widget.data.add(RentNodeTransferObj()
    //     ..MinerID = "f00$i"
    //     ..TargetID = "f10$i"
    //     ..State = "aaa");
    // }

    refresh();
  }

  bool isLoading = false;

  refresh({bool frompull}) async {

    isLoading = true;
    setLoadingWidgetVisible(true);

    HttpJsonRes hjr = await ApiMainNet.getMinersAutoSection(widget?.coinbase?.miner?.MinerIDs);
    if (hjr?.code == 0) {
      List<CbMinerObj> list_CbMinerObj = JsonArray.parseList(JsonArray.obj2List(hjr.jsonMap["list"]), (json) => CbMinerObj.fromJson(json));
      if (list_CbMinerObj == null || list_CbMinerObj?.length == 0) {
        emptyBackgroundColor = Colors.transparent;
        statelayout_margin = EdgeInsets.only(top: getAppBarHeight() + 100);
        setEmptyWidgetVisible(true);
      } else {

        for(RentNodeTransferObj obj in data)
        {
          CbMinerObj cbminerobj =list_CbMinerObj.firstWhere((element) => element.ID == obj.MinerID);
          obj.cbminerobj = cbminerobj;
          dlog("obj.MinerID : ${obj.MinerID}  cbminerobj=${obj.cbminerobj} ");
        }

        closeStateLayout();
      }
    } else {
      emptyBackgroundColor = Colors.transparent;
      statelayout_margin = EdgeInsets.only(top: getAppBarHeight() + 100);
      setEmptyWidgetVisible(true);
    }
    isLoading = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(RSID.rnntv_2.text);
  }

  Widget getAppbar() {
    return Container(
      width: double.infinity,
      height: getAppBarHeight() + getTopBarHeight(),
      padding: EdgeInsets.fromLTRB(0, getTopBarHeight(), 0, 0),
      // decoration: BoxDecoration(
      //   gradient: ResColor.lg_1,
      // ),
      child: super.getAppBar(),
    );
  }

  Widget buildWidget(BuildContext context) {
    List<Widget> items = [];
    for (RentNodeTransferObj obj in widget.data) {
      items.add(buildMinerItem(obj));
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Container(
            height: getAppBarHeight() + getTopBarHeight() + 128,
            // padding: EdgeInsets.fromLTRB(0, getTopBarHeight(), 0, 128),
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              gradient: ResColor.lg_1,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: getAppbar(),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: getAppBarHeight() + getTopBarHeight(),
            bottom: 83,
            child: Container(
              margin: EdgeInsets.fromLTRB(30, 50, 30, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                color: ResColor.b_5,
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                    child: Row(
                      children: [
                        Container(
                          width: 22.0 + 10,
                        ),
                        Expanded(
                          child: Text(
                            "NodeID",
                            style: TextStyle(
                              fontSize: 16,
                              color: ResColor.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "TargetID",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: ResColor.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "State",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 16,
                              color: ResColor.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: items,
                      ),
                    ),
                  ),
                  Container(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: getBatchBar(),
          )
        ],
      ),
    );
  }

  Widget buildMinerItem(RentNodeTransferObj obj) {
    bool isSeleted = hasMinerSelect(obj);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (ClickUtil.isFastDoubleClick()) return;
                  setMinerSelect(obj, !isSeleted);
                  setState(() {});
                },
                child: Container(
                  width: 22,
                  height: 22,
                  margin: EdgeInsets.only(right: 10),
                  decoration: isSeleted
                      ? BoxDecoration(
                          //选中
                          gradient: ResColor.lg_1,
                          borderRadius: BorderRadius.circular(22),
                        )
                      : BoxDecoration(
                          //未选中
                          color: Color(0xff424242),
                          border: Border.all(color: ResColor.white, width: 1.5),
                          borderRadius: BorderRadius.circular(22),
                        ),
                  child: isSeleted
                      ? Image.asset(
                          "assets/img/ic_checkmark.png",
                          width: 10,
                          height: 10,
                        )
                      : null,
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (StringUtils.isNotEmpty(obj.MinerID)) {
                      DeviceUtils.copyText(obj.MinerID);
                      showToast("${obj.MinerID} "+RSID.copied.text);
                    }
                  },
                  child: Text(
                    obj.MinerID,
                    style: TextStyle(
                      fontSize: 16,
                      color: ResColor.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child:
                InkWell(
                  onTap: (){
                    if (StringUtils.isNotEmpty(obj.TargetID)) {
                      DeviceUtils.copyText(obj.TargetID);
                      showToast("${obj.TargetID} "+RSID.copied.text);
                    }
                  },
                  child:  Text(
                    obj.TargetID,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: ResColor.white,
                    ),
                  ),
                ),

              ),
              Expanded(
                child: Text(
                  obj.State,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 16,
                    color: ResColor.white,
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 15,
          ),
          Divider(
            color: ResColor.white_30,
            height: 1,
            endIndent: 0,
            indent: 0,
            thickness: 1,
          ),
        ],
      ),
    );
  }

  Widget getBatchBar() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ResColor.b_4,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: true,
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Row(
            children: [
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
              // Container(width: 10),
              Container(width: 10),
              Expanded(
                child: LoadingButton(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  padding: EdgeInsets.only(bottom: 1),
                  height: 40,
                  gradient_bg: ResColor.lg_3,
                  color_bg: Colors.transparent,
                  disabledColor: Colors.transparent,
                  bg_borderradius: BorderRadius.circular(4),
                  text: RSID.mlv_21.text,
                  //"转移",Transfer
                  //全部质押
                  textstyle: TextStyle(
                    color: Colors.white,
                    fontSize: LocaleConfig.currentIsZh() ? 17 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                  onclick: (lbtn) {
                    if (hasSelected) {
                      onClickBatchTransfer();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onClickBatchTransfer() {

    if(data_seleted.length==0)
      return;

    List<CbMinerObj> minerids=[];
    List<String> targetList=[];

    for(RentNodeTransferObj obj  in data_seleted)
    {
      minerids.add(obj.cbminerobj);
      targetList.add(obj.TargetID);
    }

    ViewGT.showView(context, MinerBatchTransferView(widget?.coinbase?.ID ?? "",minerids, targetList));
  }
}
