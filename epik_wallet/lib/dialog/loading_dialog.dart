import 'dart:async';

import 'package:epikwallet/main.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingDialog {
  /// 显示loadingdialog
  /// touchOutClose : true 点击外边可以关闭
  /// backClose     : true 点击back键可以关闭
  /// onShow        : 显示时 回调
  /// Future        : 关闭时 回调
  static Future showLoadDialog(BuildContext context, String msg,
      {bool touchOutClose = true, bool backClose = true, VoidCallback onShow, Widget dialogview}) {
//    return showDialog(
//      context: context,
//      barrierDismissible: touchOutClose,
//      builder: (context) {
//        print("LoadingDialog build");
//        Widget view = WillPopScope(
//          onWillPop: () async {
//            return backClose;
//          },
//          child: getLoadingDialog(context, msg), // widget 具体显示
//        );
//        if (onShow != null) {
//          print("LoadingDialog onShow");
//          Future.delayed(Duration(milliseconds: 500)).then((v) {
//            onShow();
//          });
//        }
//        return view;
//      },
//    );

    bool first = true;
    // 自定义动画效果的dialog
    return showGeneralDialog(
      context: context,
      barrierDismissible: touchOutClose,
      barrierLabel: "",
      barrierColor: Colors.black54,
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        print("LoadingDialog build");
        Widget view = WillPopScope(
          onWillPop: () async {
            return backClose;
          },
          child: dialogview ?? getLoadingDialog(context, msg), // widget 具体显示
        );
        if (onShow != null && first) {
          print("LoadingDialog onShow");
          first = false;
          Future.delayed(Duration(milliseconds: 500)).then((v) {
            onShow();
          });
        }
        return view;
      },
      transitionDuration: Duration(milliseconds: 150),
      //动画持续时间
      transitionBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        //ScaleTransition 也可以用其他动画
        return Transform.scale(
            // 缩放
            scale: 0.7 + 0.3 * animation.value, // 从0.7到1
            child: Opacity(
              //透明度
              opacity: animation.value, // 0-1
              child: child,
            ));
      },
    );
  }

  static cloasLoadDialog(BuildContext context) {
    print("cloasLoadDialog $context");
    Navigator.pop(context);
  }

  /// dialog 左右外边距
  static double margin_lr = 60;

  /// dialog 左右内边距
  static double padding_lr = 20;

  /// dialog 上下内边距
  static double padding_tb = 20;

  /// loading 圆圈尺寸
  static double progressSize = 30;

  /// loading 圆圈线条宽度
  static double progressWidth = 2;

  /// text 文本最大宽度 运行时计算
  static double textMaxWidth = 0;

  static Widget getLoadingDialog(BuildContext context, String text) {
    if (textMaxWidth == 0) {
      textMaxWidth = MediaQuery.of(context).size.width - margin_lr * 2 - padding_lr * 2 - progressSize;
    }

    return Stack(
      children: <Widget>[
        Align(
          alignment: FractionalOffset(0.5, 0.5),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: double.infinity,
              minHeight: 100,
              maxHeight: double.infinity,
            ),
            child: Container(
              margin: EdgeInsets.fromLTRB(margin_lr, 20, margin_lr, 20),
              padding: EdgeInsets.fromLTRB(padding_lr, padding_tb, padding_lr, padding_tb),
              decoration: BoxDecoration(
                color: ResColor.b_4, //Color(0xffffffff),
                borderRadius: BorderRadius.circular(8),
//          border: Border.all(
//              color: ResColor.black_20,
//              width: 0.5,
//              style: BorderStyle.solid),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: progressSize,
                    height: progressSize,
                    padding: EdgeInsets.all(progressWidth / 2),
                    child: CircularProgressIndicator(
                      strokeWidth: progressWidth, //2.0
                      valueColor: new AlwaysStoppedAnimation<Color>(ResColor.progress),
                    ),
                  ),
                  if (StringUtils.isNotEmpty(text))
                    ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: textMaxWidth,
                        ),
                        child: Container(
                          padding: EdgeInsets.only(left: 15),
                          child: Text(
                            text,
                            style: TextStyle(
                              fontSize: 17,
                              //16,
                              color: Colors.white,
                              //Colors.black87,
                              decoration: TextDecoration.none,
                              fontFamily: fontFamily_def,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class LoadingDialogView extends StatefulWidget {
  String text;

  LoadingDialogView(this.text, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoadingDialogViewState(text);
  }
}

class LoadingDialogViewState extends State<LoadingDialogView> {

  String text;
  LoadingDialogViewState(this.text);

  @override
  Widget build(BuildContext context) {
    return LoadingDialog.getLoadingDialog(context, text);
  }
}


