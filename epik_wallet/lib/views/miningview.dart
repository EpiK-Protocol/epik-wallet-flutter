import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_testnet.dart';
import 'package:epikwallet/model/MiningRank.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';

class MiningView extends BaseInnerWidget {
  MiningView(Key key) : super(key: key) {}

  @override
  BaseInnerWidgetState<BaseInnerWidget> getState() {
    return MiningViewState();
  }

  @override
  int setIndex() {
    return 1;
  }
}

class MiningViewState extends BaseInnerWidgetState<MiningView> {
  List headerList = [];
  List<MiningRank> datalist = [];
  GlobalKey<ListPageState> key_scroll;

  /// 总奖励
  double total_supply = 0;

  /// 已发放
  double issuance = 0;

  // 已报名才有ID
  String mining_id = "";

  //等待审核pending/ 已经通过confirmed/ 拒绝rejected
  String mining_status;

  @override
  void initState() {
    super.initState();
  }

  @override
  void initStateConfig() {
    setAppBarTitle("预挖排行");
    isTopBarShow = true; //状态栏是否显示
    isAppBarShow = true; //导航栏是否显示

    key_scroll = GlobalKey();
  }

  @override
  void onCreate() {
    eventMgr.add(EventTag.REFRESH_MININGVIEW, eventcallback_refresh);
    eventMgr.add(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventcallback_refresh);
    refresh();
  }

  @override
  void dispose() {
    eventMgr.remove(EventTag.REFRESH_MININGVIEW, eventcallback_refresh);
    eventMgr.remove(
        EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventcallback_refresh);

    super.dispose();
  }

  eventcallback_refresh(arg) {
    refresh();
  }

  bool hasRefresh = false;
  bool isLoading = false;

  refresh() {
    hasRefresh = true;

    isLoading = true;
    setLoadingWidgetVisible(true);

    String address = AccountMgr()?.currentAccount?.hd_eth_address ?? "";
    ApiTestNet.home(address).then((httpjsonres) => jsoncallback(httpjsonres));
  }

  jsoncallback(HttpJsonRes httpjsonres) {
    isLoading = false;
    if (httpjsonres != null && httpjsonres.code == 0) {
      mining_id = httpjsonres.jsonMap["id"];
      mining_status =
          httpjsonres.jsonMap["status"]; //等待审核pending/ 已经通过confirmed/ 拒绝reject

      Map testnet = httpjsonres.jsonMap["testnet"];
      total_supply = StringUtils.parseDouble(testnet["total_supply"], 0);
      issuance = StringUtils.parseDouble(testnet["issuance"], 0);

      List<MiningRank> temp = JsonArray.parseList<MiningRank>(
          testnet["top_list"], (json) => MiningRank.fromJson(json));
      datalist = temp ?? [];

      if(datalist.length==0)
      {
        headerList=[ListPageDefState(ListPageDefStateType.EMPTY)];
      }else{
        headerList=[];
      }

      closeStateLayout();
    } else {
      setErrorWidgetVisible(true);
    }
  }

  @override
  void onClickErrorWidget() {
    refresh();
//    ViewGT.showMiningSignupView(context);
  }

  String amountFormat(double amount) {
    if (amount > 10000) {
      String ret = "${StringUtils.formatNumAmount(amount / 10000, point: 2)}w";
      return ret;
    }
    return StringUtils.formatNumAmount(amount, point: 0);
  }

  @override
  Widget buildWidget(BuildContext context) {
    Widget listpage = ListPage(
      datalist,
      headerList: headerList,
      headerCreator: stateHeaderWidgetBuild,
      itemWidgetCreator: (context, position) {
        return GestureDetector(
          onTap: () => onItemClick(position),
          child: getRankItem(datalist[position], position),
        );
      },
      pullRefreshCallback: _pullRefreshCallback,
      key: key_scroll,
      needNoMoreTipe: false,
    );

    return Column(children: [
      getHeader(),
      Expanded(
        child: listpage,
      ),
    ]);

//    return SingleChildScrollView(
//      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
//      physics: AlwaysScrollableScrollPhysics(),
//      child: Container(
//        child: Column(
//          children: list,
//        ),
//      ),
//    );
  }

  Widget getHeader() {
    return Container(
      margin: EdgeInsets.only(top: 0),
      padding: EdgeInsets.all(15),
      height: 223,
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
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                color: Colors.black26,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 140,
              //173
              child: Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "预挖总奖励",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          Container(height: 10),
                          Text(
                            amountFormat(total_supply),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontFamily: "DIN_Condensed_Bold",
                            ),
                          ),
                          Text(
                            "ERC20-EPK",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontFamily: "DIN_Condensed_Bold",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "已发放奖励",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          Container(height: 10),
                          Text(
                            amountFormat(issuance),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontFamily: "DIN_Condensed_Bold",
                            ),
                          ),
                          Text(
                            "ERC20-EPK",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontFamily: "DIN_Condensed_Bold",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            getActionBtn(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: InkWell(
                onTap: () {
                  DeviceUtils.copyText(mining_id);
                  showToast("已复制ID");
                },
                child: Container(
                  height: 20,
                  child: Text(
                    (StringUtils.isEmpty(mining_id))?"":"ID: ${mining_id}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double rankitem_t_w = 100;

  Widget getRankItem(MiningRank data, int index) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 50,
            padding: EdgeInsets.fromLTRB(0, 2, 0, 0),
            child: Text(
              (index + 1).toString() + ".",
              style: TextStyle(
                color: index < 3 ? Colors.black : Colors.black45,
                fontSize: 20,
                fontFamily: "DIN_Condensed_Bold",
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Text(
                        "累计奖励: ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      StringUtils.formatNumAmount(data?.profit ?? "0",
                          point: 2),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                        child: Text(
                          "ERC20-EPK",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
//                    Container(
//                      child: Text(
//                        "UUID",
//                        style: TextStyle(
//                          fontSize: 12,
//                          color: Colors.black87,
//                        ),
//                      ),
//                      width: rankitem_t_w,
//                    ),
                    Expanded(
                      child: Text(
                        "ID: " + (data?.id ?? "----"),
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
//                Row(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    Container(
//                      child: Text(
//                        "tEPK",
//                        style: TextStyle(
//                          fontSize: 12,
//                          color: Colors.black87,
//                        ),
//                      ),
//                      width: rankitem_t_w,
//                    ),
//                    Expanded(
//                      child: Text(
//                        data?.epik_address ?? "----",
//                        softWrap: false,
//                        maxLines: 1,
//                        overflow: TextOverflow.fade,
//                        style: TextStyle(
//                          fontSize: 12,
//                          color: Colors.black87,
//                        ),
//                      ),
//                    ),
//                  ],
//                ),
//                Row(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    Container(
//                      child: Text(
//                        "ERC20-EPK",
//                        style: TextStyle(
//                          fontSize: 12,
//                          color: Colors.black87,
//                        ),
//                      ),
//                      width: rankitem_t_w,
//                    ),
//                    Expanded(
//                      child: Text(
//                        data?.erc20_address ?? "----",
//                        softWrap: false,
//                        maxLines: 1,
//                        overflow: TextOverflow.fade,
//                        style: TextStyle(
//                          fontSize: 12,
//                          color: Colors.black87,
//                        ),
//                      ),
//                    ),
//                  ],
//                ),
                Container(height: 14),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xffeeeeee),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getActionBtn() {
    String text = "报名";
    bool canClick = true;

    switch (mining_status) {
      //等待审核
      case "pending":
        {
          text = "审核中";
          canClick = false;
          break;
        }
      case "confirmed":
        {
          text = "预挖奖励";
          canClick = true;
          break;
        }
      case "rejected":
        {
          text = "报名已被拒绝";
          canClick = false;
          break;
        }
      default:
        {
          text = "报名";
          canClick = true;
          break;
        }
    }

    if (canClick) {
      return Positioned(
        left: 90,
        right: 90,
        bottom: 20,
        child: FlatButton(
          highlightColor: Colors.white24,
          splashColor: Colors.white24,
          onPressed: () {
            onClickAction();
          },
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          color: Color(0xff393E45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
        ),
      );
    } else {
      return Positioned(
        left: 15,
        right: 15,
        bottom: 33,
        child: Container(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
  }

  onItemClick(position) {
    //todo
  }

  onClickAction() {
    if (AccountMgr().currentAccount == null) {
      //没账号 切换到钱包页面
      eventMgr.send(EventTag.CHANGE_MAINVIEW_INDEX, 1);
      return;
    }

    switch (mining_status) {
      case "confirmed":
        {
          // 预挖奖励
          ViewGT.showMiningProfitView(context, mining_id);
          return;
        }
      default:
        {
          // 报名
          ViewGT.showMiningSignupView(context);
          return;
        }
    }
  }

  Widget stateHeaderWidgetBuild(BuildContext context, int position) {
    try {
      if (headerList != null && headerList.length > 0) {
        var obj = headerList[0];
        if (obj is ListPageDefState) {
          ListPageDefState state = obj;
          return ListPageDefStateWidgetHeader.getWidgetHeader(state);
        }
      }
    } catch (e) {
      print(e);
    }
    return Container();
  }

  Future<void> _pullRefreshCallback() async {
    isLoading = true;
    String address = AccountMgr()?.currentAccount?.hd_eth_address ?? "";
    HttpJsonRes httpjsonres = await ApiTestNet.home(address);
    jsoncallback(httpjsonres);
  }
}
