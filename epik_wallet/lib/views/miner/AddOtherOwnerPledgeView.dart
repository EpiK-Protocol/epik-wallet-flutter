import 'package:epikplugin/epikplugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';

import '../../base/_base_widget.dart';
import '../../dialog/bottom_dialog.dart';
import '../../dialog/loading_dialog.dart';
import '../../dialog/message_dialog.dart';
import '../../localstring/resstringid.dart';
import '../../logic/account_mgr.dart';
import '../../logic/api/serviceinfo.dart';
import '../../model/CurrencyAsset.dart';
import '../../model/currencytype.dart';
import '../../utils/RegExpUtil.dart';
import '../../utils/res_color.dart';
import '../../utils/string_utils.dart';
import '../../utils/toast/toast.dart';
import '../../widget/LoadingButton.dart';
import '../viewgoto.dart';

/// 给其他owner增加质押
class AddOtherOwnerPledgeView extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> getState() {
    return AddOtherOwnerPledgeViewState();
  }
}

class AddOtherOwnerPledgeViewState extends BaseWidgetState<AddOtherOwnerPledgeView> {

  TextEditingController _tec_id, _tec_amount;
  FocusNode _fn_id=FocusNode(), _fn_amount=FocusNode();

  @override
  void initStateConfig() {
    super.initStateConfig();
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(RSID.aoopv_1.text);//"其他Owner");
  }

  @override
  Widget buildWidget(BuildContext context) {
    Widget view = SingleChildScrollView(
      child: Column(
        children: [
          getInputCard(),
        ],
      ),
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
            top: getAppBarHeight() + getTopBarHeight()+45,
            bottom: 0,
            child: view,
          ),
        ],
      ),
    );
  }

  Widget getInputCard()
  {
    List<Widget> items = [];

    CurrencyAsset epk = AccountMgr().currentAccount.getCurrencyAssetByCs(CurrencySymbol.EPK);
    String balance = StringUtils.formatNumAmount(epk?.balance ?? "0",
        supply0: false, point: 2);


    if (_tec_id == null)
      _tec_id = new TextEditingController.fromValue(TextEditingValue(
        text: "",
        selection: new TextSelection.fromPosition(
          TextPosition(affinity: TextAffinity.downstream, offset: "".length),
        ),
      ));

    if (_tec_amount== null)
      _tec_amount = new TextEditingController.fromValue(TextEditingValue(
        text: "",
        selection: new TextSelection.fromPosition(
          TextPosition(affinity: TextAffinity.downstream, offset: "".length),
        ),
      ));

    items.add(Text(
      "OwnerID",
      style: const TextStyle(
        fontSize: 14,
        color: Colors.white,
        fontWeight:FontWeight.bold,
      ),
    ));

    items.add(
      Container(
      height: 40,
      margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
      decoration: BoxDecoration(
        color: const Color(0xff424242),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: _tec_id,
        focusNode: _fn_id,
        keyboardType: TextInputType.text,
        //获取焦点时,启用的键盘类型
        maxLines: 1,
//              maxLength: 20, //允许输入的字符长度/ 右下角有数量提示
        obscureText: false,
        //是否是密码
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExpUtil.re_azAZ09),
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
          hintText: "f0xxxx",
          hintStyle: TextStyle(
            color: ResColor.white_40,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        cursorWidth: 2.0,
        //光标宽度
        cursorRadius: Radius.circular(2),
        //光标圆角弧度
        cursorColor: Colors.white,
        //光标颜色
        style: TextStyle(
          fontSize: 17,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        onChanged: (value) {
          // setState(() {
          //   // to_address = _controllerToAddress.text.trim();
          // });
        },
        onSubmitted: (value) {
          FocusScope.of(context).requestFocus(_fn_amount);
        }, // 是否隐藏输入的内容
      ),
    ),
    );
    items.add(Row(
      children: [
        Text(
          RSID.aoopv_2.text,//"流量质押数量",
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight:FontWeight.bold,
          ),
        ),
       Expanded(
         child:  Text(
           "${balance}${RSID.minerview_16.text}",
           textAlign: TextAlign.right,
           style: const TextStyle(
             fontSize: 12,
             color: Colors.white60,
           ),
         ),
       ),
      ],
    ));

    items.add(
      Container(
        height: 40,
        margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
        decoration: BoxDecoration(
          color: const Color(0xff424242),
          borderRadius: BorderRadius.circular(4),
        ),
        child: TextField(
          controller: _tec_amount,
          focusNode: _fn_amount,
          keyboardType: TextInputType.text,
          //获取焦点时,启用的键盘类型
          maxLines: 1,
//              maxLength: 20, //允许输入的字符长度/ 右下角有数量提示
          obscureText: false,
          //是否是密码
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExpUtil.re_float),
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
            hintStyle: TextStyle(
              color: ResColor.white_40,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          cursorWidth: 2.0,
          //光标宽度
          cursorRadius: Radius.circular(2),
          //光标圆角弧度
          cursorColor: Colors.white,
          //光标颜色
          style: TextStyle(
            fontSize: 17,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          onChanged: (value) {
            // setState(() {
            //   // to_address = _controllerToAddress.text.trim();
            // });
          },
          onSubmitted: (value) {
            closeInput();
          }, // 是否隐藏输入的内容
        ),
      ),
    );

    items.add(LoadingButton(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      padding: EdgeInsets.only(bottom: 1),
      width: double.infinity,
      height: 40,
      gradient_bg: ResColor.lg_2,
      color_bg: Colors.transparent,
      disabledColor: Colors.transparent,
      bg_borderradius: BorderRadius.circular(4),
      text: RSID.aoopv_3.text,//"增加流量质押",
      textstyle: TextStyle(
        color: Colors.white,
        fontSize: 17,//LocaleConfig.currentIsZh() ? 12 : 12,
        fontWeight: FontWeight.bold,
      ),
      onclick: (lbtn) {
        //输入 要增加的owner质押
        String ownerid=_tec_id.text;
        String amount_str =_tec_amount.text;
        onClickRetrieveAdd(ownerid,amount_str);
      },
    ),);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ResColor.b_2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: items,
      ),
    );
  }

  ///添加流量抵押
  onClickRetrieveAdd(String ownerID,String amount) {
    if(StringUtils.isEmpty(ownerID))
    {
      ToastUtils.showToastCenter(RSID.aoopv_4.text);//"请输入OwnerID");
      return;
    }


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


      // 流量抵押 需要用owner  不是用minerid
      ResultObj<String> robj = await AccountMgr()
          .currentAccount
          .epikWallet
          .retrievePledgeAdd(ownerID,""/*widget.minerinfo.minerid*/, amount.trim());

      LoadingDialog.cloasLoadDialog(context);

      if (robj?.isSuccess) {
        String cid = robj
            .data; //bafy2bzaceaa4fwwhrn5oqjsxe5vumlibispulwdzf4uskh4silxlfo4qh6cu6
        // getting key address: failed to get account actor state for f022202: unknown actor code bafkqaetfobvs6mjpon2g64tbm5sw22lomvza
        _tec_id=null;
        _tec_amount=null;
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
}
