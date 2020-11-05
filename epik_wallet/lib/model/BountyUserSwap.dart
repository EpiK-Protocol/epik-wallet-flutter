import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/string_utils.dart';

class BountyUserSwapRecord {
//  "id":1,
//  "created_at":"2020-10-10T00:00:00Z",
//  "updated_at":"0001-01-01T00:00:00Z",
//  "miner_id":"241b7750-e601-54ad-9145-33837529dbbb",
//  "amount":100,
//  "erc20_epk":120,
//  "status":"confirm",
//  "tx_hash":""
  int id; //1,
  String created_at; //"2020-10-10T00:00:00Z",
  String updated_at; //0001-01-01T00:00:00Z",
  int bounty_id; //1,
  String miner_id; //"241b7750-e601-54ad-9145-33837529dbbb",
  double amount; //100,
  double erc20_epk; //120,
  double fee;
  String status; //pending已提交,paid已通过,faild失败
  String tx_hash; //""

  String created_at_local;

  BountyUserSwapRecord.fromJson(Map<String, dynamic> json) {
    try {
      id = json["id"] ?? 0;
      created_at = json["created_at"] ?? "";
      updated_at = json["updated_at"] ?? "";
      bounty_id = json["bounty_id"] ?? 0;
      miner_id = json["miner_id"] ?? "";
      amount = StringUtils.parseDouble(json["amount"], 0);
      erc20_epk = StringUtils.parseDouble(json["erc20_epk"], 0);
      fee = StringUtils.parseDouble(json["fee"], 0);
      status = json["status"] ?? "";
      tx_hash = json["tx_hash"] ?? "";

      DateTime dt_created =
          DateUtil.getDateTime(created_at, isUtc: false) ?? DateTime.now();
      created_at_local =
          DateUtil.formatDate(dt_created, format: DataFormats.full);
    } catch (e) {
      print(e);
    }
  }

  String getStatusStr() {
    if (status == "pending") {
      return ResString.get(appContext, RSID.bus_1);//"已提交";
    } else if (status == "paid") {
      return ResString.get(appContext, RSID.bus_2);//"已通过";
    } else if (status == "faild") {
      return ResString.get(appContext, RSID.bus_3);//"失败";
    } else if (status == "reject") {
      return ResString.get(appContext, RSID.bus_4);//"已拒绝";
    } else {
      return "";
    }
  }
}
