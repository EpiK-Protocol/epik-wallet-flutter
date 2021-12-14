import 'package:epikwallet/utils/res_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JfRadio<T> extends StatefulWidget {

  T value;
  List group;
  List<String> group_str;

  void Function(T value) onChange;

  JfRadio({this.value , this.group,this.group_str,this.onChange}) {}

  @override
  State<StatefulWidget> createState() {
    return JfRadioState();
  }
}

class JfRadioState extends State<JfRadio> {

  @override
  Widget build(BuildContext context) {

    List<Widget> lw = [];

    for(int i =0;i<widget.group.length;i++)
    {
      var element = widget.group[i];
      String e_str=(widget.group_str!=null)?widget.group_str[i] : element.toString();

      lw.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio(
            value: element,
            groupValue: widget.value,
            activeColor: ResColor.o_1,
            onChanged: (v) {
              setState(() {
                widget.value = v;
                if(widget.onChange!=null)
                  widget.onChange(v);
              });
            },
          ),
          Text(
            e_str,
            // style: Theme.of(context).textTheme.caption.copyWith(height: 1,),
            style: TextStyle(
              fontSize: 14,
              color: ResColor.white,
            ),
          ),
        ],
      ));
    }


    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      runAlignment: WrapAlignment.start,
      spacing: 20,
      runSpacing: 10,
      children: lw,
    );
  }

}
