import 'package:epikwallet/utils/ClickUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

//当 width= null, text_alignment= null 时， 按钮可以自适应宽度
class LoadingButton extends StatefulWidget {
  double width, height;
  EdgeInsets margin, padding;
  Function(LoadingButton lbtn) onclick;
  Function(LoadingButton lbtn) onLongClick;
  Gradient gradient_bg;
  Color color_bg;
  Color disabledColor;
  Color highlightColor;
  Color splashColor;
  BorderSide side;
  String text;
  TextStyle textstyle;
  double progress_size;
  Color progress_color;
  BorderRadius bg_borderradius;
  bool loading = false;

  ///防止双击连点
  bool preventDoubleClick;

  AlignmentGeometry text_alignment;

  LoadingButton({
    Key key,
    this.text = "",
    this.textstyle = const TextStyle(
      fontSize: 16,
      color: Colors.white,
      fontWeight: FontWeight.w400,
      height: 1.2,
    ),
    this.width = double.infinity,
    this.height,
    this.margin = const EdgeInsets.fromLTRB(0, 0, 0, 0),
    this.padding = const EdgeInsets.fromLTRB(0, 0, 0, 0),
    this.onclick,
    this.onLongClick,
    this.gradient_bg,
    this.color_bg = Colors.lightBlue,
    this.progress_size = 30,
    this.progress_color = Colors.white,
    this.bg_borderradius,
    bool loading,
    this.side = BorderSide.none,
    this.disabledColor = null,
    this.highlightColor = Colors.white24,
    this.splashColor = Colors.white24,
    this.preventDoubleClick = true,
    this.text_alignment= Alignment.center,
  }) : super(key: key) {
    if (bg_borderradius == null) {
      bg_borderradius = BorderRadius.circular(20.0);
    }
    if (loading != null) this.loading = loading;
  }

  @override
  State<StatefulWidget> createState() {
    return LoadingButtonState();
  }

  setLoading(bool isloading) {
    this.loading = isloading;
    if (key != null && key is GlobalKey) {
      (key as GlobalKey).currentState?.setState(() {});
    }
  }
}

class LoadingButtonState extends State<LoadingButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      // padding: widget.padding,
      decoration: widget.gradient_bg == null
          ? null
          : BoxDecoration(
              border: widget.side != null
                  ? Border.fromBorderSide(widget.side)
                  : null,
              borderRadius: widget.bg_borderradius,
              gradient: widget.gradient_bg,
            ),
      child: getTextButton(), //getFlatButton(),
    );
  }

  // @Deprecated("Use TextButton instead")
  // Widget getFlatButton() {
  //   return FlatButton(
  //     // padding: EdgeInsets.all(0),
  //     padding: widget.padding,
  //     onPressed: (widget.loading == false && widget.onclick != null)
  //         ? () {
  //             if (widget.preventDoubleClick == true &&
  //                 ClickUtil.isFastDoubleClick()) {
  //               return;
  //             }
  //             widget.onclick(widget);
  //           }
  //         : null,
  //     onLongPress: (widget.loading == false && widget.onLongClick != null)
  //         ? () {
  //             if (widget.preventDoubleClick == true &&
  //                 ClickUtil.isFastDoubleClick()) {
  //               // print("cccmax 防止双击连点");
  //               return;
  //             }
  //             widget.onLongClick(widget);
  //           }
  //         : null,
  //     color: widget.color_bg,
  //     disabledColor: widget.disabledColor,
  //     highlightColor: widget.highlightColor,
  //     splashColor: widget.splashColor,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: widget.bg_borderradius,
  //       side: widget.side,
  //     ),
  //
  //     child: widget.loading == true
  //         ? Container(
  //             width: widget.progress_size,
  //             height: widget.progress_size,
  //             padding: EdgeInsets.all(2),
  //             child: CircularProgressIndicator(
  //               strokeWidth: 2,
  //               valueColor: AlwaysStoppedAnimation(widget.progress_color),
  //             ),
  //           )
  //         : Container(
  //             // height: 30,
  //             alignment: Alignment.center,
  //             child: Text(
  //               widget.text,
  //               textAlign: TextAlign.center,
  //               style: widget.textstyle,
  //             ),
  //           ),
  //   );
  // }

  Widget getTextButton() {
    return TextButton(
      onPressed: (widget.loading == false && widget.onclick != null)
          ? () {
              if (widget.preventDoubleClick == true &&
                  ClickUtil.isFastDoubleClick()) {
                return;
              }
              widget.onclick(widget);
            }
          : null,
      onLongPress: (widget.loading == false && widget.onLongClick != null)
          ? () {
              if (widget.preventDoubleClick == true &&
                  ClickUtil.isFastDoubleClick()) {
                // print("cccmax 防止双击连点");
                return;
              }
              widget.onLongClick(widget);
            }
          : null,
      child: widget.loading == true
          ? Container(
              width: widget.progress_size,
              height: widget.progress_size,
              padding: EdgeInsets.all(2),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(widget.progress_color),
              ),
            )
          : Container(
              // height: 30,
              alignment: widget.text_alignment,
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                style: widget.textstyle,
              ),
            ),
      style: ButtonStyle(
        //padding
        padding: MaterialStateProperty.all(widget.padding),
        //阴影
        elevation: MaterialStateProperty.all(0),

        //背景色
        backgroundColor:
            MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          // case MaterialState.hovered: //悬停：
          // case MaterialState.focused://焦点
          // case MaterialState.pressed://按住
          // case MaterialState.dragged://拖拽
          // case MaterialState.selected://选中
          // case MaterialState.disabled://禁用
          // case MaterialState.error://错误

          if (states.contains(MaterialState.disabled)) {
            //禁用时
            return widget.disabledColor;
          } else if (states.contains(MaterialState.pressed)) {
            //按住时
            return widget.highlightColor;
          }
          //默认
          return widget.color_bg;
        }),

        //前景色 控制btn里的文本和icon颜色
        // foregroundColor:MaterialStateProperty.all(Colors.white),

        //设置水波纹颜色
        overlayColor: MaterialStateProperty.all(widget.splashColor),

        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: widget.bg_borderradius, //圆角
            side: widget.side, //描边
          ),
        ),
      ),
    );
  }
}
