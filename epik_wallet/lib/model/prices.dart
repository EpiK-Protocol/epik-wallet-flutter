import 'package:epikwallet/utils/string_utils.dart';

class Prices {
  String id;
  String price="";

  double dPrice = 0;

  Prices({this.id,this.price,this.dPrice});

  Prices.fromJson(Map<String, dynamic> json) {
    try {
      id = StringUtils.parseString(json["id"], "");
      price = StringUtils.parseString(json["price"], "");
      if (StringUtils.isNotEmpty(price))
        dPrice = StringUtils.parseDouble(price, 0);
    } catch (e) {
      print(e);
    }
  }

  Map<String, dynamic> toJson(){
    Map<String, dynamic> json = {};
    json["id"] = id;
    json["price"] = price;
    return json;
  }

}
