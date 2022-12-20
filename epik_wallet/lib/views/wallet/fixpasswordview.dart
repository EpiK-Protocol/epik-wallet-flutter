import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:epikwallet/localstring/resstringid.dart';

class FixPasswordView extends BaseWidget {
  WalletAccount walletaccount;

  FixPasswordView(this.walletaccount);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _FixPasswordViewState();
  }
}

class _FixPasswordViewState extends BaseWidgetState<FixPasswordView> {
  String keyword_1 = "";
  String keyword_2 = "";
  TextEditingController _controllerKeyword_1, _controllerKeyword_2;

  @override
  void initState() {
    super.initState();
  }

  @override
  void initStateConfig() {
    isTopBarShow = true; //状态栏是否显示
    isAppBarShow = true; //导航栏是否显示
    setAppBarTitle("");
    resizeToAvoidBottomPadding = true;
  }

  SystemUiOverlayStyle oldSystemUiOverlayStyle;

  @override
  void onCreate() {
    super.onCreate();
    oldSystemUiOverlayStyle = DeviceUtils.system_bar_current;
    DeviceUtils.setSystemBarStyle(DeviceUtils.system_bar_dark);
  }

  @override
  void dispose() {
    if (oldSystemUiOverlayStyle != null)
      DeviceUtils.setSystemBarStyle(oldSystemUiOverlayStyle);
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    if (_controllerKeyword_1 == null)
      _controllerKeyword_1 =
          new TextEditingController.fromValue(TextEditingValue(
        text: keyword_1,
        selection: new TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream, offset: keyword_1.length),
        ),
      ));

    if (_controllerKeyword_2 == null)
      _controllerKeyword_2 =
          new TextEditingController.fromValue(TextEditingValue(
        text: keyword_2,
        selection: new TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream, offset: keyword_2.length),
        ),
      ));

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: getScreenHeight() -
              BaseFuntion.topbarheight -
              BaseFuntion.appbarheight_def,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(15, 6, 15, 10),
              child: Text(
                ResString.get(context, RSID.fpv_1), //"修改EpiK Portal钱包密码",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
              child: Text(
                ResString.get(context, RSID.iwv_2),
                //"请备份好您的密码！EpiK Portal不存储用户密码，无法提供找回或重置的服务。",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: Text(
                ResString.get(context, RSID.fpv_3), //"新的钱包密码",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
            getInputWidget(
              keyword_1,
              ResString.get(context, RSID.iwv_9), //"请输入钱包密码",
              _controllerKeyword_1,
              (text) {
                dlog(text); // 当输入内容变更时,如何处理
                setState(() {
                  text = _controllerKeyword_1.text;
                  text = RegExpUtil.re_noChs.stringMatch(text) ?? "";
                  dlog(text);
                  keyword_1 = text;
                });
              },
              () {
                setState(() {
                  keyword_1 = "";
                  _controllerKeyword_1 = null;
                });
              },
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15, 5, 15, 10),
              alignment: Alignment.centerRight,
              child: Text(
                ResString.get(context, RSID.iwv_10), //"*建议大小写字母、符号、数字组合 8位以上",
                style: TextStyle(
                  color: ResColor.black_50,
                  fontSize: 10,
                ),
              ),
            ),
            getInputWidget(
              keyword_2,
              ResString.get(context, RSID.iwv_11), //"请确认钱包密码",
              _controllerKeyword_2,
              (text) {
                dlog(text); // 当输入内容变更时,如何处理
                setState(() {
                  text = _controllerKeyword_2.text;
                  text = RegExpUtil.re_noChs.stringMatch(text) ?? "";
                  keyword_2 = text;
                });
              },
              () {
                setState(() {
                  keyword_2 = "";
                  _controllerKeyword_2 = null;
                });
              },
            ),
            // Container(
            //   margin: EdgeInsets.fromLTRB(15, 50, 15, 0),
            //   height: 44,
            //   child: Row(
            //     children: <Widget>[
            //       Expanded(
            //         child: Container(
            //           height: 44,
            //           child: FlatButton(
            //             highlightColor: Colors.white24,
            //             splashColor: Colors.white24,
            //             onPressed: () {
            //               clickNext();
            //             },
            //             child: Text(
            //               ResString.get(context, RSID.fpv_4), //  "确定修改密码",
            //               style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 15,
            //               ),
            //             ),
            //             color: ResColor.white_50,
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.all(Radius.circular(22)),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            LoadingButton(
              margin: EdgeInsets.fromLTRB(15, 50, 15, 0),
              width: double.infinity,
              height: 40,
              gradient_bg: ResColor.lg_1,
              color_bg: Colors.transparent,
              disabledColor: Colors.transparent,
              bg_borderradius: BorderRadius.circular(4),
              text: RSID.fpv_4.text,
              textstyle: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              onclick: (lbtn) {
                clickNext();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget getInputWidget(
    String keyword,
    String hind,
    TextEditingController controller,
    ValueChanged<String> onChanged,
    VoidCallback onClean, {
    bool isPassword = true,
  }) {
    return Container(
      width: double.infinity,
      height: 44,
      margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
      decoration: BoxDecoration(
        color: Color(0xff393E45),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(width: 5),
          Container(
            width: 44,
            height: 44,
            child: Icon(
              isPassword ? Icons.lock_outline : OMIcons.accountBalanceWallet,
              size: 20,
              color: Colors.white,
            ),
          ),
          Expanded(
            flex: 1,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.text,
              //获取焦点时,启用的键盘类型
              maxLines: 1,
              // 输入框最大的显示行数
//              maxLength: 20, //允许输入的字符长度/ 右下角有数量提示
//               maxLengthEnforced: true,
              //是否允许输入的字符长度超过限定的字符长度
              obscureText: isPassword,
              //是否是密码
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
              ],
              //WhitelistingTextInputFormatter(RegExpUtil.re_azAZ09)
              // 这里限制长度 不会有数量提示
              decoration: InputDecoration(
                // 以下属性可用来去除TextField的边框
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(0, -3, 0, 0),
//                      contentPadding: EdgeInsets.symmetric(vertical: 8.5),
                hintText: hind,
                hintStyle: TextStyle(color: ResColor.white_80, fontSize: 16),
              ),
              cursorWidth: 2.0,
              //光标宽度
              cursorRadius: Radius.circular(2),
              //光标圆角弧度
              cursorColor: Colors.white,
              //光标颜色
              style: TextStyle(fontSize: 16, color: Colors.white),
              onChanged: onChanged,
              onSubmitted: (value) {
                // 当用户确定已经完成编辑时触发
              }, // 是否隐藏输入的内容
            ),
          ),
          (StringUtils.isEmpty(keyword))
              ? Container()
              : SizedBox(
                  width: 30,
                  height: 40,
                  child: IconButton(
                    onPressed: () {
                      onClean();
                    },
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.clear),
                    color: Colors.white,
                    iconSize: 14,
                  ),
                ),
          Container(width: 5),
        ],
      ),
    );
  }

  bool checkPassword() {
    if (StringUtils.isEmpty(keyword_1)) {
//      showToast("请输入密码");
      showToast(ResString.get(context, RSID.iwv_9));
      return false;
    }

    if (StringUtils.isEmpty(keyword_2)) {
//      showToast("请输入确认密码");
      showToast(ResString.get(context, RSID.iwv_14));
      return false;
    }

    if (keyword_1 != keyword_2) {
//      showToast("两次输入的密码必须一致");
      showToast(ResString.get(context, RSID.iwv_15));
      return false;
    }

    if (keyword_1.length < 8) {
//      showToast("密码至少需要8位");
      showToast(ResString.get(context, RSID.iwv_16));
      return false;
    }

    return true;
  }

  clickNext() {
    if (!checkPassword()) {
      return;
    }

    closeInput();

    MessageDialog.showMsgDialog(
      context,
      title: ResString.get(context, RSID.tip),
      // "提示",
      msg: ResString.get(context, RSID.fpv_5),
      // "您确定已牢记新的密码并修改钱包密码吗?",
      btnLeft: ResString.get(context, RSID.cancel),
      // 取消,
      btnRight: ResString.get(context, RSID.confirm),
      //"确定",
      onClickBtnLeft: (dialog) {
        dialog.dismiss();
      },
      onClickBtnRight: (dialog) {
        widget.walletaccount.password = keyword_1;
        AccountMgr().save();
        dialog.dismiss();
        Future.delayed(Duration(milliseconds: 200)).then((value) => finish());
      },
    );
  }
}
