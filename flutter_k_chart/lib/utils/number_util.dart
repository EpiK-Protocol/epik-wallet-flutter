class NumberUtil {
  static String volFormat(double n) {
    if (n > 10000 && n < 999999) {
      double d = n / 1000;
      return "${d.toStringAsFixed(2)}K";
    } else if (n > 1000000) {
      double d = n / 1000000;
      return "${d.toStringAsFixed(2)}M";
    }
    return n.toStringAsFixed(2);
  }

  //保留多少位小数
  static int _fractionDigits = 2;
  
  // 补零
  static bool supply0=false;

  static set fractionDigits(int value) {
    if (value != _fractionDigits) _fractionDigits = value;
  }

  static String format(double price) {
    // return price.toStringAsFixed(_fractionDigits);
    String str = price.toString();
    if(str.contains("e")){
      str = price.toStringAsFixed(20);
    }
    // 分开截取
    List<String> sub = str.split('.');
    // 处理值
    List val = List.from(sub[0].split(''));
    // 处理点
    if(sub.length>1 && sub[1].length>_fractionDigits)
    {
      sub[1] = sub[1].substring(0,_fractionDigits);
    }
    List<String> points = sub.length>1 ?List.from(sub[1].split('')): [];
    // 处理小数点
    if(supply0)
    {
      // 是否需要补零
      int pointsize = _fractionDigits - points.length;
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
    if (points.length > _fractionDigits) {
      // 截取数组
      points = points.sublist(0, _fractionDigits);
    }
    // 判断是否有长度
    if (points.length > 0) {
      return '${val.join('')}.${points.join('')}';
    } else {
      return val.join('');
    }
  }
}
