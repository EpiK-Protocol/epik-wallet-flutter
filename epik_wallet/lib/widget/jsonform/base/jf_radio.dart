import 'package:epikwallet/utils/res_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class JfRadio<T> extends StatefulWidget {
  T value;
  List group;
  List<String> group_str;

  void Function(T value) onChange;

  bool enable = true;

  double spacing = 20;
  double runSpacing = 10;
  double fontSize =14;

  String materialTapTargetSize;
  String visualDensity;

  JfRadio({
    this.value,
    this.group,
    this.group_str,
    this.onChange,
    this.enable = true,
    this.spacing=20,
    this.runSpacing=10,
    this.fontSize=14,
    this.materialTapTargetSize = "padded", //触摸范围 padded 大, shrinkWrap 小,
    this.visualDensity = "standard", // 视觉密度 standard 标准, comfortable 舒适, compact 紧凑
  }) {}

  @override
  State<StatefulWidget> createState() {
    return JfRadioState();
  }
}

class JfRadioState extends State<JfRadio> {
  @override
  Widget build(BuildContext context) {
    List<Widget> lw = [];

    MaterialTapTargetSize mtts =  MaterialTapTargetSize.padded;
    switch(widget.materialTapTargetSize)
    {
      case "padded":
        mtts =  MaterialTapTargetSize.padded;
        break;
      case "shrinkWrap":
        mtts =  MaterialTapTargetSize.shrinkWrap;
        break;
    }

    VisualDensity vd = VisualDensity.standard;
    switch(widget.visualDensity)
    {
      case "standard":
        vd =  VisualDensity.standard;
        break;
      case "comfortable":
        vd =  VisualDensity.comfortable;
        break;
      case "compact":
        vd =  VisualDensity.compact;
        break;
    }

    for (int i = 0; i < widget.group.length; i++) {
      var element = widget.group[i];
      String e_str = (widget.group_str != null) ? widget.group_str[i] : element.toString();

      lw.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio(
            value: element,
            groupValue: widget.value,
            activeColor: ResColor.o_1,
            fillColor: MaterialStateProperty.all(ResColor.o_1),
            materialTapTargetSize: mtts, //padded, shrinkWrap,
            visualDensity: vd, // standard,comfortable,compact
            onChanged: widget.enable
                ? (v) {
                    setState(() {
                      widget.value = v;
                      if (widget.onChange != null) widget.onChange(v);
                    });
                  }
                : null,
          ),
          InkWell(
            child: Text(
              e_str,
              // style: Theme.of(context).textTheme.caption.copyWith(height: 1,),
              style: TextStyle(
                fontSize: widget.fontSize,
                color: ResColor.white,
              ),
            ),
            onTap: widget.enable?(){
              setState(() {
                widget.value = element;
                if (widget.onChange != null) widget.onChange(element);
              });
            }:null,
          ),
        ],
      ));
    }

    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      runAlignment: WrapAlignment.start,
      spacing: widget.spacing,
      runSpacing: widget.runSpacing,
      children: lw,
    );
  }
}
