import 'package:epikwallet/utils/res_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';

typedef YYDialogCallback = void Function(YYDialog dialog);

typedef GdDialogCallback = void Function();

// ignore: must_be_immutable
class MessageDialog {
  static YYDialog showMsgDialog(
    BuildContext context, {
    String title,
    String msg,
    Widget extend,
    String btnLeft,
    String btnRight,
    Color btnLeftColor = ResColor.o_1, //const Color(0xff808080),
    Color btnRightColor = ResColor.o_1, //Colors.black,
    YYDialogCallback onClickBtnLeft,
    YYDialogCallback onClickBtnRight,
    bool touchOutClose = true,
    bool backClose = true,
    YYDialogCallback onShow,
    YYDialogCallback onDismiss,
    TextAlign msgAlign = TextAlign.left,
    TextAlign titleAlign = TextAlign.left,
    Color dialogbg = ResColor.b_4, //Colors.white; dialog背景色
    double borderRadius = 20, //dialog 圆角 10
    Color titleColor = Colors.white, //Colors.black,
    Color msgColor = ResColor.white_80, //Color(0xff333333),
    Color dividerColor = ResColor.white_20, //Color(0xfff5f5f5),
  }) {
    YYDialog dialog = YYDialog().build(context)
      ..width = MediaQuery.of(context).size.width // dialog宽度
      ..margin = EdgeInsets.fromLTRB(50, 0, 50, 0) //外边距
      ..borderRadius = borderRadius // 圆角尺寸
      ..barrierColor = Colors.black54 //dialog 外部背景颜色
      ..barrierDismissible = touchOutClose // dialog外部 点击可以关闭
      ..duration = Duration(milliseconds: 200) //动画持续时间
      ..gravityAnimationEnable = false //使用对齐方向动画  除center外 其他对齐位置 有飞入动画
      ..backgroundColor = dialogbg
      ..gravity = Gravity.center; //弹窗出现的位置

    //动画
    dialog.animatedFunc = (Widget child, Animation<double> animation) {
      //      return ScaleTransition(
      //        child: child,
      //        scale: Tween(begin: 0.7, end: 1.0).animate(animation),
      //      );
      return Transform.scale(
          // 缩放
          scale: Tween(begin: 0.7, end: 1.0).animate(animation).value, // 从0.7到1
          child: Opacity(
            //透明度
            opacity: animation.value, // 0-1
            child: child,
          ));
    };

    // 显示回调
    dialog.showCallBack = () {
      if (onShow != null) onShow(dialog);
    };

    // 关闭回调
    dialog.dismissCallBack = () {
      if (onDismiss != null) onDismiss(dialog);
    };

    // 顶部 h20 占位
    dialog.widget(Container(height: 20));

    if (!backClose) {
      dialog.widget(WillPopScope(
        onWillPop: () async {
          print("MessageDialog WillPopScope false");
          return false;
        },
        child: Container(),
      ));
    }

    // title
    if (title != null && title.isNotEmpty) {
      dialog.text(
        text: title,
        textAlign: titleAlign,
        color: titleColor,
        fontSize: 17.0,
        fontWeight: FontWeight.bold,
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        alignment: Alignment.center,
      );
    }

    // msg
    if (msg != null && msg.isNotEmpty) {
      dialog.text(
        text: msg,
        color: msgColor,
        fontSize: 14.0,
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        alignment: Alignment.center,
        textAlign: msgAlign,
      );
    }

    if (extend != null) {
      dialog.widget(extend);
    }

    if (btnLeft != null || btnRight != null) {
      // 分割线
      dialog.widget(Divider(
        height: 1,
        thickness: 1,
        color: dividerColor,
        // indent: 20,
        // endIndent: 20,
      ));

      bool needDivider = btnLeft != null && btnRight != null;
      dialog.widget(Container(
        width: double.infinity,
        height: 59,
        child: Row(
          children: <Widget>[
            //左按钮
            if (btnLeft != null)
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (onClickBtnLeft != null) onClickBtnLeft(dialog);
                    },
                    child: Container(
                      height: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        btnLeft,
                        style: TextStyle(
                          fontSize: 17,
                          color: btnLeftColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            if (needDivider)
              Container(
                width: 1,
                height: double.infinity,
                // margin: EdgeInsets.only(top: 10, bottom: 10),
                color: dividerColor,
              ),

            // 右按钮
            if (btnRight != null)
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (onClickBtnRight != null) onClickBtnRight(dialog);
                    },
                    child: Container(
                      height: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        btnRight,
                        style: TextStyle(
                          fontSize: 17,
                          color: btnRightColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ));
    }

    dialog.show();

    return dialog;
  }

  static Future showMsgDialog_GD(
    BuildContext context, {
    String title,
    String msg,
    Widget extend,
    String btnLeft,
    String btnRight,
    Color btnLeftColor = ResColor.o_1, //const Color(0xff808080),
    Color btnRightColor = ResColor.o_1, //Colors.black,
        GdDialogCallback onClickBtnLeft,
        GdDialogCallback onClickBtnRight,
    bool touchOutClose = true,
    bool backClose = true,
    VoidCallback onShow,
    VoidCallback onDismiss,
    TextAlign msgAlign = TextAlign.left,
    TextAlign titleAlign = TextAlign.left,
    Color dialogbg = ResColor.b_4, //Colors.white; dialog背景色
    double borderRadius = 20, //dialog 圆角 10
    Color titleColor = Colors.white, //Colors.black,
    Color msgColor = ResColor.white_80, //Color(0xff333333),
    Color dividerColor = ResColor.white_20, //Color(0xfff5f5f5),
  }) {
    // YYDialog dialog = YYDialog().build(context)
    //   ..width = MediaQuery.of(context).size.width // dialog宽度
    //   ..margin = EdgeInsets.fromLTRB(50, 0, 50, 0) //外边距
    //   ..borderRadius = borderRadius // 圆角尺寸
    //   ..barrierColor = Colors.black54 //dialog 外部背景颜色
    //   ..barrierDismissible = touchOutClose // dialog外部 点击可以关闭
    //   ..duration = Duration(milliseconds: 200) //动画持续时间
    //   ..gravityAnimationEnable = false //使用对齐方向动画  除center外 其他对齐位置 有飞入动画
    //   ..backgroundColor = dialogbg
    //   ..gravity = Gravity.center; //弹窗出现的位置



    bool first = true;

    RoutePageBuilder builder = (context, animation, secondaryAnimation) {


      List<Widget> views = [];

      // 顶部 h20 占位
      views.add(Container(height: 20));

      if (!backClose) {
        views.add(WillPopScope(
          onWillPop: () async {
            print("MessageDialog WillPopScope false");
            return false;
          },
          child: Container(),
        ));
      }

      // title
      if (title != null && title.isNotEmpty) {
        views.add(Container(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          alignment: Alignment.center,
          child: Text(
            title,
            textAlign: titleAlign,
            style: TextStyle(
              color: titleColor,
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ));
      }

      // msg
      if (msg != null && msg.isNotEmpty) {
        views.add(Container(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          alignment: Alignment.center,
          child: Text(
            msg,
            textAlign: msgAlign,
            style: TextStyle(
              color: msgColor,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ));
      }

      if (extend != null) {
        views.add(extend);
      }

      if (btnLeft != null || btnRight != null) {
        // 分割线
        views.add(Divider(
          height: 1,
          thickness: 1,
          color: dividerColor,
          // indent: 20,
          // endIndent: 20,
        ));

        bool needDivider = btnLeft != null && btnRight != null;
        views.add(Container(
          width: double.infinity,
          height: 59,
          child: Row(
            children: <Widget>[
              //左按钮
              if (btnLeft != null)
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (onClickBtnLeft != null) onClickBtnLeft();
                      },
                      child: Container(
                        height: double.infinity,
                        alignment: Alignment.center,
                        child: Text(
                          btnLeft,
                          style: TextStyle(
                            fontSize: 17,
                            color: btnLeftColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              if (needDivider)
                Container(
                  width: 1,
                  height: double.infinity,
                  // margin: EdgeInsets.only(top: 10, bottom: 10),
                  color: dividerColor,
                ),

              // 右按钮
              if (btnRight != null)
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (onClickBtnRight != null) onClickBtnRight();
                      },
                      child: Container(
                        height: double.infinity,
                        alignment: Alignment.center,
                        child: Text(
                          btnRight,
                          style: TextStyle(
                            fontSize: 17,
                            color: btnRightColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ));
      }

      Widget dialogview = Column(
        mainAxisSize: MainAxisSize.min,
        children: views,
      );

       print("GD_msg_dialog build");
      Widget view = WillPopScope(
        onWillPop: () async {
          return backClose;
        },
        child: dialogview,
      );
      if (onShow != null && first) {
        print("GD_msg_dialog onShow");
        first = false;
        Future.delayed(Duration(milliseconds: 500)).then((v) {
          onShow();
        });
      }
      return view;

    };



   return  showGeneralDialog(
      context: context,
      barrierDismissible: touchOutClose,
      barrierLabel: "",
      barrierColor: Colors.black54,
      pageBuilder: builder,
      // transitionDuration: Duration(milliseconds: 150),
      //动画持续时间
      // transitionBuilder: (
      //     BuildContext context,
      //     Animation<double> animation,
      //     Animation<double> secondaryAnimation,
      //     Widget child,
      //     ) {
      //   //ScaleTransition 也可以用其他动画
      //   return Transform.scale(
      //     // 缩放
      //       scale: 0.7 + 0.3 * animation.value, // 从0.7到1
      //       child: Opacity(
      //         //透明度
      //         opacity: animation.value, // 0-1
      //         child: child,
      //       ));
      // },
    );
  }
}
