import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/string_utils.dart';

class BountyUserRewardRecord {
//  "id":1,
//  "created_at":"2020-10-10T00:00:00Z",
//  "updated_at":"0001-01-01T00:00:00Z",
//  "bounty_id":1,
//  "miner_id":"241b7750-e601-54ad-9145-33837529dbbb",
//  "bonus":100,
//  "status":"done",
//  "description":""
  int id; //1,
  String created_at; //"2020-10-10T00:00:00Z",
  String updated_at; //0001-01-01T00:00:00Z",
  int bounty_id; //1,
  String miner_id; //"241b7750-e601-54ad-9145-33837529dbbb",
  double bonus; //100,
  String status; //done",
  String title;
  String description; //""

  String created_at_local;

  BountyUserRewardRecord.fromJson(Map<String, dynamic> json) {
    try {
      id = json["id"] ?? 0;
      created_at = json["created_at"] ?? "";
      updated_at = json["updated_at"] ?? "";
      bounty_id = json["bounty_id"] ?? 0;
      miner_id = json["miner_id"] ?? "";
      bonus = StringUtils.parseDouble(json["bonus"], 0);
      status = json["status"] ?? "";
      title = json["title"] ?? "";
      description = json["description"] ?? ResString.get(appContext, RSID.bur_1);// "完成任务";

      DateTime dt_created = DateUtil.getDateTime(created_at,isUtc: false) ?? DateTime.now();
      created_at_local =
          DateUtil.formatDate(dt_created, format: DataFormats.full);
    } catch (e) {
      print(e);
    }
  }
}
