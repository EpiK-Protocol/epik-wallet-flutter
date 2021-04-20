import 'package:cached_network_image/cached_network_image.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/logic/api/api_dapp.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/model/Dapp.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/epk_exchange/DappBountyItem.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/views/wallet/create/createwalletview.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

///赏金猎人领取epk
class BountyDappListView extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> getState() {
    return BountyDappListViewState();
  }
}

class BountyDappListViewState extends BaseWidgetState<BountyDappListView> {
  List<Dapp> list_dapp = [];

  @override
  void initStateConfig() {
    super.initStateConfig();
    resizeToAvoidBottomPadding = true;
    refresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle("赏金猎人奖励");
  }


  refresh() async {
    setLoadingWidgetVisible(true);

    HttpJsonRes hjr_info = await ApiDapp.dappList();
    if (hjr_info?.code == 0) {
      list_dapp = JsonArray.parseList(
              JsonArray.obj2List(hjr_info.jsonMap["list"]),
              (json) => Dapp.createInCache(json)) ??
          [];
    } else {
      //请求错误
      setErrorWidgetVisible(true);
      return;
    }

    if (list_dapp.length == 0) {
      // 无数据
      setEmptyWidgetVisible(true);
      return;
    }


    closeStateLayout();
  }

  @override
  void onClickErrorWidget() {
    refresh();
  }

  @override
  void onClickEmptyWidget() {
    refresh();
  }

  @override
  Widget buildWidget(BuildContext context) {
    List<Widget> items = [
      Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Text(
          "领取须知",
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 14,
              fontFamily: fontFamily_def,
            ),
            children: [
              TextSpan(
                text: "赏金猎人奖励所需的EPK有EpiK知识基金提供。领取过程中，需要您提供",
              ),
              TextSpan(
                text: "Dapp", //"知识大陆",
                style: TextStyle(
                  color: Colors.blue,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    // ViewGT.openOutUrl("https://www.epikg.com/");
                  },
              ),
              TextSpan(
                text:
                    "提供的领取令牌，领取金额有最小限额，只有余额大于最小限额才能领取。领取后您在知识大陆的EPK余额会减少，您领取的EPK将自动转入您当前的EpiK钱包。",
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Text(
          "风险提示",
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 14,
              fontFamily: fontFamily_def,
            ),
            children: [
              TextSpan(
                text: "请确保您没有泄露当前钱包助记词和私钥，否则强烈建议",
              ),
              TextSpan(
                text: "创建新钱包",
                style: TextStyle(
                  color: Colors.blue,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    ViewGT.showView(context, CreateWalletView(),
                        model: ViewPushModel.PushReplacement);
                  },
              ),
              TextSpan(
                text: "，在新钱包中进行领取。",
              ),
            ],
          ),
        ),
      ),
    ];

    list_dapp.forEach((dapp) {
      items.add(buildDappCard(dapp));
    });

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: Container(
        constraints: BoxConstraints(
          minHeight: getScreenHeight() -
              BaseFuntion.topbarheight -
              BaseFuntion.appbarheight_def,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items,
        ),
      ),
    );
  }


  Widget buildDappCard(Dapp dapp) {
   return DappBountyItem(dapp);
  }
}
