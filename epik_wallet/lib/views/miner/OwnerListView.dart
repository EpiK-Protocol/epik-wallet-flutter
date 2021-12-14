import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/loading_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/LocaleConfig.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/CoinbaseInfo2.dart';
import 'package:epikwallet/utils/ClickUtil.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/utils/toast/toast.dart';
import 'package:epikwallet/views/miner/AddOtherOwnerPledgeView.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:epikwallet/widget/text/TextEllipsisMiddle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

///矿机owner列表  增加、撤回 流量抵押
class OwnerListView extends BaseWidget {
  CoinbaseInfo2 coinbase;

  OwnerListView(this.coinbase);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return OwnerListViewState();
  }
}

class OwnerListViewState extends BaseWidgetState<OwnerListView> {
  List<CbOwner> data = [];

  @override
  void initStateConfig() {
    super.initStateConfig();
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);
    setAppBarTitle("Owners");

    data = widget?.coinbase?.retrieve?.Owners ?? [];

    refresh();
  }


  @override
  Widget getAppBarRight({Color color}) {
    return InkWell(
      onTap: (){
        ViewGT.showView(context, AddOtherOwnerPledgeView(),model: ViewPushModel.PushReplacement);
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 0 , 20, 0),
        width: 24.0+20+20,
        height: getAppBarHeight(),
        child: Icon(
          Icons.add_rounded,
          color: color ?? Colors.white,
          size: 24,
        ),
        // child: Center(
        //   child: Image.asset("assets/img/ic_back.png",width: 24,height: 24,
        //     color: color ?? _appBarContentColor,
        //   ),
        // ),
      ),
    );
  }

  bool isFirst = true;

  bool isLoading = false;

  refresh({bool frompull}) async {
    // if (isFirst) {
    //   isFirst = false;
    // }
    //
    // // if (AccountMgr().currentAccount == null) {
    // //   _MinerStateType = MinerStateType.needwallet;
    // //   closeStateLayout();
    // //   isLoading = false;
    // //   return;
    // // }
    //
    // isLoading = true;
    // proressBackgroundColor = Colors.transparent;
    // if (frompull != true) setLoadingWidgetVisible(true);
    //
    // await Future.delayed(Duration(milliseconds: 500));
    // data = [];
    // for (int i = 0; i < 5; i++) data.add(i);
    //
    // // if (data == null || data?.length == 0) {
    // //   closeStateLayout();
    // // } else {
    // //   errorBackgroundColor = Colors.transparent;
    // //   statelayout_margin =
    // //       EdgeInsets.only(top: getAppBarHeight() + getTopBarHeight());
    // //   setErrorContent(RSID.net_error.text);
    // //   setErrorWidgetVisible(true);
    // // }
    // closeStateLayout();
    // isLoading = false;

    if (data == null || data?.length == 0) {
      emptyBackgroundColor = Colors.transparent;
      statelayout_margin =
          EdgeInsets.only(top: getAppBarHeight() + 100); //+ getTopBarHeight()
      setEmptyWidgetVisible(true);
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    Widget view = ListPage(
      data ?? [],
      headerList: [0],
      headerCreator: (context, position) {
        return Container(
          height: 45,
        );
      },
      itemWidgetCreator: (context, position) {
        return buildItem(position);
      },
      // pullRefreshCallback: _pullRefreshCallback,
    );

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Container(
            height: getAppBarHeight() + getTopBarHeight() + 128,
            padding: EdgeInsets.fromLTRB(0, getTopBarHeight(), 0, 128),
            decoration: BoxDecoration(
              gradient: ResColor.lg_1,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: getAppBar(),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: getAppBarHeight() + getTopBarHeight(),
            bottom: 0,
            child: view,
          ),
        ],
      ),
    );
  }

  Widget getColumnKeyValue(
    String key,
    String value, {
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    double centerpading = 4,
    bool textem = false,
    bool clickCopy = false,
  }) {
    Widget w = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(key, style: TextStyle(fontSize: 14, color: ResColor.white_60)),
        Container(
          height: centerpading,
        ),
        textem
            ? TextEm(value,
                style: TextStyle(fontSize: 14, color: ResColor.white))
            : Text(value,
                style: TextStyle(fontSize: 14, color: ResColor.white)),
      ],
    );
    return InkWell(
      onTap: () {
        if (clickCopy) {
          if (ClickUtil.isFastDoubleClick()) return;
          if (StringUtils.isNotEmpty(value)) {
            DeviceUtils.copyText(value);
            showToast(RSID.copied.text);
          }
        }
      },
      child: w,
    );
  }

  Widget buildItem(int position) {
    CbOwner owner = data[position];

    List<Widget> items = [];

    // address      ownerID     余额
    // xxxx         xxxx        xxxx
    items.add(
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: getColumnKeyValue("OwnersID", owner?.ID ?? "--",
                crossAxisAlignment: CrossAxisAlignment.start, clickCopy: true),
          ),
          Expanded(
            child: getColumnKeyValue(RSID.olv_6.text,
                StringUtils.formatNumAmount(owner?.TotalMiner_i ?? 0),
                crossAxisAlignment: CrossAxisAlignment.center, clickCopy: false),
          ),
          Expanded(
            child: getColumnKeyValue(
                RSID.olv_1.text, //"余额",
                // "${StringUtils.formatNumAmountLocaleUnit(owner?.Balance_d??0, context, point: 2, needZhUnit: false)} EPK",
                "${StringUtils.formatNumAmount(owner?.Balance_d ?? 0, point: 2, supply0: false)} EPK",
                crossAxisAlignment: CrossAxisAlignment.end),
          ),
        ],
      ),
    );

    items.add(Container(height: 20));

    items.add(
      getColumnKeyValue("Address", owner?.Address ?? "--",
          crossAxisAlignment: CrossAxisAlignment.start,
          clickCopy: true,
          textem: true),
    );

    // 流量质押： xxx EPK
    // 增加  赎回
    items.add(
      Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: const Color(0xff424242),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  RSID.olv_7.text + ": ", //"总流量质押: ",
                  style: const TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Text(
                    // "${StringUtils.formatNumAmountLocaleUnit(0, context, point: 2, needZhUnit: false)} EPK",
                    "${StringUtils.formatNumAmount(owner?.Pledged_d ?? 0, point: 2, supply0: false)} EPK",
                    style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Container(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  RSID.olv_2.text + ": ", //"我的流量质押: ",
                  style: const TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Text(
                    // "${StringUtils.formatNumAmountLocaleUnit(0, context, point: 2, needZhUnit: false)} EPK",
                    "${StringUtils.formatNumAmount(owner?.MyPledged_d ?? 0, point: 2, supply0: false)} EPK",
                    style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Container(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: LoadingButton(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    padding: EdgeInsets.only(bottom: 1),
                    // width: 40,
                    height: 30,
                    gradient_bg: ResColor.lg_2,
                    color_bg: Colors.transparent,
                    disabledColor: Colors.transparent,
                    bg_borderradius: BorderRadius.circular(4),
                    text: RSID.olv_3.text,
                    //"增加",
                    textstyle: TextStyle(
                      color: Colors.white,
                      fontSize: 14,//LocaleConfig.currentIsZh() ? 12 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                    onclick: (lbtn) {
                      //输入 要增加的owner质押
                      String amount_str ="";
                      BottomDialog.showTextInputDialog(
                        context,
                        "${owner.ID} ${RSID.olv_3.text} ",
                        amount_str,
                        "",
                        999,
                            (amount) {
                          onClickRetrieveAdd(owner,amount);
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExpUtil.re_float)
                        ],
                        keyboardType:TextInputType.numberWithOptions(decimal: true),
                      );
                    },
                  ),
                ),
                Container(width: 10),
                Expanded(
                  child: LoadingButton(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    padding: EdgeInsets.only(bottom: 1),
                    // width: LocaleConfig.currentIsZh() ? 40 : 60,
                    height: 30,
                    gradient_bg: ResColor.lg_5,
                    color_bg: Colors.transparent,
                    disabledColor: Colors.transparent,
                    bg_borderradius: BorderRadius.circular(4),
                    text: RSID.olv_4.text,
                    // "赎回", Withdraw
                    textstyle: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    onclick: (lbtn) {
                      //输入 要赎回的owner质押
                      if(owner.MyPledged_d>0)
                      {
                        String amount_str =owner.MyPledged??"0";
                        BottomDialog.showTextInputDialog(
                          context,
                          "${owner.ID} ${RSID.olv_4.text} ",
                          amount_str,
                          "",
                          999,
                              (amount) {
                            onClickRetrieveApplyWithdraw(owner,amount);
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExpUtil.re_float)
                          ],
                            keyboardType:TextInputType.numberWithOptions(decimal: true),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    items.add(Container(height: 20));
    items.add(Text(RSID.olv_5.text,
        style: const TextStyle(fontSize: 14, color: ResColor.white_60)));
    items.add(Container(height: 4));
    items.add(Row(
      children: [
        Text(
          "${owner.getRetrieveNumerator()} / ${owner.getRetrieveDenominator()}",
          style: const TextStyle(fontSize: 14, color: ResColor.white),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 4, 0, 0),
            child: LinearPercentIndicator(
              // width: double.infinity,
              lineHeight: 5,
              animation: true,
              animationDuration: 500,
              animateFromLastPercent: true,
              // restartAnimation: true,
              percent: owner.getRetrievePercent(),
              center: Text(""),
              padding: EdgeInsets.only(
                left: 2.5,
                right: 2.5,
              ),
              backgroundColor: ResColor.white_20,
              linearStrokeCap: LinearStrokeCap.roundAll,
              // progressColor: const Color(0xff57B836),
              linearGradient: ResColor.lg_1,
            ),
          ),
        ),
      ],
    ));

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(30, 0, 30, 10),
      padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ResColor.b_2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    );
  }

  // Future<void> _pullRefreshCallback() async {
  //   if (isLoading) {
  //     return;
  //   }
  //   await refresh(frompull: true);
  //   return;
  // }

  ///添加流量抵押
  onClickRetrieveAdd(CbOwner owner,String amount) {
    if(owner==null)
      return;

    double num = StringUtils.parseDouble(amount, 0);
    if (num <= 0) {
      ToastUtils.showToastCenter(RSID.uspav_4.text);
      return;
    }

    closeInput();

    BottomDialog.showPassWordInputDialog(
        context, AccountMgr().currentAccount.password, (value) async {
      LoadingDialog.showLoadDialog(context, "",
          touchOutClose: false, backClose: false);


      // 流量抵押 需要用owner  不是用minerid
      ResultObj<String> robj = await AccountMgr()
          .currentAccount
          .epikWallet
          .retrievePledgeAdd(owner.ID,""/*widget.minerinfo.minerid*/, amount.trim());

      LoadingDialog.cloasLoadDialog(context);

      if (robj?.isSuccess) {
        String cid = robj
            .data; //bafy2bzaceaa4fwwhrn5oqjsxe5vumlibispulwdzf4uskh4silxlfo4qh6cu6
        // getting key address: failed to get account actor state for f022202: unknown actor code bafkqaetfobvs6mjpon2g64tbm5sw22lomvza
        setState(() {});

        MessageDialog.showMsgDialog(
          context,
          title: RSID.minerview_17.text,//"访问流量抵押",
          msg: "${RSID.minerview_20.text}\n$cid",//添加抵押交易已提交
          btnLeft: RSID.minerview_19.text,//"查看交易",
          btnRight: RSID.isee.text,
          onClickBtnLeft: (dialog) {
            dialog.dismiss();
            String url = ServiceInfo.epik_msg_web + cid;
            ViewGT.showGeneralWebView(context, RSID.berlv_4.text, url);
          },
          onClickBtnRight: (dialog) {
            dialog.dismiss();
          },
        );
      } else {
        ToastUtils.showToastCenter(robj?.errorMsg ?? RSID.request_failed.text);
      }
    });
  }

  //撤回抵押
  onClickRetrieveApplyWithdraw(CbOwner owner,String amount) {
      if(owner==null)
        return;

      double num = StringUtils.parseDouble(amount, 0);
      if (num <= 0) {
        ToastUtils.showToastCenter(RSID.uspav_4.text);
        return;
      }

      closeInput();


      closeInput();

      BottomDialog.showPassWordInputDialog(
          context, AccountMgr().currentAccount.password, (value) async {
        LoadingDialog.showLoadDialog(context, "",
            touchOutClose: false, backClose: false);

        ResultObj<String> robj = await AccountMgr()
            .currentAccount
            .epikWallet
            .retrievePledgeApplyWithdraw(owner.ID, amount.trim());

        LoadingDialog.cloasLoadDialog(context);

        if (robj?.isSuccess) {
          String cid = robj
              .data; //bafy2bzaceaa4fwwhrn5oqjsxe5vumlibispulwdzf4uskh4silxlfo4qh6cu6
          setState(() {});

          MessageDialog.showMsgDialog(
            context,
            title:RSID.minerview_25.text,// "访问流量抵押",
            msg: "${RSID.minerview_27.text}\n$cid",//解锁抵押交易已提交
            btnLeft: RSID.minerview_19.text,//"查看交易",
            btnRight: RSID.isee.text,
            onClickBtnLeft: (dialog) {
              dialog.dismiss();
              String url = ServiceInfo.epik_msg_web + cid;
              ViewGT.showGeneralWebView(context, RSID.berlv_4.text, url);
            },
            onClickBtnRight: (dialog) {
              dialog.dismiss();
            },
          );
        } else {
          ToastUtils.showToastCenter(robj?.errorMsg ?? RSID.request_failed.text);
        }
      });
  }
}
