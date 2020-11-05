import 'dart:async';

import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_bounty.dart';
import 'package:epikwallet/logic/loader/DL_TepkLoginToken.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/model/BountyTask.dart';
import 'package:epikwallet/model/BountyTaskUser.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/DashLineWidget.dart';
import 'package:epikwallet/widget/text/diff_scale_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class BountyDetailView extends BaseWidget {
  BountyTask bountyTask;

  BountyDetailView(this.bountyTask);

  BaseWidgetState<BaseWidget> getState() {
    return BountyDetailViewState();
  }
}

class BountyDetailViewState extends BaseWidgetState<BountyDetailView> {
  bool isAdmin = false;

  List<BountyTaskUser> userlist = [];

  String title="";// "任务详情";
  String title_2 = "";
  bool useTitle2 = false;
  double header_top = 0;
  ScrollController _ScrollController;

  @override
  void initStateConfig() {
    super.initStateConfig();
    if (widget.bountyTask.title.length > 16) {
      title_2 = widget.bountyTask.title.trim().substring(0, 16) + "…";
    } else {
      title_2 = widget.bountyTask.title;
    }

    _ScrollController = ScrollController();
    _ScrollController.addListener(() {
      if (header_top == 0) header_top = getAppBarHeight();
      bool _useTitle2 = _ScrollController.position.pixels >= header_top;
      if (_useTitle2 != useTitle2) {
        setState(() {
          useTitle2 = _useTitle2;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    title = ResString.get(context, RSID.bdv_1);//"任务详情";
  }

  ///导航栏appBar中间部分 ，不满足可以自行重写
  Widget getAppBarCenter({Color color}) {
    return Container(
      padding: EdgeInsets.only(left: 40, right: 40),
      alignment: Alignment.center,
      width: double.infinity,
      child: DiffScaleText(
        text: useTitle2 ? title_2 : title,
        textStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w400,
          fontFamily: fontFamily_def,
        ),
      ),
//      Text(
//        title,
//        textAlign: TextAlign.center,
//        softWrap: false,
//        overflow: TextOverflow.ellipsis,
//        style: TextStyle(
//          fontSize: 18,
//          color: Colors.black,
//        ),
//      ),
    );
  }

  @override
  void onCreate() {
    super.onCreate();
    eventMgr.add(EventTag.BOUNTY_EDITED_USER_LIST, eventcallback_edited);
    refresh();
  }

  @override
  void dispose() {
    closeRefreshCountdown();
    eventMgr.remove(EventTag.BOUNTY_EDITED_USER_LIST, eventcallback_edited);
    super.dispose();
  }

  eventcallback_edited(arg) async {
    userlist = BountyTaskUser.parseLinesData(widget.bountyTask.result);
    setState(() {});
  }

  refresh() {
    setLoadingWidgetVisible(true);
    ApiBounty.getBountyInfo(
            DL_TepkLoginToken.getEntity().getToken(), widget.bountyTask.id)
        .then((httpjsonres) async {
      if (httpjsonres != null && httpjsonres.code == 0) {
        Map<String, dynamic> j_record = httpjsonres.jsonMap["task"];
        if (j_record != null && j_record.length > 0) {
          widget.bountyTask.parseJson(j_record);
          userlist = BountyTaskUser.parseLinesData(widget.bountyTask.result);
          closeStateLayout();

          if (widget.bountyTask.status == BountyStateType.PUBLICITY &&
              widget.bountyTask.getCountdownTimeNum() > 0) {
            startRefreshCountdown();
          } else {
            closeRefreshCountdown();
          }
          return;
        }
      }
      setErrorWidgetVisible(true);
    });

    // 是否是管理员
    isAdmin =
        widget.bountyTask.admin == AccountMgr()?.currentAccount?.mining_id;
  }

  Timer timerCountdown;
  bool hasCountdownRefresh = false;

  startRefreshCountdown() {
    if (timerCountdown != null && timerCountdown.isActive) {
      timerCountdown.cancel();
    }
    if (widget.bountyTask.status == BountyStateType.PUBLICITY)
      timerCountdown = Timer.periodic(Duration(seconds: 1), (timer) {
        if (widget.bountyTask.getCountdownTimeNum() <= 0) {
          closeRefreshCountdown();
          if (hasCountdownRefresh == false) {
            hasCountdownRefresh = true;
            refresh();
          }
        } else {
          setState(() {});
        }
      });
  }

  closeRefreshCountdown() {
    if (timerCountdown != null && timerCountdown.isActive) {
      timerCountdown.cancel();
    }
    timerCountdown = null;
  }

  @override
  Widget buildWidget(BuildContext context) {
    List<Widget> views = [
      Padding(
        padding: EdgeInsets.fromLTRB(15, 6, 15, 10),
        child: Text(
          widget?.bountyTask?.title ?? "",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
        child: Text(
          "${ResString.get(context, RSID.bdv_2)} ${widget?.bountyTask?.reward}",//奖励区间
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
      getHtmlView(),
      Container(
        height: 30,
      ),
    ];

    if (userlist != null && userlist.length > 0) {
      views.add(
        // 虚线分割线
        Container(
          height: 10,
          alignment: Alignment.center,
          child: DashLineWidget(
            width: double.infinity,
            height: 1,
            dashWidth: 10,
            dashHeight: 0.5,
            spaceWidth: 5,
            color: ResColor.main_1,
            margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
          ),
        ),
      );

      views.add(
        Container(
          padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 2,
                width: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black26, Colors.transparent],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                ),
              ),
              Text(
                ResString.get(context, RSID.bdv_3),//" 奖励分配公示 ",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              Container(
                height: 2,
                width: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black26, Colors.transparent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      views.addAll(userlist.map((item) => getUserItem(item)).toList());
    }

    views.add(Container(height: 30));

    Widget w1 = SingleChildScrollView(
      controller: _ScrollController,
      padding: EdgeInsets.all(0),
      child: Container(
        constraints: BoxConstraints(
          minHeight: getScreenHeight() -
              BaseFuntion.topbarheight -
              BaseFuntion.appbarheight_def,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: views,
        ),
      ),
    );

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                bottom: 0,
                child: w1,
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0x10000000), Color(0x00000000)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Container(height: 10),

        Container(
          margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
          width: double.infinity,
          height: 40,
          child: FlatButton(
            highlightColor: Colors.white24,
            splashColor: Colors.white24,
            onPressed: () {
              // todo
            },
            child: Text(
    ResString.get(context, RSID.bdv_4)+"${widget?.bountyTask?.status.getName()} ${widget?.bountyTask?.getCountdownString()}",//任务状态
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            color: ResColor.main_1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
        ),

        Container(height: 10),
        // 联系方式
        getContactView(),

        Container(height: 10),
        //编辑
        if (isAdmin == true && widget.bountyTask.status != BountyStateType.END)
          Container(
            margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
            width: double.infinity,
            height: 40,
            child: FlatButton(
              highlightColor: Colors.white24,
              splashColor: Colors.white24,
              onPressed: () {
                ViewGT.showBountyEditView(context, widget?.bountyTask);
              },
              child: Text(
                ResString.get(context, RSID.bdv_5),//"编辑奖励",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              color: ResColor.main_1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ),
      ],
    );
  }

  Widget getHtmlView() {
    return HtmlWidget(
      widget?.bountyTask?.content ?? ResString.get(context, RSID.content_empty),//"无详情",
      webView: true,
      config: HtmlWidgetConfig(
        bodyPadding: const EdgeInsets.fromLTRB(15, 15, 15, 0), //内容边距
        textStyle: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Color(0xff666666),
        ), // 默认文本样式
        onTapUrl: (url) {
          if (StringUtils.isEmpty(url)) return;
          ViewGT.openOutUrl(url);
        },
//        builderCallback: (meta, e) {
//          if (e.localName == "a") {
//            String url = e.attributes["href"];
//            if (StringUtils.isNotEmpty(url) && !url.startsWith("http")) {
//              e.attributes["href"] = ServiceInfo.HOST + url;
//              print("builderCallback---href fix ->" + e.attributes["href"]);
//            }
//          }else if(e.localName == "img") {
//            String url = e.attributes["src"];
//            if (StringUtils.isNotEmpty(url) && !url.startsWith("http")) {
//              e.attributes["src"] = ServiceInfo.HOST + url;
//              print("builderCallback---href fix ->" + e.attributes["src"]);
//            }
//          }
//          return meta;
//        },
      ),
    );
  }

  Widget getContactView() {
    String text = "";
    switch (widget?.bountyTask?.status) {
      case BountyStateType.PUBLICITY:
        text =ResString.get(context, RSID.bdv_6);// "申诉方式: ";
        break;
      case BountyStateType.END:
        text =ResString.get(context, RSID.bdv_7);// "感谢方式: ";
        break;
      case BountyStateType.AVAILABLE:
      default:
        text = ResString.get(context, RSID.bdv_8);//"认领方式: ";
        break;
    }

    String wechat = widget?.bountyTask?.admin_weixin;
//    text += "联系负责人微信 " + wechat;
    text += ResString.get(context, RSID.bdv_9) +wechat;

    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
      width: double.infinity,
      height: 40,
      child: FlatButton(
        highlightColor: Colors.white24,
        splashColor: Colors.white24,
        onPressed: () {
          DeviceUtils.copyText(wechat);
          showToast(ResString.get(context, RSID.bdv_10));//"负责人微信已复制");
          ViewGT.openOutUrl("weixin://");
        },
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        color: ResColor.main_1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }

  Widget getUserItem(BountyTaskUser user) {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  user.userid,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                ResString.get(context, RSID.bdv_11,replace: [user.amount_str]),//"+ ${user.amount_str} 积分",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
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
}
