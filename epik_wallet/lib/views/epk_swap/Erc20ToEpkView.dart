import 'dart:async';
import 'dart:ui';

import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_wallet.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/model/CurrencyAsset.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/sp_utils/sp_utils.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/views/wallet/create/createwalletview.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';

enum Erc2EpkStep {
  post_destroy,
  confirm_destroy,
  submitepk,
  complete,
}

extension Erc2EpkStepEx on Erc2EpkStep {
  String get name {
    switch (this) {
      case Erc2EpkStep.post_destroy:
        return "发起销毁";
      case Erc2EpkStep.confirm_destroy:
        return "确认销毁";
      case Erc2EpkStep.submitepk:
        return "发放EPK";
      case Erc2EpkStep.complete:
        return "完成";
    }
  }
}

///erc20兑换epk
class Erc20ToEpkView extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> getState() {
    return Erc20ToEpkViewState();
  }
}

class Erc20ToEpkViewState extends BaseWidgetState<Erc20ToEpkView> {
  Erc2EpkStep current_step = Erc2EpkStep.post_destroy;

  TextEditingController _tec_erc20;
  String text_erc20 = "0";
  double amount_erc20 = 0;

  // 销毁erc20的交易记录
  ResultObj hdwallet_result;

  // 发布epk的交易记录
  ResultObj epkwallet_result;

  @override
  void initStateConfig() {
    super.initStateConfig();
    resizeToAvoidBottomPadding = true;
    refresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle("ERC20-EPK兑换EPK");
  }

  static String getLocalTxHash_Erc20epk() {
    return SpUtils.getString("erc20-epk-txhash", defValue: "");
  }

  static setLocalTxHash_Erc20epk(String txHash) {
    SpUtils.putString("erc20-epk-txhash", txHash ?? "");
  }

  static String getLocalTxHash_epk() {
    return SpUtils.getString("epk-cid", defValue: "");
  }

  static setLocalTxHash_epk(String cid) {
    SpUtils.putString("epk-cid", cid ?? "");
  }

  bool isFristRefresh = true;

  refresh() async {
    if (isFristRefresh) {
      isFristRefresh = false;
      setLoadingWidgetVisible(true);
    } else {
      showLoadDialog("", touchOutClose: false, backClose: false);
    }

    Erc2EpkStep temp_step = Erc2EpkStep.post_destroy;

    //刷新钱包余额
    EpikWalletUtils.requestBalance(AccountMgr().currentAccount).then((value) {
      if (mounted && isDestory != true) setState(() {});
    });

    //查询没完成的兑换
    HttpJsonRes hjr = await ApiWallet.Erc2EpkRunningSwap();
    dlog("Erc2EpkRunningSwap $hjr");

    String txhash = getLocalTxHash_Erc20epk();
    dlog("erc20_txhash = $txhash");

    String epkcid = getLocalTxHash_epk();
    dlog("epk_cid = $epkcid");

    if (StringUtils.isNotEmpty(epkcid)) {
      //发放EPK的结果
      ResultObj result = await AccountMgr()
          ?.currentAccount
          ?.epikWallet
          ?.messageReceipt(epkcid);
      dlog("epk_receipt = ${result?.data}");
      epkwallet_result = result;
      if (epkwallet_result?.code == 0) {
        temp_step = Erc2EpkStep.complete;
      }
    } else if (StringUtils.isNotEmpty(txhash)) {
      //本地有销毁记录
      //查询销毁结果
      ResultObj result =
          await AccountMgr()?.currentAccount?.hdwallet?.receipt(txhash);
      dlog("erc20_receipt = ${result?.data}");
      hdwallet_result = result;
      if (hdwallet_result?.code == 0) {
        // test
        // hdwallet_result.data="failed";
        // hdwallet_result.data = "pending";

        //交易记录查询成功
        if (hdwallet_result.data == "success") {
          temp_step = Erc2EpkStep.submitepk;
        } else {
          temp_step = Erc2EpkStep.confirm_destroy;
        }
      }
    }

    //设置步骤
    current_step = temp_step;

    closeStateLayout();
    closeLoadDialog();
  }

  ///导航栏appBar中间部分 ，不满足可以自行重写
  Widget getAppBarRight({Color color}) {
    return InkWell(
      onTap: () {
        ViewGT.showErc20ToEpkRecordView(context);
      },
      child: Text(
        "兑换记录",
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
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Text(
          "兑换须知",
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Text(
          "此次兑换所需的EPK有EpiK基金会提供。兑换过程中，需要您发起一笔以太坊交易，所以请确保您当前账户内有足够的以太坊支付此笔交易的手续费。兑换后，您当前以太坊钱包中的所有ERC20-EPK将会销毁，并按照1:1的比例兑换得到EPK，这些EPK将自动转入您当前EpiK钱包。",
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 14,
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
      // Padding(
      //   padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      //   child: Text(
      //     "为避免您之前参与挖矿活动有意或者无意的泄露过当前钱包的助记词或私钥，强烈建议创建新钱包，将ERC20-EPK转入全新的钱包后，再进行兑换。",
      //     style: TextStyle(
      //       color: Colors.redAccent,
      //       fontSize: 14,
      //     ),
      //   ),
      // ),
      Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child:RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 14,
              fontFamily: fontFamily_def,
            ),
            children: [
              TextSpan(
                text: "为避免您之前参与挖矿活动有意或者无意的泄露过当前钱包的助记词或私钥，强烈建议",
              ),
              TextSpan(
                text: "创建新钱包",
                style: TextStyle(
                  color: Colors.blue,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    ViewGT.showView(context, CreateWalletView(),model: ViewPushModel.PushReplacement);
                  },
              ),
              TextSpan(
                text: "，将ERC20-EPK转入全新的钱包后，再进行兑换。",
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Text(
          "免责声明",
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Text(
          "如您通过其他渠道自行销毁了ERC20-EPK导致无法正常兑换EPK，EpiK基金会将不予赔偿",
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 14,
          ),
        ),
      ),
      getErc20EpkCard(),
      getEpkCard(),
      getSteps(),
    ];

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

  Widget getErc20EpkCard() {
    String balance = "0.0";
    String address = AccountMgr()?.currentAccount?.hd_eth_address ?? "";

    CurrencyAsset ca = AccountMgr()
        ?.currentAccount
        ?.getCurrencyAssetByCs(CurrencySymbol.EPKerc20);
    if (ca != null) balance = ca.balance;

    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
      // padding: EdgeInsets.all(15),
      width: double.infinity,
      child: Card(
        color: ResColor.main,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        elevation: 10,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "ERC20-EPK",
                style: TextStyle(
                  color: ResColor.white,
                  fontSize: 20,
                  fontFamily: "DIN_Condensed_Bold",
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: Text(
                      "余额:",
                      style: TextStyle(
                        color: ResColor.white,
                        fontSize: 16,
                        // fontFamily: "DIN_Condensed_Bold",
                      ),
                    ),
                  ),
                  Text(
                    // balance,
                    StringUtils.isNotEmpty(balance)
                        ? StringUtils.formatNumAmount(ca.getBalanceDouble(),
                            point: 16, supply0: false)
                        : "--",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      // fontFamily: "DIN_Condensed_Bold",
                      // height: 1,
                    ),
                  ),
                ],
              ),
              Container(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: Text(
                      "地址:",
                      style: TextStyle(
                        color: ResColor.white,
                        fontSize: 16,
                        // fontFamily: "DIN_Condensed_Bold",
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      address,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        // fontFamily: "DIN_Condensed_Bold",
                        // height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getEpkCard() {
    String balance = "0.0";
    String address = AccountMgr()?.currentAccount?.epik_EPK_address ?? "";

    CurrencyAsset ca =
        AccountMgr()?.currentAccount?.getCurrencyAssetByCs(CurrencySymbol.EPK);
    if (ca != null) balance = ca.balance;

    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
      // padding: EdgeInsets.all(15),
      width: double.infinity,
      child: Card(
        color: ResColor.main,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        elevation: 10,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "EPK",
                style: TextStyle(
                  color: ResColor.white,
                  fontSize: 20,
                  fontFamily: "DIN_Condensed_Bold",
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: Text(
                      "余额:",
                      style: TextStyle(
                        color: ResColor.white,
                        fontSize: 16,
                        // fontFamily: "DIN_Condensed_Bold",
                      ),
                    ),
                  ),
                  Text(
                    // balance,
                    StringUtils.isNotEmpty(balance)
                        ? StringUtils.formatNumAmount(ca.getBalanceDouble(),
                            point: 16, supply0: false)
                        : "--",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      // fontFamily: "DIN_Condensed_Bold",
                      // height: 1,
                    ),
                  ),
                ],
              ),
              Container(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: Text(
                      "地址:",
                      style: TextStyle(
                        color: ResColor.white,
                        fontSize: 16,
                        // fontFamily: "DIN_Condensed_Bold",
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      address,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        // fontFamily: "DIN_Condensed_Bold",
                        // height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getSteps() {
    List<Widget> items = [];

    // 步骤列表
    List<Widget> wrapitms = [];

    List<Erc2EpkStep> steps = Erc2EpkStep.values.toList();
    for (int i = 0; i < steps.length; i++) {
      Erc2EpkStep step = steps[i];
      wrapitms.add(Text(
        "${i + 1}.${step.name}",
        style: TextStyle(
          fontSize: 14,
          color: current_step == step ? Colors.green : Colors.black,
          fontWeight: current_step == step ? FontWeight.bold : null,
        ),
      ));
      if (i < steps.length - 1) {
        wrapitms.add(Container(
          margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
          color: Colors.black,
          width: 10,
          height: 1,
        ));
      }
    }

    items.add(Container(
      height: 20,
    ));
    items.add(
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: wrapitms,
      ),
    );

    // 具体步骤
    items.add(getStep());

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: items,
    );
  }

  Widget getStep() {
    switch (current_step) {
      case Erc2EpkStep.post_destroy:
        return getStep_destroy();
      case Erc2EpkStep.confirm_destroy:
        return getStep_confirm();
      case Erc2EpkStep.submitepk:
        return getStep_submitepk();
      case Erc2EpkStep.complete:
        return getStep_complete();
    }
    return Container();
  }

  /// 发起销毁
  Widget getStep_destroy() {
    if (_tec_erc20 == null)
      _tec_erc20 = new TextEditingController.fromValue(TextEditingValue(
        text: text_erc20,
        selection: new TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream, offset: text_erc20.length),
        ),
      ));

    Widget input = Row(
      children: [
        Text(
          "销毁数量：",
          style: TextStyle(
            color: ResColor.black_80,
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 33,
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                      height: 33,
                      child: TextField(
                        controller: _tec_erc20,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        maxLines: 1,
                        obscureText: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExpUtil.re_float)
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
                          contentPadding: EdgeInsets.fromLTRB(0, -15, 0, 0),
                          // hintText: ResString.get(context, RSID.bexv_5),
                          //"请输入兑换数量",
                          hintStyle:
                              TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                        cursorWidth: 2.0,
                        //光标宽度
                        cursorRadius: Radius.circular(2),
                        //光标圆角弧度
                        cursorColor: Colors.blue,
                        //光标颜色
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        onChanged: (value) {
                          text_erc20 = _tec_erc20.text.trim();
                          amount_erc20 = StringUtils.parseDouble(text_erc20, 0);
                        },
                      ),
                    )),
                    // max
                    InkWell(
                      onTap: () {
                        String balance = "0";

                        CurrencyAsset ca = AccountMgr()
                            ?.currentAccount
                            ?.getCurrencyAssetByCs(CurrencySymbol.EPKerc20);
                        if (ca != null) balance = ca.balance;

                        // _tec_erc20.text=balance;
                        _tec_erc20 = null;
                        text_erc20 = balance;

                        setState(() {});
                      },
                      child: Text(
                        " Max ",
                        style: TextStyle(
                          color: ResColor.black_80,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 0.5,
                thickness: 0.5,
                color: ResColor.main,
              ),
            ],
          ),
        ),
      ],
    );

    Widget items = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "销毁ERC20-EPK",
          style: TextStyle(
            color: ResColor.black,
            fontSize: 18,
          ),
        ),
        Container(
          height: 10,
        ),
        input,
        LoadingButton(
          margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
          height: 44,
          color_bg: ResColor.main,
          disabledColor: ResColor.main,
          progress_color: Colors.white,
          progress_size: 20,
          padding: EdgeInsets.all(0),
          text: Erc2EpkStep.post_destroy.name,
          textstyle: const TextStyle(
            color: ResColor.white,
            fontSize: 15,
          ),
          loading: false,
          onclick: (lbtn) {
            // erc20-epk转账到空地址销毁
            BottomDialog.showPassWordInputDialog(
                context, AccountMgr()?.currentAccount?.password, (password) {
              //点击确定回调
              showLoadDialog(
                "正在销毁ERC20-EPK......",
                touchOutClose: false,
                backClose: false,
                onShow: () async {
                  String from_address =
                      AccountMgr()?.currentAccount?.hd_eth_address;
                  String to_address =
                      "0x000000000000000000000000000000000000dEaD";
                  ResultObj<String> result = await AccountMgr()
                      .currentAccount
                      .hdwallet
                      .transferToken(from_address, to_address,
                          CurrencySymbol.EPKerc20.symbolToNetWork, text_erc20);
                  closeLoadDialog();

                  if (result?.code != 0 || StringUtils.isEmpty(result?.data)) {
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

                  //刷新钱包余额
                  EpikWalletUtils.requestBalance(AccountMgr().currentAccount)
                      .then((value) {
                    setState(() {});
                  });

                  MessageDialog.showMsgDialog(
                    context,
                    title: RSID.tip.text,
                    msg: "销毁已提交",
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
                },
              );
            }).then((value) {
              closeInput();
            });
          },
        ),
        InkWell(
          child: Text(
            "已销毁记录补领EPK",
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue,
            ),
          ),
          onTap: () {
            //  导入之前销毁记录的tx  进入下一步
            BottomDialog.showTextInputDialog(
                context, "请输入销毁记录的TxHash", "", "", 999, (txhash) async {
              if (StringUtils.isNotEmpty(txhash) && txhash.startsWith("0x")) {
                showLoadDialog("", touchOutClose: false, backClose: false);

                // 检查txhash 能否进入下一步
                //查询销毁结果
                ResultObj result = await AccountMgr()
                    ?.currentAccount
                    ?.hdwallet
                    ?.receipt(txhash);
                dlog("erc20_receipt = ${result?.data}");

                closeLoadDialog();

                hdwallet_result = result;
                if (hdwallet_result?.code == 0) {
                  //交易记录查询成功
                  setLocalTxHash_Erc20epk(txhash);
                  if (hdwallet_result.data == "success") {
                    current_step = Erc2EpkStep.submitepk;
                  } else {
                    current_step = Erc2EpkStep.confirm_destroy;
                  }
                  setState(() {});
                  return;
                }
              }
              showToast("TxHash无效");
            }).then((value) {
              closeInput();
            });
          },
        ),
      ],
    );

    return Container(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
      // padding: EdgeInsets.all(15),
      width: double.infinity,
      child: Card(
        color: ResColor.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        elevation: 10,
        shadowColor: ResColor.black_30,
        child: Container(
          padding: EdgeInsets.all(15),
          child: items,
        ),
      ),
    );
  }

  ///等待确认
  Widget getStep_confirm() {
    String txhash = getLocalTxHash_Erc20epk();

    List<Widget> items = [];
    switch (hdwallet_result.data) {
      case "success":
        {}
        break;
      case "failed":
        {
          //failed交易失败
          items.add(Text(
            "销毁失败",
            style: TextStyle(
              color: ResColor.black,
              fontSize: 18,
            ),
          ));
          items.add(Container(
            height: 10,
          ));

          items.add(InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              DeviceUtils.copyText(txhash);
              showToast("TxHash已复制");
            },
            child: Text(
              "$txhash",
              style: TextStyle(
                fontSize: 14,
                color: ResColor.black_80,
              ),
            ),
          ));

          items.add(Container(
            height: 10,
          ));

          items.add(Wrap(
            children: [
              InkWell(
                child: Text(
                  "查看交易",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
                onTap: () {
                  lookEthTxhash(txhash);
                },
              ),
            ],
          ));

          items.add(LoadingButton(
            margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
            height: 44,
            color_bg: ResColor.main,
            disabledColor: ResColor.main,
            progress_color: Colors.white,
            progress_size: 20,
            padding: EdgeInsets.all(0),
            text: "发起新的兑换",
            textstyle: const TextStyle(
              color: ResColor.white,
              fontSize: 15,
            ),
            loading: false,
            onclick: (lbtn) {
              setLocalTxHash_Erc20epk(null);
              setLocalTxHash_epk(null);
              hdwallet_result = null;
              epkwallet_result = null;
              current_step = Erc2EpkStep.post_destroy;
              setState(() {});
            },
          ));
        }
        break;
      case "pending":
        {
          //pending交易等待中
          items.add(Text(
            "等待ERC20-EPK销毁确认",
            style: TextStyle(
              color: ResColor.black,
              fontSize: 18,
            ),
          ));
          items.add(Container(
            height: 10,
          ));

          items.add(InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              DeviceUtils.copyText(txhash);
              showToast("TxHash已复制");
            },
            child: Text(
              "$txhash",
              style: TextStyle(
                fontSize: 14,
                color: ResColor.black_80,
              ),
            ),
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
                  text: "查看交易",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      lookEthTxhash(txhash);
                    },
                ),
                TextSpan(
                  text: "，如长时间不上链可以",
                  style: TextStyle(
                    fontSize: 14,
                    color: ResColor.black_80,
                  ),
                ),
                TextSpan(
                  text: "加速交易",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      // 加速交易
                      onClickAccelerateTx(txhash);
                    },
                ),
              ],
            ),
          ));

          items.add(LoadingButton(
            margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
            height: 44,
            color_bg: ResColor.main,
            disabledColor: ResColor.main,
            progress_color: Colors.white,
            progress_size: 20,
            padding: EdgeInsets.all(0),
            text: "刷新",
            textstyle: const TextStyle(
              color: ResColor.white,
              fontSize: 15,
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
      child: Card(
        color: ResColor.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        elevation: 10,
        shadowColor: ResColor.black_30,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items,
          ),
        ),
      ),
    );
  }

  lookEthTxhash(String txhash) {
    String url = ServiceInfo.ether_tx_web+txhash;
    ViewGT.showGeneralWebView(
      context,
      RSID.usolv_3.text, //"详情",
      url,
    );
  }

  lookEpkCid(String cid) {
    String url = ServiceInfo.epik_msg_web + cid; // 需要epk浏览器地址
    ViewGT.showGeneralWebView(
      context,
      RSID.usolv_3.text, //"详情",
      url,
    );
  }

  onClickSubmitepk(String txhash) async {
    // 提交发放

    showLoadDialog("", backClose: false, touchOutClose: false);

    HttpJsonRes hrj = await ApiWallet.Erc2EpkSubmitTx(txhash);

    closeLoadDialog();

    if (hrj.code == 0) {
      //epk交易hash
      String epk_cid = hrj.jsonMap["cid"];

      MessageDialog.showMsgDialog(
        context,
        title: RSID.tip.text,
        msg: "已提交发放EPK",
        btnLeft: RSID.confirm.text,
        onClickBtnLeft: (dialog) {
          dialog.dismiss();
        },
        onDismiss: (dialog) {
          Future.delayed(Duration(milliseconds: 200)).then((value) {
            setLocalTxHash_Erc20epk(null);
            hdwallet_result = null;
            setLocalTxHash_epk(epk_cid);
            refresh();
          });
        },
      );
      return;
    }

    MessageDialog.showMsgDialog(
      context,
      title: RSID.tip.text,
      msg: hrj?.msg ?? RSID.request_failed.text,
      btnLeft: RSID.confirm.text,
      onClickBtnLeft: (dialog) {
        dialog.dismiss();
      },
      onDismiss: (dialog) {
        // 发放epk请求失败
        Future.delayed(Duration(milliseconds: 200)).then((value) {
          setLocalTxHash_Erc20epk(null);
          hdwallet_result = null;
          current_step = Erc2EpkStep.post_destroy;
          setState(() {});
        });
      },
    );
  }

  ///发放epk
  Widget getStep_submitepk() {
    String txhash = getLocalTxHash_Erc20epk();

    List<Widget> items = [];

    {
      // erc20  success交易成功
      items.add(Text(
        "ERC20-EPK已销毁",
        style: TextStyle(
          color: ResColor.black,
          fontSize: 18,
        ),
      ));
      items.add(Container(
        height: 10,
      ));

      items.add(InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          DeviceUtils.copyText(txhash);
          showToast("TxHash已复制");
        },
        child: Text(
          "$txhash",
          style: TextStyle(
            fontSize: 14,
            color: ResColor.black_80,
          ),
        ),
      ));

      items.add(Container(
        height: 10,
      ));

      items.add(Wrap(
        children: [
          InkWell(
            child: Text(
              "查看交易",
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
              ),
            ),
            onTap: () {
              lookEthTxhash(txhash);
            },
          ),
        ],
      ));

      items.add(LoadingButton(
        margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
        height: 44,
        color_bg: ResColor.main,
        disabledColor: ResColor.main,
        progress_color: Colors.white,
        progress_size: 20,
        padding: EdgeInsets.all(0),
        text: Erc2EpkStep.submitepk.name,
        textstyle: const TextStyle(
          color: ResColor.white,
          fontSize: 15,
        ),
        loading: false,
        onclick: (lbtn) {
          // 上报销毁交易
          onClickSubmitepk(txhash);
        },
      ));
    }

    return Container(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
      // padding: EdgeInsets.all(15),
      width: double.infinity,
      child: Card(
        color: ResColor.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        elevation: 10,
        shadowColor: ResColor.black_30,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items,
          ),
        ),
      ),
    );
  }

  onClickAccelerateTx(String txhash) {
    // hd钱包加速交易
    BottomDialog.showEthAccelerateTx(
      context,
      AccountMgr().currentAccount,
      txhash,
      callback: (newTxHash) {
        if (StringUtils.isNotEmpty(newTxHash)) {
          setLocalTxHash_Erc20epk(newTxHash);
          Future.delayed(Duration(milliseconds: 200)).then((value) => refresh());
        }
      },
    );
  }

  ///完成
  Widget getStep_complete() {
    String epkcid = getLocalTxHash_epk();

    List<Widget> items = [];
    switch (epkwallet_result.data) {
      case "success":
        {
          //成功
          //failed交易失败
          items.add(Text(
            "EPK已到账",
            style: TextStyle(
              color: ResColor.black,
              fontSize: 18,
            ),
          ));
          items.add(Container(
            height: 10,
          ));

          items.add(InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              DeviceUtils.copyText(epkcid);
              showToast("cid已复制");
            },
            child: Text(
              "$epkcid",
              style: TextStyle(
                fontSize: 14,
                color: ResColor.black_80,
              ),
            ),
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
                  text: "查看交易",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      lookEpkCid(epkcid);
                    },
                ),
              ],
            ),
          ));

          items.add(LoadingButton(
            margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
            height: 44,
            color_bg: ResColor.main,
            disabledColor: ResColor.main,
            progress_color: Colors.white,
            progress_size: 20,
            padding: EdgeInsets.all(0),
            text: "发起新的兑换",
            textstyle: const TextStyle(
              color: ResColor.white,
              fontSize: 15,
            ),
            loading: false,
            onclick: (lbtn) {
              setLocalTxHash_Erc20epk(null);
              setLocalTxHash_epk(null);
              hdwallet_result = null;
              epkwallet_result = null;
              current_step = Erc2EpkStep.post_destroy;
              setState(() {});
            },
          ));
        }
        break;
      case "failed":
        {
          //failed交易失败
          items.add(Text(
            "发放EPK失败",
            style: TextStyle(
              color: ResColor.black,
              fontSize: 18,
            ),
          ));
          items.add(Container(
            height: 10,
          ));

          items.add(InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              DeviceUtils.copyText(epkcid);
              showToast("cid已复制");
            },
            child: Text(
              "$epkcid",
              style: TextStyle(
                fontSize: 14,
                color: ResColor.black_80,
              ),
            ),
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
                  text: "查看交易",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      lookEpkCid(epkcid);
                    },
                ),
              ],
            ),
          ));

          items.add(LoadingButton(
            margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
            height: 44,
            color_bg: ResColor.main,
            disabledColor: ResColor.main,
            progress_color: Colors.white,
            progress_size: 20,
            padding: EdgeInsets.all(0),
            text: "发起新的兑换",
            textstyle: const TextStyle(
              color: ResColor.white,
              fontSize: 15,
            ),
            loading: false,
            onclick: (lbtn) {
              setLocalTxHash_Erc20epk(null);
              setLocalTxHash_epk(null);
              hdwallet_result = null;
              epkwallet_result = null;
              current_step = Erc2EpkStep.post_destroy;
              setState(() {});
            },
          ));
        }
        break;
      case "pending":
        {
          //pending交易等待中
          items.add(Text(
            "等待发放EPK到账",
            style: TextStyle(
              color: ResColor.black,
              fontSize: 18,
            ),
          ));
          items.add(Container(
            height: 10,
          ));

          items.add(InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              DeviceUtils.copyText(epkcid);
              showToast("cid已复制");
            },
            child: Text(
              "$epkcid",
              style: TextStyle(
                fontSize: 14,
                color: ResColor.black_80,
              ),
            ),
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
                  text: "查看交易",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      lookEpkCid(epkcid);
                    },
                ),
                TextSpan(
                  text: "，如长时间不上链可以",
                  style: TextStyle(
                    fontSize: 14,
                    color: ResColor.black_80,
                  ),
                ),
                TextSpan(
                  text: "询问客服",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      onClickServer();
                    },
                ),
              ],
            ),
          ));

          items.add(LoadingButton(
            margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
            height: 44,
            color_bg: ResColor.main,
            disabledColor: ResColor.main,
            progress_color: Colors.white,
            progress_size: 20,
            padding: EdgeInsets.all(0),
            text: "刷新",
            textstyle: const TextStyle(
              color: ResColor.white,
              fontSize: 15,
            ),
            loading: false,
            onclick: (lbtn) {
              refresh();
            },
          ));
        }
        break;
      default:
        {
          //未知
          //failed交易失败
          items.add(Text(
            "未知状态",
            style: TextStyle(
              color: ResColor.black,
              fontSize: 18,
            ),
          ));
          items.add(Container(
            height: 10,
          ));

          items.add(InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              DeviceUtils.copyText(epkcid);
              showToast("cid已复制");
            },
            child: Text(
              "$epkcid",
              style: TextStyle(
                fontSize: 14,
                color: ResColor.black_80,
              ),
            ),
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
                  text: "查看交易",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      lookEpkCid(epkcid);
                    },
                ),
                TextSpan(
                  text: "，未知状态可以",
                  style: TextStyle(
                    fontSize: 14,
                    color: ResColor.black_80,
                  ),
                ),
                TextSpan(
                  text: "询问客服",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      onClickServer();
                    },
                ),
              ],
            ),
          ));

          items.add(LoadingButton(
            margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
            height: 44,
            color_bg: ResColor.main,
            disabledColor: ResColor.main,
            progress_color: Colors.white,
            progress_size: 20,
            padding: EdgeInsets.all(0),
            text: "发起新的兑换",
            textstyle: const TextStyle(
              color: ResColor.white,
              fontSize: 15,
            ),
            loading: false,
            onclick: (lbtn) {
              setLocalTxHash_Erc20epk(null);
              setLocalTxHash_epk(null);
              hdwallet_result = null;
              epkwallet_result = null;
              current_step = Erc2EpkStep.post_destroy;
              setState(() {});
            },
          ));
        }
        break;
    }

    return Container(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
      // padding: EdgeInsets.all(15),
      width: double.infinity,
      child: Card(
        color: ResColor.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        elevation: 10,
        shadowColor: ResColor.black_30,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items,
          ),
        ),
      ),
    );
  }

  onClickServer() {
    //咨询客服
    //todo 客服
  }
}
