import 'dart:math';

import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:flutter/cupertino.dart';

class StringUtils {
  static bool isEmpty(String text, {bool trim = false}) {
    return text == null || (trim ? text.trim().isEmpty : text.isEmpty);
  }

  static bool isNotEmpty(String text) {
    return text != null && text.isNotEmpty;
  }

  static String def(String text, String def) {
    if (isEmpty(text)) return def;
    return text;
  }

  static String parseString(Object text, String _def) {
    if (text == null) return _def;
    if (text is String) return def(text, _def);
    if (text is int || text is double || text is num || text is bool)
      return text.toString();
    return _def;
  }

  static int parseInt(Object data, int def) {
    if (data == null) return def;
    int ret = def;
    try {
      if (data is String) {
        if (isEmpty(data)) return def;
        ret = int.parse(data);
      } else if (data is double) {
        ret = data.toInt();
      } else if (data is int) {
        ret = data;
      }
    } catch (e) {
      ret = def;
    }
    return ret;
  }

  static double parseDouble(Object data, double def) {
    if (data == null) return def;
    double ret = def;
    try {
      if (data is String) {
        if (isEmpty(data)) return def;
        ret = double.parse(data);
      } else if (data is int) {
        ret = data.toDouble();
      } else if (data is double) {
        ret = data;
      }
    } catch (e) {
      ret = def;
    }
    return ret;
  }

  static bool parseBool(Object obj, bool def) {
    if (obj == null) return def;
    if (obj is bool) return obj;
    if (obj is String) {
      String text = obj;
      if ("true" == text) return true;
      if ("false" == text) return false;
      if ("1" == text) return true;
      if ("0" == text) return false;
    }
    if (obj is int) {
      if (1 == obj) return true;
      if (0 == obj) return false;
    }
    return def;
  }

  static const RollupSize_Units = ["TB", "GB", "MB", "KB", "B"];
  static const RollupSize_Units1 = ["T", "G", "M", "K", ""];
  static const RollupSize_Units2 = ["Tb", "Gb", "Mb", "Kb", ""];
  static const RollupSize_Units3 = [
    "m",
    "μ",
    "n",
    "p",
    "f",
    "a"
  ]; //"a", "f", "p", "n", "μ", "m"

  /** 返回文件大小字符串 */
  static String getRollupSize(int size,
      {int radix = 1024,
      int extraUp = 0,
      int fractionDigits = 2,
      List<String> units = RollupSize_Units}) {
    // print("getRollupSize size=$size radix=$radix");

    double num = 0;
    String numstr = "0";
    String unit = "";

    int maxIndex = units.length - 1; //  4 3 2 1 0
    int index = maxIndex;
    while (index >= 0) {
      int power = pow(radix, index);
      // print("getRollupSize index=$index  pow=$power");
      if (size >= power) {
        num = 1.0 * size / power;
        break;
      }
      if (index > 0)
        index--;
      else
        break;
    }

    //额外进位
    if (extraUp > 0 && num >= extraUp && index != maxIndex) {
      index++;
      num = num / radix;
      // print("getRollupSize extraUp=$extraUp  num=$num  index=$index");
    }

    if (num == 0) {
      numstr = "0";
    } else {
      numstr = num.toStringAsFixed(fractionDigits);
      // print("getRollupSize numstr=$numstr");
        while (numstr.contains(".") && (numstr.endsWith("0") || numstr.endsWith("."))) {
          numstr = numstr.substring(0, numstr.length - 1);
          // print("getRollupSize del0  $numstr");
        }
    }

    // print("getRollupSize maxIndex=$maxIndex index=$index units.size=${units.length}");
    unit = units[maxIndex - index];

    if (isEmpty(numstr)) numstr = "0";

    String result = "$numstr$unit";
    // print("getRollupSize  result=$result");
    return result;
  }

  static String formatNumAmount(num, {int point: 2, bool supply0 = false}) {
    try {
      if (num != null) {
        double dnum = double.parse(num.toString());
        String str = dnum.toString();
        if (str.contains("e")) {
          str = dnum.toStringAsFixed(20);
        }
        if (dnum == 0) str = "0";
        // 分开截取
        List<String> sub = str.split('.');
        // 处理值
        List val = List.from(sub[0].split(''));
        // 处理点
        if (sub.length > 1 && sub[1].length > point) {
          sub[1] = sub[1].substring(0, point);
        }
        List<String> points = sub.length > 1 ? List.from(sub[1].split('')) : [];
        //处理分割符
        for (int index = 0, i = val.length - 1; i >= 0; index++, i--) {
          // 除以三没有余数、不等于零并且不等于1 就加个逗号
          if (index % 3 == 0 && index != 0) // && i != 1
          {
            val[i] = val[i] + ',';
          }
        }
        // 处理小数点
        if (supply0) {
          // 是否需要补零
          int pointsize = point - points.length;
          if (pointsize > 0) {
            for (int i = 0; i < pointsize; i++) {
              points.add('0');
            }
          }
        } else {
          while (points.length > 0 && points[points.length - 1] == "0") {
            points.removeLast();
          }
        }
        //如果大于长度就截取
        if (points.length > point) {
          // 截取数组
          points = points.sublist(0, point);
        }
        // 判断是否有长度
        if (points.length > 0) {
          return '${val.join('')}.${points.join('')}';
        } else {
          return val.join('');
        }
      } else {
        return "0";
      }
    } catch (e, s) {
      print(e);
      print(s);
      return "0";
    }
  }

  /// 格式化金额，中文缩略成w(万),其他语言缩略成M(百万)\K(千)
  static String formatNumAmountLocaleUnit(double amount, BuildContext context,
      {int point: 2, bool supply0 = false, bool needZhUnit = true}) {
    String languageCode = "zh";

    try {
      Locale _locale = Localizations.localeOf(context);
      languageCode = _locale.languageCode;
      // Dlog.p("formatNumAmountLocaleUnit", languageCode);
    } catch (e, s) {
      print(e);
      print(s);
    }

    double x = 1;
    String u = "";
    if (languageCode == "zh" && needZhUnit) {
      //中文
      if (amount > 10000) {
        x = 10000;
        u = "w";
      }
    } else {
      //其他语言
      if (amount >= 1000000000000000000) {
        x = 1000000000000000000; // 1,000,000,000,000,000,000 =  1E
        u = "E";
      } else if (amount >= 1000000000000000) {
        x = 1000000000000000; // 1,000,000,000,000,000 =  1P
        u = "P";
      } else if (amount >= 1000000000000) {
        x = 1000000000000; // 1,000,000,000,000 =  1T
        u = "T";
      } else if (amount >= 1000000000) {
        x = 1000000000; // 1,000,000,000 =  1G
        u = "G";
      } else if (amount >= 1000000) {
        x = 1000000; // 1,000,000 =  1M
        u = "M";
      } else if (amount >= 1000) {
        x = 1000; // 1,000 = 1K
        u = "K";
      }
    }

    String ret =
        "${StringUtils.formatNumAmount(amount / x, point: point, supply0: supply0)}" +
            u;
    // print("$amount  =>  $ret");
    return ret;
  }

  ///100000123456789012345678 ->  100000.123456789012345678
  ///                                      1200000000000000
  static String bigNumDownsizing(String num, {int bit = 18}) {
    num = num?.trim();
    if (num != null && num.length <= bit) {
      int zero = bit - num.length;
      zero += 2;
      for (int i = 0; i < zero; i++) {
        num = "0" + num;
      }
    }
    if (num != null && num.length > bit && num.contains(".") == false) {
      List<String> list = num.split("");
      int index = list.length - 18;
      list.insert(index, ".");
      if (index == 0) list.insert(0, "0");
      String ret = list.join();

      String ret1 = ret.replaceAll(RegExpUtil.re_end_zero, "");
      if (ret1.endsWith(".")) ret1 = ret1.substring(0, ret1.length - 1);

      // print("bigNumDownsizing $ret => $ret1");

      return ret1;
    }
    return num;
  }

  static double bigNumDownsizingDouble(String num, {int bit = 18}) {
    String text = bigNumDownsizing(num, bit: 18);
    return parseDouble(text, 0);
  }
}
