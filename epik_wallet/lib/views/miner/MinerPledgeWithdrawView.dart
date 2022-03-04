import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/loading_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/LocaleConfig.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/CurrencyAsset.dart';
import 'package:epikwallet/model/MinerInfo.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/utils/toast/toast.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';

class MinerPledgeWithdrawView extends StatefulWidget {
  MinerInfo minerinfo;

  MinerPledgeWithdrawView(this.minerinfo, {Key key}) : super(key: key);

  @override
  State<MinerPledgeWithdrawView> createState() {
    return MinerPledgeWithdrawViewState();
  }

  @override
  int setIndex() {
    return 0;
  }
}

class MinerPledgeWithdrawViewState extends State<MinerPledgeWithdrawView> {
  TextEditingController _tec_base,_tec_retrieve_apply,_tec_retrieve_withdraw,_tec_retrieve_unbind;

  String getDesText()
  {
    // return "注意：\n- 仅能赎回自己抵押的EPK\n- 如果你当前已经消耗了一部分访问流量，则无法赎回全部的访问流量抵押，请尝试减少赎回的数量\n- 矿工基础抵押赎回中的EPK将会立刻到账\n- 访问流量抵押的EPK需要在解锁操作3天后才能赎回\n";
    return RSID.minerview_21.text;
  }

  @override
  Widget build(BuildContext context) {

    // CurrencyAsset epk = AccountMgr().currentAccount.getCurrencyAssetByCs(CurrencySymbol.EPK);
    // String balance = StringUtils.formatNumAmount(epk.balance,supply0: false,point: 8);

    if(_tec_base==null)
      _tec_base= new TextEditingController.fromValue(TextEditingValue(
        text: "",
        selection: new TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream, offset: "".length),
        ),
      ));


    if(_tec_retrieve_apply==null)
      _tec_retrieve_apply= new TextEditingController.fromValue(TextEditingValue(
        text: "",
        selection: new TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream, offset: "".length),
        ),
      ));

    if(_tec_retrieve_withdraw==null)
      _tec_retrieve_withdraw= new TextEditingController.fromValue(TextEditingValue(
        text: "",
        selection: new TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream, offset: "".length),
        ),
      ));

    if(_tec_retrieve_unbind==null)
      _tec_retrieve_unbind= new TextEditingController.fromValue(TextEditingValue(
        text: "",
        selection: new TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream, offset: "".length),
        ),
      ));


    List<Widget> items=[

      //矿工基础抵押   000  EPK 赎回
      getRowText(RSID.minerview_10.text, widget.minerinfo==null? "":"${StringUtils.formatNumAmount(widget.minerinfo.my_mining_pledge,supply0:  false,point: 8)}${RSID.minerview_22.text}"),
      getInputRow(controller: _tec_base,btnText: RSID.minerview_2.text,onClick: onClickBaseWithdraw),//赎回
      Container(height: 20,),
      //流量抵押锁定   000  EPK 可解锁
      getRowText(RSID.minerview_13.text,widget.minerinfo==null? "": "${StringUtils.formatNumAmount(widget.minerinfo.my_retrieve_pledge,supply0:  false,point: 8)}${RSID.minerview_23.text}"),
      getInputRow(controller: _tec_retrieve_apply,btnText: RSID.minerview_24.text,onClick: onClickRetrieveApplyWithdraw),//解锁
      Container(height: 20,),
      //访问流量抵押  000  EPK 赎回    ，   剩余高度 xxxx
      getRowText(RSID.minerview_25.text, widget.minerinfo==null? "":(widget.minerinfo.retrieve_unlock_epoch_left_d>0 ? "${RSID.minerview_29.text} ${widget.minerinfo.retrieve_unlock_epoch_left}" :"${StringUtils.formatNumAmount(widget.minerinfo.retrieve_locked_d,supply0: false,point: 8)}${RSID.minerview_22.text}")),
      getInputRow(controller: _tec_retrieve_withdraw,btnText:  RSID.minerview_2.text,onClick: onClickRetrieveWithdraw),//赎回
      // Container(height: 20,),
      // getRowText("访问流量抵押解绑", ""),
      // getInputRow(controller: _tec_retrieve_withdraw,btnText: "解绑",onClick: onClickRetrieveUnbind),

      Container(
        margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
        width: double.infinity,
        child:  Text(
          getDesText(),
          style: TextStyle(
            fontSize: 14,
            color: ResColor.white_80,
            height: 1.5,
          ),
        ),
      ),

    ];



    return Container(
      margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ),
    );
  }


  Widget getRowText(String left, String right,
      {TextStyle leftstyle = const TextStyle(
        fontSize: 11,
        color: ResColor.white_60,
      ),
        TextStyle rightstyle = const TextStyle(
          fontSize: 11,
          color: ResColor.white_60,
        ),
        EdgeInsetsGeometry margin = const EdgeInsets.fromLTRB(0, 0, 0, 10)}) {
    return Container(
      margin: margin,
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: leftstyle,
            ),
          ),
          Text(
            right,
            style: rightstyle,
          ),
        ],
      ),
    );
  }

  Widget getInputRow({TextEditingController controller,String btnText="", Key btnkey,
    Function(LoadingButton lbtn, String amount) onClick})
  {
    Widget input = Container(
      height: 40,
      decoration: BoxDecoration(
        color:const Color(0xff424242),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        //获取焦点时,启用的键盘类型
        maxLines: 1,
//              maxLength: 20, //允许输入的字符长度/ 右下角有数量提示
        maxLengthEnforced: true,
        //是否允许输入的字符长度超过限定的字符长度
        obscureText: false,
        //是否是密码
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
          contentPadding: EdgeInsets.fromLTRB(14, 0, 14, 10),
          hintText: "0",
          hintStyle: TextStyle(color: ResColor.white, fontSize: 17,fontWeight:FontWeight.bold,),
        ),
        cursorWidth: 2.0,
        //光标宽度
        cursorRadius: Radius.circular(2),
        //光标圆角弧度
        cursorColor: Colors.white,
        //光标颜色
        style: TextStyle(fontSize: 17, color: Colors.white,fontWeight:FontWeight.bold,),
        onChanged: (value) {
          // setState(() {
          //   // to_address = _controllerToAddress.text.trim();
          // });
        },
        onSubmitted: (value) {
          // setState(() {
          //   // to_address = _controllerToAddress.text.trim();
          // });
        }, // 是否隐藏输入的内容
      ),
    );



    return Row(
      children: [
        Expanded(child: input),
        LoadingButton(
          margin: EdgeInsets.fromLTRB(10, 0, 0,0),
          width: 62,
          height: 40,
          gradient_bg: ResColor.lg_5,
          color_bg: Colors.transparent,
          disabledColor: Colors.transparent,
          bg_borderradius: BorderRadius.circular(4),
          text:btnText,
          textstyle: TextStyle(
            color: Colors.white,
            fontSize: LocaleConfig.currentIsZh()?17:12,
            fontWeight:FontWeight.bold,
          ),
          onclick: (lbtn) {
            onClick(lbtn, controller.text);
          },
        ),
      ],
    );

  }

  closeInput() {
    try {
      FocusScope.of(context).requestFocus(new FocusNode());
    } catch (e) {
      print(e);
    }
  }


  onClickBaseWithdraw(LoadingButton lbtn, String amount) async
  {
    if(widget.minerinfo==null)
      return;

    double num = StringUtils.parseDouble(amount, 0);
    if (num <= 0) {
      ToastUtils.showToastCenter(RSID.uspav_4.text);
      return;
    }

    closeInput();

    BottomDialog.simpleAuth(
        context, AccountMgr().currentAccount.password, (value) async {
      LoadingDialog.showLoadDialog(context, "",
          touchOutClose: false, backClose: false);

      ResultObj<String> robj = await AccountMgr()
          .currentAccount
          .epikWallet
          .minerPledgeWithdraw(widget.minerinfo.minerid, amount.trim());

      LoadingDialog.cloasLoadDialog(context);

      if (robj?.isSuccess) {
        String cid = robj
            .data; //bafy2bzaceaa4fwwhrn5oqjsxe5vumlibispulwdzf4uskh4silxlfo4qh6cu6
        _tec_base = null;
        setState(() {});

        MessageDialog.showMsgDialog(
          context,
          title: RSID.minerview_10.text,//"矿工基础抵押",
          msg: "${RSID.minerview_26.text}\n$cid",//赎回抵押交易已提交
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

  onClickRetrieveApplyWithdraw(LoadingButton lbtn, String amount) async
  {
    if(widget.minerinfo==null)
      return;

    double num = StringUtils.parseDouble(amount, 0);
    if (num <= 0) {
      ToastUtils.showToastCenter(RSID.uspav_4.text);
      return;
    }

    closeInput();

    BottomDialog.simpleAuth(
        context, AccountMgr().currentAccount.password, (value) async {
      LoadingDialog.showLoadDialog(context, "",
          touchOutClose: false, backClose: false);

      ResultObj<String> robj = await AccountMgr()
          .currentAccount
          .epikWallet
          .retrievePledgeApplyWithdraw(widget.minerinfo.owner, amount.trim());

      LoadingDialog.cloasLoadDialog(context);

      if (robj?.isSuccess) {
        String cid = robj
            .data; //bafy2bzaceaa4fwwhrn5oqjsxe5vumlibispulwdzf4uskh4silxlfo4qh6cu6
        _tec_retrieve_apply = null;
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

  onClickRetrieveWithdraw(LoadingButton lbtn, String amount) async
  {

    if(widget.minerinfo==null)
      return;

    double num = StringUtils.parseDouble(amount, 0);
    if (num <= 0) {
      ToastUtils.showToastCenter(RSID.uspav_4.text);
      return;
    }

    closeInput();

    BottomDialog.simpleAuth(
        context, AccountMgr().currentAccount.password, (value) async {
      LoadingDialog.showLoadDialog(context, "",
          touchOutClose: false, backClose: false);

      ResultObj<String> robj = await AccountMgr()
          .currentAccount
          .epikWallet
          .retrievePledgeWithdraw( amount.trim());//widget.minerinfo.minerid,

      LoadingDialog.cloasLoadDialog(context);

      if (robj?.isSuccess) {
        String cid = robj
            .data; //bafy2bzaceaa4fwwhrn5oqjsxe5vumlibispulwdzf4uskh4silxlfo4qh6cu6
        _tec_retrieve_withdraw = null;
        setState(() {});

        MessageDialog.showMsgDialog(
          context,
          title: RSID.minerview_25.text,//"访问流量抵押",
          msg: "${RSID.minerview_26.text}\n$cid",//赎回抵押交易已提交
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
