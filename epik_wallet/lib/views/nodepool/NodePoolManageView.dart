import 'package:decimal/decimal.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/localstring/LocaleConfig.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_pool.dart';
import 'package:epikwallet/model/nodepool/PoolObj.dart';
import 'package:epikwallet/utils/ClickUtil.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/nodepool/NodePoolAddOwnerView.dart';
import 'package:epikwallet/views/nodepool/NodePoolCreateView.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:epikwallet/widget/text/TextEllipsisMiddle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';

//自己创建的节点池管理页面
class NodePoolManageView extends BaseWidget {
  PoolObj pool;

  NodePoolManageView(this.pool);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return NodePoolManageViewState();
  }
}

class PoolNodeState {
  String minerid;

  //激活中
  bool actived = false;

  //可出租的
  bool available = false;

  //锁定的
  bool locked = false;
}

class NodePoolManageViewState extends BaseWidgetState<NodePoolManageView> {
  bool result = false;

  List<PoolNodeState> nodeStateList = [];

  @override
  void initStateConfig() {
    super.initStateConfig();
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);

    if (widget.pool.Nodes != null)
      for (String minerid in widget.pool.Nodes) {
        nodeStateList.add(PoolNodeState()
          ..minerid = minerid
          ..actived = !widget.pool.AvailableNodes.contains(minerid)
          ..available = widget.pool.AvailableNodes.contains(minerid)
          ..locked = widget.pool.LockedNodes.contains(minerid));
      }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(RSID.nodepool_node_poolmanage.text);
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

  List<String> headerdata = ["card", "owners", "miners"];

  Widget buildWidget(BuildContext context) {
    Widget widget = ListPage(
      [],
      headerList: headerdata,
      headerCreator: (context, position) {
        String ddd = headerdata[position];
        switch (ddd) {
          case "card":
            return getHeaderCard();
          case "owners":
            return getHeaderOwners();
          case "miners":
            return getHeaderMiners();
        }
        return Container();
      },
      itemWidgetCreator: (context, position) {
        return Container();
      },
    );

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
            bottom: 0,
            child: widget,
          ),
        ],
      ),
    );
  }

  Widget getHeaderCard() {
    PoolObj obj = widget.pool;

    List<Widget> items = [];

    items.add(
      Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Text(
          obj?.Name ?? "--",
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 16, color: ResColor.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

    if (StringUtils.isNotEmpty(obj?.Description)) {
      items.add(
        Container(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
          alignment: Alignment.topLeft,
          child: Text(
            obj?.Description ?? "--",
            textAlign: TextAlign.start,
            // maxLines: ,
            // overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: ResColor.white),
          ),
        ),
      );
    }
    items.add(Container(height: 10));

    // coinbaseID      count
    // xxxx            xxxx
    items.add(
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: getColumnKeyValue("CoinbaseID", obj?.CoinbaseID ?? "--", clickCopy: true)),
          Expanded(
            child: getColumnKeyValue(
                RSID.npcv_7.text, (Decimal.parse(obj?.Fee) * Decimal.fromInt(100)).toString() + "%" ?? "--",
                crossAxisAlignment: CrossAxisAlignment.end),
          ),
        ],
      ),
    );

    items.add(Container(height: 10));
    items.add(
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: getColumnKeyValue(RSID.npcv_5.text, obj?.FeeAddress ?? "--", clickCopy: true)),
        ],
      ),
    );


    // items.add(Container(height: 10));
    // //Count            Actived       Available
    // // xxxx            xxxx            xxxx
    // items.add(
    //   Row(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Expanded(
    //         child: getColumnKeyValue(RSID.nodepool_node_count.text, obj?.Count?.toString() ?? "--",
    //             crossAxisAlignment: CrossAxisAlignment.start),
    //       ),
    //       Expanded(
    //         child: getColumnKeyValue(RSID.nodepool_node_actived.text, obj?.Actived?.toString() ?? "--",
    //             crossAxisAlignment: CrossAxisAlignment.center),
    //       ),
    //       Expanded(
    //         child: getColumnKeyValue(RSID.nodepool_node_available.text, obj?.Available?.toString() ?? "--",
    //             crossAxisAlignment: CrossAxisAlignment.end),
    //       ),
    //     ],
    //   ),
    // );

    items.add(Container(height: 20));

    items.add(Row(
      children: [
        Expanded(
          child: LoadingButton(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
            padding: EdgeInsets.only(bottom: 1),
            height: 30,
            gradient_bg: ResColor.lg_1,
            color_bg: Colors.transparent,
            disabledColor: Colors.grey,
            bg_borderradius: BorderRadius.circular(4),
            text: RSID.nodepool_edit.text,
            //赎回 apply withdraw
            textstyle: TextStyle(
              color: Colors.white,
              fontSize: LocaleConfig.currentIsZh() ? 17 : 14,
            ),
            onclick: (lbtn) {
              onclickUpdate();
            },
          ),
        ),
      ],
    ));

    Widget card = Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
      padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ResColor.b_5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    );

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          card,
          Positioned(
              top: 0,
              right: 25,
              child: Container(
                padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                decoration: BoxDecoration(
                  color: widget.pool.Enable ? ResColor.g_1 : ResColor.r_1,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.pool.Enable ? RSID.npcv_9.text : RSID.npcv_10.text,
                  style: const TextStyle(
                    color: ResColor.white,
                    fontSize: 12,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget getColumnKeyValue(
    String key,
    String value, {
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    double centerpading = 4,
    bool textem = false,
    bool clickCopy = false,
  }) {
    Widget w = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(key, style: TextStyle(fontSize: 14, color: ResColor.white_60)),
        Container(
          height: centerpading,
        ),
        textem
            ? TextEm(value, style: TextStyle(fontSize: 14, color: ResColor.white))
            : Text(value, style: TextStyle(fontSize: 14, color: ResColor.white)),
      ],
    );
    return InkWell(
      onTap: clickCopy
          ? () {
              if (ClickUtil.isFastDoubleClick()) return;
              if (StringUtils.isNotEmpty(value)) {
                DeviceUtils.copyText(value);
                showToast(RSID.copied.text);
              }
            }
          : null,
      child: w,
    );
  }

  Widget getHeaderOwners() {
    PoolObj obj = widget.pool;

    List<Widget> items = [];

    items.add(
      Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Text(
          "Owners",
          style: TextStyle(fontSize: 16, color: ResColor.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
    items.add(Container(height: 10));

    List<Widget> owneritems = [];
    for (String ownerid in obj.Owners) {
      owneritems.add(buildOwnerItem(ownerid));
    }
    if (owneritems.length > 0) {
      items.addAll(owneritems);
    } else {}

    items.add(Container(height: 10));

    items.add(Row(
      children: [
        Expanded(
          child: LoadingButton(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
            padding: EdgeInsets.only(bottom: 1),
            height: 30,
            gradient_bg: ResColor.lg_1,
            color_bg: Colors.transparent,
            disabledColor: Colors.grey,
            bg_borderradius: BorderRadius.circular(4),
            text: RSID.npmv_1.text,
            //添加owner
            textstyle: TextStyle(
              color: Colors.white,
              fontSize: LocaleConfig.currentIsZh() ? 17 : 14,
            ),
            onclick: (lbtn) {
              onClickAddOwner();
            },
          ),
        ),
      ],
    ));

    Widget card = Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
      padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ResColor.b_5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    );

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          card,
        ],
      ),
    );
  }

  Widget buildOwnerItem(String ownerid) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ownerid,
                  style: TextStyle(
                    fontSize: 16,
                    color: ResColor.white,
                  ),
                ),
              ),
              LoadingButton(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                padding: EdgeInsets.only(bottom: 1),
                width: 80,
                height: 30,
                gradient_bg: ResColor.lg_7,
                color_bg: Colors.transparent,
                disabledColor: Colors.grey,
                bg_borderradius: BorderRadius.circular(4),
                text: RSID.npmv_2.text,
                //删除
                //赎回 apply withdraw
                textstyle: TextStyle(
                  color: Colors.white,
                  fontSize: LocaleConfig.currentIsZh() ? 17 : 14,
                ),
                onclick: (lbtn) {
                  onItemClickRemoveOwner(ownerid);
                },
              ),
            ],
          ),
          Divider(
            color: ResColor.white_30,
            height: 15,
            endIndent: 0,
            indent: 0,
            thickness: 1,
          ),
        ],
      ),
    );
  }

  Widget getHeaderMiners() {
    PoolObj obj = widget.pool;

    List<Widget> items = [];

    items.add(
      Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Text(
                "Nodes",
                style: TextStyle(fontSize: 16, color: ResColor.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (obj.Count > 0)
            LoadingButton(
              width: 100,
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              padding: EdgeInsets.only(bottom: 1),
              height: 30,
              gradient_bg: ResColor.lg_3,
              color_bg: Colors.transparent,
              bg_borderradius: BorderRadius.circular(4),
              text: RSID.npmv_8.text,
              //"节点变更",// "Node change",
              textstyle: TextStyle(
                color: Colors.white,
                fontSize: LocaleConfig.currentIsZh() ? 14 : 14,
              ),
              onclick: (lbtn) {
                onClickNodeChange();
              },
            ),
        ],
      ),
    );
    items.add(Container(height: 10));

    //Count            Actived       Available
    // xxxx            xxxx            xxxx
    items.add(
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: getColumnKeyValue(RSID.nodepool_node_count.text, obj?.Count?.toString() ?? "--",
                crossAxisAlignment: CrossAxisAlignment.start),
          ),
          Expanded(
            child: getColumnKeyValue(RSID.nodepool_node_actived.text, obj?.Actived?.toString() ?? "--",
                crossAxisAlignment: CrossAxisAlignment.center),
          ),
          Expanded(
            child: getColumnKeyValue(RSID.nodepool_node_available.text, obj?.Available?.toString() ?? "--",
                crossAxisAlignment: CrossAxisAlignment.end),
          ),
        ],
      ),
    );

    items.add(Container(height: 10));

    List<Widget> minerviews = [];
    for (PoolNodeState pns in nodeStateList) {
      minerviews.add(buildMinerItem(pns));
    }

    if (minerviews != null && minerviews.length > 0) {
      items.addAll(minerviews);
    }

    Widget card = Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
      padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ResColor.b_5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    );

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          card,
        ],
      ),
    );
  }

  Widget buildMinerItem(PoolNodeState pns) {
    String state = "";
    if (pns.locked) {
      state = RSID.nodepool_node_lock.text;
    } else if (pns.available) {
      state = RSID.nodepool_node_available.text;
    } else if (pns.actived) {
      state = RSID.nodepool_node_actived.text;
    }

    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pns.minerid,
                  style: TextStyle(
                    fontSize: 16,
                    color: ResColor.white,
                  ),
                ),
              ),
              Text(
                state,
                style: TextStyle(
                  fontSize: 16,
                  color: ResColor.white,
                ),
              ),
            ],
          ),
          Divider(
            color: ResColor.white_30,
            height: 15,
            endIndent: 0,
            indent: 0,
            thickness: 1,
          ),
        ],
      ),
    );
  }

  @override
  void clickAppBarBack() {
    finish(result);
  }

  onclickUpdate() {
    ViewGT.showView(context, NodePoolCreateView(pool: widget.pool)).then((value) {
      if (value == true) {
        setState(() {});
        result = true;
      }
    });
  }

  //  添加owner
  onClickAddOwner() {
    ViewGT.showView(
        context,
        NodePoolAddOwnerView(
          pool: widget.pool,
        )).then((value) {
      if (value == true) {
        setState(() {});
        result = true;
      }
    });
  }

  onItemClickRemoveOwner(String ownerid) {
    //删除owner
    BottomDialog.simpleAuth(context, AccountMgr().currentAccount.password, (value) async {
      showLoadDialog("", touchOutClose: false, backClose: false);

      HttpJsonRes hjr = await ApiPool.pool_removeOwner(OwnerID: ownerid);

      closeLoadDialog();

      if (hjr.code == 0) {
        setState(() {
          widget.pool.Owners.remove(ownerid);
        });
      } else {
        showToast(hjr.msg);
      }
    });
  }

  // 变更节点
  onClickNodeChange() {
    List<String> minerID = [];
    List<String> targetID = [];

    GlobalKey key_header = GlobalKey();
    Widget header = StatefulBuilder(
      key: key_header,
      builder: (context, setState) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: Text(
            RSID.npmv_3.text,//"提交需要转移质押的节点，节点用户会依据这些记录转移质押到新节点。",
            style: TextStyle(
              fontSize: 14,
              color: ResColor.white,
            ),
          ),
        );
      },
    );
    GlobalKey key_footer = GlobalKey();
    Widget footer = StatefulBuilder(
      key: key_footer,
      builder: (context, setState) {
        bool amountok = minerID.length > 0 && minerID.length == targetID.length;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(30, 10, 30, 0),
          child: Text(
            "${minerID.length}  /  ${targetID.length}",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              color: amountok ? ResColor.white : ResColor.r_1,
            ),
          ),
        );
      },
    );

    BottomDialog.showTextInputDialogMultiple(
      context: context,
      title: RSID.npmv_8.text,
      //"节点变更",
      autoChangeFocus: true,
      header: header,
      footer: footer,
      objlist: [
        TextInputConfigObj()
          ..oldText = ""
          ..hint = RSID.npmv_4.text//'输入原MinerID 多个用","分隔'
          ..inputFormatters = [FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z, ]+"))]
          ..keyboardType = TextInputType.emailAddress
          ..maxLength = 9999,
        TextInputConfigObj()
          ..oldText = ""
          ..hint = RSID.npmv_5.text//'输入新MinerID 多个用","分隔'
          ..inputFormatters = [FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z, ]+"))]
          ..keyboardType = TextInputType.emailAddress
          ..maxLength = 9999,
      ],
      onChangeCallback: (datas) {
        String s_data = datas[0];
        String t_data = datas[1];

        {
          List<String> _minerID = [];
          List<String> sList = s_data?.split(",") ?? [];
          sList.forEach((str) {
            if (RegExpUtil.re_epik_address.hasMatch(str?.trim() ?? "")) _minerID.add(str?.trim());
          });
          minerID = _minerID;
        }

        {
          List<String> _targetID = [];
          List<String> tList = t_data?.split(",") ?? [];
          tList.forEach((str) {
            if (RegExpUtil.re_epik_address.hasMatch(str?.trim() ?? "")) _targetID.add(str?.trim());
          });
          targetID = _targetID;
        }

        key_footer.currentState.setState(() {});
      },
      onOkClose: false,
      //点确定后不自动关闭dialog
      callback: (datas) {
        // 输入完成 判断数据 给提示 或关闭dialog
        if (minerID.length <= 0) {
          showToast(RSID.npmv_4.text);//'输入原MinerID 多个用","分隔');
          return;
        }
        if (targetID.length <= 0) {
          showToast(RSID.npmv_5.text);//'输入新MinerID 多个用","分隔');
          return;
        }
        if (minerID.length != targetID.length) {
          showToast(RSID.npmv_6.text);//"MinerID数量需要相同");
          return;
        }
        Navigator.pop(context);

        BottomDialog.simpleAuth(context, AccountMgr().currentAccount.password, (value) async {

          showLoadDialog("");

          List<NodeTransferObj> postdata = [];
          for (int i = 0; i < minerID.length; i++) {
            postdata.add(NodeTransferObj()
              ..MinerID = minerID[i]
              ..TargetID = targetID[i]);
          }

          ApiPool.pool_node_transfer(postdata).then((hjr){
            closeLoadDialog();
            if(hjr.code==0)
            {
              showToast(RSID.npmv_7.text);//"已提交");
            }else{
              showToast(hjr.msg);
            }
          });

        });

      },
    );
  }
}

class NodeTransferObj {
  String MinerID;
  String TargetID;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json["MinerID"] = MinerID;
    json["TargetID"] = TargetID;
    return json;
  }
}
