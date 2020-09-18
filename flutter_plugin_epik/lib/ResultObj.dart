import 'package:flutter/services.dart';

class ResultObj<T> {
  T data;
  String errorMsg;
  int code = 0;

  ResultObj({this.data, this.code = 0, this.errorMsg});

  ResultObj.fromError(Exception e, {this.code = -1}) {
    if (e != null) {
      String err = "";
      if (e is PlatformException) {
        err = e.message;
      } else {
        err = e.toString();
      }
      if (err != null && err.length > 0) {
        List<String> array = err.split(":");
        if (array != null) {
          if (array.length == 1) {
            errorMsg = array[0];
          } else {
            errorMsg = array[1];
          }
        }
      }
    }
  }

  bool get isSuccess => code == 0;
}
