import '../../../utils/data/date_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class JfDateTimePicker extends StatefulWidget {
  DateTime datetime;

  String hint;

  void Function(DateTime value) onChange;

  JfDateTimePicker({this.datetime, this.hint, this.onChange}) {}

  @override
  State<StatefulWidget> createState() {
    return JfDateTimePickerState();
  }
}

class JfDateTimePickerState extends State<JfDateTimePicker> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showPicker();
      },
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.datetime == null
                  ? ""
                  : DateUtil.formatDate(widget.datetime,
                      format: DataFormats.y_mo_d),
              style: Theme.of(context).textTheme.caption.copyWith(height: 1.2),
            ),
            Container(height: 5),
            Divider(
              height: 1,
              thickness: 1,
              color: const Color(0xffb0b0b0),
            ),
          ],
        ),
      ),
    );
  }

  showPicker() async {
    DateTime p_date = await showDatePicker(
        context: context,
        initialDate: widget.datetime ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now());

    widget.datetime = p_date;
    widget?.onChange(p_date);
    setState(() {});

  }
}
