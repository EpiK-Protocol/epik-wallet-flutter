import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_testnet.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/model/MiningProfit.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

///testnet 预挖收益
class MiningProfitView extends BaseWidget {
  String mining_id;
  String title;

  MiningProfitView(this.mining_id,this.title);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _MiningProfitViewState();
  }
}

class _MiningProfitViewState extends BaseWidgetState<MiningProfitView> {
  ListPageDefState _ListPageDefState = ListPageDefState(null);
  List<MiningProfit> datalist = [];

  GlobalKey<ListPageState> key_scroll = GlobalKey();

  double total_supply = 0;
  double erc20_epk = 0;
  double tepk = 0;

  @override
  void initStateConfig() {
    isTopBarShow = false; //状态栏是否显示
    isAppBarShow = false; //导航栏是否显示
    isTopFloatWidgetShow = true;
    setBackIconHinde(isHinde: false);
//    setAppBarTitle("预挖收益");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(widget.title??ResString.get(context, RSID.mpv_1));
  }

  @override
  Widget getTopFloatWidget() {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.only(top: getTopBarHeight()),
        child: getAppBar(),
      ),
      onTap: onTapAppBar,
    );
  }

  onTapAppBar() {
    if (key_scroll != null && !isLoading) {
      key_scroll.currentState.scrollController.animateTo(0,
          duration: Duration(milliseconds: 200), curve: Curves.easeIn);
    }
  }

  @override
  void onCreate() {
    super.onCreate();
    refresh();
  }

  bool isLoading = false;

  refresh() {
    isLoading = true;
    // setLoadingWidgetVisible(true);
    setState(() {
      _ListPageDefState.type = ListPageDefStateType.LOADING;
    });
    requestTotal();
    ApiTestNet.getProfit(widget.mining_id).then((httpjsonres) {
      jsonCallback(httpjsonres);
    });
  }

  jsonCallback(HttpJsonRes httpjsonres) {
    isLoading = false;
    if (httpjsonres != null && httpjsonres.code == 0) {
      erc20_epk = StringUtils.parseDouble(httpjsonres.jsonMap["erc20_epk"], 0);
      tepk = StringUtils.parseDouble(httpjsonres.jsonMap["tepk"], 0);

      List<MiningProfit> temp = JsonArray.parseList<MiningProfit>(
          JsonArray.obj2List(httpjsonres.jsonMap["list"]),
          (json) => MiningProfit.fromJson(json));

      datalist = temp ?? [];

      if (datalist.length == 0) {
        _ListPageDefState.type = ListPageDefStateType.EMPTY;
      } else {
        _ListPageDefState.type = null;
      }

      closeStateLayout();
    } else {
      // setErrorWidgetVisible(true);
      _ListPageDefState.type = ListPageDefStateType.ERROR;
    }
  }

  requestTotal() async {

    HttpJsonRes httpjsonres = await ApiTestNet.home(
        AccountMgr()?.currentAccount?.hd_eth_address ?? "");

    if (httpjsonres != null && httpjsonres.code == 0) {
      // mining_id = httpjsonres.jsonMap["id"];
      // mining_weixin = httpjsonres.jsonMap["weixin"];
      // mining_platform = httpjsonres.jsonMap["platform"];
      // mining_status =httpjsonres.jsonMap["status"]; //等待审核pending/ 已经通过confirmed/ 拒绝reject
      // if (StringUtils.isEmpty(mining_platform))
      //   mining_platform = BingAccountPlatform.WEIXIN;
      // dlog("platform = $mining_platform");
      // AccountMgr()?.currentAccount?.mining_id = mining_id;
      // AccountMgr()?.currentAccount?.mining_bind_account = mining_weixin;
      // AccountMgr()?.currentAccount?.mining_account_platform = mining_platform;

      Map testnet = httpjsonres.jsonMap["testnet"];
      // total_supply = StringUtils.parseDouble(testnet["total_supply"], 0);
      double issuance = StringUtils.parseDouble(testnet["issuance"], 0);
      total_supply = issuance;

      // List<MiningRank> temp = JsonArray.parseList<MiningRank>(
      //     testnet["top_list"], (json) => MiningRank.fromJson(json));
      // datalist = temp ?? [];

      // if (datalist.length == 0) {
      //   headerList = [ListPageDefState(ListPageDefStateType.EMPTY)];
      // } else {
      //   headerList = [];
      // }
    }
    setState(() {
    });
  }

  @override
  void onClickErrorWidget() {
    super.onClickErrorWidget();
    refresh();
  }

  @override
  Widget buildWidget(BuildContext context) {
    Widget listpage = ListPage(
      datalist,
      headerList: ["header", _ListPageDefState],
      headerCreator: (context, position) {
        if (position == 0) {
          // return buildHeaderWidget(context, position);
          return Container(
            height: 20,
          );
        } else {
          return stateHeaderWidgetBuild(context, position);
        }
      },
      itemWidgetCreator: (context, position) {
        return GestureDetector(
          onTap: () => onItemClick(position),
          child: buildItemWidget(datalist[position], position),
        );
      },
      pullRefreshCallback: _pullRefreshCallback,
      needNoMoreTipe: false,
    );

    // return listpage;
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              top: getTopBarHeight() + getAppBarHeight() + 128,
              child: listpage),
          headerBuilder(context, 0),
        ],
      ),
    );
  }

  String amountFormat(double amount) {
    return StringUtils.formatNumAmountLocaleUnit(amount, appContext, point: 2);
  }

  Widget buildHeaderWidget(Object item, int position) {
    return Container(
      margin: EdgeInsets.only(top: 0),
      padding: EdgeInsets.all(15),
      height: 173,
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
              bottom: 0,
              child: Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            ResString.get(context, RSID.mpv_2), //"挖出数量\nEPK",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Container(height: 10),
                          Text(
                            amountFormat(tepk),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
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
                            ResString.get(context, RSID.mpv_3),
                            //"奖励数量\nERC20-EPK",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Container(height: 10),
                          Text(
                            amountFormat(erc20_epk),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
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
          ],
        ),
      ),
    );
  }

  double header_top = 0;

  Widget headerBuilder(BuildContext context, int position) {
    if (position == 0 /*&& bannerlist != null && bannerlist.length > 0*/) {
      if (header_top == 0) header_top = getTopBarHeight() + getAppBarHeight();
      double h_bg = header_top + 128;
      double h_btn = 40;
      return Container(
        padding: EdgeInsets.all(0),
        width: double.infinity,
        // color: Colors.white,
        height: h_bg + h_btn,
        child: Stack(
          children: [
            //背景内容
            Container(
              width: double.infinity,
              height: h_bg,
              padding: EdgeInsets.fromLTRB(30, header_top, 30, 0),
              decoration: BoxDecoration(
                gradient: ResColor.lg_1,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              // child: Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     DiffScaleText(
              //       text: balance,
              //       textStyle: TextStyle(
              //         color: Colors.white,
              //         fontSize: 35,
              //         fontFamily: "DIN_Condensed_Bold",
              //         height: 1,
              //       ),
              //     ),
              //     Text(
              //       "≈ \$${StringUtils.formatNumAmount(widget.currencyAsset.getUsdValue())}",
              //       style: TextStyle(
              //         color: ResColor.white_80,
              //         fontSize: 14,
              //         fontWeight:FontWeight.bold,
              //       ),
              //     ),
              //   ],
              // ),
              child: Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            // ResString.get(context, RSID.mpv_2), //"挖出数量\nEPK",
                            ResString.get(context, RSID.mpv_4), //"总奖励\nEPK",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Container(height: 10),
                          Text(
                            amountFormat(total_supply), //amountFormat(tepk),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
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
                        color: Colors.white60,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            ResString.get(context, RSID.mpv_3),
                            //"奖励数量\nERC20-EPK",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Container(height: 10),
                          Text(
                            amountFormat(erc20_epk),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
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
          ],
        ),
      );
    } else {
      return new Padding(
        padding: EdgeInsets.all(10.0),
        child: Text('$position -----header------- '),
      );
    }
  }

  Widget stateHeaderWidgetBuild(BuildContext context, int position) {
    try {
      return ListPageDefStateWidgetHeader.getWidgetHeader(_ListPageDefState);
    } catch (e) {
      print(e);
    }
    return Container();
  }

  Widget buildItemWidget(MiningProfit item, int index) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 25, 20, 0),
      color: ResColor.b_3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  DateUtil.formatDateMs(item.created_at_ms,
                      format: DataFormats.y_mo_d_h_m),
                  style: TextStyle(fontSize: 14, color: Colors.white60),
                ),
              ),
            ],
          ),
          Container(
            width: 20,
          ),
          Row(
            children: <Widget>[
              Container(
                width: 100,
                child: Text(
                  "EPK",
                  style: TextStyle(fontSize: 14, color: Colors.white60),
                ),
              ),
              Expanded(
                child: Text(
                  StringUtils.formatNumAmount(item.tepk),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: 20,
          ),
          Row(
            children: <Widget>[
              Container(
                width: 100,
                child: Text(
                  "ERC20-EPK",
                  style: TextStyle(fontSize: 14, color: Colors.white60),
                ),
              ),
              Expanded(
                child: Text(
                  StringUtils.formatNumAmount(item.erc20_epk),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: 20,
          ),
          if (StringUtils.isNotEmpty(item.hash))
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    item.hash,
                    style: TextStyle(fontSize: 14, color: Colors.white60),
                  ),
                ),
              ],
            ),
          Container(
            margin: EdgeInsets.only(top: 24),
            height: 1,
            color: ResColor.white_20,
          ),
        ],
      ),
    );
  }

  onItemClick(int position) {
    //todo
  }

  Future<void> _pullRefreshCallback() async {
    isLoading = true;
    requestTotal();
    HttpJsonRes httpjsonres = await ApiTestNet.getProfit(widget.mining_id);
    jsonCallback(httpjsonres);
  }
}
