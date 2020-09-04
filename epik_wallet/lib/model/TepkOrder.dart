import 'package:epikwallet/utils/string_utils.dart';

class TepkOrder {
//  "version":0,
//  "from":"t1445lrdsqjoq4x7hw2r254ni3yhmk337h27mrczq",
//  "to":"t1zhwmbbibecmxdoxzslsoi6vzszgaxdur33tuxmq",
//  "value":"33123456000000000000",
//  "nonce":1,
//  "gas_limit":10000,
//  "gas_price":"0",
//  "method":"0",
//  "params":""

  int version = 0;
  String from = "";
  String to = "";
  String value = "0";
  double value_d = 0;
  int nonce = 0;
  double gas_limit = 0;
  String gas_price = "0";
  String method = "";
  String params = "";

  TepkOrder.fromJson(Map<String, dynamic> json) {
    try {
      version = json["version"] ?? 0;
      from = json["from"] ?? "";
      to = json["to"] ?? "";
      value = json["value"] ?? "0";
      double v = StringUtils.parseDouble(value, 0);
      value_d = v / 1000000000000000000;
      nonce = json["nonce"] ?? 0;
      gas_limit = StringUtils.parseDouble(json["gas_limit"], 0);
      gas_price = json["gas_price"] ?? "0";
      method = json["method"] ?? "0";
      params = json["params"] ?? "";
    } catch (e) {
      print(e);
    }
  }

  bool isWithdraw = true;

  checkSelf(String selfaddress)
  {
    isWithdraw = from==selfaddress;
  }
}
