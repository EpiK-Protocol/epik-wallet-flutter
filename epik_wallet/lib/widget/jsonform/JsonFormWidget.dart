import 'package:epikwallet/utils/res_color.dart';

import '../../utils/string_utils.dart';
import 'base/jf_date_time_picker.dart';
import 'base/jf_radio.dart';
import 'base/jf_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// JsonFormWidget jfw = JsonFormWidget(
//   formData: {
//     "account": "",
//     "password": "",
//   },
//   schemaData: [
//     {
//       "key": "account",
//       "type": "text_input",
//       "label": "账号",
//       "hint": "",
//       "isPassword": false,
//       "maxLines": 1,
//       "maxLength": null,
//       "regexp": r'[\u0000-\u007f]+',
//     },
//     {
//       "key": "password",
//       "type": "text_input",
//       "label": "密码",
//       "hint": "",
//       "isPassword": true,
//       "maxLines": 1,
//       "maxLength": null,
//       "regexp": r'[\u0000-\u007f]+',
//     },
//   ],
//   onFormDataChange: (formData, key) {
//     // 内容改变
//   },
// );


typedef OnFormDataChange = void Function(
    Map<String, dynamic> formData, String key);

class JsonFormWidget extends StatefulWidget {
  Map<String, dynamic> formData;
  List schemaData;
  OnFormDataChange onFormDataChange;

  JsonFormWidget({
    Key key,
    @required this.formData,
    @required this.schemaData,
    this.onFormDataChange,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return JsonFormWidgetState();
  }
}

class JsonFormWidgetState extends State<JsonFormWidget> {
  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = parseData(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  List<Widget> parseData(BuildContext ct) {
    List<Widget> ret = [];
    widget.schemaData.forEach((element) {
      if (element is Map) {
        if (/*element.containsKey("key") &&*/ element.containsKey("type")) {
          List<Widget> lw =
              switchType(ct, widget.formData, element, widget.onFormDataChange);
          if (lw != null) {
            ret.addAll(lw);
            ret.add(Container(height: 20));
          }
        }
      }
    });
    return ret;
  }

  List<Widget> switchType(BuildContext ct, Map<String, dynamic> formData,
      Map json, OnFormDataChange onFormDataChange) {
    if (json == null) return [];

    List<Widget> ret = [];

    if (json["label"] != null) {
      ret.addAll(getLable(ct, json["label"],size: json["label_size"],isBoold: json["label_boold"]??true));
    }
    if (json["des"] != null) {
      ret.addAll(getDes(ct, json["des"]));
    }

    switch (json["type"]) {
      case "space":
        {
          ret.add(Container(width: json["w"], height: json["h"]));
        }
        break;
      case "row":
        {
          List<Map<String, dynamic>> datalist = json["list"];
          Row row = Row(
            mainAxisSize: MainAxisSize.max,
            children: datalist.map((e) {
              Widget item = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: switchType(ct, formData, e, onFormDataChange),
              );
              if (e["type"] == "space") return item;
              return Expanded(
                child: item,
              );
            }).toList(),
          );
          ret.add(row);
        }
        break;
      case "text_input":
        {
          ret.add(JfText(
            data: formData[json["key"]]?.toString(),
            autofocus: false,
            minLines: json["minLines"]??1,
            maxLines: json["maxLines"] ?? 1,
            hint: json["hint"],
            label:json["t_label"],
            isPassword: json["isPassword"] ?? false,
            maxLength: json["maxLength"],
            regexp: json["regexp"],
            classtype: json["classtype"],
            onChanged: (text, classtype) {
              var dd;
              switch (classtype) {
                case "double":
                  dd = StringUtils.parseDouble(text, 0);
                  break;
                case "integer":
                  dd = StringUtils.parseInt(text, 0);
                  break;
                case "bool":
                  dd = StringUtils.parseBool(text, false);
                  break;
                default:
                  dd = text;
                  break;
              }
              formData[json["key"]] = dd;
              if (formData != null) {
                onFormDataChange(formData, json["key"]);
              }
            },
          ));
        }
        break;
      case "radio":
        {
          Object value = formData[json["key"]];
          ret.add(JfRadio(
            value: value,
            group: json["list"],
            group_str: json["list_str"],
            onChange: (value) {
              formData[json["key"]] = value;
              if (formData != null) {
                onFormDataChange(formData, json["key"]);
              }
            },
          ));
        }
        break;
      case "date_time_picker":
        {
          ret.add(JfDateTimePicker(
            datetime: formData[json["key"]],
            hint: json["hint"],
            onChange: (value) {
              formData[json["key"]] = value;
              if (formData != null) {
                onFormDataChange(formData, json["key"]);
              }
            },
          ));
        }
        break;
    }
    return ret;
  }

  List<Widget> getLable(BuildContext ct, String lable,{num size=17,bool isBoold=true}) {
    List<Widget> ret = [];
    if (lable != null && lable.length > 0) {
      ret.add(Text(
        lable,
        // style: Theme.of(ct).textTheme.bodyText2,
        style: TextStyle(
          fontSize: size?.toDouble(),
          color: ResColor.white,
          fontWeight:isBoold!=true?FontWeight.normal:FontWeight.bold,
        ),
      ));
      ret.add(Container(height: 10));
    }
    return ret;
  }

  List<Widget> getDes(BuildContext ct, String des) {
    List<Widget> ret = [];
    if (des != null && des.length > 0) {
      ret.add(Text(
        des,
        style: TextStyle(
          fontSize: 14,
          color: ResColor.white_60,
        ),
      ));
      ret.add(Container(height: 10));
    }
    return ret;
  }
}
