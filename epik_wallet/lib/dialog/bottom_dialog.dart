import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/utils/toast/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BottomDialog {
  static Future showBottomPop(BuildContext context, Widget widget,
      {double radius_top = 15, Color bgColor = Colors.white}) {
    return showModalBottomSheet(
        context: context,
        //可滚动 解除showModalBottomSheet最大显示屏幕一半的限制
        isScrollControlled: true,
        //圆角
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius_top)),
        ),
        //背景颜色
        backgroundColor: bgColor,
        builder: (BuildContext context) {
          return AnimatedPadding(
            //showModalBottomSheet 键盘弹出时自适应
            padding: MediaQuery.of(context).viewInsets, //边距（必要）
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
                children: <Widget>[
                  widget,
                ],
              ),
            ),
          );
        });
  }

  static Future showPassWordInputDialog(@required BuildContext context,String verifyText,@required ValueChanged<String> callback) {

    String password = "";
    TextEditingController tec = TextEditingController(text: password);

    Widget widget = Container(
      padding: EdgeInsets.fromLTRB(0, 5, 0, 20),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 44,
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: FractionalOffset.center,
                  child: Text(
                    "钱包密码",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ),
                Align(
                  alignment: FractionalOffset.centerRight,
                  child: GestureDetector(
                    onTap: (){
                      // 关闭
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      color: Colors.transparent,
                      child: Icon(
                        Icons.close,
                        color: Color(0xff666666),
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
            padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: TextField(
              autofocus: true, //自动获取焦点， 自动弹出输入法
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
                hintText: "请输入钱包密码",
                hintStyle: TextStyle(color: Color(0xff999999), fontSize: 16),
              ),
              cursorWidth: 2.0,
              //光标宽度
              cursorRadius: Radius.circular(2),
              //光标圆角弧度
              cursorColor: Colors.black,
              //光标颜色
              style: TextStyle(fontSize: 16, color: Color(0xff333333)),
              onChanged: (text){
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
            color: Colors.blue,
            indent: 25,
            endIndent: 25,
          ),

          Container(
            height: 44,
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(0,30,0,0),
            padding: EdgeInsets.fromLTRB(25,0,25,0),
            child: FlatButton(
              highlightColor: Colors.white24,
              splashColor: Colors.white24,
              onPressed: () {

                if(StringUtils.isEmpty(password))
                {
                  ToastUtils.showToast("请输入密码");
                  return;
                }

                if(StringUtils.isEmpty(verifyText))
                {
                  Navigator.pop(context);
                  callback(password);
                }else
                  {
                    if(verifyText!=password)
                    {
                      ToastUtils.showToast("密码不正确");
                    }else{
                      Navigator.pop(context);
                      callback(password);
                    }
                  }
              },
              child: Text(
                "确定",
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
        ],
      ),
    );


    return showBottomPop(context, widget, radius_top: 15, bgColor: Colors.white);
  }
}
