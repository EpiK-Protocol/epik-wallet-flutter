import 'package:epikwallet/utils/string_utils.dart';

class Prices {
  String ID;
  String Price;

  double dPrice = 0;

  Prices();

  Prices.fromJson(Map<String, dynamic> json) {
    try {
      ID = StringUtils.parseString(json["ID"], "");
      Price = StringUtils.parseString(json["Price"], "");
      if (StringUtils.isNotEmpty(Price))
        dPrice = StringUtils.parseDouble(Price, 0);
    } catch (e) {
      print(e);
    }
  }

  Map<String, dynamic> toJson(){
    Map<String, dynamic> json = {};
    json["ID"] = ID;
    json["Price"] = Price;
    return json;
  }

}
