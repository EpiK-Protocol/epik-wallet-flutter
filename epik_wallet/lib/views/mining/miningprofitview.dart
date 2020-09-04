import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/logic/api/api_testnet.dart';
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

class MiningProfitView extends BaseWidget {
  String mining_id;

  MiningProfitView(this.mining_id);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _MiningProfitViewState();
  }
}

class _MiningProfitViewState extends BaseWidgetState<MiningProfitView> {
  List<MiningProfit> datalist = [];

  double erc20_epk = 0;
  double tepk = 0;

  @override
  void initStateConfig() {
    isTopBarShow = true; //状态栏是否显示
    isAppBarShow = true; //导航栏是否显示
    setAppBarTitle("预挖收益");
  }

  @override
  void onCreate() {
    super.onCreate();
    refresh();
  }

  bool isLoading = false;

  refresh() {
    isLoading = true;
    setLoadingWidgetVisible(true);
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
      closeStateLayout();
    } else {
      setErrorWidgetVisible(true);
    }
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
      headerList: ["1"],
      headerCreator: buildHeaderWidget,
      itemWidgetCreator: (context, position) {
        return GestureDetector(
          onTap: () => onItemClick(position),
          child: buildItemWidget(datalist[position], position),
        );
      },
      pullRefreshCallback: _pullRefreshCallback,
      needNoMoreTipe: false,
    );

    return listpage;
  }

  String amountFormat(double amount) {
    if (amount > 10000) {
      String ret = "${StringUtils.formatNumAmount(amount / 10000, point: 2)}w";
      return ret;
    }
    return StringUtils.formatNumAmount(amount, point: 0);
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
                            "挖出数量\ntEPK",
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
                            "奖励数量\nEPK-ERC20",
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

  Widget buildItemWidget(MiningProfit item, int index) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
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
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xff333333),
//                    color: Color(0xffAAAAAA),
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 5,
          ),
          Row(
            children: <Widget>[
              Container(
                width: 100,
                child: Text(
                  "tEPK",
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xff333333),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  StringUtils.formatNumAmount(item.tepk),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xff333333),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                width: 100,
                child: Text(
                  "EPK-ERC20",
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xff333333),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  StringUtils.formatNumAmount(item.erc20_epk),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xff333333),
                  ),
                ),
              ),
            ],
          ),
          Container(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
//              Container(
//                width: 100,
//                child: Text(
//                  "HASH",
//                  style: TextStyle(
//                    fontSize: 15,
////                    color: Color(0xff333333),
//                    color: Color(0xffAAAAAA),
//                  ),
//                ),
//              ),
              Expanded(
                child: Text(
                  item.hash,
//                  textAlign: TextAlign.end,
//                  maxLines: 1,
//                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
//                    color: Color(0xff333333),
                    color: Color(0xffAAAAAA),
                  ),
                ),
              ),
            ],
          ),
          Container(height: 14),
          Divider(
            height: 1,
            thickness: 1,
            color: Color(0xffeeeeee),
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
    HttpJsonRes httpjsonres = await ApiTestNet.getProfit(widget.mining_id);
    jsonCallback(httpjsonres);
  }
}
