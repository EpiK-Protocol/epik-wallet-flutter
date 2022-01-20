import 'dart:ui';

import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/model/CreateAccountModel.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/views/wallet/create/createmnemonicview.dart';
import 'package:epikwallet/views/wallet/import/importwalletview.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';

class CreateWalletView extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> getState() {
    return _CreateWalletViewState();
  }
}

class _CreateWalletViewState extends BaseWidgetState<CreateWalletView> {
  String keyword_1 = "";
  String keyword_2 = "";
  TextEditingController _controllerKeyword_1, _controllerKeyword_2;

  String accountName = "";
  TextEditingController _controllerAccount;

  @override
  void initState() {
    super.initState();
  }

  @override
  void initStateConfig() {
    isTopBarShow = true; //状态栏是否显示
    isAppBarShow = true; //导航栏是否显示
    resizeToAvoidBottomPadding = true;
    setAppBarTitle("");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // setAppBarTitle(RSID.cwtv_1.text);
  }

  @override
  Widget buildWidget(BuildContext context) {
    if (_controllerKeyword_1 == null)
      _controllerKeyword_1 = new TextEditingController.fromValue(TextEditingValue(
        text: keyword_1,
        selection: new TextSelection.fromPosition(
          TextPosition(affinity: TextAffinity.downstream, offset: keyword_1.length),
        ),
      ));

    if (_controllerKeyword_2 == null)
      _controllerKeyword_2 = new TextEditingController.fromValue(TextEditingValue(
        text: keyword_2,
        selection: new TextSelection.fromPosition(
          TextPosition(affinity: TextAffinity.downstream, offset: keyword_2.length),
        ),
      ));

    if (_controllerAccount == null)
      _controllerAccount = new TextEditingController.fromValue(TextEditingValue(
        text: accountName,
        selection: new TextSelection.fromPosition(
          TextPosition(affinity: TextAffinity.downstream, offset: accountName.length),
        ),
      ));

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: getScreenHeight() - BaseFuntion.topbarheight - BaseFuntion.appbarheight_def,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(height: 20),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 20),
              child: Text(
                ResString.get(context, RSID.cwtv_1), //"创建EpiK Portal钱包",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
              child: Text(
                ResString.get(context, RSID.iwv_2),
                // "请备份好您的密码！EpiK Portal不存储用户密码，无法提供找回或重置的服务。",
                style: TextStyle(
                  color: Colors.white, //Colors.redAccent,
                  fontSize: 14,
                ),
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(15, 25, 15, 15),
            //   child: Text(
            //     ResString.get(context, RSID.iwv_6), // "钱包名称",
            //     style: TextStyle(
            //       color: Colors.black,
            //       fontSize: 15,
            //     ),
            //   ),
            // ),
            getInputWidget(
              accountName,
              RSID.iwv_6.text,
              RSID.iwv_7.text, //iwv_7"请输入钱包名称",
              _controllerAccount,
              (text) {
                dlog(text); // 当输入内容变更时,如何处理
                setState(() {
//              text = RegExpUtil.re_noChs.stringMatch(text) ?? "";
                  dlog(text);
                  accountName = text.trim();
                });
              },
              () {
                setState(
                  () {
                    accountName = "";
                    _controllerAccount = null;
                  },
                );
              },
              isPassword: false,
            ),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
            //   child: Text(
            //     ResString.get(context, RSID.iwv_8), // "钱包密码",
            //     style: TextStyle(
            //       color: Colors.black,
            //       fontSize: 15,
            //     ),
            //   ),
            // ),
            getInputWidget(
              keyword_1,
              RSID.iwv_8.text,
              RSID.iwv_10.text, //iwv_9"请输入钱包密码",
              _controllerKeyword_1,
              (text) {
                dlog(text); // 当输入内容变更时,如何处理
                setState(() {
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
            // Container(
            //   padding: EdgeInsets.fromLTRB(15, 5, 15, 10),
            //   alignment: Alignment.centerRight,
            //   child: Text(
            //     ResString.get(context, RSID.iwv_10), //"*建议大小写字母、符号、数字组合 8位以上",
            //     style: TextStyle(
            //       color: ResColor.black_50,
            //       fontSize: 10,
            //     ),
            //   ),
            // ),
            getInputWidget(
              keyword_2,
              RSID.iwv_11.text,
              RSID.iwv_10.text, //iwv_11"请确认钱包密码",
              _controllerKeyword_2,
              (text) {
                dlog(text); // 当输入内容变更时,如何处理
                setState(() {
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
            LoadingButton(
              margin: EdgeInsets.fromLTRB(30, 40, 30, 0),
              gradient_bg: ResColor.lg_1,
              color_bg: Colors.transparent,
              disabledColor: Colors.transparent,
              height: 40,
              text: RSID.next_step.text,
              // "下一步",
              textstyle: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              bg_borderradius: BorderRadius.circular(4),
              onclick: (lbtn) {
                clickNext();
              },
            ),
            InkWell(
              onTap: () {
                clickToImport();
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 40, 0, 10),
                padding: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: Text(
                  ResString.get(context, RSID.cwtv_2), //"已有钱包？马上导入",
                  style: TextStyle(
                    fontSize: 14,
                    color: ResColor.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getInputWidget(
    String keyword,
    String label,
    String hind,
    TextEditingController controller,
    ValueChanged<String> onChanged,
    VoidCallback onClean, {
    bool isPassword = true,
  }) {
    return Container(
      width: double.infinity,
      height: 77,
      margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.text,
                    //获取焦点时,启用的键盘类型
                    maxLines: 1,
                    // 输入框最大的显示行数
//              maxLength: 20, //允许输入的字符长度/ 右下角有数量提示
                    maxLengthEnforced: true,
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
                      // border: InputBorder.none,
                      // errorBorder: InputBorder.none,
                      // focusedErrorBorder: InputBorder.none,
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      enabledBorder: const UnderlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                          color: ResColor.white_20,
                          width: 1,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                          color: ResColor.white,
                          width: 1,
                        ),
                      ),
                      contentPadding: EdgeInsets.fromLTRB(0, 10, 40, 20),

//                      contentPadding: EdgeInsets.symmetric(vertical: 8.5),
                      hintText: hind,
                      hintStyle: TextStyle(color: ResColor.white_50, fontSize: 14),
                      labelText: label,
                      labelStyle: TextStyle(color: ResColor.white, fontSize: 17),
                    ),
                    cursorWidth: 2.0,
                    //光标宽度
                    cursorRadius: Radius.circular(2),
                    //光标圆角弧度
                    cursorColor: Colors.white,
                    //光标颜色
                    style: TextStyle(fontSize: 17, color: Colors.white),
                    onChanged: onChanged,
                    onSubmitted: (value) {
                      // 当用户确定已经完成编辑时触发
                    }, // 是否隐藏输入的内容
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: (StringUtils.isEmpty(keyword))
                ? Container()
                : SizedBox(
                    width: 40,
                    height: 62,
                    child: IconButton(
                      onPressed: () {
                        onClean();
                      },
                      padding: EdgeInsets.all(0),
                      icon: Icon(Icons.clear_rounded),
                      color: Colors.white,
                      iconSize: 14,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  bool checkPassword() {
    if (StringUtils.isEmpty(accountName)) {
      showToast(ResString.get(context, RSID.iwv_7)); //"请输入钱包名称");
      return false;
    }

    if (StringUtils.isEmpty(keyword_1)) {
      showToast(ResString.get(context, RSID.iwv_9)); //"请输入密码");
      return false;
    }

    if (StringUtils.isEmpty(keyword_2)) {
      showToast(ResString.get(context, RSID.iwv_14)); //"请输入确认密码");
      return false;
    }

    if (keyword_1 != keyword_2) {
      showToast(ResString.get(context, RSID.iwv_15)); //"两次输入的密码必须一致");
      return false;
    }

    if (keyword_1.length < 8) {
      showToast(ResString.get(context, RSID.iwv_16)); //"密码至少需要8位");
      return false;
    }

    return true;
  }

  clickNext() {
    if (!checkPassword()) {
      return;
    }

    closeInput();

    CreateAccountModel cam = CreateAccountModel();
    cam.password = this.keyword_1;
    cam.accountname = this.accountName;

    ViewGT.showView(context, CreateMnemonicView(cam), model: ViewPushModel.PushReplacement);
  }

  clickToImport() {
    closeInput();

    ViewGT.showView(context, ImportWalletView(), model: ViewPushModel.PushReplacement);
  }
}
