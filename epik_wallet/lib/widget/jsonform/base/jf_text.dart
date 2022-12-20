import 'package:epikwallet/utils/res_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JfText extends StatefulWidget {
  String data;
  String hint;
  String label;

  ///自动获取焦点， 自动弹出输入法
  bool autofocus;

  int minLines;

  /// 输入框最大的显示行数
  int maxLines;

  ///
  int maxLength;

  ///
  bool isPassword;

  ///
  String regexp;

  String classtype;

  double fontsize;

  bool enable;
  TextAlign textAlign;

  void Function(String value, String classtype) onChanged;

  JfText({
    this.data = "",
    this.hint = "",
    this.label = "",
    this.autofocus = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
    this.isPassword = false,
    this.regexp,
    this.classtype = "String",
    this.onChanged,
    this.fontsize = 14,
    this.enable = true,
    this.textAlign = TextAlign.left,
  }) {}

  @override
  State<StatefulWidget> createState() {
    return JfTextState();
  }
}

class JfTextState extends State<JfText> {
  TextEditingController tec;
  RegExp re;

  @override
  Widget build(BuildContext context) {
    if (widget.regexp != null && re == null) re = RegExp(widget.regexp);

    if (tec == null || (tec != null && widget.data != tec.text))
      tec = TextEditingController.fromValue(TextEditingValue(
        text: widget.data ?? "",
        selection: TextSelection.fromPosition(
          TextPosition(affinity: TextAffinity.downstream, offset: widget?.data?.length ?? 0),
        ),
      ));

    // 白色主题使用
    // return TextField(
    //   controller: tec,
    //   autofocus: widget.autofocus,
    //   textAlign: TextAlign.left,
    //   keyboardType: widget.maxLines == 1 ? TextInputType.text : TextInputType.multiline,
    //   //获取焦点时,启用的键盘类型
    //   minLines: widget.minLines,
    //   maxLines: widget.maxLines==-1 ? null: widget.maxLines ,
    //   // 输入框最大的显示行数
    //   maxLength: widget.maxLength,
    //   // maxLengthEnforced: true,
    //   //是否允许输入的字符长度超过限定的字符长度
    //   obscureText: widget.isPassword,
    //   //是否是密码
    //   inputFormatters: [
    //     // LengthLimitingTextInputFormatter(maxLength),
    //     if (widget.regexp != null) FilteringTextInputFormatter.allow(re), //todo
    //   ],
    //   // 这里限制长度 不会有数量提示
    //   decoration: InputDecoration(
    //     border: OutlineInputBorder(
    //       gapPadding: 0,
    //     ),
    //     errorBorder: InputBorder.none,
    //     focusedErrorBorder: InputBorder.none,
    //     // disabledBorder: InputBorder.none,
    //     // enabledBorder: InputBorder.none,
    //     // focusedBorder: InputBorder.none,
    //     contentPadding:  widget.maxLines==-1 ? null:EdgeInsets.fromLTRB(10, -5, 10, -5),
    //     labelText: (widget?.label?.isNotEmpty == true)? " ${widget.label} " :null, //有label的话 没焦点时不显示hint
    //     hintText: widget.hint,
    //     hintStyle: const TextStyle(
    //       fontSize: 14,
    //       color: ResColor.black_40,
    //     ),
    //     labelStyle: const TextStyle(
    //       fontSize: 14,
    //       color: ResColor.black_40,
    //     ),
    //   ),
    //   // cursorWidth: 2.0,
    //   //光标宽度
    //   // cursorRadius: Radius.circular(2),
    //   // 光标圆角弧度
    //   // cursorColor: Colors.black,
    //   //光标颜色
    //   style: const TextStyle(
    //     fontSize: 14,
    //     color: ResColor.black_80,
    //   ),
    //   onChanged: (value) {
    //     widget.data = value;
    //     if (widget.onChanged != null) {
    //       widget.onChanged(value, widget.classtype);
    //     }
    //   },
    //   onSubmitted: (value) {
    //     widget.data = value;
    //     if (widget.onChanged != null) {
    //       widget.onChanged(value, widget.classtype);
    //     }
    //   },
    // );

    return TextField(
      enabled: widget.enable,
      controller: tec,
      autofocus: widget.autofocus,
      textAlign: widget.textAlign,
      keyboardType: widget.maxLines == 1 ? TextInputType.text : TextInputType.multiline,
      //获取焦点时,启用的键盘类型
      minLines: widget.minLines,
      maxLines: widget.maxLines == -1 ? null : widget.maxLines,
      // 输入框最大的显示行数
      maxLength: widget.maxLength,
      // maxLengthEnforced: true,
      //是否允许输入的字符长度超过限定的字符长度
      obscureText: widget.isPassword,
      //是否是密码
      inputFormatters: [
        // LengthLimitingTextInputFormatter(maxLength),
        if (widget.regexp != null) FilteringTextInputFormatter.allow(re), //todo
      ],
      // 这里限制长度 不会有数量提示
      decoration: InputDecoration(
        // 以下属性可用来去除TextField的边框
        border: OutlineInputBorder(
          gapPadding: 0,
        ),
        // errorBorder: InputBorder.none,
        // focusedErrorBorder: InputBorder.none,
        // disabledBorder: InputBorder.none,
        // enabledBorder: InputBorder.none,
        // focusedBorder: InputBorder.none,
        disabledBorder: const UnderlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: ResColor.white_20,
            width: 1,
          ),
        ),
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
        // contentPadding: EdgeInsets.fromLTRB(0, 10, 40, 20),
        contentPadding: widget.maxLines == -1 ? EdgeInsets.fromLTRB(0, 10, 0, 20) : EdgeInsets.fromLTRB(0, 10, 0, 20),
        // labelText: widget.maxLines == -1 ? null : ((widget?.label?.isNotEmpty == true) ? " ${widget.label} " : null),
        //有label的话 没焦点时不显示hint
        hintText: widget.hint,
        hintStyle: TextStyle(
          fontSize: widget.fontsize,
          color: ResColor.white_60,
        ),
        labelStyle: TextStyle(
          fontSize: widget.fontsize,
          color: ResColor.white,
        ),
        // label: (widget?.label?.isEmpty == true)
        //     ? null
        //     : Text(
        //         (widget?.label?.isNotEmpty == true) ? " ${widget.label} " : "",
        //         style: TextStyle(
        //           fontSize: widget.fontsize,
        //           color: ResColor.white,
        //         ),
        //       ),
        label: /*widget.maxLines != -1 ||*/ widget?.label?.isNotEmpty == true
            ? Text(
                " ${widget.label} ",
                style: const TextStyle(
                  fontSize: 14,
                  color: ResColor.white,
                ),
              )
            : null,
      ),
      cursorWidth: 2.0,
      //光标宽度
      cursorRadius: Radius.circular(2),
      // 光标圆角弧度
      cursorColor: Colors.white,
      //光标颜色
      style: TextStyle(
        fontSize: widget.fontsize,
        color: ResColor.white,
      ),
      onChanged: (value) {
        widget.data = value;
        if (widget.onChanged != null) {
          widget.onChanged(value, widget.classtype);
        }
      },
      onSubmitted: (value) {
        widget.data = value;
        if (widget.onChanged != null) {
          widget.onChanged(value, widget.classtype);
        }
      },
    );
  }
}
