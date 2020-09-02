import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

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
  List<Object> datalist = [];
  GlobalKey<ListPageState> key_scroll;


  @override
  void initState() {
    super.initState();
  }

  @override
  void initStateConfig() {
    setAppBarTitle("预挖排行");
    isTopBarShow = true; //状态栏是否显示
    isAppBarShow = true; //导航栏是否显示

    key_scroll= GlobalKey();

    for (int i = 0; i < 100; i++) {
      datalist.add(i);
    }
  }

  @override
  Widget buildWidget(BuildContext context) {


    Widget listpage = ListPage(
      datalist,
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


    return Column(
      children: [
        getHeader(),
        Expanded(
          child: listpage,
        ),
      ]
    );

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
              height: 153,//173
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
                            "已发放奖励",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
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
            getActionBtn(),
          ],
        ),
      ),
    );
  }

  double rankitem_t_w = 100;

  Widget getRankItem(Object data, int index) {
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
                color: index<3 ? Colors.black: Colors.black45,
                fontSize: 20,
                fontFamily: "DIN_Condensed_Bold",
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      child: Text(
                        "微信号",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      width: rankitem_t_w,
                    ),
                    Expanded(
                      child: Text(
                        "Wechat1234",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(
                      child: Text(
                        "TEPK",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      width: rankitem_t_w,
                    ),
                    Expanded(
                      child: Text(
                        "xxxxxxx",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(
                      child: Text(
                        "EPK-ERC20",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      width: rankitem_t_w,
                    ),
                    Expanded(
                      child: Text(
                        "xxxxxxxx",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
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
          ),
        ],
      ),
    );
  }

  Widget getActionBtn() {
    return Positioned(
      left: 90,
      right: 90,
      bottom: 10,
      child: FlatButton(
        highlightColor: Colors.white24,
        splashColor: Colors.white24,
        onPressed: () {
          onClickAction();
        },
        child: Text(
          "报名",
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
  }

  onItemClick(position) {
    //todo
  }

  onClickAction()
  {
    // 报名 、 审核中 、
//    ViewGT.showMiningSignupView(context);

    // 预挖奖励
    ViewGT.showMiningProfitView(context);
  }

  Future<void> _pullRefreshCallback() async{
    // todo 刷新排行榜
    await Future.delayed(Duration(milliseconds: 1000));
  }
}
