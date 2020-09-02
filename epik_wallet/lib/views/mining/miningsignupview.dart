import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/widget/custom_checkbox.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';

/// 挖矿报名
class MiningSignupView extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> getState() {
    return _MiningSignupViewState();
  }
}

class _MiningSignupViewState extends BaseWidgetState<MiningSignupView> {
  static String server_wechat = "xxxxxx";

  TextEditingController _controllerWechat;
  String wechat = "";
  bool agreement = false;

  @override
  void initStateConfig() {
    isTopBarShow = true; //状态栏是否显示
    isAppBarShow = true; //导航栏是否显示
    setAppBarTitle("");
    resizeToAvoidBottomPadding = true;
  }

  @override
  Widget buildWidget(BuildContext context) {
    if (_controllerWechat == null)
      _controllerWechat = new TextEditingController.fromValue(TextEditingValue(
        text: wechat,
        selection: new TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream, offset: wechat.length),
        ),
      ));

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Container(
        constraints: BoxConstraints(
          minHeight: getScreenHeight() -
              BaseFuntion.topbarheight -
              BaseFuntion.appbarheight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(15, 6, 15, 10),
              child: Text(
                "预挖报名",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),

           InkWell(
             onTap: (){
               DeviceUtils.copyText(server_wechat);
               showToast("已复制客服微信号");
             },
             child:  Container(
               width: double.infinity,
               padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
               child: Text.rich(
                 TextSpan(
                   style: TextStyle(
                     color: ResColor.black_50,
                     fontSize: 13,
                   ),
                   children: <TextSpan>[
                     TextSpan(
                       text:"请使用绑定的微信号添加客服微信",
                     ),
                     TextSpan(
                       text:"$server_wechat",
                       style: TextStyle(
                         color: Colors.blue,
                         fontSize: 13,
                         decoration: TextDecoration.underline,
                       ),
                     ),
                     TextSpan(
                       text: "为好友，成功报名后将显示ID发送给客服微信。",
                     ),
                   ],
                 ),
               ),
             ),
           ),

            Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
              child: Text(
                "本次测试活动由铭识协议基金会监督，最终解释权归铭识协议基金会所有 ，参与本次活动视为接受以下规定： 铭识协议基金会保留在测试中任何时刻修改、完善和增加测试活动或测试规则的权力，并在测试期间及测试结束后任何时刻均有权取消包括且不限于试图或有嫌疑利用、欺诈、恶意攻击网络的参赛者参赛权益和已获得挖矿奖励。辱骂、威胁主办方，铭识协议基金会保留取消参赛者参赛权益和已获得挖矿奖励的权力。",
                style: TextStyle(
                  color: ResColor.black_50,
                  fontSize: 13,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 25, 15, 15),
              child: Text(
                "绑定微信号",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ),
            getInputWidget(
              wechat,
              "请输入微信号",
              _controllerWechat,
              (text) {
                setState(() {
                  wechat = _controllerWechat.text ?? "";
                  dlog(wechat);
                });
              },
              () {
                setState(() {
                  wechat = "";
                  _controllerWechat = null;
                });
              },
              isPassword: false,
              icon: ImageIcon(
                AssetImage("assets/img/ic_wechat.png"),
                size: 20,
                color: Colors.white,
              ),
              inputFormatters: [
                WhitelistingTextInputFormatter(RegExpUtil.re_noChs)
              ],
            ),
            Container(
              margin: EdgeInsets.fromLTRB(15, 50, 15, 0),
              height: 44,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      height: 44,
                      child: FlatButton(
                        highlightColor: Colors.white24,
                        splashColor: Colors.white24,
                        onPressed: () {
                          clickNext();
                        },
                        child: Text(
                          "报名",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        color: Color(0xff1A1C1F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(22)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: (){
                setState(() {
                  this.agreement=!this.agreement;
                });
              },
              child: Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CustomCheckBox(
                      value: this.agreement,
                      margin: EdgeInsets.only(top:2),
                      onChanged: (bool value) {
                        setState(() {
                          this.agreement = value;
                        });
                      },
                    ),
                    Container(width: 5),
                    Text(
                      '已读上述',
                      maxLines: 1,
                      style: TextStyle(color: Color(0xff1A1C1F), fontSize: 16),
                    ),
                    InkWell(
                      onTap: () {
                        //todo
                      },
                      child: Text(
                        '活动说明',
                        maxLines: 1,
                        style: TextStyle(
                          color: Color(0xff1A1C1F),
                          fontSize: 16,
//                        decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Container(
                      width: 15,
                      height: 0,
                    ),
                  ],
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
    String hind,
    TextEditingController controller,
    ValueChanged<String> onChanged,
    VoidCallback onClean, {
    bool isPassword = true,
    ImageIcon icon,
    List<TextInputFormatter> inputFormatters,
  }) {
    if (inputFormatters == null) inputFormatters = [];
    inputFormatters.add(LengthLimitingTextInputFormatter(20));

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
            padding: EdgeInsets.all(11),
            child: isPassword
                ? Icon(
                    Icons.lock_outline,
                    size: 20,
                    color: Colors.white,
                  )
                : icon,
          ),
          Expanded(
            flex: 1,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              //获取焦点时,启用的键盘类型
              maxLines: 1,
              // 输入框最大的显示行数
//              maxLength: 20, //允许输入的字符长度/ 右下角有数量提示
              maxLengthEnforced: true,
              //是否允许输入的字符长度超过限定的字符长度
              obscureText: isPassword,
              //是否是密码
              inputFormatters: inputFormatters,
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

  clickNext() {

    closeInput();

    if (StringUtils.isEmpty(wechat)) {
      showToast("请输入微信号");
      return;
    }
    if(!agreement)
    {
      showToast("请确认已读活动说明");
      return;
    }

    // todo
  }
}
