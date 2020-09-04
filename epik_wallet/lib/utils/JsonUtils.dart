class JsonArray<T> {
  JsonArray();

  ///解析jsonarray 返回需要的T类型的数据List
  static List<T> parseList<T>(List data, T Function(Map<String, dynamic> json)) {
    try {
      List<T> ret = List();
      if (data != null) {
        data.forEach((item) {
          if (item != null && item is Map) {
            Map itemMap = item;
            T child = Function(itemMap);
            ret.add(child);
          }
        });
      }
      return ret;
    } catch (e) {
      print("parseList error ${T}");
      print(e);
    }
    return null;
  }

  List<T> parse(Object data, T Function(Map<String, dynamic> json)) {
    if (data != null && data is List) {
      return parseList(data, Function);
    }
    return null;
  }

  static List obj2List(Object obj,{List def=null})
  {
    if(obj!=null && obj is List)
      return obj;
    return def;
  }
}
