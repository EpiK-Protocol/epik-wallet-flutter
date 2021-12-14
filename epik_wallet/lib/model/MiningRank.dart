import 'package:epikwallet/utils/string_utils.dart';

class MiningRank {
  String id = ""; //241b7750-e601-54ad-9145-33837529dbbb",
  String wei_xin = ""; //chengyu612",
  String epik_address = ""; //t1ryu3loaszmm7hu4jzm3om4kwebgk5koic436sni",
  String erc20_address = ""; //0xE4b261d6dF28B91288cA5038335E165b484B8418",
  String status = ""; //confirmed",
  String created_at = ""; //2020-09-03T17:26:42.642996Z",
  /// erc20收益
  double profit = 0;
  double airdrop = 0;

  MiningRank.fromJson(Map<String, dynamic> json) {
    try {
      id = json["id"] ?? "";
      wei_xin = json["wei_xin"] ?? "";
      epik_address = json["epik_address"] ?? "";
      erc20_address = json["erc20_address"] ?? "";
      status = json["status"] ?? "";
      created_at = json["created_at"] ?? "";
      profit = StringUtils.parseDouble(json["profit"], 0);
      airdrop = StringUtils.parseDouble(json["airdrop"], 0);
    } catch (e) {
      print("MiningRank.fromJson");
      print(e);
    }
  }
}
