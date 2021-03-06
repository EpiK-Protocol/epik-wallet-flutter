import 'dart:async';
import 'dart:ui';

import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/model/auth/RemoteAuth.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/utils/toast/toast.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
            // padding: MediaQuery.of(context).viewInsets, //边距（必要） //键盘高度
            padding: EdgeInsets.all(0),
            duration: const Duration(milliseconds: 100), //动画时长 （必要）
            child: Container(
              // height: 180,
              constraints: BoxConstraints(
                minHeight: 90, //设置最小高度（必要）
                maxHeight:
                    MediaQuery.of(context).size.height / 1.5, //设置最大高度（必要）
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
                        print("bottomdialog WillPopScope false");
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

  ///密码输入弹窗
  static Future showPassWordInputDialog(@required BuildContext context,
      String verifyText, @required ValueChanged<String> callback) {
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
              maxLengthEnforced: true,
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
          Row(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: 55,
                  padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                  child: TextField(
                    autofocus: true,
                    //自动获取焦点， 自动弹出输入法
                    controller: tec,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.text,
                    //获取焦点时,启用的键盘类型
                    maxLines: 1,
                    // 输入框最大的显示行数
                    maxLengthEnforced: true,
                    //是否允许输入的字符长度超过限定的字符长度
                    obscureText: false,
                    //是否是密码
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(maxLength),
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
                      TextPosition(
                          affinity: TextAffinity.downstream,
                          offset: _text.length),
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
  static Future showEthAccelerateTx(
      BuildContext context, WalletAccount walletaccount, String txHash,
      {String oldText = "", ValueChanged<String> callback}) {
    String _text = oldText ?? "";
    TextEditingController tec =
        new TextEditingController.fromValue(TextEditingValue(
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
                    RSID.eatd_1.text,//"加速交易",
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
              maxLengthEnforced: true,
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
                hintText: RSID.eatd_2.text,//"输入加速交易的Gas比例",
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
                  textstyle: const TextStyle(
                      fontSize: 11,
                      color: ResColor.o_1,
                      fontWeight: FontWeight.bold),
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
                      TextPosition(
                          affinity: TextAffinity.downstream,
                          offset: _text.length),
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
              maxLengthEnforced: true,
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
                ToastUtils.showToastCenter(RSID.eatd_3.text);//"请输入加速Gas比例");
                return;
              }
              if (_gasrate < 1) {
                ToastUtils.showToastCenter(RSID.eatd_4.text);//"Gas比例需要>1");
                return;
              }
              if (password != walletaccount.password) {
                ToastUtils.showToastCenter(RSID.eatd_5.text);//"密码错误");
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

              ResultObj<String> resultobj =
                  await walletaccount.hdwallet.accelerateTx(txHash, _gasrate);

              lbtn.setLoading(false);

              if (resultobj.code != 0) {
                Navigator.of(context).pop();
                Future.delayed(Duration(milliseconds: 200)).then((value) {
                  MessageDialog.showMsgDialog(
                    context,
                    title: RSID.tip.text,
                    msg:
                        "ERROR: ${resultobj?.errorMsg ?? RSID.request_failed.text}",
                    btnLeft: RSID.confirm.text,
                    onClickBtnLeft: (dialog) {
                      dialog.dismiss();
                    },
                  );
                });
              } else {
                Navigator.of(context).pop();
                Future.delayed(Duration(milliseconds: 200)).then((value) {
                  MessageDialog.showMsgDialog(
                    context,
                    title: RSID.tip.text,
                    msg: RSID.eatd_6.text,//"加速交易已提交",
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
      BuildContext context,
      WalletAccount walletaccount,
      RemoteAuth ra,
      ValueChanged<String> callback) {
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
              right = StringUtils.formatNumAmount(right, point: 18) + " EPK";
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
              maxLengthEnforced: true,
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
}
