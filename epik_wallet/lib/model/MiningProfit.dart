import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/string_utils.dart';

class MiningProfit {
//  "id":6,
//  "miner_id":"f6289536-e252-5861-bd1e-a57db516bb5f",
//  "tepk":100,
//  "erc20_epk":0,
//  "hash":"txhash",
//  "created_at":"0001-01-01T00:00:00Z"

  int id = 0;
  String miner_id = "";
  double tepk = 0;
  double erc20_epk = 0;
  String hash = "";
  String created_at = ""; //0001-01-01T00:00:00Z
  int created_at_ms = 0;

  MiningProfit.fromJson(Map<String, dynamic> json) {
    try {
      id = json["id"] ?? 0;
      miner_id = json["miner_id"] ?? "";
      tepk = StringUtils.parseDouble(json["tepk"], 0);
      erc20_epk = StringUtils.parseDouble(json["erc20_epk"], 0);
      hash = json["hash"] ?? "";
      created_at = json["created_at"] ?? "";
      DateTime dt = DateUtil.getDateTime(created_at,isUtc: false);
      if (dt != null) {
        created_at_ms = dt.millisecondsSinceEpoch;
      }
    } catch (e) {
      print(e);
    }
  }
}
