import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/string_utils.dart';

class AiBotBill {
  int id; //": 84,
  String createdAt; //": "2023-03-14T09:19:28.066Z",
  String createdAt_str; //": "2023-03-14T09:19:28.066Z",
  // String updatedAt;//": "2023-03-14T09:19:28.066Z",
  int userId; //": 3,
  int botId; //": 17,
  String item; //": "68c5b547-8193-4af0-ac7a-7d92934d443c",
  int type = -1; //": null, 正常1是充值，-1是消费
  double amount; //": 1

  //是否消费
  bool get isConsume {
    return type < 0;
  }

  AiBotBill();

  AiBotBill.fromJson(Map<String, dynamic> json) {
    try {
      id = StringUtils.parseInt(json["id"], 0);
      createdAt = StringUtils.parseString(json["createdAt"], "");
      userId = StringUtils.parseInt(json["userId"], 0);
      botId = StringUtils.parseInt(json["botId"], 0);
      item = StringUtils.parseString(json["item"], "");
      type = StringUtils.parseInt(json["type"], -1);
      amount = StringUtils.parseDouble(json["amount"], 0);

      DateTime dt_created = DateUtil.getDateTime(createdAt, isUtc: false) ?? DateTime.now();
      createdAt_str = DateUtil.formatDate(dt_created, format: DataFormats.full);
    } catch (e, s) {
      print(e);
      print(s);
    }
  }
}
