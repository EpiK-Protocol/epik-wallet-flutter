import 'dart:async';

import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/dialog/loading_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/LocalAddressMgr.dart';
import 'package:epikwallet/logic/LocalAuthUtils.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_AIBot.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/model/AIBotApp.dart';
import 'package:epikwallet/model/CurrencyAsset.dart';
import 'package:epikwallet/model/auth/RemoteAuth.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/ClickUtil.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/EnumEx.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/utils/toast/toast.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/jsonform/JsonFormWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:jazzicon/jazzicon.dart';

class BottomDialog {
  static Future showBottomPop(
    BuildContext context,
    Widget widget, {
    double radius_top = 20, //15,
    Color bgColor = ResColor.b_4, //Colors.white,
    bool dragClose = true, // 是否可以向下拖拽关闭
    bool outbackClose = true, // 是否可以外部返回关闭  触摸外部阴影、back按键
  }) {
    return showModalBottomSheet(
        context: context,
        //可滚动 解除showModalBottomSheet最大显示屏幕一半的限制
        isScrollControlled: true,
        enableDrag: dragClose,
        //向下拖拽关闭
        //圆角
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius_top)),
        ),
        //背景颜色
        backgroundColor: bgColor,
        builder: (BuildContext context) {
          return AnimatedPadding(
            //showModalBottomSheet 键盘弹出时自适应
            padding: MediaQuery.of(context).viewInsets, //边距（必要） //键盘高度
            // padding: EdgeInsets.all(0),
            duration: const Duration(milliseconds: 100), //动画时长 （必要）
            child: Container(
              // height: 180,
              constraints: BoxConstraints(
                minHeight: 90, //设置最小高度（必要）
                maxHeight: MediaQuery.of(context).size.height / 1.5, //设置最大高度（必要）
              ),
//              padding: EdgeInsets.only(top: 34, bottom: 48),
//              decoration: BoxDecoration(
//                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//                  color: Colors.white), //圆角
              child: ListView(
                shrinkWrap: true, //防止状态溢出 自适应大小
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  WillPopScope(
                    onWillPop: () async {
                      if (outbackClose) {
                        return true;
                      } else {
                        // print("bottomdialog WillPopScope false");
                        return false;
                      }
                    },
                    child: widget,
                  ),
                ],
              ),
            ),
          );
        });
  }

  //优先使用指纹 面部识别  如果不成功 改用密码
  static Future simpleAuth(@required BuildContext context, String verifyText, @required ValueChanged<String> callback,
      {String secretVerifyText}) async {
    if (AccountMgr()?.currentAccount?.biometrics == true && await LocalAuthUtils.checkBiometrics() == true) {
      bool value = await LocalAuthUtils.authenticate();
      Dlog.p("simpleAuth", "authenticate $value");
      switch (value) {
        case true:
          {
            callback(verifyText);
          }
          break;
        case false:
        default:
          {
            //切换到密码输入
            return showPassWordInputDialog(context, verifyText, callback, secretVerifyText: secretVerifyText);
          }
          break;
      }
    } else {
      return showPassWordInputDialog(context, verifyText, callback, secretVerifyText: secretVerifyText);
    }
  }

  ///密码输入弹窗
  static Future showPassWordInputDialog(
      @required BuildContext context, String verifyText, @required ValueChanged<String> callback,
      {String secretVerifyText}) {
    String password = "";
    TextEditingController tec = TextEditingController(text: password);

    Widget widget = Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 58,
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: FractionalOffset.center,
                  child: Text(
                    ResString.get(context, RSID.dlg_bd_1), //"钱包密码",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: FractionalOffset.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // 关闭
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 58,
                      height: 58,
                      color: Colors.transparent,
                      child: Icon(
                        Icons.close,
                        color: ResColor.white_60, //Color(0xff666666),
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 44,
            padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: TextField(
              autofocus: true,
              //自动获取焦点， 自动弹出输入法
              controller: tec,
              textAlign: TextAlign.left,
              keyboardType: TextInputType.text,
              //获取焦点时,启用的键盘类型
              maxLines: 1,
              // 输入框最大的显示行数
              // maxLengthEnforced: true,
              //是否允许输入的字符长度超过限定的字符长度
              obscureText: true,
              //是否是密码
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
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
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                hintText: ResString.get(context, RSID.dlg_bd_2),
                //"请输入钱包密码",
                // hintStyle: TextStyle(color: Color(0xff999999), fontSize: 16),
                hintStyle: TextStyle(color: ResColor.white_60, fontSize: 17),
              ),
              cursorWidth: 2.0,
              //光标宽度
              cursorRadius: Radius.circular(2),
              //光标圆角弧度
              cursorColor: Colors.white,
              //光标颜色
              style: TextStyle(fontSize: 17, color: Colors.white),
              onChanged: (text) {
                text = RegExpUtil.re_noChs.stringMatch(text) ?? "";

                //输入密码时震动
                if ((text?.length ?? 0) > (password?.length ?? 0)) {
                  Vibrate.canVibrate.then((ok) {
                    Vibrate.feedback(FeedbackType.medium);
                  });
                }

                password = text;
              },
              onSubmitted: (value) {
                // 当用户确定已经完成编辑时触发
              }, // 是否隐藏输入的内容
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: ResColor.white_20,
            //Colors.blue,
            indent: 30,
            endIndent: 30,
          ),
          LoadingButton(
            margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
            width: double.infinity,
            height: 40,
            gradient_bg: ResColor.lg_1,
            color_bg: Colors.transparent,
            disabledColor: Colors.transparent,
            bg_borderradius: BorderRadius.circular(4),
            text: RSID.confirm.text,
            //"确定",
            textstyle: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            onclick: (lbtn) {
              if (StringUtils.isEmpty(password)) {
//                  ToastUtils.showToast("请输入密码");
                ToastUtils.showToast(ResString.get(context, RSID.dlg_bd_3));
                return;
              }

              if (StringUtils.isEmpty(verifyText)) {
                Navigator.pop(context);
                callback(password);
              } else {
                if (StringUtils.isNotEmpty(secretVerifyText) && password == (verifyText + secretVerifyText)) {
                  Navigator.pop(context);
                  callback(password);
                  return;
                }

                if (verifyText != password) {
//                    ToastUtils.showToast("密码不正确");
                  ToastUtils.showToast(ResString.get(context, RSID.dlg_bd_4));
                } else {
                  Navigator.pop(context);
                  callback(password);
                }
              }
            },
          ),
        ],
      ),
    );

    return showBottomPop(
      context,
      widget,
    );
  }

  ///密码输入弹窗
  static Future showWeb3PassWordInputDialog(
    @required BuildContext context, {
    @required String verifyText,
    @required String title,
    String msg,
    Color msgColor = ResColor.white_80, //Color(0xff333333
    TextAlign msgAlign = TextAlign.left,
    bool dragClose = false, // 是否可以向下拖拽关闭
    bool outbackClose = false, // 是否可以外部返回关闭  触摸外部阴影、back按键
    Widget header,
    Widget footer,
    bool autoinputverifyText = false, //自动输入密码 已开启免密码
    bool useSimpleAuth = true, //可以使用密码或指纹,单独弹出
    VoidCallback cancelCallback,
    @required ValueChanged<String> callback,
  }) {
    String password = "";
    if (autoinputverifyText) password = verifyText;
    TextEditingController tec = TextEditingController(text: password);

    Function btnOnClick = (LoadingButton lbtn) {
      if (useSimpleAuth == true) {
        if (autoinputverifyText == true) {
          //免密
          Navigator.pop(context);
          Future.delayed(Duration(milliseconds: 10)).then((value) {
            try {
              callback(password);
            } catch (e) {
              print(e);
            }
          });
        } else {
          //使用SimpleAuth验证
          simpleAuth(context, verifyText, (value) async {
            await Future.delayed(Duration(milliseconds: 200));
            Navigator.pop(context);
            Future.delayed(Duration(milliseconds: 10)).then((value) {
              try {
                callback(password);
              } catch (e) {
                print(e);
              }
            });
          });
        }
        return;
      }

      if (StringUtils.isEmpty(password)) {
        ToastUtils.showToast(ResString.get(context, RSID.dlg_bd_3)); //请输入密码
        return;
      }

      if (verifyText != password) {
        ToastUtils.showToast(ResString.get(context, RSID.dlg_bd_4)); //密码不正确
      } else {
        Navigator.pop(context);
        Future.delayed(Duration(milliseconds: 10)).then((value) {
          try {
            callback(password);
          } catch (e) {
            print(e);
          }
        });
      }
    };

    Widget widget = Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 58,
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: FractionalOffset.center,
                  child: Text(
                    title ?? ResString.get(context, RSID.dlg_bd_1), //"钱包密码",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: FractionalOffset.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // 关闭
                      Navigator.pop(context);
                      if (cancelCallback != null) {
                        Future.delayed(Duration(milliseconds: 10)).then((value) {
                          try {
                            cancelCallback();
                          } catch (e) {
                            print(e);
                          }
                        });
                      }
                    },
                    child: Container(
                      width: 58,
                      height: 58,
                      color: Colors.transparent,
                      child: Icon(
                        Icons.close,
                        color: ResColor.white_60, //Color(0xff666666),
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (header != null) header,
          // msg
          if (msg?.isNotEmpty == true)
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                msg,
                textAlign: msgAlign,
                style: TextStyle(
                  color: msgColor,
                  fontSize: 14.0,
                ),
              ),
            ),
          if (footer != null) footer,
          if (useSimpleAuth != true)
            Container(
              width: double.infinity,
              height: 44,
              padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: TextField(
                autofocus: autoinputverifyText == true ? false : true,
                //自动获取焦点， 自动弹出输入法
                controller: tec,
                textAlign: TextAlign.left,
                keyboardType: TextInputType.text,
                //获取焦点时,启用的键盘类型
                maxLines: 1,
                // 输入框最大的显示行数
                // maxLengthEnforced: true,
                //是否允许输入的字符长度超过限定的字符长度
                obscureText: true,
                //是否是密码
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20),
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
                  contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  hintText: ResString.get(context, RSID.dlg_bd_2),
                  //"请输入钱包密码",
                  // hintStyle: TextStyle(color: Color(0xff999999), fontSize: 16),
                  hintStyle: TextStyle(color: ResColor.white_60, fontSize: 17),
                ),
                cursorWidth: 2.0,
                //光标宽度
                cursorRadius: Radius.circular(2),
                //光标圆角弧度
                cursorColor: Colors.white,
                //光标颜色
                style: TextStyle(fontSize: 17, color: Colors.white),
                onChanged: (text) {
                  text = RegExpUtil.re_noChs.stringMatch(text) ?? "";

                  //输入密码时震动
                  if ((text?.length ?? 0) > (password?.length ?? 0)) {
                    Vibrate.canVibrate.then((ok) {
                      Vibrate.feedback(FeedbackType.medium);
                    });
                  }

                  password = text;
                },
                onSubmitted: (value) {
                  // 当用户确定已经完成编辑时触发
                }, // 是否隐藏输入的内容
              ),
            ),
          Divider(
            height: 1,
            thickness: 1,
            color: ResColor.white_20,
            //Colors.blue,
            indent: 30,
            endIndent: 30,
          ),
          LoadingButton(
            margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
            width: double.infinity,
            height: 40,
            gradient_bg: ResColor.lg_1,
            color_bg: Colors.transparent,
            disabledColor: Colors.transparent,
            bg_borderradius: BorderRadius.circular(4),
            text: RSID.confirm.text,
            //"确定",
            textstyle: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            onclick: btnOnClick,
          ),
        ],
      ),
    );

    return showBottomPop(
      context,
      widget,
      dragClose: dragClose,
      outbackClose: outbackClose,
    );
  }

  ///普通文本输入弹窗
  static Future showTextInputDialog(
    BuildContext context,
    String title,
    String oldText,
    String hint,
    int maxLength,
    ValueChanged<String> callback, {
    String autoBtnString,
    String autoBtnContent,
    List<TextInputFormatter> inputFormatters = const [],
    TextInputType keyboardType = TextInputType.text,
    bool multipleLine = false,
  }) {
    String _text = oldText ?? "";
    TextEditingController tec = TextEditingController(text: _text);

    Color dialogbg = ResColor.b_4; //Colors.white;
    Color titleColor = Colors.white; //Colors.black;
    Color closeIconColor = Colors.white; //Color(0xff666666);
    Color hintColor = Colors.white70; // Color(0xff999999);
    Color textColor = Colors.white; //Color(0xff333333);
    Color dividerColor = ResColor.white_20; //Colors.blue;

    Widget widget = Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            // height: 58,
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: FractionalOffset.center,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(30, 15, 30, 15),
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: FractionalOffset.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // 关闭
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 58,
                      height: 58,
                      color: Colors.transparent,
                      child: Icon(
                        Icons.close,
                        color: ResColor.white_60, //Color(0xff666666),
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: multipleLine ? 110 : 55,
                  padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                  child: TextField(
                    autofocus: true,
                    //自动获取焦点， 自动弹出输入法
                    controller: tec,
                    textAlign: TextAlign.left,
                    keyboardType: multipleLine ? TextInputType.multiline : TextInputType.text,
                    //获取焦点时,启用的键盘类型
                    maxLines: multipleLine ? 999 : 1,
                    // 输入框最大的显示行数
                    // maxLengthEnforced: true,
                    //是否允许输入的字符长度超过限定的字符长度
                    obscureText: false,
                    //是否是密码
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(maxLength),
                      ...inputFormatters,
                    ],
                    // 这里限制长度 不会有数量提示
                    decoration: InputDecoration(
                      // 以下属性可用来去除TextField的边框
                      border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      enabledBorder: multipleLine
                          ? OutlineInputBorder(
                              gapPadding: 0,
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: dividerColor,
                                width: 1,
                              ),
                            )
                          : InputBorder.none,
                      focusedBorder: multipleLine
                          ? OutlineInputBorder(
                              gapPadding: 0,
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: dividerColor,
                                width: 1,
                              ),
                            )
                          : InputBorder.none,
                      contentPadding:
                          multipleLine ? EdgeInsets.fromLTRB(10, 10, 10, 0) : EdgeInsets.fromLTRB(0, 0, 0, -10),
                      hintText: hint,
                      hintStyle: TextStyle(color: hintColor, fontSize: 17),
                    ),
                    cursorWidth: 2.0,
                    //光标宽度
                    cursorRadius: Radius.circular(2),
                    //光标圆角弧度
                    cursorColor: textColor,
                    //Colors.black,
                    //光标颜色
                    style: TextStyle(fontSize: 16, color: textColor),
                    onChanged: (text) {
                      _text = text;
                    },
                    onSubmitted: (value) {
                      // 当用户确定已经完成编辑时触发
                    }, // 是否隐藏输入的内容
                  ),
                ),
              ),
              if (autoBtnString != null && autoBtnContent != null)
                InkWell(
                  onTap: () {
                    _text = autoBtnContent;
                    // TextEditingController tec = TextEditingController(text: _text);
                    tec.text = _text;
                    tec.selection = new TextSelection.fromPosition(
                      TextPosition(affinity: TextAffinity.downstream, offset: _text.length),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.only(left: 15),
                    child: Text(
                      autoBtnString,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Container(
                width: 30,
              ),
            ],
          ),
          if (multipleLine == false)
            Divider(
              height: 1,
              thickness: 1,
              color: dividerColor,
              indent: 30,
              endIndent: 30,
            ),
          LoadingButton(
            margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
            gradient_bg: ResColor.lg_1,
            color_bg: Colors.transparent,
            disabledColor: Colors.transparent,
            height: 40,
            text: RSID.confirm.text,
            //"确定",
            textstyle: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            bg_borderradius: BorderRadius.circular(4),
            onclick: (lbtn) {
              if (StringUtils.isEmpty(_text.trim())) {
                ToastUtils.showToast(hint);
                return;
              }

              Navigator.pop(context);
              callback(_text);
            },
          ),
          // Container(
          //   height: 44,
          //   width: double.infinity,
          //   margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
          //   padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
          //   child: FlatButton(
          //     highlightColor: Colors.white24,
          //     splashColor: Colors.white24,
          //     onPressed: () {
          //       if (StringUtils.isEmpty(_text.trim())) {
          //         ToastUtils.showToast(hint);
          //         return;
          //       }
          //
          //       Navigator.pop(context);
          //       callback(_text);
          //     },
          //     child: Text(
          //       ResString.get(context, RSID.confirm), //"确定",
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontSize: 15,
          //       ),
          //     ),
          //     color: Color(0xff1A1C1F),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.all(Radius.circular(22)),
          //     ),
          //   ),
          // ),
        ],
      ),
    );

    return showBottomPop(context, widget, radius_top: 15, bgColor: dialogbg);
  }

  /// 交易加速 成功后在callback中返回新的交易hash
  static Future showEthAccelerateTx(BuildContext context, WalletAccount walletaccount, CurrencySymbol cs, String txHash,
      {String oldText = "", ValueChanged<String> callback}) {
    String _text = oldText ?? "";
    TextEditingController tec = new TextEditingController.fromValue(TextEditingValue(
      text: _text,
      selection: new TextSelection.fromPosition(
        TextPosition(affinity: TextAffinity.downstream, offset: _text.length),
      ),
    ));

    String password = "";
    TextEditingController tec_password = TextEditingController(text: password);

    List<String> list_gasrate = ["1.1", "1.2", "1.3", "1.4", "1.5"];

    GlobalKey<LoadingButtonState> lbtnkey = GlobalKey();

    Widget widget = Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 58,
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: FractionalOffset.center,
                  child: Text(
                    RSID.eatd_1.text, //"加速交易",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: FractionalOffset.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // 关闭
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 58,
                      height: 58,
                      color: Colors.transparent,
                      child: Icon(
                        Icons.close,
                        color: ResColor.white_60, //Color(0xff666666),
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 44,
            padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: TextField(
              autofocus: true,
              //自动获取焦点， 自动弹出输入法
              controller: tec,
              textAlign: TextAlign.left,
              keyboardType: TextInputType.text,
              //获取焦点时,启用的键盘类型
              maxLines: 1,
              // 输入框最大的显示行数
              // maxLengthEnforced: true,
              //是否允许输入的字符长度超过限定的字符长度
              obscureText: false,
              //是否是密码
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
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
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                hintText: RSID.eatd_2.text,
                //"输入加速交易的Gas比例",
                //"请输入钱包密码",
                // hintStyle: TextStyle(color: Color(0xff999999), fontSize: 16),
                hintStyle: TextStyle(color: ResColor.white_60, fontSize: 17),
              ),
              cursorWidth: 2.0,
              //光标宽度
              cursorRadius: Radius.circular(2),
              //光标圆角弧度
              cursorColor: Colors.white,
              //光标颜色
              style: TextStyle(fontSize: 17, color: Colors.white),
              onChanged: (text) {
                _text = text;
              },
              onSubmitted: (value) {
                // 当用户确定已经完成编辑时触发
              }, // 是否隐藏输入的内容
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: ResColor.white_20,
            indent: 30,
            endIndent: 30,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              children: list_gasrate.map((e) {
                return Expanded(
                    child: LoadingButton(
                  height: 20,
                  text: e,
                  textstyle: const TextStyle(fontSize: 11, color: ResColor.o_1, fontWeight: FontWeight.bold),
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  bg_borderradius: BorderRadius.circular(4),
                  color_bg: Colors.transparent,
                  disabledColor: Colors.transparent,
                  side: BorderSide(
                    color: ResColor.o_1,
                    width: 1,
                  ),
                  onclick: (lbtn) {
                    tec.text = e;
                    _text = e;
                    tec.selection = new TextSelection.fromPosition(
                      TextPosition(affinity: TextAffinity.downstream, offset: _text.length),
                    );
                  },
                ));
              }).toList(),
            ),
          ),
          Container(
            width: double.infinity,
            height: 44,
            padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: TextField(
              autofocus: true,
              //自动获取焦点， 自动弹出输入法
              controller: tec_password,
              textAlign: TextAlign.left,
              keyboardType: TextInputType.text,
              //获取焦点时,启用的键盘类型
              maxLines: 1,
              // 输入框最大的显示行数
              // maxLengthEnforced: true,
              //是否允许输入的字符长度超过限定的字符长度
              obscureText: true,
              //是否是密码
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
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
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                hintText: ResString.get(context, RSID.dlg_bd_2),
                //"请输入钱包密码",
                // hintStyle: TextStyle(color: Color(0xff999999), fontSize: 16),
                hintStyle: TextStyle(color: ResColor.white_60, fontSize: 17),
              ),
              cursorWidth: 2.0,
              //光标宽度
              cursorRadius: Radius.circular(2),
              //光标圆角弧度
              cursorColor: Colors.white,
              //光标颜色
              style: TextStyle(fontSize: 17, color: Colors.white),
              onChanged: (text) {
                text = RegExpUtil.re_noChs.stringMatch(text) ?? "";
                password = text;
              },
              onSubmitted: (value) {
                // 当用户确定已经完成编辑时触发
              }, // 是否隐藏输入的内容
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: ResColor.white_20,
            indent: 30,
            endIndent: 30,
          ),
          LoadingButton(
            key: GlobalKey(),
            margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
            width: double.infinity,
            height: 40,
            gradient_bg: ResColor.lg_1,
            color_bg: Colors.transparent,
            disabledColor: Colors.transparent,
            bg_borderradius: BorderRadius.circular(4),
            text: RSID.confirm.text,
            //"确定",
            textstyle: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            onclick: (lbtn) async {
              double _gasrate = StringUtils.parseDouble(_text, 0);

              if (_gasrate == null) {
                ToastUtils.showToastCenter(RSID.eatd_3.text); //"请输入加速Gas比例");
                return;
              }
              if (_gasrate < 1) {
                ToastUtils.showToastCenter(RSID.eatd_4.text); //"Gas比例需要>1");
                return;
              }
              if (password != walletaccount.password) {
                ToastUtils.showToastCenter(RSID.eatd_5.text); //"密码错误");
                return;
              }

              //关闭输入法
              try {
                FocusScope.of(context).requestFocus(new FocusNode());
              } catch (e) {
                print(e);
              }

              // 提交加速请求
              lbtn.setLoading(true);

              // ResultObj<String> resultobj = await walletaccount.hdwallet.accelerateTx(txHash, _gasrate);
              ResultObj<String> resultobj = await EpikWalletUtils.hdAccelerateTx(cs, txHash, _gasrate);

              lbtn.setLoading(false);

              if (resultobj.code != 0) {
                Navigator.of(context).pop();
                Future.delayed(Duration(milliseconds: 200)).then((value) {
                  MessageDialog.showMsgDialog(
                    context,
                    title: RSID.tip.text,
                    msg: "ERROR: ${resultobj?.errorMsg ?? RSID.request_failed.text}",
                    btnLeft: RSID.confirm.text,
                    onClickBtnLeft: (dialog) {
                      dialog.dismiss();
                    },
                  );
                });
              } else {
                Navigator.of(context).pop();
                Dlog.p("showEthAccelerateTx", "txhash=$txHash newhash=${resultobj.data}");
                Future.delayed(Duration(milliseconds: 200)).then((value) {
                  MessageDialog.showMsgDialog(
                    context,
                    title: RSID.tip.text,
                    msg: RSID.eatd_6.text,
                    //"加速交易已提交",
                    btnLeft: RSID.confirm.text,
                    onClickBtnLeft: (dialog) {
                      dialog.dismiss();
                    },
                    onDismiss: (dialog) {
                      if (callback != null) {
                        callback(resultobj.data);
                      }
                    },
                  );
                });
              }
            },
          )
        ],
      ),
    );

    return showBottomPop(
      context,
      widget,
    );
  }

  ///远程授权消息  密码输入弹窗  用于EPIK远程付款
  static Future showRemoteAuthMessageDialog(
      BuildContext context, WalletAccount walletaccount, RemoteAuth ra, ValueChanged<String> callback) {
    String password = "";
    TextEditingController tec = TextEditingController(text: password);

    Widget getRow(String left, String right, {bool bold = false}) {
      return Container(
        padding: EdgeInsets.fromLTRB(30, 0, 30, 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              left,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
            Container(
              width: 30,
            ),
            Expanded(
              child: Text(
                right,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: bold ? FontWeight.bold : null,
                ),
              ),
            ),
          ],
        ),
      );
    }

    List<Widget> getRemoteInfo(RemoteAuth _ra) {
      List<Widget> items = [];
      items.add(getRow("from:", walletaccount.epik_EPK_address));
      if (_ra.m != null) {
        _ra.m.forEach((key, value) {
          String left = key ?? "";
          String right = value?.toString() ?? "";
          bool bold = false;
          if (left == "value") {
            try {
              right = StringUtils.bigNumDownsizing(right ?? "0");
              right = StringUtils.formatNumAmount(right, point: 18) + " AIEPK";
              bold = true;
            } catch (e) {
              print(e);
            }
          }
          items.add(getRow(left + ":", right ?? "", bold: bold));
        });
      }
      return items;
    }

    Widget widget = Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 58,
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: FractionalOffset.center,
                  child: Text(
                    RSID.dlg_bd_5.text, //"发送交易",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: FractionalOffset.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // 关闭
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 58,
                      height: 58,
                      color: Colors.transparent,
                      child: Icon(
                        Icons.close,
                        color: ResColor.white_60, //Color(0xff666666),
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...getRemoteInfo(ra),
          Container(
            width: double.infinity,
            height: 44,
            padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: TextField(
              autofocus: true,
              //自动获取焦点， 自动弹出输入法
              controller: tec,
              textAlign: TextAlign.left,
              keyboardType: TextInputType.text,
              //获取焦点时,启用的键盘类型
              maxLines: 1,
              // 输入框最大的显示行数
              // maxLengthEnforced: true,
              //是否允许输入的字符长度超过限定的字符长度
              obscureText: true,
              //是否是密码
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
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
                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                hintText: ResString.get(context, RSID.dlg_bd_2),
                //"请输入钱包密码",
                // hintStyle: TextStyle(color: Color(0xff999999), fontSize: 16),
                hintStyle: TextStyle(color: ResColor.white_60, fontSize: 17),
              ),
              cursorWidth: 2.0,
              //光标宽度
              cursorRadius: Radius.circular(2),
              //光标圆角弧度
              cursorColor: Colors.white,
              //光标颜色
              style: TextStyle(fontSize: 17, color: Colors.white),
              onChanged: (text) {
                text = RegExpUtil.re_noChs.stringMatch(text) ?? "";

                //输入密码时震动
                if ((text?.length ?? 0) > (password?.length ?? 0)) {
                  Vibrate.canVibrate.then((ok) {
                    Vibrate.feedback(FeedbackType.medium);
                  });
                }

                password = text;
              },
              onSubmitted: (value) {
                // 当用户确定已经完成编辑时触发
              }, // 是否隐藏输入的内容
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: ResColor.white_20,
            //Colors.blue,
            indent: 30,
            endIndent: 30,
          ),
          LoadingButton(
            margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
            width: double.infinity,
            height: 40,
            gradient_bg: ResColor.lg_1,
            color_bg: Colors.transparent,
            disabledColor: Colors.transparent,
            bg_borderradius: BorderRadius.circular(4),
            text: RSID.confirm.text,
            //"确定",
            textstyle: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            onclick: (lbtn) {
              if (StringUtils.isEmpty(password)) {
//                  ToastUtils.showToast("请输入密码");
                ToastUtils.showToast(ResString.get(context, RSID.dlg_bd_3));
                return;
              }

              if (walletaccount.password != password) {
//                    ToastUtils.showToast("密码不正确");
                ToastUtils.showToast(ResString.get(context, RSID.dlg_bd_4));
                return;
              }

              Navigator.pop(context);
              try {
                callback(password);
              } catch (e) {
                print(e);
              }
            },
          ),
        ],
      ),
    );

    return showBottomPop(
      context,
      widget,
    );
  }

  ///普通文本输入弹窗
  static Future showTextInputDialogMultiple({
    BuildContext context,
    String title,
    bool autoChangeFocus = true,
    bool autofocus = true,
    bool dragClose = true, // 是否可以向下拖拽关闭
    bool outbackClose = true, // 是否可以外部返回关闭  触摸外部阴影、back按键
    Widget header,
    Widget footer,
    List<TextInputConfigObj> objlist = const [],
    Function(List<String> datas) callback, //输入完成点确定后的回调
    bool onOkClose = true, //点确认后是否关闭dialog
    Function(List<String> datas) onChangeCallback, //输入中更新数据的回调
  }) {
    Color dialogbg = ResColor.b_4; //Colors.white;
    Color titleColor = Colors.white; //Colors.black;
    Color closeIconColor = Colors.white; //Color(0xff666666);
    Color hintColor = Colors.white70; // Color(0xff999999);
    Color textColor = Colors.white; //Color(0xff333333);
    Color dividerColor = ResColor.white_20; //Colors.blue;

    List<TextEditingController> teclist = [];
    List<FocusNode> focuslist = [];

    Function btnclick = () {
      List<String> result = [];

      for (int i = 0; i < teclist.length; i++) {
        TextEditingController tec = teclist[i];
        String value = tec?.text?.trim() ?? "";
        if (value?.isEmpty == true) {
          ToastUtils.showToast(objlist[i]?.hint);
          return;
        }
        result.add(value);
      }

      if (onOkClose) {
        Navigator.pop(context);
      }
      callback(result);
    };

    Function onChange = () {
      List<String> result = [];

      for (int i = 0; i < teclist.length; i++) {
        TextEditingController tec = teclist[i];
        String value = tec?.text?.trim() ?? "";
        // if (value?.isEmpty == true) {
        //   ToastUtils.showToast(objlist[i]?.hint);
        //   return;
        // }
        result.add(value);
      }
      if (onChangeCallback != null) onChangeCallback(result);
    };

    List<Widget> inputlist = [];
    if (objlist != null && objlist.length > 0) {
      objlist.forEach((obj) {
        String _text = obj.oldText ?? "";
        TextEditingController tec = TextEditingController(text: _text);
        teclist.add(tec);

        FocusNode focus = FocusNode();
        focuslist.add(focus);

        Widget row = Row(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                height: 55,
                padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                child: TextField(
                  focusNode: focus,
                  autofocus: autofocus,
                  //自动获取焦点， 自动弹出输入法
                  controller: tec,
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.text,
                  //获取焦点时,启用的键盘类型
                  maxLines: 1,
                  // 输入框最大的显示行数
                  // maxLengthEnforced: true,
                  //是否允许输入的字符长度超过限定的字符长度
                  obscureText: false,
                  //是否是密码
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(obj.maxLength),
                    ...obj.inputFormatters,
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
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 0, -10),
                    hintText: obj.hint,
                    hintStyle: TextStyle(color: hintColor, fontSize: 17),
                  ),
                  cursorWidth: 2.0,
                  //光标宽度
                  cursorRadius: Radius.circular(2),
                  //光标圆角弧度
                  cursorColor: textColor,
                  //Colors.black,
                  //光标颜色
                  style: TextStyle(fontSize: 16, color: textColor),
                  onChanged: (text) {
                    _text = text;
                    if (onChangeCallback != null) onChange();
                  },
                  onSubmitted: (value) {
                    // 当用户确定已经完成编辑时触发

                    if (autoChangeFocus != true) return;

                    int index = focuslist.indexOf(focus);
                    if (index == focuslist.length - 1) {
                      //最后一个输入框
                      btnclick();
                    } else if ((index + 1) < focuslist.length) {
                      //切换到下一个焦点
                      FocusScope.of(appContext).requestFocus(focuslist[index + 1]);
                    }
                  }, // 是否隐藏输入的内容
                ),
              ),
            ),
            if (StringUtils.isNotEmpty(obj.autoBtnString) && StringUtils.isNotEmpty(obj.autoBtnContent))
              InkWell(
                onTap: () {
                  _text = obj.autoBtnContent;
                  // TextEditingController tec = TextEditingController(text: _text);
                  tec.text = _text;
                  tec.selection = new TextSelection.fromPosition(
                    TextPosition(affinity: TextAffinity.downstream, offset: _text.length),
                  );
                },
                child: Container(
                  padding: EdgeInsets.only(left: 15),
                  child: Text(
                    obj.autoBtnString,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Container(
              width: 30,
            ),
          ],
        );
        Widget divider = Divider(
          height: 1,
          thickness: 1,
          color: dividerColor,
          indent: 30,
          endIndent: 30,
        );
        inputlist.add(row);
        inputlist.add(divider);
      });
    }

    Widget widget = Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 58,
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: FractionalOffset.center,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: FractionalOffset.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // 关闭
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 58,
                      height: 58,
                      color: Colors.transparent,
                      child: Icon(
                        Icons.close,
                        color: ResColor.white_60, //Color(0xff666666),
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (header != null) header,
          ...inputlist,
          if (footer != null) footer,
          LoadingButton(
            margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
            gradient_bg: ResColor.lg_1,
            color_bg: Colors.transparent,
            disabledColor: Colors.transparent,
            height: 40,
            text: RSID.confirm.text,
            //"确定",
            textstyle: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            bg_borderradius: BorderRadius.circular(4),
            onclick: (lbtn) {
              btnclick();
              // List<String> result = [];
              //
              // for (int i = 0; i < teclist.length; i++) {
              //   TextEditingController tec = teclist[i];
              //   String value = tec?.text?.trim() ?? "";
              //   if (StringUtils.isEmpty(value)) {
              //     ToastUtils.showToast(objlist[i]?.hint);
              //     return;
              //   }
              //   result.add(value);
              // }
              //
              // Navigator.pop(context);
              // callback(result);
            },
          ),
          // Container(
          //   height: 44,
          //   width: double.infinity,
          //   margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
          //   padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
          //   child: FlatButton(
          //     highlightColor: Colors.white24,
          //     splashColor: Colors.white24,
          //     onPressed: () {
          //       if (StringUtils.isEmpty(_text.trim())) {
          //         ToastUtils.showToast(hint);
          //         return;
          //       }
          //
          //       Navigator.pop(context);
          //       callback(_text);
          //     },
          //     child: Text(
          //       ResString.get(context, RSID.confirm), //"确定",
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontSize: 15,
          //       ),
          //     ),
          //     color: Color(0xff1A1C1F),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.all(Radius.circular(22)),
          //     ),
          //   ),
          // ),
        ],
      ),
    );

    return showBottomPop(
      context,
      widget,
      radius_top: 15,
      bgColor: dialogbg,
      dragClose: dragClose,
      outbackClose: outbackClose,
    );
  }

  static showAddressSeleteDialog(
      BuildContext context, List<LocalAddressObj> data, Function(LocalAddressObj seletedAddress) callback) {
    Widget addressview = StatefulBuilder(
      builder: (context, setState) {
        return Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height / 2,
          ),
          child: Column(
            children: [
              Container(
                height: 58,
                width: double.infinity,
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: FractionalOffset.center,
                      child: Text(
                        RSID.alv_select_address.text, //"选择地址",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Align(
                      alignment: FractionalOffset.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          // 关闭
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 58,
                          height: 58,
                          color: Colors.transparent,
                          child: Icon(
                            Icons.close,
                            color: ResColor.white_60, //Color(0xff666666),
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: data.map((lao) {
                    bool isCurrent = AccountMgr().currentAccount.hd_eth_address == lao.address ||
                        AccountMgr().currentAccount.epik_EPK_address == lao.address;
                    Widget item = Container(
                      width: double.infinity,
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(50),
                                  gradient: lao.useJazzicon ? null : lao.gradientCover,
                                ),
                                child: Stack(
                                  children: [
                                    if (lao.useJazzicon) Jazzicon.getIconWidget(lao.jazziconData),
                                    Align(
                                      alignment: FractionalOffset(0.5, 0.5),
                                      child: Text(
                                        lao.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.clip,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12, color: Colors.white, shadows: [
                                          Shadow(
                                              color: ResColor.black_80, //Color(0x28000000),
                                              offset: Offset(0, 0),
                                              blurRadius: 6)
                                        ]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  lao.name,
                                  style: TextStyle(fontSize: 16, color: isCurrent ? Colors.white54 : Colors.white),
                                ),
                              ),
                              if (isCurrent)
                                Container(
                                  height: 20,
                                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: ResColor.o_1, width: 1, style: BorderStyle.solid)),
                                  child: Text(
                                    "Self",
                                    style: TextStyle(fontSize: 12, color: ResColor.o_1, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          Container(
                            height: 5,
                          ),
                          Text(
                            lao.address,
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 14, color: isCurrent ? Colors.white54 : Colors.white),
                          ),
                          Container(
                            height: 10,
                          ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: ResColor.white_60,
                          ),
                        ],
                      ),
                    );
                    return InkWell(
                      child: item,
                      onTap: () {
                        if (ClickUtil.isFastDoubleClick()) return;
                        if (isCurrent) return;
                        if (callback != null) {
                          Navigator.pop(context);
                          callback(lao);
                        }
                      },
                    );
                  }).toList(),
                ),
              )),
            ],
          ),
        );
      },
    );
    BottomDialog.showBottomPop(context, addressview, dragClose: false);
  }

  // ai bot point 充值
  static showAiBotPointRechargeDialog(BuildContext context, WalletAccount account, AIBotRechargeConfig config,
      Function(bool ok_transfer, bool ok_recharge, CurrencySymbol cs, String txhash, String error) callback) {
    // List<CurrencySymbol> cslist = [CurrencySymbol.EPK, CurrencySymbol.EPKerc20, CurrencySymbol.EPKbsc];
    List<CurrencySymbol> cslist = [
      CurrencySymbol.AIEPK,
      CurrencySymbol.EPKerc20,
      if (!ServiceInfo.hideBSC) CurrencySymbol.EPKbsc,
    ];

    List<CurrencySymbol> _cslist = List.from(cslist);
    _cslist.sort(
      (a, b) {
        CurrencyAsset ca_a = account.getCurrencyAssetByCs(a);
        CurrencyAsset ca_b = account.getCurrencyAssetByCs(b);
        if (ca_a != null && ca_b != null) {
          return ca_b.getBalanceDouble().compareTo(ca_a.getBalanceDouble());
        } else {
          return 0;
        }
      },
    );
    CurrencySymbol use_cs = _cslist[0]; //默认选中最大值
    CurrencyAsset use_cs_ca = account.getCurrencyAssetByCs(use_cs);

    double amount_d = config.max / 10; //config.min;
    amount_d = 500;
    // if (amount_d > (use_cs_ca?.getBalanceDouble() ?? 0)) {
    //   amount_d = 500;
    // }
    // if (amount_d < config.min) amount_d = config.min;
    // if (amount_d > config.max) amount_d = config.max;
    String amount_str = StringUtils.formatNumAmount(amount_d).replaceAll(",", "");

    bool lessMinimum = false;

    String amounttip =
        RSID.main_abv_18.replace([StringUtils.formatNumAmount(config.min), StringUtils.formatNumAmount(config.max)]);

    // List<double> options = [config.max * 0.0005, config.max * 0.001, config.max * 0.005, config.max * 0.01];
    List<double> options = [50, 100, 500, 1000];

    Widget _widget = StatefulBuilder(
      builder: (context, setState) {
        Widget titleview = Container(
          height: 58,
          width: double.infinity,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: FractionalOffset.center,
                child: Text(
                  RSID.main_abv_7.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Align(
                alignment: FractionalOffset.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // 关闭
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 58,
                    height: 58,
                    color: Colors.transparent,
                    child: Icon(
                      Icons.close,
                      color: ResColor.white_60, //Color(0xff666666),
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

        Widget blancepointview = Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(25, 0, 35, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                RSID.main_abv_8.text, // "My Points :   ",
                style: TextStyle(
                  fontSize: 14,
                  color: ResColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${StringUtils.formatNumAmount(account.aibot_point)}",
                style: TextStyle(
                  fontSize: 17,
                  color: ResColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );

        Widget getBlanceItem(CurrencySymbol cs) {
          CurrencyAsset ca = account.getCurrencyAssetByCs(cs);
          if (ca != null) {
            bool hasbalance = ca.getBalanceDouble() > 0;
            return Container(
              // height: 65,
              padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
              width: double.infinity,
              child: Stack(
                children: [
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                        width: 20,
                        height: 20,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            Positioned(
                              left: 0,
                              top: 0,
                              child: ca.networkType != null
                                  ? Container(
                                      width: 20,
                                      height: 20,
                                      padding: EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff202020), //Colors.white,
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                      ),
                                      child: Image(
                                        image: AssetImage(ca.networkType.iconUrl),
                                        width: 13,
                                        height: 13,
                                      ))
                                  : Container(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Text(
                          ca.symbol,
                          style: TextStyle(
                            fontSize: 14,
                            color: ResColor.white,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        ca.balance.isNotEmpty
                            ? StringUtils.formatNumAmount(ca.getBalanceDouble(), point: 8, supply0: false)
                            : "--",
                        style: TextStyle(
                          fontSize: 14,
                          color: hasbalance ? ResColor.white : ResColor.white_50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        }

        Widget blancecoinview = Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
          padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
          decoration: BoxDecoration(
            color: ResColor.b_2,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                RSID.main_abv_11.text, //"Wallet Balance",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(height: 5),
              ...cslist.map((cs) => getBlanceItem(cs)).toList()
            ],
          ),
        );

        Widget cs_radio_view = Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(25, 0, 20, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
                child: Text(
                  RSID.main_abv_9.text, //"Type : ",
                  style: TextStyle(
                    fontSize: 14,
                    color: ResColor.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: JsonFormWidget(
                  paragraph_spacing: 10,
                  formData: {
                    "type": use_cs,
                  },
                  schemaData: [
                    {
                      "key": "type",
                      "type": "radio",
                      "list": cslist,
                      "list_str": cslist.map((e) => e.symbol).toList(),
                      // "label": RSID.applyexpertview_26.text, //语言
                      "label_size": 14,
                      "label_boold": false,
                      "spacing": 5.0,
                      "runSpacing": 2.0,
                      "materialTapTargetSize": "shrinkWrap", //触摸范围 padded 大, shrinkWrap 小,
                      "visualDensity": "compact", //视觉密度 standard 标准, comfortable 舒适, compact 紧凑
                    },
                  ],
                  onFormDataChange: (formData, key) {
                    use_cs = formData["type"];
                    setState(() {
                      // print("use_cs = ${use_cs.symbol}");
                    });
                  },
                ),
              ),
            ],
          ),
        );

        TextEditingController _tec_amount = new TextEditingController.fromValue(TextEditingValue(
          text: amount_str,
          selection: new TextSelection.fromPosition(
            TextPosition(affinity: TextAffinity.downstream, offset: amount_str.length),
          ),
        ));

        Widget amount_input_view = Container(
          width: double.infinity,
          // height: 55,
          padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 6, 10, 0),
                child: Text(
                  RSID.main_abv_10.text, //"Amount : ",
                  style: TextStyle(
                    fontSize: 14,
                    color: ResColor.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                  child: Container(
                height: 30,
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: _tec_amount,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  maxLines: 1,
                  obscureText: false,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExpUtil.re_int)],
                  // 这里限制长度 不会有数量提示
                  decoration: InputDecoration(
                    // 以下属性可用来去除TextField的边框
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(0, -15, 0, 0),
                    enabledBorder: const UnderlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                        color: ResColor.white_40,
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
                  ),
                  onChanged: (value) {
                    amount_str = _tec_amount.text.trim();
                    amount_d = StringUtils.parseDouble(amount_str, 0);
                    if (amount_d < config.min) {
                      // amount_d = config.min;
                      lessMinimum = true;
                    } else if (amount_d > config.max) {
                      amount_d = config.max;
                      lessMinimum = false;
                    } else {
                      lessMinimum = false;
                    }
                    amount_str = StringUtils.formatNumAmount(amount_d).replaceAll(",", "");
                    setState(() {
                      Dlog.p("showAiBotPointRechargeDialog", "amount_str=$amount_str  amount_d=$amount_d");
                    });
                  },
                ),
              )),
            ],
          ),
        );

        Widget amounttipview = Container(
          margin: EdgeInsets.fromLTRB(25, 0, 25, 0),
          alignment: Alignment.centerRight,
          child: Text(
            amounttip,
            style: TextStyle(
              fontSize: 12,
              color: lessMinimum ? ResColor.r_1 : ResColor.white_50,
            ),
          ),
        );

        Widget amount_options_view = Container(
          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Wrap(
            children: options.map((e) {
              bool isSeleted = amount_d == e;
              return LoadingButton(
                width: null,
                text_alignment: null,
                height: 20,
                text: StringUtils.formatNumAmount(e),
                textstyle: TextStyle(
                  fontSize: 11,
                  color: isSeleted ? ResColor.black : ResColor.o_1,
                  fontWeight: FontWeight.bold,
                ),
                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                bg_borderradius: BorderRadius.circular(4),
                color_bg: isSeleted ? ResColor.o_1 : Colors.transparent,
                disabledColor: Colors.transparent,
                side: BorderSide(
                  color: ResColor.o_1,
                  width: 1,
                ),
                onclick: (lbtn) {
                  amount_d = e;
                  amount_str = StringUtils.formatNumAmount(amount_d).replaceAll(",", "");
                  setState(() {
                    // print("seleted_option = $amount_d");
                  });
                },
              );
            }).toList(),
          ),
        );

        // Widget slider_view = Container(
        //   margin: EdgeInsets.fromLTRB(25, 0, 25, 0),
        //   width: double.infinity,
        //   child: Row(
        //     children: [
        //       Container(
        //         padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        //         child: Text(
        //           "${StringUtils.formatNumAmount(config.min)}",
        //           style: TextStyle(
        //             fontSize: 14,
        //             color: ResColor.white,
        //             fontWeight: FontWeight.bold,
        //           ),
        //         ),
        //       ),
        //       Expanded(
        //         child: Slider(
        //           value: amount_d,
        //           // 当前滑块定位到的值
        //           // label: '${StringUtils.formatNumAmount(amount_d, point: 8, supply0: false)}',
        //           onChanged: (val) {
        //             // 滑动监听
        //             if (val < config.min) val = config.min;
        //             setState(() {
        //               amount_d = StringUtils.parseDouble(val.toStringAsFixed(0), config.min);
        //               amount_str = StringUtils.formatNumAmount(amount_d).replaceAll(",", "");
        //               // Decimal d = Decimal.fromInt(Fee) / Decimal.fromInt(100);
        //               // // Fee_d = d.toDouble();
        //             });
        //           },
        //           onChangeStart: (val) {},
        //           onChangeEnd: (val) {},
        //           min: 0,
        //           //config.min,
        //           max: config.max,
        //           divisions: (config.max / 500).toInt(),
        //           activeColor: ResColor.o_1,
        //           inactiveColor: ResColor.white,
        //         ),
        //       ),
        //       Container(
        //         padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        //         child: Text(
        //           "${StringUtils.formatNumAmount(config.max)}",
        //           style: TextStyle(
        //             fontSize: 14,
        //             color: ResColor.white,
        //             fontWeight: FontWeight.bold,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // );

        Widget button = LoadingButton(
          margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
          width: double.infinity,
          height: 40,
          gradient_bg: ResColor.lg_1,
          color_bg: Colors.transparent,
          disabledColor: Colors.transparent,
          bg_borderradius: BorderRadius.circular(4),
          text: RSID.main_abv_4.text,
          textstyle: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          onclick: (lbtn) {
            //  AI BOT 充值
            CurrencyAsset ca = account.getCurrencyAssetByCs(use_cs);
            if (amount_d > ca.getBalanceDouble()) {
              ToastUtils.showToast(RSID.cwv_14.text); //余额不足
              return;
            } else if (lessMinimum) {
              ToastUtils.showToast(amounttip); //充值小于最小值
              return;
            }

            BottomDialog.simpleAuth(
              context,
              account.password,
              (password) {
                String address = "";
                switch (use_cs) {
                  case CurrencySymbol.AIEPK:
                    address = config.epik_address;
                    break;
                  case CurrencySymbol.EPKerc20:
                    address = config.eth_address;
                    break;
                  case CurrencySymbol.EPKbsc:
                    address = config.bsc_address;
                    break;
                }

                if (StringUtils.isEmpty(address)) {
                  ToastUtils.showToast(RSID.no_address_available.text); //没有交易地址
                  return;
                }

                Navigator.pop(context);

                Future.delayed(Duration(milliseconds: 500)).then((value) {
                  LoadingDialog.showLoadDialog(appContext, RSID.main_abv_19.text,
                      touchOutClose: false, backClose: false);

                  Future<ResultObj<String>> result_future;
                  switch (use_cs) {
                    case CurrencySymbol.AIEPK:
                      result_future = account.epikWallet.send(address, amount_str);
                      break;
                    case CurrencySymbol.EPKerc20:
                      result_future = EpikWalletUtils.hdTransfer(account, use_cs, address, amount_str);
                      break;
                    case CurrencySymbol.EPKbsc:
                      result_future = EpikWalletUtils.hdTransfer(account, use_cs, address, amount_str);
                      break;
                  }
                  // todo test
                  // Future<ResultObj<String>> result_future = Future.delayed(Duration(seconds: 2)).then((value) {
                  //   return ResultObj<String>(data: "bafy2bzacedmbaeiw67kvdcm55jbavkcvlerflfmwtyt53q3ae2b6mukyzbjuw");
                  // });

                  result_future?.then((result) async {
                    if (result?.isSuccess != true) {
                      //交易失败
                      String err = "";
                      if (StringUtils.isNotEmpty(result.errorMsg)) {
                        err = "ERROR: ${result.errorMsg}";
                      } else {
                        err = RSID.cwv_11.text; //"转账失败");
                      }
                      LoadingDialog.cloasLoadDialog(appContext);
                      try {
                        callback(false, false, use_cs, "", err);
                      } catch (e, s) {
                        print(e);
                        print(s);
                      }
                      return;
                    }

                    //交易成功
                    String txhash = result?.data;
                    Dlog.p("showAiBotPointRechargeDialog", "txhash=$txhash cs=${use_cs.enumName}");

                    // 上报充值订单
                    HttpJsonRes hjr = await ApiAIBot.recharge(use_cs, txhash, amount_str);
                    //todo test
                    // HttpJsonRes hjr = HttpJsonRes()
                    //   ..code = 0
                    //   ..msg = "aaaa";

                    LoadingDialog.cloasLoadDialog(appContext);
                    try {
                      if (hjr?.code == 0) {
                        //充值成功 已上报
                        callback(true, true, use_cs, txhash, "ok");
                      } else {
                        //上报失败
                        callback(true, false, use_cs, txhash, hjr?.msg);
                      }
                    } catch (e, s) {
                      print(e);
                      print(s);
                    }
                  });
                });
              },
            );
          },
        );

        Widget claim_point = Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
          child: GestureDetector(
            child: Text(
              RSID.main_abv_12.text, //"Use Cid or TxHash to claim points",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ResColor.white_80,
                fontSize: 12,
                decoration: TextDecoration.underline,
                decorationStyle: TextDecorationStyle.solid,
                decorationThickness: 1,
                decorationColor: ResColor.white_80,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Future.delayed(Duration(milliseconds: 300)).then((value) {
                showAiBotPointClaimDialog(null, null, null);
              });
            },
          ),
        );

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(
              // maxHeight: MediaQuery.of(context).size.height / 2,
              ),
          child: Column(
            children: [
              titleview,
              blancepointview,
              blancecoinview,
              cs_radio_view,
              amount_input_view,
              amounttipview,
              amount_options_view,
              // slider_view,
              button,
              claim_point,
            ],
          ),
        );
      },
    );

    BottomDialog.showBottomPop(context, _widget, dragClose: false);
  }

  //ai bot point 充值补领
  static Future showAiBotPointClaimDialog(CurrencySymbol cs, String txhash, Function() callback) {
    // cs=CurrencySymbol.EPKbsc;
    // txhash = "asdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdf";

    List<CurrencySymbol> cslist = [
      CurrencySymbol.AIEPK,
      CurrencySymbol.EPKerc20,
      if(!ServiceInfo.hideBSC)
        CurrencySymbol.EPKbsc,
    ];

    CurrencySymbol use_cs = cslist[0];
    if (cs != null && cslist.contains(cs)) {
      use_cs = cs;
    }

    Widget header = StatefulBuilder(
      builder: (context, setState) {
        Widget cs_radio_view = Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(30, 0, 20, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
                child: Text(
                  RSID.main_abv_9.text, //"Type : ",
                  style: TextStyle(
                    fontSize: 14,
                    color: ResColor.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: JsonFormWidget(
                  paragraph_spacing: 0,
                  formData: {
                    "type": use_cs,
                  },
                  schemaData: [
                    {
                      "key": "type",
                      "type": "radio",
                      "list": cslist,
                      "list_str": cslist.map((e) => e.symbol).toList(),
                      // "label": RSID.applyexpertview_26.text, //语言
                      "label_size": 14,
                      "label_boold": false,
                      "spacing": 5.0,
                      "runSpacing": 2.0,
                      "materialTapTargetSize": "shrinkWrap", //触摸范围 padded 大, shrinkWrap 小,
                      "visualDensity": "compact", //视觉密度 standard 标准, comfortable 舒适, compact 紧凑
                    },
                  ],
                  onFormDataChange: (formData, key) {
                    use_cs = formData["type"];
                    setState(() {
                      // print("use_cs = ${use_cs.symbol}");
                    });
                  },
                ),
              ),
            ],
          ),
        );
        return cs_radio_view;
      },
    );

    return BottomDialog.showTextInputDialogMultiple(
      context: appContext,
      title: RSID.main_abv_12.text,
      autofocus: false,
      header: header,
      objlist: [
        TextInputConfigObj()
          ..oldText = txhash ?? ""
          ..hint = "CID or TxHash"
          ..maxLength = 99,
      ],
      callback: (datas) async {
        Dlog.p("showAiBotPointClaimDialog", datas.toString());
        txhash = datas[0];
        await Future.delayed(Duration(milliseconds: 100));
        LoadingDialog.showLoadDialog(appContext, "", backClose: false, touchOutClose: false);
        ApiAIBot.recharge(use_cs, txhash, "0").then((hjr) async {
          LoadingDialog.cloasLoadDialog(appContext);
          await Future.delayed(Duration(milliseconds: 100));
          try {
            if (hjr?.code == 0) {
              ToastUtils.showToast(RSID.er2ep_state_success.text);
            } else {
              //上报失败
              MessageDialog.showMsgDialog(
                appContext,
                title: RSID.er2ep_state_failed.text,
                msg: hjr?.msg ?? "error",
                btnLeft: RSID.confirm.text,
                onClickBtnLeft: (dialog) {
                  dialog.dismiss();
                },
              );
            }
          } catch (e) {
            print(e);
          }
        });
      },
    );
  }

  static Future showAiBotMakeOrderAmountConfirmDialog(
    BuildContext context, {
    String bot_name,
    String bot_id,
    String description,
    List<String> options = const ["100"],
    String def_option = "100",
    Function(String amount) callback,
  }) {
    String seleted_option = def_option;

    Widget header_bar = Container(
      height: 58,
      width: double.infinity,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: FractionalOffset.center,
            child: Text(
              bot_name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Align(
            alignment: FractionalOffset.centerRight,
            child: GestureDetector(
              onTap: () {
                // 关闭
                Navigator.pop(context);
              },
              child: Container(
                width: 58,
                height: 58,
                color: Colors.transparent,
                child: Icon(
                  Icons.close,
                  color: ResColor.white_60, //Color(0xff666666),
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Widget confirm_btn = LoadingButton(
      margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
      gradient_bg: ResColor.lg_1,
      color_bg: Colors.transparent,
      disabledColor: Colors.transparent,
      height: 40,
      text: RSID.confirm.text,
      //"确定",
      textstyle: TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
      bg_borderradius: BorderRadius.circular(4),
      onclick: (lbtn) {
        Navigator.pop(context);
        callback(seleted_option);
      },
    );
    Widget des_view = StringUtils.isNotEmpty(description)
        ? Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Text(
              description ?? "",
              style: TextStyle(
                fontSize: 14,
                color: ResColor.white,
              ),
            ),
          )
        : Container();
    Widget amount_view = Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(25, 20, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
            child: Text(
              "Points : ",
              style: TextStyle(
                fontSize: 14,
                color: ResColor.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: JsonFormWidget(
              paragraph_spacing: 10,
              formData: {
                "type": seleted_option,
              },
              schemaData: [
                {
                  "key": "type",
                  "type": "radio",
                  "list": options,
                  "list_str": options,
                  "label_size": 14,
                  "label_boold": false,
                  "spacing": 5.0,
                  "runSpacing": 2.0,
                  "materialTapTargetSize": "shrinkWrap", //触摸范围 padded 大, shrinkWrap 小,
                  "visualDensity": "compact", //视觉密度 standard 标准, comfortable 舒适, compact 紧凑
                },
              ],
              onFormDataChange: (formData, key) {
                seleted_option = formData["type"];
                // setState(() {
                //   print("seleted_option = $seleted_option");
                // });
              },
            ),
          ),
        ],
      ),
    );

    Widget widget = Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          header_bar,
          des_view,
          amount_view,
          confirm_btn,
        ],
      ),
    );
    return showBottomPop(context, widget, radius_top: 15, bgColor: ResColor.b_4);
  }

  static Future showAiBotPayOrderAmountConfirmDialog(
    BuildContext context, {
    String verifyText,
    String bot_name,
    String description,
    double amount,
    double balance = 0,
    Function(String verifyText) callback,
    Function() onClickRecharge,
  }) async {
    EventCallback ecb = null;

    Widget wwwww = StatefulBuilder(
      builder: (context, setState) {
        // amount *= 10; //todo test
        bool insufficient_balance = balance < amount;
        // print([balance,amount]);

        if (ecb == null) {
          ecb = (arg) {
            if (AccountMgr()?.currentAccount != null) {
              balance = AccountMgr()?.currentAccount.aibot_point;
            }
            insufficient_balance = balance < amount;
            setState(() {});
          };
          eventMgr.add(EventTag.AI_BOT_POINT_UPDATE, ecb);
        }

        Widget header_bar = Container(
          height: 58,
          width: double.infinity,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: FractionalOffset.center,
                child: Text(
                  RSID.main_abv_14.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Align(
                alignment: FractionalOffset.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // 关闭
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 58,
                    height: 58,
                    color: Colors.transparent,
                    child: Icon(
                      Icons.close,
                      color: ResColor.white_60, //Color(0xff666666),
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        Widget bot_view = Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                RSID.main_abv_15.text, //"Pay Points to ",
                style: TextStyle(
                  fontSize: 17,
                  color: ResColor.white,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  "${bot_name}",
                  style: TextStyle(
                    fontSize: 17,
                    color: ResColor.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
        Widget des_view = Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(25, 10, 25, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                RSID.main_abv_16.text + " : ",
                style: TextStyle(
                  fontSize: 14,
                  color: ResColor.white,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  description ?? "",
                  style: TextStyle(
                    fontSize: 14,
                    color: ResColor.white,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
        Widget points_view = Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(25, 10, 25, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                child: Text(
                  "Points : ",
                  style: TextStyle(
                    fontSize: 14,
                    color: ResColor.white,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  StringUtils.formatNumAmount(amount),
                  style: TextStyle(
                    fontSize: 30,
                    color: ResColor.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
        Widget balance_view = Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(25, 10, 25, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "${RSID.main_abv_8.text}",
                style: TextStyle(
                  fontSize: 14,
                  color: ResColor.white,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  StringUtils.formatNumAmount(balance),
                  style: TextStyle(
                    fontSize: 14,
                    color: insufficient_balance ? ResColor.r_1 : ResColor.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (insufficient_balance)
                LoadingButton(
                  text: RSID.main_abv_4.text,
                  //"Recharge",
                  width: null,
                  height: 20,
                  text_alignment: null,
                  textstyle: TextStyle(
                    color: ResColor.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  bg_borderradius: BorderRadius.circular(5),
                  gradient_bg: ResColor.lg_5,
                  color_bg: Colors.transparent,
                  disabledColor: Colors.transparent,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  preventDoubleClick: false,
                  onclick: (lbtn) {
                    if (onClickRecharge != null) onClickRecharge();
                  },
                ),
            ],
          ),
        );
        Widget confirm_btn = LoadingButton(
          margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
          gradient_bg: ResColor.lg_1,
          color_bg: Colors.transparent,
          disabledColor: Colors.transparent,
          height: 40,
          text: RSID.confirm.text,
          //"确定",
          textstyle: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          bg_borderradius: BorderRadius.circular(4),
          onclick: (lbtn) {
            // Navigator.pop(context);
            simpleAuth(context, AccountMgr()?.currentAccount?.password, (password) async {
              await Future.delayed(Duration(milliseconds: 200));
              Future.delayed(Duration(milliseconds: 10)).then((value) {
                try {
                  callback(password);
                } catch (e) {
                  print(e);
                }
              });
            });
          },
        );

        Widget widget = Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              header_bar,
              bot_view,
              des_view,
              points_view,
              balance_view,
              if (insufficient_balance)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(25, 5, 25, 0),
                  child: Text(
                    RSID.main_abv_17.text,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 12,
                      color: ResColor.r_1,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              confirm_btn,
            ],
          ),
        );
        return widget;
      },
    );

    // return showBottomPop(context, wwwww, radius_top: 15, bgColor: ResColor.b_4);
    await showBottomPop(context, wwwww, radius_top: 15, bgColor: ResColor.b_4);

    eventMgr.remove(EventTag.AI_BOT_POINT_UPDATE, ecb);

    return;
  }

// static showAddAddressDialog(BuildContext context, Function(LocalAddressObj lao) callback,
//     {String inputaddress, CurrencySymbol cs}) {
//   List<CurrencySymbol> cslist = CurrencySymbol.values;
//   CurrencySymbol seletedCs = cs;
//   Widget footer = StatefulBuilder(
//     builder: (context, setState) {
//       return Container(
//         width: double.infinity,
//         padding: EdgeInsets.fromLTRB(30, 10, 30, 0),
//         child: Wrap(
//           alignment: WrapAlignment.start,
//           crossAxisAlignment: WrapCrossAlignment.start,
//           spacing: 20,
//           runSpacing: 10,
//           children: cslist.map((cs) {
//             String net = cs.netNamePatch??"";
//             if(StringUtils.isNotEmpty(net))
//             {
//               net = "($net)";
//             }
//             Widget row = Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CustomCheckBox(
//                   value: seletedCs == cs,
//                   color_check: ResColor.o_1,
//                   color_border: ResColor.o_1,
//                   borderRadius: 100,
//                   onChanged: (value) {
//                     if (seletedCs == cs)
//                       seletedCs = null;
//                     else
//                       seletedCs = cs;
//                     setState(() {});
//                   },
//                 ),
//                 Container(width: 5),
//                 Text(
//                   cs.symbol+net,
//                   style: TextStyle(fontSize: 14, color: ResColor.white),
//                 ),
//               ],
//             );
//             return InkWell(
//               child: row,
//               onTap: () {
//                 if (seletedCs == cs)
//                   seletedCs = null;
//                 else
//                   seletedCs = cs;
//                 setState(() {});
//               },
//             );
//           }).toList(),
//         ),
//       );
//     },
//   );
//
//   // todo add new address
//   BottomDialog.showTextInputDialogMultiple(
//     context: context,
//     title: RSID.alv_addnew.text,//"添加新地址",
//     objlist: [
//       TextInputConfigObj()
//         ..hint = RSID.alv_name.text//"名称"
//         ..maxLength = 50,
//       TextInputConfigObj()
//         ..hint = RSID.alv_address.text//"地址"
//         ..maxLength = 200
//         ..oldText = inputaddress
//         ..inputFormatters = [
//           FilteringTextInputFormatter.allow(RegExpUtil.re_azAZ09),
//         ],
//     ],
//     footer: footer,
//     onOkClose: false,
//     callback: (datas) {
//       if (seletedCs == null) {
//         ToastUtils.showToast(RSID.alv_select_currency.text);//"请选择币种");
//         return;
//       }
//
//       String name = datas[0].trim();
//       String address = datas[1].trim();
//       Dlog.p("showAddAddressDialog", "add new address");
//       Dlog.p("showAddAddressDialog", name);
//       Dlog.p("showAddAddressDialog", address);
//       Dlog.p("showAddAddressDialog", seletedCs.symbol);
//
//       bool checkaddress = false;
//       if (seletedCs.networkType == CurrencySymbol.ETH) {
//         checkaddress = AddressListViewState.checkEthAddress(address);
//       } else if (seletedCs.networkType == CurrencySymbol.EPK) {
//         checkaddress = AddressListViewState.checkEpikAddress(address);
//       }
//       if (checkaddress != true) {
//         ToastUtils.showToast(RSID.alv_input_address.text);//"请输入正确的钱包地址");
//         return;
//       }
//
//       Navigator.pop(context);
//
//       LocalAddressObj lao = LocalAddressObj()
//         ..name = name
//         ..address = address
//         ..symbol = seletedCs.symbol;
//
//       localaddressmgr.add(lao);
//       localaddressmgr.save();
//       callback(lao);
//     },
//   );
// }
}

class TextInputConfigObj {
  String oldText;
  String hint;
  int maxLength;
  String autoBtnString;
  String autoBtnContent;
  List<TextInputFormatter> inputFormatters = [];
  TextInputType keyboardType = TextInputType.text;

  TextInputConfigObj();

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      "oldText": oldText ?? "",
      "hint": hint ?? "",
      "maxLength": maxLength ?? 9999,
      "autoBtnString": autoBtnString,
      "autoBtnContent": autoBtnContent,
      // "inputFormatters": [] //
      "keyboardType": keyboardType == TextInputType.number ? "number" : "text",
    };
    return json;
  }

  TextInputConfigObj.fromJson(Map<String, dynamic> json) {
    try {
      oldText = StringUtils.parseString(json["oldText"], "");
      hint = StringUtils.parseString(json["hint"], "");
      maxLength = StringUtils.parseInt(json["maxLength"], 9999);
      autoBtnString = StringUtils.parseString(json["autoBtnString"], "");
      autoBtnContent = StringUtils.parseString(json["autoBtnContent"], "");
      // inputFormatters
      String _keyboardType = StringUtils.parseString(json["keyboardType"], "text");
      if (_keyboardType == "number") {
        keyboardType = TextInputType.number;
      } else {
        keyboardType = TextInputType.text;
      }
    } catch (e, s) {
      print(e);
      print(s);
    }
  }
}
