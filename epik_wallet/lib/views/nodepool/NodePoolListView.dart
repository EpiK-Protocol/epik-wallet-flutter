import 'dart:async';
import 'dart:ui';

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/LocaleConfig.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_pool.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/nodepool/PoolObj.dart';
import 'package:epikwallet/utils/ClickUtil.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/nodepool/NodePoolCreateView.dart';
import 'package:epikwallet/views/nodepool/NodePoolManageView.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:epikwallet/widget/text/TextEllipsisMiddle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';

class NodePoolListView extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> getState() {
    return NodePoolListViewState();
  }
}

class NodePoolListViewState extends BaseWidgetState<NodePoolListView> with TickerProviderStateMixin {

  String epkname="AIEPK";

  List<PoolObj> data = [];
  PoolObj myCreatePoolObj = null;
  GlobalKey<ListPageState> key_scroll = GlobalKey();

  @override
  void initStateConfig() {
    super.initStateConfig();

    setTopBarVisible(false);
    isTopFloatWidgetShow = true;
    refresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(RSID.nodepool_title.text);
  }

  //商户
  bool inWhiteList = false;

  //加载状态
  bool isLoading = false;

  bool _showBottombar = false;
  int tickertime = 500;

  bool get showBottombar => _showBottombar;

  bool isFirst = true;

  set showBottombar(bool v) {
    _showBottombar = v;

    //todo test
    // _showBottombar=true;

    setState(() {});
    if (_showBottombar) {
      viewSystemUiOverlayStyle = DeviceUtils.system_bar_main.copyWith(systemNavigationBarColor: ResColor.b_4);
      DeviceUtils.setSystemBarStyle(viewSystemUiOverlayStyle);
    } else {
      viewSystemUiOverlayStyle = DeviceUtils.system_bar_light;
      DeviceUtils.setSystemBarStyle(viewSystemUiOverlayStyle);
    }
  }

  refresh({bool frompull}) async {
    if (frompull != true) setLoadingWidgetVisible(true);
    isLoading = true;

    PoolObj _myCreatePoolObj = null;

    //是否为矿商
    HttpJsonRes hjr_wl = await ApiPool.whiteList();
    inWhiteList = hjr_wl?.code == 0;
    // dlog("whiteList ${hjr_wl.code}  ${hjr_wl.msg}");

    //矿商列表
    HttpJsonRes hjr_list = await ApiPool.list();
    if (hjr_list.code == 0) {
      data = JsonArray.parseList(JsonArray.obj2List(hjr_list.jsonMap["Pools"]), (json) => PoolObj.fromJson(json));

      //查找自己的pool
      if (inWhiteList) {
        String myepikaddress = AccountMgr()?.currentAccount?.epik_EPK_address;
        for (PoolObj pool in data) {
          if (pool?.Creator == myepikaddress) {
            pool.myCreated = true;
            _myCreatePoolObj = pool;
          }
        }
      }
      myCreatePoolObj = _myCreatePoolObj;
      //自己创建的pool放到前面
      if (myCreatePoolObj != null) {
        data.remove(myCreatePoolObj);
        data.insert(0, myCreatePoolObj);
      }

      if (isFirst) {
        isFirst = false;
        Future.delayed(Duration(milliseconds: 200))
            .then((value) => showBottombar = inWhiteList && myCreatePoolObj == null);
      } else {
        showBottombar = inWhiteList && myCreatePoolObj == null;
      }

      closeStateLayout();
      isLoading = false;
    } else {
      myCreatePoolObj = _myCreatePoolObj;

      if (isFirst) {
        isFirst = false;
        Future.delayed(Duration(milliseconds: 200)).then((value) => showBottombar = false);
      } else {
        showBottombar = false;
      }

      setErrorWidgetVisible(true);
      isLoading = false;
    }
  }

  @override
  Widget getAppBar() {
    return Container(
      width: double.infinity,
      height: getTopBarHeight() + getAppBarHeight(),
      padding: EdgeInsets.fromLTRB(0, getTopBarHeight(), 0, 0),
      decoration: BoxDecoration(
        gradient: ResColor.lg_1,
      ),
      child: super.getAppBar(),
    );
  }

  @override
  Widget getTopFloatWidget() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: bottomBar(),
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: buildList(),
          ),
        ],
      ),
    );
  }

  Widget bottomBar() {
    Widget view = Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(30, 10, 30, 10 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: ResColor.b_4,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: LoadingButton(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              padding: EdgeInsets.only(bottom: 1),
              height: 40,
              gradient_bg: ResColor.lg_1,
              color_bg: Colors.transparent,
              disabledColor: Colors.transparent,
              bg_borderradius: BorderRadius.circular(4),
              text: RSID.nodepool_create.text,
              textstyle: TextStyle(
                color: Colors.white,
                fontSize: LocaleConfig.currentIsZh() ? 17 : 14,
                fontWeight: FontWeight.bold,
              ),
              onclick: (lbtn) {
                //  create
                onClickCreatePool();
              },
            ),
          ),
        ],
      ),
    );
    return AnimatedSizeAndFade(
      vsync: this,
      child: showBottombar ? view : Container(),
      fadeDuration: Duration(milliseconds: tickertime),
      sizeDuration: Duration(milliseconds: tickertime),
    );
  }

  Widget buildList() {
    Widget widget = new ListPage(
      data ?? [],
      headerList: [1],
      headerCreator: (context, position) {
        return Container(height: 10);
      },
      itemWidgetCreator: (context, position) {
        return itemWidgetBuild(context, position);
      },
      pullRefreshCallback: _pullRefreshCallback,
      // needLoadMore: needLoadMore,
      // onLoadMore: onLoadMore,
      key: key_scroll,
    );
    return widget;
  }

  Widget itemWidgetBuild(BuildContext context, int position) {
    PoolObj obj = data[position];

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
        InkWell(
          onTap: () {
            setState(() {
              obj.opendes = !obj.opendes;
            });
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            alignment: Alignment.topLeft,
            child: AnimatedSizeAndFade(
              vsync: this,
              child: obj?.opendes
                  ? Text(
                      obj?.Description ?? "--",
                      textAlign: TextAlign.start,
                      // maxLines: ,
                      // overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: ResColor.white),
                    )
                  : Text(
                      obj?.Description ?? "--",
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: ResColor.white),
                    ),
              fadeDuration: Duration(milliseconds: 200),
              sizeDuration: Duration(milliseconds: 200),
            ),
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
            child: getColumnKeyValue(RSID.nodepool_node_apy.text, obj?.apy_f ?? "--",
                crossAxisAlignment: CrossAxisAlignment.end),
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

    bool hasAvailable = obj.Available > 0 && obj.Enable == true;

    //todo test
    // obj.myCreated=true;
    // hasAvailable=true;

    items.add(Row(
      children: [
        Expanded(
          child: LoadingButton(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
            padding: EdgeInsets.only(bottom: 1),
            height: 30,
            gradient_bg:  hasAvailable ? ResColor.lg_2 :ResColor.lg_7,
            color_bg: Colors.transparent,
            bg_borderradius: BorderRadius.circular(4),
            text: RSID.nodepool_node_rent.text,
            //租赁
            textstyle: TextStyle(
              color: Colors.white,
              fontSize: LocaleConfig.currentIsZh() ? 17 : 14,
            ),
            onclick: hasAvailable
                ? (lbtn) {
                    onItemClickRent(obj);
                  }
                : null,
          ),
        ),
        if (obj.myCreated) Container(width: 20),
        if (obj.myCreated)
          Expanded(
            child: LoadingButton(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              padding: EdgeInsets.only(bottom: 1),
              height: 30,
              gradient_bg: ResColor.lg_1,
              color_bg: Colors.transparent,
              disabledColor: Colors.transparent,
              bg_borderradius: BorderRadius.circular(4),
              text: RSID.nodepool_node_manage.text,
              //租赁
              textstyle: TextStyle(
                color: Colors.white,
                fontSize: LocaleConfig.currentIsZh() ? 17 : 14,
              ),
              onclick: (lbtn) {
                // 管理自己的节点池
                onItemClickManage(obj);
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
          if (obj.myCreated)
            Positioned(
                top: 0,
                right: 25,
                child: Container(
                  padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                  decoration: BoxDecoration(
                    color: ResColor.blue_1,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    RSID.nodepool_node_own.text, //"Own",
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

  void onClickErrorWidget() {
    refresh();
  }

  void onClickEmptyWidget() {
    refresh();
  }

  Future<void> _pullRefreshCallback() async {
    if (isLoading) {
      return;
    }
    await refresh(frompull: true);
    return;
  }

  onClickCreatePool() {
    //  创建节点池
    ViewGT.showView(context, NodePoolCreateView()).then((value) {
      // 刷新列表
      if (value == true) {
        Future.delayed(Duration(milliseconds: 200)).then((value) {
          refresh();
        });
      }
    });
  }

  onItemClickRent(PoolObj pool) async {
    // 租节点
    dlog("click rent");

    showLoadDialog("");

    //先校验余额
    String epk_balance_str =
        await AccountMgr().currentAccount.epikWallet.balance(AccountMgr().currentAccount.epik_EPK_address);
    double epk_balance = StringUtils.parseDouble(epk_balance_str, 0);
    dlog("epk_balance = $epk_balance");
    if (epk_balance <= 1000) {
      showToast(RSID.nodepool_node_insufficient_epk.text);
      closeLoadDialog();
      return;
    }
    closeLoadDialog();

    if(isDestory)
      return;

    //密码确认
    BottomDialog.simpleAuth(context, AccountMgr().currentAccount.password, (value) async {

      showLoadDialog("");

      //网络请求 节点
      HttpJsonRes hjr = await ApiPool.createNode(PoolCreator: pool.Creator);

      closeLoadDialog();

      if (hjr.code == 0) {
        //获取到节点ID
        String MinerID = hjr.jsonMap["MinerID"];

        if (StringUtils.isEmpty(MinerID)) {
          showToast(RSID.request_error.text);
          return;
        }

        //自动复制NodeID
        DeviceUtils.copyText(MinerID);
        showToast("NodeID ${RSID.copied.text.toLowerCase()}");

        //dialog 提示现在质押 还是放弃
        MessageDialog.showMsgDialog(
          context,
          backClose: false,
          touchOutClose: false,
          msg: RSID.nodepool_node_locked.replace([MinerID]),
          btnLeft: RSID.nodepool_node_abort.text,
          //"舍弃",
          btnRight: RSID.nodepool_node_palde.text,
          //"立刻质押",
          onClickBtnLeft: (dialog) {
            //放弃 暂时不质押 可以后面手动自行操作
            dialog.dismiss();
          },
          onClickBtnRight: (dialog) {
            dialog.dismiss();
            // 输入框确认质押金额
            BottomDialog.showTextInputDialog(
              context,
              "${RSID.minerview2_7.text} $MinerID",
              "1000",
              "",
              999,
              (amount) {
                //网络请求 执行质押
                todoNodePalde(MinerID, amount: amount);
              },
              inputFormatters: [FilteringTextInputFormatter.allow(RegExpUtil.re_float)],
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            );
          },
        );

        //质押

      } else {
        showToast(hjr.msg);
      }
    }).then((value){
      dlog("simpleAuth value = $value");
      closeLoadDialog();
    });
  }

  //节点质押处理  密码确认 网络请求 弹窗提示
  todoNodePalde(String minerid, {String amount = "1000"}) {
    closeInput();

    BottomDialog.simpleAuth(context, AccountMgr().currentAccount.password, (value) async {
      showLoadDialog("", touchOutClose: false, backClose: false);

      ResultObj<String> robj = await AccountMgr().currentAccount.epikWallet.minerPledgeAdd(minerid, amount);

      closeLoadDialog();

      if (robj?.isSuccess) {
        String cid = robj.data; //bafy2bzaceaa4fwwhrn5oqjsxe5vumlibispulwdzf4uskh4silxlfo4qh6cu6
        setState(() {});

        MessageDialog.showMsgDialog(
          context,
          title: RSID.minerview_10.text,
          //"矿工基础抵押",
          msg: "${RSID.minerview_18.text}\n$cid",
          //交易已提交
          btnLeft: RSID.minerview_19.text,
          //"查看交易",
          btnRight: RSID.isee.text,
          onClickBtnLeft: (dialog) {
            dialog.dismiss();
            String url = ServiceInfo.epik_msg_web + cid;
            ViewGT.showGeneralWebView(context, RSID.berlv_4.text, url);
          },
          onClickBtnRight: (dialog) {
            dialog.dismiss();
          },
        );
      } else {
        showToast(robj?.errorMsg ?? RSID.request_failed.text);
      }
    });
  }

  onItemClickManage(PoolObj pool) {
    // 节点池管理
    dlog("click manage");

    ViewGT.showView(context, NodePoolManageView(pool)).then((value) {
      // 刷新列表
      if (value == true) {
        Future.delayed(Duration(milliseconds: 200)).then((value) {
          refresh();
        });
      }
    });
  }
}
