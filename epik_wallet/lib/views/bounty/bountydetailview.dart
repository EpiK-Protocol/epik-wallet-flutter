import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_bounty.dart';
import 'package:epikwallet/logic/loader/DL_TepkLoginToken.dart';
import 'package:epikwallet/model/BountyTask.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/DashLineWidget.dart';
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

  @override
  void initStateConfig() {
    super.initStateConfig();
    setAppBarTitle("");
  }

  @override
  void onCreate() {
    super.onCreate();
    refresh();
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
          closeStateLayout();
          return;
        }
      }
      setErrorWidgetVisible(true);
    });

    // 是否是管理员
    isAdmin =
        widget.bountyTask.admin == AccountMgr()?.currentAccount?.mining_id;
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
          "奖励区间: ${widget?.bountyTask?.reward}",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
      ),

      getHtmlView(),

      // 虚线分割线
      Container(
        height: 30,
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

      Container(
        margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
        width: double.infinity,
        height: 40,
        child: FlatButton(
          highlightColor: Colors.white24,
          splashColor: Colors.white24,
          onPressed: () {
            // todo
          },
          child: Text(
            "任务状态: ${widget?.bountyTask?.status.getName()}",
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

      // 联系方式
      getContactView(),

      //编辑
      if (isAdmin == true && widget.bountyTask.status != BountyStateType.END)
        Container(
          margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
          width: double.infinity,
          height: 40,
          child: FlatButton(
            highlightColor: Colors.white24,
            splashColor: Colors.white24,
            onPressed: () {
              ViewGT.showBountyEditView(context, widget?.bountyTask);
            },
            child: Text(
              "编辑奖励",
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

      Container(height: 30),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(0),
      child: ConstrainedBox(
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
  }

  Widget getHtmlView() {
    return HtmlWidget(
      widget?.bountyTask?.content ?? "无详情",
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
        text = "申诉方式: ";
        break;
      case BountyStateType.END:
        text = "感谢方式: ";
        break;
      case BountyStateType.AVAILABLE:
      default:
        text = "认领方式: ";
        break;
    }

    String wechat = widget?.bountyTask?.admin_weixin;
    text += "联系负责人微信 " + wechat;

    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
      width: double.infinity,
      height: 40,
      child: FlatButton(
        highlightColor: Colors.white24,
        splashColor: Colors.white24,
        onPressed: () {
          DeviceUtils.copyText(wechat);
          showToast("负责人微信已复制");
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
}
