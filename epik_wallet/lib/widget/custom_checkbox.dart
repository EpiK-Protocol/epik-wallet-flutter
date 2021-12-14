import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCheckBox extends StatefulWidget {
  bool value;
  ValueChanged<bool> onChanged;

  // 对号颜色  ， 边框颜色
  Color color_check, color_border;
  Color color_check_no, color_border_no;

  double width, height;
  double checkSize;
  double borderRadius;

  EdgeInsetsGeometry padding, margin;

  bool hasClick;

  CustomCheckBox({
    @required this.value,
    @required this.onChanged,
    this.color_check = const Color(0xff1A1C1F),//Colors.blue,
    this.color_border = const Color(0xff1A1C1F),
    this.color_check_no = const Color(0xff393E45),//Color(0xFF90CAF9)
    this.color_border_no = const Color(0xff393E45),
    this.width = 16,
    this.height = 16,
    this.checkSize = 14,
    this.borderRadius = 4,
    this.padding,
    this.margin,
  }) {
    hasClick = onChanged != null;
  }

  @override
  State<StatefulWidget> createState() {
    return CustomCheckBoxState();
  }
}

class CustomCheckBoxState<T extends CustomCheckBox> extends State<T> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.hasClick) {
          setState(() {
            widget.value = !widget.value;
            widget.onChanged(widget.value);
          });
        }
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        margin: widget.margin,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
                color: widget.hasClick
                    ? widget.color_border
                    : widget.color_border_no,
                width: 1,
                style: BorderStyle.solid),
          ),
          child: widget.value
              ? Icon(
                  Icons.check,
                  size: widget.checkSize,
                  color: widget.hasClick
                      ? widget.color_check
                      : widget.color_check_no,
                )
              : null,
        ),
      ),
    );
  }
}
