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
    } catch (e,s) {
      print(e);
      print(s);
    }
  }

  int height;
  String time;
  DateTime time_dt;

  // Height: 195007,
  // Time: "2020-12-28T04:04:27Z"
  // Message: {
  //   Version: 0,
  //   To: "t04",
  //   From: "t3v2m2rkfoaqcqavhazvuplnqjpn4tgfgrej5r7sjrv27sa2ulftepflbcjakzk3pw3fysrdznz6kw6l4aamja",
  //   Nonce: 0,
  //   Value: "0",
  //   GasPrice: "0",
  //   GasLimit: 10000000,
  //   Method: 2,
  //   Params: "hVgxA66ZqKiuBAUAVODNaPW2CXt5MxTRInsfyTGuvyBqiyzI8qwiSBWVbfbZcSiPLc+Vb1gxA66ZqKiuBAUAVODNaPW2CXt5MxTRInsfyTGuvyBqiyzI8qwiSBWVbfbZcSiPLc+VbwFYJgAkCAESIGrQGoPrwFHUHD3dJiPb7wNPgTXj9l5W/Bgd0mlzZYwYgA=="
  // }
  TepkOrder.fromJsonTepk(Map<String, dynamic> jsonobj) {
    try {
      height = jsonobj["Height"];
      time = jsonobj["Time"]; //"2020-12-28T04:04:27Z"
      time_dt = DateTime.tryParse(time);
      Map<String, dynamic> json = jsonobj["Message"];
      version = json["Version"] ?? 0;
      from = json["From"] ?? "";
      to = json["To"] ?? "";
      value = json["Value"] ?? "0";
      double v = StringUtils.parseDouble(value, 0);
      value_d = v / 1000000000000000000;
      nonce = json["Nonce"] ?? 0;
      gas_limit = StringUtils.parseDouble(json["GasLimit"], 0);
      gas_price = json["GasPrice"] ?? "0";
      method = json["Method"].toString();
      params = json["Params"] ?? "";
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
