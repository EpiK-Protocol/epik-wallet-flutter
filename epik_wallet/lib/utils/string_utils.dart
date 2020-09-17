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

  static const RollupSize_Units = ["GB", "MB", "KB", "B"];

  /** 返回文件大小字符串 */
  static String getRollupSize(int size) {
    int idx = 3;
    int r1 = 0;
    String result = "";
    while (idx >= 0) {
      int s1 = size % 1024;
      size = size >> 10;
      if (size == 0 || idx == 0) {
        r1 = (r1 * 100) ~/ 1024;
        if (r1 > 0) {
          if (r1 >= 10)
            result = "$s1.$r1${RollupSize_Units[idx]}";
          else
            result = "$s1.0$r1${RollupSize_Units[idx]}";
        } else
          result = s1.toString() + RollupSize_Units[idx];
        break;
      }
      r1 = s1;
      idx--;
    }
    return result;
  }

  static String formatNumAmount(num, {int point: 2, bool supply0=false}) {
    if (num != null) {
      double dnum= double.parse(num.toString()) ;
      String str = dnum.toString();
      if(str.contains("e")){
        str = dnum.toStringAsFixed(20);
      }
      if(dnum==0)
        str="0";
      // 分开截取
      List<String> sub = str.split('.');
      // 处理值
      List val = List.from(sub[0].split(''));
      // 处理点
      if(sub.length>1 && sub[1].length>point)
      {
        sub[1] = sub[1].substring(0,point);
      }
      List<String> points = sub.length>1 ?List.from(sub[1].split('')): [];
      //处理分割符
      for (int index = 0, i = val.length - 1; i >= 0; index++, i--) {
        // 除以三没有余数、不等于零并且不等于1 就加个逗号
        if (index % 3 == 0 && index != 0) // && i != 1
        {
          val[i] = val[i] + ',';
        }
      }
      // 处理小数点
      if(supply0)
      {
        // 是否需要补零
        int pointsize = point - points.length;
        if (pointsize > 0) {
          for (int i = 0; i < pointsize; i++) {
            points.add('0');
          }
        }
      }else{
        while(points.length>0 && points[points.length-1]=="0")
        {
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
      return "0.0";
    }
  }
}
