import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/abi/ERC20.g.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_wallet.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/logic/loader/DL_TepkLoginToken.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/model/CurrencyAsset.dart';
import 'package:epikwallet/model/EpikErc20SwapConfig.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/ClickUtil.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/sp_utils/sp_utils.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/views/wallet/create/createwalletview.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/text/TextEllipsisMiddle.dart';
import 'package:epikwallet/widget/text/diff_scale_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

enum Erc2EpkStep {
  swap,
  confirm_swap,
  complete,
}

extension Erc2EpkStepEx on Erc2EpkStep {
  String get name {
    switch (this) {
      case Erc2EpkStep.swap:
        // return "发起兑换";
        return RSID.eev_2.text;
      case Erc2EpkStep.confirm_swap:
        // return "确认交易";
        return RSID.eev_3.text;
      case Erc2EpkStep.complete:
        // return "完成";
        return RSID.eev_4.text;
    }
  }
}

///erc20兑换epk
class Erc20ToEpkView extends BaseWidget {
  String title;

  Erc20ToEpkView(this.title);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return Erc20ToEpkViewState();
  }
}

class Erc20ToEpkViewState extends BaseWidgetState<Erc20ToEpkView>
    with TickerProviderStateMixin {
  final int tickertiem = 500;

  Erc2EpkStep current_step = Erc2EpkStep.swap;

  TextEditingController _tec_amount;
  String amount_text = "";
  double amount = 0;

  // 销毁erc20的交易记录
  ResultObj hdwallet_result;
  ResultObj epikwallet_result;

  @override
  void initStateConfig() {
    super.initStateConfig();
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);
    resizeToAvoidBottomPadding = true;
    refresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(widget.title??RSID.main_wv_7.text); //"ERC20-EPK兑换EPK");
  }

  static String getLocalTxHash_Erc20epk() {
    return SpUtils.getString(
        "eev-txhash-${AccountMgr()?.currentAccount?.epik_EPK_address
            ?.hashCode ?? ""}",
        defValue: "");
  }

  static setLocalTxHash_Erc20epk(String txHash) {
    SpUtils.putString(
        "eev-txhash-${AccountMgr()?.currentAccount?.epik_EPK_address
            ?.hashCode ?? ""}",
        txHash ?? "");
  }

  static String getLocalTxHash_epk() {
    return SpUtils.getString(
        "eev-cid-${AccountMgr()?.currentAccount?.epik_EPK_address?.hashCode ??
            ""}",
        defValue: "");
  }

  static setLocalTxHash_epk(String cid) {
    SpUtils.putString(
        "eev-cid-${AccountMgr()?.currentAccount?.epik_EPK_address?.hashCode ??
            ""}",
        cid ?? "");
  }

  bool isFristRefresh = true;

  EpikErc20SwapConfig config;

  // true  erc20->epik   ; false epik->erc20
  bool is2Epik = true;

  refresh() async {
    if (isFristRefresh) {
      isFristRefresh = false;
      setLoadingWidgetVisible(true);
    } else {
      showLoadDialog("", touchOutClose: false, backClose: false);
    }

    if (config == null) {
      config = await ApiWallet.getSwapConfig();
    }
    if (config == null) {
      closeLoadDialog();
      setErrorWidgetVisible(true);
      return;
    }

    if (!DL_TepkLoginToken.getEntity().hasToken()) {
      await DL_TepkLoginToken.getEntity().refreshData(false);
      if (!DL_TepkLoginToken.getEntity().hasToken()) {
        closeLoadDialog();
        setErrorWidgetVisible(true);
        return;
      }
    }

    Erc2EpkStep temp_step = Erc2EpkStep.swap;

    //刷新钱包余额
    EpikWalletUtils.requestBalance(AccountMgr().currentAccount).then((value) {
      if (mounted && isDestory != true) setState(() {});
    });

    String txhash = getLocalTxHash_Erc20epk();
    dlog("erc20_txhash = $txhash");
    String cid = getLocalTxHash_epk();
    dlog("epik_cid = $cid");

    if (StringUtils.isNotEmpty(txhash)) {
      //本地有销毁记录
      //查询销毁结果
      // ResultObj result = await AccountMgr()?.currentAccount?.hdwallet?.receipt(txhash);
      ResultObj  result = null;
      try{
        TransactionReceipt tr = await EpikWalletUtils.ethClient.getTransactionReceipt(txhash);
        result = ResultObj();
        if(tr!=null)
        {
          result.code=0;
          result.data=tr.status==true?"success":"";
        }
      }catch(e)
      {
        print(e);
        result = ResultObj.fromError(e);
      }
      dlog("erc20_receipt = ${result?.data}");
      hdwallet_result = result;
      if (hdwallet_result?.code == 0) {
        // test
        // hdwallet_result.data="failed";
        // hdwallet_result.data = "pending";
        //交易记录查询成功
        is2Epik = true;
        if (hdwallet_result.data == "success") {
          temp_step = Erc2EpkStep.complete;
        } else {
          temp_step = Erc2EpkStep.confirm_swap;
        }
      }
    } else if (StringUtils.isNotEmpty(cid)) {
      //本地有销毁记录
      //查询销毁结果
      ResultObj result =
      await AccountMgr()?.currentAccount?.epikWallet?.messageReceipt(cid);
      dlog("epik_receipt = ${result?.data}");
      epikwallet_result = result;
      if (epikwallet_result?.code == 0) {
        // test
        // epikwallet_result.data="failed";
        // epikwallet_result.data = "pending";
        //交易记录查询成功
        is2Epik = false;
        if (epikwallet_result.data == "success") {
          temp_step = Erc2EpkStep.complete;
        } else {
          temp_step = Erc2EpkStep.confirm_swap;
        }
      }
    }

    //设置步骤
    current_step = temp_step;

    closeStateLayout();
    closeLoadDialog();
  }

  @override
  void onClickErrorWidget() {
    refresh();
  }

  ///导航栏appBar中间部分 ，不满足可以自行重写
  Widget getAppBarRight({Color color}) {
    return InkWell(
      onTap: () {
        ViewGT.showErc20ToEpkRecordView(context);
      },
      child: Text(
        RSID.eev_1.text, //"兑换记录",
        style: TextStyle(
          fontSize: 15,
          color: color ?? appBarContentColor,
        ),
      ),
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    List<Widget> items = [
      Padding(
        padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: Text(
          RSID.eev_5.text,//"兑换须知",
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
        color: ResColor.warning_bg,
        child: Text(
          // "此次兑换所需的EPK有EpiK基金会提供。兑换过程中，需要您发起一笔以太坊交易，所以请确保您当前账户内有足够的以太坊支付此笔交易的手续费。兑换后，您当前以太坊钱包中的所有ERC20-EPK将会销毁，并按照1:1的比例兑换得到EPK，这些EPK将自动转入您当前EpiK钱包。",
          RSID.eev_6.text,
          style: TextStyle(
            color: ResColor.warning_text,
            fontSize: 14,
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: Text(
          //"风险提示",
          RSID.eev_7.text,
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
        color: ResColor.warning_bg,
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              color: ResColor.warning_text,
              fontSize: 14,
              fontFamily: fontFamily_def,
            ),
            children: [
              TextSpan(
                // text: "为避免您之前参与挖矿活动有意或者无意的泄露过当前钱包的助记词或私钥，强烈建议",
                text:RSID.eev_8_1.text,
              ),
              TextSpan(
                // text: "创建新钱包",
                text:RSID.eev_8_2.text,
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
                // text: "，将ERC20-EPK转入全新的钱包后，再进行兑换。",
                text:RSID.eev_8_3.text,
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: Text(
          RSID.eev_9.text,//"免责声明",
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
        color: ResColor.warning_bg,
        child: Text(
          // "如您通过其他渠道自行销毁了ERC20-EPK导致无法正常兑换EPK，EpiK基金会将不予赔偿",
          RSID.eev_10.text,
          style: TextStyle(
            color: ResColor.warning_text,
            fontSize: 14,
          ),
        ),
      ),
      Container(
        margin: EdgeInsets.only(top: 30, bottom: 10),
        alignment: Alignment.centerLeft,
        child: Text(
          "From",
          style: TextStyle(
            fontSize: 17,
            color: ResColor.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      AnimatedSizeAndFade(
        vsync: this,
        child: is2Epik ? getErc20EpkCard() : getEpkCard(),
        fadeDuration: Duration(milliseconds: tickertiem),
        sizeDuration: Duration(milliseconds: tickertiem),
      ),
      InkWell(
        onTap: () {
          if (current_step != Erc2EpkStep.swap) return;
          if (!ClickUtil.isFastDoubleClickT(tickertiem + 100)) {
            is2Epik = !is2Epik;

            amount = 0;
            amount_text = "";
            _tec_amount = null;

            setLocalTxHash_epk(null);
            setLocalTxHash_Erc20epk(null);
            hdwallet_result = null;
            epikwallet_result = null;

            setState(() {});
          }
        },
        child: Container(
          padding: EdgeInsets.all(10),
          child: current_step == Erc2EpkStep.swap
              ? Image.asset("assets/img/ic_swap_2.png", width: 35, height: 35)
              : ClipOval(
            child: ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(colors: [
                  ResColor.white_90,
                  ResColor.black_90,
                ]).createShader(bounds);
              },
              child: Image.asset("assets/img/ic_swap_2.png",
                  width: 35, height: 35),
              blendMode: BlendMode.hue, //BlendMode.saturation, //灰度模式
            ),
          ),
        ),
      ),
      Container(
        margin: EdgeInsets.only(top: 0, bottom: 0),
        alignment: Alignment.centerLeft,
        child: Text(
          "To",
          style: TextStyle(
            fontSize: 17,
            color: ResColor.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      AnimatedSizeAndFade(
        vsync: this,
        child: is2Epik ? getEpkCard() : getErc20EpkCard(),
        fadeDuration: Duration(milliseconds: tickertiem),
        sizeDuration: Duration(milliseconds: tickertiem),
      ),
      getSteps(),
    ];

    Widget child = SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(0),
      child: Container(
        constraints: BoxConstraints(
          minHeight: getScreenHeight() -
              BaseFuntion.topbarheight -
              BaseFuntion.appbarheight_def,
        ),
        child: Column(children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(30, 40, 30, 30),
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            decoration: BoxDecoration(
              color: ResColor.b_3,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: Column(
              children: items,
            ),
          ),
        ]),
      ),
    );

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
                getAppBar(),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: getAppBarHeight() + getTopBarHeight(),
            bottom: 0,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget getErc20EpkCard() {
    String balance = "0.0";
    String address = AccountMgr()?.currentAccount?.hd_eth_address ?? "";

    CurrencyAsset ca = AccountMgr()
        ?.currentAccount
        ?.getCurrencyAssetByCs(CurrencySymbol.EPKerc20);
    if (ca != null) balance = ca.balance;

    // balance = "999598150.037303903730390373039"; //todo test

    return Container(
      key: ValueKey("erc20"),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      // padding: EdgeInsets.all(15),
      width: double.infinity,
      height: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                width: 30,
                height: 30,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Image(
                        image: AssetImage(ca.cs.iconUrl),
                        width: 30,
                        height: 30,
                      ),
                    ),
                    Positioned(
                      right: -1.5,
                      bottom: -1.5,
                      child: Container(
                          width: 15,
                          height: 15,
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color:
                            const Color(0xff202020), //Colors.white,
                            borderRadius:
                            BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Image(
                            image: AssetImage(ca.networkType.iconUrl),
                            width: 13,
                            height: 13,
                          )),
                    ),
                  ],
                ),
              ),
              Text(
                ca.symbol,
                style: TextStyle(
                    color: ResColor.white,
                    fontSize: 14, //17,
                    fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(
                  // balance,
                  StringUtils.isNotEmpty(balance)
                      ? StringUtils.formatNumAmount(balance,
                      point: 8, supply0: false)
                      : "--",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14, //17,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Container(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Text(
                  RSID.eev_11.text,//"地址:",
                  style: TextStyle(
                    color: ResColor.white_60,
                    fontSize: 11,
                    // fontFamily: "DIN_Condensed_Bold",
                  ),
                ),
              ),
              Expanded(
                child: TextEm(
                  address,
                  style: TextStyle(
                    color: ResColor.white_60,
                    fontSize: 11,
                    // fontFamily: "DIN_Condensed_Bold",
                    // height: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getEpkCard() {
    String balance = "0.0";
    String address = AccountMgr()?.currentAccount?.epik_EPK_address ?? "";

    CurrencyAsset ca =
    AccountMgr()?.currentAccount?.getCurrencyAssetByCs(CurrencySymbol.EPK);
    if (ca != null) balance = ca.balance;

    // balance = "999598150.2350130746327";//todo test

    return Container(
      key: ValueKey("epik"),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      // padding: EdgeInsets.all(15),
      width: double.infinity,
      height: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                width: 30,
                height: 30,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Image(
                        image: AssetImage(ca.cs.iconUrl),
                        width: 30,
                        height: 30,
                      ),
                    ),
                    Positioned(
                      right: -1.5,
                      bottom: -1.5,
                      child: Container(
                          width: 15,
                          height: 15,
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color:
                            const Color(0xff202020), //Colors.white,
                            borderRadius:
                            BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Image(
                            image: AssetImage(ca.networkType.iconUrl),
                            width: 13,
                            height: 13,
                          )),
                    ),
                  ],
                ),
              ),
              Text(
                ca.symbol,
                style: TextStyle(
                    color: ResColor.white,
                    fontSize: 14, //17,
                    fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(
                  // balance,
                  StringUtils.isNotEmpty(balance)
                      ? StringUtils.formatNumAmount(balance,
                      point: 8, supply0: false)
                      : "--",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14, //17,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Container(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Text(
                  RSID.eev_11.text,//"地址:",
                  style: TextStyle(
                    color: ResColor.white_60,
                    fontSize: 11,
                    // fontFamily: "DIN_Condensed_Bold",
                  ),
                ),
              ),
              Expanded(
                child: TextEm(
                  address,
                  style: TextStyle(
                    color: ResColor.white_60,
                    fontSize: 11,
                    // fontFamily: "DIN_Condensed_Bold",
                    // height: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getSubType(String text1,
      {String text2, Key key, double text2PadingTop = 0, double paddingbottom=20}) {
    return Container(
      key: key,
      margin: EdgeInsets.fromLTRB(0, 0, 0, paddingbottom),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 14,
            color: ResColor.o_1,
            margin: EdgeInsets.fromLTRB(0, 0, 6, 0),
          ),
          Text(
            text1,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            // child: Text(
            //   text ?? "",
            //   style: TextStyle(
            //     fontSize: 14,
            //     color: Colors.white,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            child: text2 == null
                ? Container()
                : Padding(
              padding: EdgeInsets.only(top: text2PadingTop),
              child: DiffScaleText(
                text: text2 ?? "",
                textStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getSteps() {
    List<Widget> items = [];

    items.add(getStepProgress());

    // 具体步骤
    items.add(getStep());

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: items,
    );
  }

  Widget getStepProgress() {
    // ---- (  ) ----
    //  15   30   15

    // wrapitms.add(Text(
    //   "${i + 1}.${step.name}",
    //   style: TextStyle(
    //     fontSize: 14,
    //     color: current_step == step ? Colors.green : Colors.black,
    //     fontWeight: current_step == step ? FontWeight.bold : null,
    //   ),
    // ));
    // if (i < steps.length - 1) {
    //   wrapitms.add(Container(
    //     margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
    //     color: Colors.black,
    //     width: 10,
    //     height: 1,
    //   ));
    // }

    List<Widget> items = [];

    List<Erc2EpkStep> steps = Erc2EpkStep.values.toList();
    int currentIndex = steps.indexOf(current_step);
    for (int i = 0; i < steps.length; i++) {
      Erc2EpkStep step = steps[i];
      bool isFirst = i == 0;
      bool isLast = i >= steps.length - 1;
      bool isCurrent = current_step == step;

      Widget getLine() {
        return Container(
          width: double.infinity,
          height: 1,
          color: (isCurrent || i <= currentIndex) ? ResColor.o_1 : Colors.white,
        );
      }

      items.add(
        Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: isFirst ? Container() : getLine()),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: isCurrent
                          ? BoxDecoration(
                        color: ResColor.o_1,
                        borderRadius: BorderRadius.circular(30),
                      )
                          : BoxDecoration(
                        color: ResColor.b_3,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.fromBorderSide(BorderSide(
                          width: 1,
                          color:
                          i <= currentIndex ? ResColor.o_1 : Colors.white,
                        )),
                      ),
                      child: Center(
                        child: Text(
                          "${i + 1}",
                          style: TextStyle(
                            color: i < currentIndex ? ResColor.o_1 : Colors
                                .white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: isLast ? Container() : getLine()),
                  ],
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Text(
                    "${step.name}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: isCurrent ? ResColor.o_1 : Colors.white,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight
                          .normal,
                    ),
                  ),
                ),
              ],
            )),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18, 30, 18, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    );
  }

  Widget getStep() {
    switch (current_step) {
      case Erc2EpkStep.swap:
        return getStep_swap();
      case Erc2EpkStep.confirm_swap:
        return is2Epik ? getStep_confirm_2epk() : getStep_confirm_2erc20();
      case Erc2EpkStep.complete:
        return getStep_complete();
    }
    return Container();
  }

  /// 发起销毁
  Widget getStep_swap() {
    if (_tec_amount == null)
      _tec_amount = new TextEditingController.fromValue(TextEditingValue(
        text: amount_text,
        selection: new TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream, offset: amount_text.length),
        ),
      ));

    Widget input = Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 55,
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                          height: 55,
                          child: TextField(
                            controller: _tec_amount,
                            keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                            maxLines: 1,
                            obscureText: false,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExpUtil.re_float)
                            ],
                            // 这里限制长度 不会有数量提示
                            decoration: InputDecoration(
                              // 以下属性可用来去除TextField的边框
                              border: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.fromLTRB(0, -10, 0, 0),
                              // hintText: ResString.get(context, RSID.bexv_5),
                              //"请输入兑换数量",
                              hintStyle:
                              TextStyle(color: ResColor.white_60, fontSize: 17),
                              labelText: RSID.eev_12.text,//"兑换数量",
                              labelStyle:
                              TextStyle(color: ResColor.white, fontSize: 17),
                            ),
                            cursorWidth: 2.0,
                            //光标宽度
                            cursorRadius: Radius.circular(2),
                            //光标圆角弧度
                            cursorColor: Colors.white,
                            //光标颜色
                            style: TextStyle(fontSize: 17, color: Colors.white),
                            onChanged: (value) {
                              amount_text = _tec_amount.text.trim();
                              amount = StringUtils.parseDouble(amount_text, 0);
                              dlog("amount_text=$amount_text----amount=$amount");
                            },
                          ),
                        )),
                    // max
                    LoadingButton(
                      height: 20,
                      width: 40,
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      // gradient_bg: ResColor.lg_1,
                      color_bg: Colors.transparent,
                      disabledColor: Colors.transparent,
                      side: BorderSide(width: 1, color: ResColor.o_1),
                      bg_borderradius: BorderRadius.circular(4),
                      text: RSID.main_bv_4.text,
                      //"全部",
                      textstyle: const TextStyle(
                        color: ResColor.o_1,
                        fontSize: 11,
                      ),
                      loading: false,
                      onclick: (lbtn) {
                        String balance = "0";

                        CurrencyAsset ca = AccountMgr()
                            ?.currentAccount
                            ?.getCurrencyAssetByCs(is2Epik
                            ? CurrencySymbol.EPKerc20
                            : CurrencySymbol.EPK);
                        if (ca != null) balance = ca.balance;

                        // _tec_erc20.text=balance;
                        _tec_amount = null;
                        amount_text = balance;
                        amount = StringUtils.parseDouble(amount_text, 0);
                        dlog("amount_text=$amount_text----amount=$amount");

                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              // Divider(
              //   height: 0.5,
              //   thickness: 0.5,
              //   color: ResColor.main,
              // ),
            ],
          ),
        ),
      ],
    );

    Widget items = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        getSubType(RSID.eev_13.text,//"兑换为",
            text2: is2Epik ? "EPK" : "ERC20-EPK", text2PadingTop: 4,paddingbottom: 2),
        Container(
          margin: EdgeInsets.only(left: 10,right: 10,bottom: 20),
          width: double.infinity,
          child: Text(
            is2Epik ? RSID.eev_37.text : RSID.eev_38.text,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: ResColor.white_60,
              fontSize: 12,
            ),
          ),
        ),
        input,
        Divider(
          color: ResColor.white_20,
          height: 1,
          thickness: 1,
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                //最少兑换
                "${RSID.eev_14.text} ${StringUtils.formatNumAmount(
                    (is2Epik ? config?.min_erc20_swap : config
                        ?.min_epik_swap) ?? "0", point: 8, supply0: false)}",
                style: const TextStyle(
                  fontSize: 14,
                  color: ResColor.white_60,
                ),
              ),
              Text(
                //最多兑换
                "${RSID.eev_15.text} ${StringUtils.formatNumAmount(
                    (is2Epik ? config?.max_erc20_swap : config
                        ?.max_epik_swap) ?? "0", point: 8, supply0: false)}",
                style: const TextStyle(
                  fontSize: 14,
                  color: ResColor.white_60,
                ),
              ),
              Text(
                //手续费
                "${RSID.eev_16.text} ${(is2Epik ? config?.erc20_fee : config?.epik_fee) ??
                    "0"} ${is2Epik ? "ERC20-EPK" : "EPK"}",
                style: const TextStyle(
                  fontSize: 14,
                  color: ResColor.white_60,
                ),
              ),
            ],
          ),
        ),
        LoadingButton(
          height: 40,
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
          gradient_bg: ResColor.lg_1,
          color_bg: Colors.transparent,
          disabledColor: Colors.transparent,
          progress_color: Colors.white,
          progress_size: 20,
          padding: EdgeInsets.all(0),
          bg_borderradius: BorderRadius.circular(4),
          text: Erc2EpkStep.swap.name,
          textstyle: const TextStyle(
            color: ResColor.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          loading: false,
          onclick: (lbtn) {
            if (is2Epik) {
              // erc20-epk转账到销毁地址
              onClickErc20ToEpk();
            } else {
              // epik转账到销毁地址
              onClickEpkToErc20();
            }
          },
        ),
        AnimatedSizeAndFade(
          vsync: this,
          fadeDuration: Duration(milliseconds: tickertiem),
          sizeDuration: Duration(milliseconds: tickertiem),
          child: is2Epik
              ? InkWell(
            key: ValueKey("rp_er2ep"),
            child: Container(
              width: double.infinity,
              height: 20,
              child: Text(
                RSID.eev_17.text,//"已转出交易补领EPK",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            onTap: () {
              //  导入之前销毁记录的tx  进入下一步
              onClickReplacementErc20ToEpk();
            },
          )
              : InkWell(
            key: ValueKey("rp_ep2er"),
            child: Container(
              width: double.infinity,
              height: 20,
              child: Text(
                RSID.eev_18.text,//"已转出交易补领ERC20-EPK",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            onTap: () {
              //  导入之前销毁记录的tx  进入下一步
              onClickReplacementEpkToERC20();
            },
          ),
        ),
      ],
    );

    return Container(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
      // padding: EdgeInsets.all(15),
      width: double.infinity,
      child: items,
    );
  }

  ///等待确认 erc20->epk
  Widget getStep_confirm_2epk() {
    String txhash = getLocalTxHash_Erc20epk();

    List<Widget> items = [];
    switch (hdwallet_result.data) {
    // case "success":
    //   {}
    //   break;
      case "error":
      case "failed":
        {
          //failed交易失败
          items.add(getSubType(RSID.eev_19.text));//"交易失败"));
          items.add(Row(
            children: [
              Expanded(
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    DeviceUtils.copyText(txhash);
                    showToast(RSID.eev_20.text);//"TxHash已复制");
                  },
                  child: TextEm(
                    "$txhash",
                    style: TextStyle(
                      fontSize: 11,
                      color: ResColor.white_60,
                    ),
                  ),
                ),
              ),
              Container(
                width: 30,
              ),
              InkWell(
                child: Text(
                 RSID.minerview_19.text,// "查看交易",
                  style: TextStyle(
                    fontSize: 11,
                    color: ResColor.o_1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  lookEthTxhash(txhash);
                },
              ),
            ],
          ));

          items.add(LoadingButton(
            margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
            height: 40,
            gradient_bg: ResColor.lg_1,
            color_bg: Colors.transparent,
            disabledColor: Colors.transparent,
            progress_color: Colors.white,
            progress_size: 20,
            padding: EdgeInsets.all(0),
            bg_borderradius: BorderRadius.circular(4),
            text: RSID.eev_21.text,//"发起新的兑换",
            textstyle: const TextStyle(
              color: ResColor.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            loading: false,
            onclick: (lbtn) {
              setLocalTxHash_Erc20epk(null);
              setLocalTxHash_epk(null);
              hdwallet_result = null;
              epikwallet_result = null;
              current_step = Erc2EpkStep.swap;
              setState(() {});
            },
          ));
        }
        break;
      case "pending":
        {
          //pending交易等待中
          items.add(getSubType(RSID.eev_22.text));//"等待交易确认"));
          items.add(Row(
            children: [
              Expanded(
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    DeviceUtils.copyText(txhash);
                    showToast(RSID.eev_20.text);//"TxHash已复制");
                  },
                  child: TextEm(
                    "$txhash",
                    style: TextStyle(
                      fontSize: 11,
                      color: ResColor.white_60,
                    ),
                  ),
                ),
              ),
              Container(
                width: 30,
              ),
              InkWell(
                child: Text(
                  RSID.minerview_19.text,//"查看交易",
                  style: TextStyle(
                    fontSize: 11,
                    color: ResColor.o_1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  lookEthTxhash(txhash);
                },
              ),
            ],
          ));
          items.add(Container(
            height: 10,
          ));
          items.add(RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: fontFamily_def,
              ),
              children: [
                TextSpan(
                  text: RSID.eev_23_1.text,//"如长时间不上链可以",
                  style: TextStyle(
                    fontSize: 11,
                    color: ResColor.white,
                  ),
                ),
                TextSpan(
                  text: RSID.eev_23_2.text,//"加速交易",
                  style: TextStyle(
                    fontSize: 11,
                    color: ResColor.o_1,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      onClickAccelerateTx(txhash);
                    },
                ),
              ],
            ),
          ));

          items.add(LoadingButton(
            margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
            height: 40,
            color_bg: const Color(0xff424242),
            disabledColor: ResColor.main,
            progress_color: Colors.white,
            progress_size: 20,
            padding: EdgeInsets.all(0),
            bg_borderradius: BorderRadius.circular(4),
            text: RSID.eev_24.text,//"刷新",
            textstyle: const TextStyle(
              color: ResColor.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            loading: false,
            onclick: (lbtn) {
              refresh();
            },
          ));
        }
        break;
    }

    return Container(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
      // padding: EdgeInsets.all(15),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ),
    );
  }

  ///等待确认 epk->erc20
  Widget getStep_confirm_2erc20() {
    String cid = getLocalTxHash_epk();

    List<Widget> items = [];
    switch (epikwallet_result.data) {
    // case "success":
    //   {}
    //   break;
      case "error":
      case "failed":
        {
          //failed交易失败
          items.add(getSubType(RSID.eev_19.text));//"交易失败"));
          items.add(Row(
            children: [
              Expanded(
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    DeviceUtils.copyText(cid);
                    showToast(RSID.eev_25.text);//"cid已复制");
                  },
                  child: TextEm(
                    "$cid",
                    style: TextStyle(
                      fontSize: 11,
                      color: ResColor.white_60,
                    ),
                  ),
                ),
              ),
              Container(
                width: 30,
              ),
              InkWell(
                child: Text(
                  RSID.minerview_19.text,//"查看交易",
                  style: TextStyle(
                    fontSize: 11,
                    color: ResColor.o_1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  lookEpkCid(cid);
                },
              ),
            ],
          ));

          items.add(LoadingButton(
            margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
            height: 40,
            gradient_bg: ResColor.lg_1,
            color_bg: Colors.transparent,
            disabledColor: Colors.transparent,
            progress_color: Colors.white,
            progress_size: 20,
            padding: EdgeInsets.all(0),
            bg_borderradius: BorderRadius.circular(4),
            text: RSID.eev_21.text,//"发起新的兑换",
            textstyle: const TextStyle(
              color: ResColor.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            loading: false,
            onclick: (lbtn) {
              setLocalTxHash_Erc20epk(null);
              setLocalTxHash_epk(null);
              hdwallet_result = null;
              epikwallet_result = null;
              current_step = Erc2EpkStep.swap;
              setState(() {});
            },
          ));
        }
        break;
      case "pending":
        {
          //pending交易等待中
          items.add(getSubType(RSID.eev_22.text));//"等待交易确认"));
          items.add(Row(
            children: [
              Expanded(
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    DeviceUtils.copyText(cid);
                    showToast(RSID.eev_25.text);//"cid已复制");
                  },
                  child: TextEm(
                    "$cid",
                    style: TextStyle(
                      fontSize: 11,
                      color: ResColor.white_60,
                    ),
                  ),
                ),
              ),
              Container(
                width: 30,
              ),
              InkWell(
                child: Text(
                  RSID.minerview_19.text,//"查看交易",
                  style: TextStyle(
                    fontSize: 11,
                    color: ResColor.o_1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  lookEpkCid(cid);
                },
              ),
            ],
          ));

          items.add(LoadingButton(
            margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
            height: 40,
            color_bg: const Color(0xff424242),
            disabledColor: ResColor.main,
            progress_color: Colors.white,
            progress_size: 20,
            padding: EdgeInsets.all(0),
            bg_borderradius: BorderRadius.circular(4),
            text: RSID.eev_24.text,//"刷新",
            textstyle: const TextStyle(
              color: ResColor.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            loading: false,
            onclick: (lbtn) {
              refresh();
            },
          ));
        }
        break;
    }

    return Container(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
      // padding: EdgeInsets.all(15),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ),
    );
  }

  ///完成
  Widget getStep_complete() {
    List<Widget> items = [];
    //成功
    items.add(getSubType(RSID.eev_26.text));//"兑换完成"));

    //"请在兑换记录中查看到账情况",
    items.add(Row(
      children: [
        Expanded(
          child:  RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 11,
                color: ResColor.white_60,
              ),
              children: [
                TextSpan(
                  text:RSID.eev_27_1.text,// "请在",
                ),
                TextSpan(
                  text: RSID.eev_27_2.text,//"兑换记录",
                  style: TextStyle(
                    fontSize: 11,
                    color: ResColor.white,
                    decoration: TextDecoration.underline, //下滑线
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = (){
                      ViewGT.showErc20ToEpkRecordView(context);
                    },
                ),
                TextSpan(
                  text: RSID.eev_27_3.text,//"中查看到账情况",
                ),
              ],
            ),
          ),
        ),
      ],
    ));

    items.add(LoadingButton(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
      height: 40,
      gradient_bg: ResColor.lg_1,
      color_bg: Colors.transparent,
      disabledColor: Colors.transparent,
      progress_color: Colors.white,
      progress_size: 20,
      padding: EdgeInsets.all(0),
      bg_borderradius: BorderRadius.circular(4),
      text: RSID.eev_21.text,//"发起新的兑换",
      textstyle: const TextStyle(
        color: ResColor.white,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
      loading: false,
      onclick: (lbtn) {
        setLocalTxHash_Erc20epk(null);
        setLocalTxHash_epk(null);
        hdwallet_result = null;
        epikwallet_result = null;
        current_step = Erc2EpkStep.swap;
        setState(() {});
      },
    ));

    return Container(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
      // padding: EdgeInsets.all(15),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ),
    );
  }

  ///查看eth交易
  lookEthTxhash(String txhash) {
    String url = ServiceInfo.ether_tx_web + txhash;
    ViewGT.showGeneralWebView(
      context,
      RSID.usolv_3.text, //"详情",
      url,
    );
  }

  ///查看epik交易
  lookEpkCid(String cid) {
    String url = ServiceInfo.epik_msg_web + cid; // 需要epk浏览器地址
    ViewGT.showGeneralWebView(
      context,
      RSID.usolv_3.text, //"详情",
      url,
    );
  }

  /// hd钱包加速交易
  onClickAccelerateTx(String txhash) {
    BottomDialog.showEthAccelerateTx(
      context,
      AccountMgr().currentAccount,
      CurrencySymbol.EPKerc20,
      txhash,
      callback: (newTxHash) async{
        if (StringUtils.isNotEmpty(newTxHash)) {
          await Future.delayed(Duration(milliseconds: 200));
          showLoadDialog("");

          setLocalTxHash_Erc20epk(newTxHash);
          setLocalTxHash_epk(null);
          // hdwallet_result = null;

          //加速后新的txhash上报给服务
          HttpJsonRes hjr = await ApiWallet.swap2EPIK(
              AccountMgr().currentAccount,
              DL_TepkLoginToken.getEntity().getToken(),
              newTxHash);

          if (hjr?.code == 0) {
            closeLoadDialog();
            await Future.delayed(Duration(milliseconds: 100));
            refresh();
            return;
          }else{
            closeLoadDialog();
            showToast(StringUtils.isNotEmpty(hjr?.msg) ? hjr?.msg : RSID.eev_31.text);//"提交失败");
            return;
          }
        }
      },
    );
  }

  /// erc20-epk转账到空地址销毁
  onClickErc20ToEpk() {
    dlog("amount=$amount");
    if (amount < config.min_erc20_swap || amount > config.max_erc20_swap) {
      showToast(
      // 兑换数量限制
          "${RSID.eev_28.text} ${StringUtils.formatNumAmount(
              config.min_erc20_swap, point: 8, supply0: false)} - ${StringUtils
              .formatNumAmount(
              config.max_erc20_swap, point: 8, supply0: false)}");
      return;
    }

    BottomDialog.showPassWordInputDialog(
        context, AccountMgr()?.currentAccount?.password, (password) {
      //点击确定回调
      showLoadDialog(
        "",
        touchOutClose: false,
        backClose: false,
        onShow: () async {
          String from_address = AccountMgr()?.currentAccount?.hd_eth_address;
          String to_address = config.erc20_address;
          // ResultObj<String> result = await AccountMgr()
          //     .currentAccount
          //     .hdwallet
          //     .transferToken(from_address, to_address,
          //     CurrencySymbol.EPKerc20.symbolToNetWork, amount_text);

          ResultObj<String> result=ResultObj();
          try{
            ERC20 erc20 =AccountMgr().currentAccount.hdTokenMap[CurrencySymbol.EPKerc20];
            BigInt decimals = await erc20.decimals();//获取token的精度
            // BigInt value = BigInt.from((amount*pow(10, decimals.toInt())).toDouble());
            BigInt value = StringUtils.numUpsizingBigint(amount_text,bit: decimals.toInt());
            dlog("value = $value");
            String tx = await erc20.transfer(EthereumAddress.fromHex(to_address), value, credentials:AccountMgr().currentAccount.credentials);

            result.code=0;
            result.data=tx;
          }catch(e){
            print(e);
            result=ResultObj.fromError(e);
          }


          if (result?.code != 0 || StringUtils.isEmpty(result?.data)) {
            closeLoadDialog();
            String err = "";
            if (StringUtils.isNotEmpty(result.errorMsg)) {
              err = "ERROR: ${result.errorMsg}";
            } else {
              err = RSID.request_failed.text; //"转账失败");
            }
            MessageDialog.showMsgDialog(
              context,
              title: RSID.tip.text,
              msg: err,
              btnLeft: RSID.confirm.text,
              onClickBtnLeft: (dialog) {
                dialog.dismiss();
              },
            );
            return;
          }

          dlog("doWithdraw_hd result=${result?.data}");

          // 提取txhash 进入下一步

          String tx = result?.data;
          setLocalTxHash_Erc20epk(tx);
          setLocalTxHash_epk(null);

          amount = 0;
          amount_text = "";
          _tec_amount = null;

          //刷新钱包余额
          EpikWalletUtils.requestBalance(AccountMgr().currentAccount)
              .then((value) {
            setState(() {});
          });

          HttpJsonRes hjr = await ApiWallet.swap2EPIK(
              AccountMgr().currentAccount,
              DL_TepkLoginToken.getEntity().getToken(),
              tx);

          closeLoadDialog();

          if (hjr?.code == 0) {
            MessageDialog.showMsgDialog(
              context,
              title: RSID.tip.text,
              msg:RSID.eev_29.text,// "兑换已提交",
              btnLeft: RSID.confirm.text,
              onClickBtnLeft: (dialog) {
                dialog.dismiss();
              },
              onDismiss: (dialog) {
                Future.delayed(Duration(milliseconds: 200)).then((value) {
                  refresh();
                });
              },
            );
          } else {
            showToast(hjr.msg);
          }
        },
      );
    }).then((value) {
      closeInput();
    });
  }

  /// epik转账到销毁地址
  onClickEpkToErc20() {
    if (amount < config.min_epik_swap || amount > config.max_epik_swap) {
      showToast(
        //兑换数量限制
          "${RSID.eev_28.text} ${StringUtils.formatNumAmount(
              config.min_epik_swap, point: 8, supply0: false)} - ${StringUtils
              .formatNumAmount(
              config.max_epik_swap, point: 8, supply0: false)}");
      return;
    }

    BottomDialog.showPassWordInputDialog(
        context, AccountMgr()?.currentAccount?.password, (password) {
      //点击确定回调
      showLoadDialog(
        "",
        touchOutClose: false,
        backClose: false,
        onShow: () async {
          // String from_address = AccountMgr()?.currentAccount?.epik_EPK_address;
          String to_address = config.epik_address;

          ResultObj result = await AccountMgr()
              .currentAccount
              .epikWallet
              .send(to_address, amount_text);

          if (result?.code != 0 || StringUtils.isEmpty(result?.data)) {
            closeLoadDialog();
            String err = "";
            if (StringUtils.isNotEmpty(result.errorMsg)) {
              err = "ERROR: ${result.errorMsg}";
            } else {
              err = RSID.request_failed.text; //"转账失败");
            }
            MessageDialog.showMsgDialog(
              context,
              title: RSID.tip.text,
              msg: err,
              btnLeft: RSID.confirm.text,
              onClickBtnLeft: (dialog) {
                dialog.dismiss();
              },
            );
            return;
          }

          dlog("doWithdraw_epik result=${result?.data}");

          // 提取cid 进入下一步

          String cid = result?.data;
          setLocalTxHash_Erc20epk(null);
          setLocalTxHash_epk(cid);

          amount = 0;
          amount_text = "";
          _tec_amount = null;

          //刷新钱包余额
          EpikWalletUtils.requestBalance(AccountMgr().currentAccount)
              .then((value) {
            setState(() {});
          });

          HttpJsonRes hjr = await ApiWallet.swap2ERC20EPK(
              AccountMgr().currentAccount,
              DL_TepkLoginToken.getEntity().getToken(),
              cid);

          closeLoadDialog();

          if (hjr?.code == 0) {
            MessageDialog.showMsgDialog(
              context,
              title: RSID.tip.text,
              msg: RSID.eev_29.text,//"兑换已提交",
              btnLeft: RSID.confirm.text,
              onClickBtnLeft: (dialog) {
                dialog.dismiss();
              },
              onDismiss: (dialog) {
                Future.delayed(Duration(milliseconds: 200)).then((value) {
                  refresh();
                });
              },
            );
          } else {
            showToast(hjr.msg);
          }
        },
      );
    }).then((value) {
      closeInput();
    });
  }

  ///已转erc20 补领 epk
  onClickReplacementErc20ToEpk() {
    BottomDialog.showTextInputDialog(
      //请输入转出ERC20-EPK交易的TxHash
        context, RSID.eev_30.text, "", "", 999, (txhash) async {
      if (StringUtils.isNotEmpty(txhash) && txhash.startsWith("0x")) {
        showLoadDialog("", touchOutClose: false, backClose: false);

        // 检查txhash 能否进入下一步
        //查询销毁结果
        // ResultObj result = await AccountMgr()?.currentAccount?.hdwallet?.receipt(txhash);
        ResultObj  result = null;
        try{
          TransactionReceipt tr = await EpikWalletUtils.ethClient.getTransactionReceipt(txhash);
          result = ResultObj();
          if(tr!=null)
          {
            result.code=0;
            result.data=tr.status==true?"success":"";
          }
        }catch(e)
        {
          print(e);
          result = ResultObj.fromError(e);
        }
        dlog("erc20_receipt = ${result?.data}");
        // closeLoadDialog();
        hdwallet_result = result;
        if (hdwallet_result?.code == 0) {
          HttpJsonRes hjr = await ApiWallet.swap2EPIK(
              AccountMgr().currentAccount,
              DL_TepkLoginToken.getEntity().getToken(),
              txhash);

          if (hjr?.code == 0) {
            closeLoadDialog();
            //交易记录查询成功 提交兑换成功
            setLocalTxHash_Erc20epk(txhash);
            if (hdwallet_result.data == "success") {
              current_step = Erc2EpkStep.complete;
            } else {
              current_step = Erc2EpkStep.confirm_swap;
            }
            setState(() {});
            return;
          }

          closeLoadDialog();
          showToast(StringUtils.isNotEmpty(hjr?.msg) ? hjr?.msg : RSID.eev_31.text);//"提交失败");
          return;
        } else {
          closeLoadDialog();
          showToast(StringUtils.isNotEmpty(hdwallet_result?.errorMsg)
              ? hdwallet_result?.errorMsg
              : RSID.eev_32.text);//"TxHash查询失败");
          return;
        }
      }
      closeLoadDialog();
      showToast(RSID.eev_33.text);//"TxHash无效");
    }).then((value) {
      closeInput();
    });
  }

  ///已转epk  补领 erc20
  onClickReplacementEpkToERC20() {
    //"请输入转出EPK交易的cid"
    BottomDialog.showTextInputDialog(context, RSID.eev_34.text, "", "", 999,
            (cidStr) async {
          if (StringUtils.isNotEmpty(cidStr) /*&& txhash.startsWith("0x")*/) {
            showLoadDialog("", touchOutClose: false, backClose: false);

            // 检查txhash 能否进入下一步
            //查询销毁结果
            ResultObj result =
            await AccountMgr().currentAccount.epikWallet.messageReceipt(cidStr);
            dlog("epik_receipt = ${result?.data}");

            epikwallet_result = result;
            if (epikwallet_result?.code == 0) {
              HttpJsonRes hjr = await ApiWallet.swap2ERC20EPK(
                  AccountMgr().currentAccount,
                  DL_TepkLoginToken.getEntity().getToken(),
                  cidStr);

              if (hjr?.code == 0) {
                closeLoadDialog();

                //交易记录查询成功 提交了补领兑换申请
                setLocalTxHash_Erc20epk(cidStr);
                if (epikwallet_result.data == "success") {
                  current_step = Erc2EpkStep.complete;
                } else {
                  current_step = Erc2EpkStep.confirm_swap;
                }
                setState(() {});
                return;
              }

              closeLoadDialog();
              showToast(StringUtils.isNotEmpty(hjr?.msg) ? hjr?.msg :RSID.eev_31.text);// "提交失败");
              return;
            } else {
              closeLoadDialog();
              showToast(StringUtils.isNotEmpty(epikwallet_result?.errorMsg)
                  ? epikwallet_result?.errorMsg
                  : RSID.eev_35.text);//"cid查询失败");
              return;
            }
          }
          closeLoadDialog();
          showToast(RSID.eev_36.text);//"cid无效");
        }).then((value) {
      closeInput();
    });
  }

  onClickServer() {
    //咨询客服
    //todo 客服
  }
}
