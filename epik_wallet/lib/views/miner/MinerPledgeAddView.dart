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

class MinerPledgeAddView extends StatefulWidget {
  MinerInfo minerinfo;

  MinerPledgeAddView(this.minerinfo, {Key key}) : super(key: key);

  @override
  State<MinerPledgeAddView> createState() {
    return MinerPledgeAddViewState();
  }
}

class MinerPledgeAddViewState extends State<MinerPledgeAddView> {
  TextEditingController _tec_base, _tec_retrieve, _tec_retrieve_bind;

  String getDesText() {
    // return "注意：\n- 知识矿工需要启动实体矿机才能参与挖矿\n- 知识矿工需要完成1000EPK的矿工基础抵押才能获得出块资格\n- 知识矿工需要从网络里读取新文件，存储新文件才能增加算力，增大出块概率 \n- 1EPK=10Mb的每日访问流量，每日已用访问流量将会返还\n- 您可以在任何时候赎回抵押的EPK";
    return RSID.minerview_15.text;
  }

  @override
  Widget build(BuildContext context) {
    CurrencyAsset epk =
        AccountMgr().currentAccount.getCurrencyAssetByCs(CurrencySymbol.AIEPK);
    String balance = StringUtils.formatNumAmount(epk?.balance ?? "0",
        supply0: false, point: 8);

    if (_tec_base == null)
      _tec_base = new TextEditingController.fromValue(TextEditingValue(
        text: "",
        selection: new TextSelection.fromPosition(
          TextPosition(affinity: TextAffinity.downstream, offset: "".length),
        ),
      ));

    if (_tec_retrieve == null)
      _tec_retrieve = new TextEditingController.fromValue(TextEditingValue(
        text: "",
        selection: new TextSelection.fromPosition(
          TextPosition(affinity: TextAffinity.downstream, offset: "".length),
        ),
      ));

    if(_tec_retrieve_bind==null)
      _tec_retrieve_bind = new TextEditingController.fromValue(TextEditingValue(
        text: "",
        selection: new TextSelection.fromPosition(
          TextPosition(affinity: TextAffinity.downstream, offset: "".length),
        ),
      ));

    List<Widget> items = [
      getRowText(RSID.minerview_10.text, "${balance}${RSID.minerview_16.text}"),//矿工基础抵押  000 EPK 可用
      getInputRow(
          controller: _tec_base, btnText: RSID.minerview_4.text, onClick: onClickBaseAdd),//添加
      Container(
        height: 20,
      ),
      getRowText(RSID.minerview_17.text, "${balance}${RSID.minerview_16.text}"),//"访问流量抵押"  000 EPK 可用
      getInputRow(
          controller: _tec_retrieve,
          btnText: RSID.minerview_4.text,//"添加",
          onClick: onClickRetrieveAdd),
      // Container(
      //   height: 20,
      // ),
      // getRowText("访问流量抵押绑定", "${balance} EPK 可用"),
      // getInputRow(
      //     controller: _tec_retrieve_bind,
      //     btnText: "绑定",
      //     onClick: onClickRetrieveBindAdd),
      Container(
        margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
        width: double.infinity,
        child: Text(
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

  Widget getInputRow(
      {TextEditingController controller,
      String btnText = "",
      Key btnkey,
      Function(LoadingButton lbtn, String amount) onClick}) {
    Widget input = Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xff424242),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        //获取焦点时,启用的键盘类型
        maxLines: 1,
//              maxLength: 20, //允许输入的字符长度/ 右下角有数量提示
//         maxLengthEnforced: true,
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
          hintStyle: TextStyle(
            color: ResColor.white,
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
          key: btnkey,
          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
          width: 62,
          height: 40,
          gradient_bg: ResColor.lg_2,
          color_bg: Colors.transparent,
          disabledColor: Colors.transparent,
          bg_borderradius: BorderRadius.circular(4),
          text: btnText,
          textstyle: TextStyle(
            color: Colors.white,
            fontSize: LocaleConfig.currentIsZh()?17:12,
            fontWeight: FontWeight.bold,
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

  onClickBaseAdd(LoadingButton lbtn, String amount) async {

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
          .minerPledgeAdd(widget.minerinfo.minerid, amount.trim());

      LoadingDialog.cloasLoadDialog(context);

      if (robj?.isSuccess) {
        String cid = robj
            .data; //bafy2bzaceaa4fwwhrn5oqjsxe5vumlibispulwdzf4uskh4silxlfo4qh6cu6
        _tec_base = null;
        setState(() {});

        MessageDialog.showMsgDialog(
          context,
          title: RSID.minerview_10.text,//"矿工基础抵押",
          msg: "${RSID.minerview_18.text}\n$cid",//交易已提交
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

  onClickRetrieveAdd(LoadingButton lbtn, String amount) {

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


      // 流量抵押 需要用owner  不是用minerid
      ResultObj<String> robj = await AccountMgr()
          .currentAccount
          .epikWallet
          .retrievePledgeAdd(widget.minerinfo.owner,""/*widget.minerinfo.minerid*/, amount.trim());

      LoadingDialog.cloasLoadDialog(context);

      if (robj?.isSuccess) {
        String cid = robj
            .data; //bafy2bzaceaa4fwwhrn5oqjsxe5vumlibispulwdzf4uskh4silxlfo4qh6cu6
        // getting key address: failed to get account actor state for f022202: unknown actor code bafkqaetfobvs6mjpon2g64tbm5sw22lomvza
        _tec_base = null;
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
