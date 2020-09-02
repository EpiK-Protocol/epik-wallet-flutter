import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class MiningProfitView extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> getState() {
    return _MiningProfitViewState();
  }
}

class _MiningProfitViewState extends BaseWidgetState<MiningProfitView> {
  List<Object> datalist = [];

  @override
  void initStateConfig() {
    isTopBarShow = true; //状态栏是否显示
    isAppBarShow = true; //导航栏是否显示
    setAppBarTitle("预挖收益");

    for (int i = 0; i < 100; i++) {
      datalist.add(i);
    }
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

  Widget buildHeaderWidget(Object item, int position) {
    return Container(
      margin: EdgeInsets.only(top: 0),
      padding: EdgeInsets.all(15),
      height: 173,
      width: double.infinity,
      child: Card(
        color: Color(0xff10052f),
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
                            "挖出数量\nTEPK",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Container(height: 10),
                          Text(
                            "250W",
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
                            "奖励数量\nERC20-EPK",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Container(height: 10),
                          Text(
                            "55W",
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

  Widget buildItemWidget(Object item, int index) {
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
                  "2020-09-03 18:11",
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
                  "TEPK",
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xff333333),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  "123456.8901",
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
                  "ERC20-EPK",
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xff333333),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  "6543.0084",
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
                  "0x2cac6e4b11d6b58f6d3c1c9d5fe8faa89f60e5a2",
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
    // todo 刷新排行榜
    await Future.delayed(Duration(milliseconds: 1000));
  }
}
