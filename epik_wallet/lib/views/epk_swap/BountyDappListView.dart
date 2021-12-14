import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/api/api_dapp.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/model/Dapp.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/views/epk_swap/DappBountyItem.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/views/wallet/create/createwalletview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

///赏金猎人领取epk
class BountyDappListView extends BaseWidget {

  String title;

  BountyDappListView(this.title);

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
    navigationColor = ResColor.b_2;
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);
    resizeToAvoidBottomPadding = true;
    isTopFloatWidgetShow=true;
    refresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // setAppBarTitle(RSID.bdlv_1.text);//"赏金猎人奖励");
    setAppBarTitle(widget.title??RSID.bdlv_1.text);
  }


  @override
  Widget getTopFloatWidget() {
    return  Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: getTopBarHeight()),
      child: getAppBar(),
    );
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
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: Text(
          RSID.bdlv_2.text,//"领取须知",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20, 11, 20, 11),
        decoration: BoxDecoration(
          color: ResColor.warning_bg,
              borderRadius:BorderRadius.circular(4),
        ),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              color: ResColor.warning_text,
              fontSize: 14,
              fontFamily: fontFamily_def,
            ),
            children: [
              TextSpan(
                text: RSID.bdlv_3_1.text,//"赏金猎人奖励所需的EPK有EpiK知识基金提供。领取过程中，需要您提供",
              ),
              TextSpan(
                text: " Dapp ", //Dapp "知识大陆",  Third Party App
                style: TextStyle(
                  color: Colors.white,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    // ViewGT.openOutUrl("https://www.epikg.com/");
                  },
              ),
              TextSpan(
                text:RSID.bdlv_3_2.text,
                    //"提供的领取令牌，领取金额有最小限额，只有余额大于最小限额才能领取。领取后您在知识大陆的EPK余额会减少，您领取的EPK将自动转入您当前的EpiK钱包。",
              ),
            ],
          ),
        ),
      ),
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(0, 31, 0, 20),

        child: Text(
          RSID.bdlv_4.text,//"风险提示",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20, 11, 20, 11),
        decoration: BoxDecoration(
          color: ResColor.warning_bg,
          borderRadius:BorderRadius.circular(4),
        ),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              color: ResColor.warning_text,
              fontSize: 14,
              fontFamily: fontFamily_def,
            ),
            children: [
              TextSpan(
                text:RSID.bdlv_5_1.text,// "请确保您没有泄露当前钱包助记词和私钥，否则强烈建议",
              ),
              TextSpan(
                text:RSID.bdlv_5_2.text,// " 创建新钱包 ",
                style: TextStyle(
                  color: Colors.white,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    ViewGT.showView(context, CreateWalletView(),
                        model: ViewPushModel.PushReplacement);
                  },
              ),
              TextSpan(
                text:RSID.bdlv_5_3.text,// "，在新钱包中进行领取。",
              ),
            ],
          ),
        ),
      ),
    ];

    List<Widget> listitems = [];
    listitems.add(Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(30, 40, 30, 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ResColor.b_3,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    ));
    list_dapp.forEach((dapp) {
      listitems.add(buildDappCard(dapp));
    });

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // header card
          Container(
            width: double.infinity,
            height: getAppBarHeight() + getTopBarHeight() + 128,
            padding: EdgeInsets.only(top: getTopBarHeight()),
            decoration: BoxDecoration(
              gradient: ResColor.lg_1,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // getAppBar(),
              ],
            ),
          ),
          Positioned(
              left: 0,
              right: 0,
              top: getAppBarHeight() + getTopBarHeight(),
              bottom: 0,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: listitems,
                ),
              )),
        ],
      ),
    );

  }

  Widget buildDappCard(Dapp dapp) {
    return DappBountyItem(dapp);
  }
}
