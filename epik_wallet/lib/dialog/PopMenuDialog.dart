import 'dart:ui';

import 'package:epikwallet/utils/res_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';

class PopMenuDialog {
  static TextStyle style_name = TextStyle(
    color: Colors.white,
    fontSize: 14,
  );

  static YYDialog show<T>({
    BuildContext context,
    Rect rect, //外部入口按钮再屏幕上的位置
    List<T> datas, //数据列表
    Widget Function(T item, YYDialog dialog) itemBuilder, // 构造器
    Color outColor = Colors.transparent, //dialog 外部背景颜色
    Color backgroundColor = ResColor.b_4, //dialog 背景色
    double borderRadius = 10, // 圆角尺寸
    double topMargin = 5,
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(0, 5, 0, 5),
  }) {
    // sd.name_zh="一二三四五六七八九十";
    double screen_h = MediaQuery.of(context).size.height;
    double screen_w = MediaQuery.of(context).size.width;

    double rect_center = rect.topCenter.dx;

    bool isLeft = rect_center < (screen_w / 2); //  靠左 或者靠右

    double view_left = isLeft ? rect.left : 0;
    if (view_left <= 0) {
      view_left = 5;
    }
    double view_right = isLeft ? 0 : rect.right;
    if (view_right > screen_w) {
      view_right = screen_w - 5;
    }
    print("view_left = $view_left");
    print("view_right = $view_right");

    YYDialog dialog = YYDialog().build(context)
      // ..width = 87.5 // dialog宽度
      ..margin =
          EdgeInsets.fromLTRB(view_left, rect.bottom+topMargin, screen_w-view_right,0) //外边距
      ..borderRadius = borderRadius // 圆角尺寸
      ..backgroundColor = backgroundColor
      ..barrierColor = outColor //dialog 外部背景颜色
      ..barrierDismissible = true // dialog外部 点击可以关闭
      ..duration = Duration(milliseconds: 200) //动画持续时间
      ..gravityAnimationEnable = false //使用对齐方向动画  除center外 其他对齐位置 有飞入动画
      ..gravity = isLeft? Gravity.leftTop : Gravity.rightTop; //弹窗出现的位置

    //动画
    dialog.animatedFunc = (Widget child, Animation<double> animation) {
      return Transform.scale(
          // 缩放
          alignment: FractionalOffset(rect_center / screen_w, 0), //缩放出现的起始位置
          scale: Tween(begin: 0.8, end: 1.0).animate(animation).value, // 从0.7到1
          child: Opacity(
            //透明度
            opacity: animation.value, // 0-1
            child: child,
          ));
    };

    Widget w = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: datas.map((e) {
        return itemBuilder(e,dialog);
      }).toList(),
    );

    dialog.widget(Padding(padding: padding,child: w,));

    dialog.show();

    return dialog;
  }
}
