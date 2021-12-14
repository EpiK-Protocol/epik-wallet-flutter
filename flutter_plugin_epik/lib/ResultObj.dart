import 'package:epikplugin/epikplugin.dart';
import 'package:flutter/services.dart';

class ResultObj<T> {
  T data;
  String errorMsg;
  int code = 0;

  ResultObj({this.data, this.code = 0, this.errorMsg});

  ResultObj.fromError(Exception e, {this.code = -1}) {
    errorMsg="";
    if (e != null) {
      errorMsg = ErrorUtils.parseErrorMsg(e);
    }
  }

  bool get isSuccess => code == 0;
}
