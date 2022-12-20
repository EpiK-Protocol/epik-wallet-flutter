import 'package:epikwallet/model/CoinbaseInfo2.dart';
import 'package:epikwallet/utils/string_utils.dart';

class RentNodeTransferObj {
  String MinerID; //": "f01018",
  String TargetID; //": "f01020",
  String Buyer; //": "f3us5euujg34wkxynq4m7sqwikr72iklphdyyb5eebctczvfsikekifmyuub5vaw2nypp2gru6xj7bry7ubv2a",
  String State; //": "waiting"

  CbMinerObj cbminerobj;

  RentNodeTransferObj();

  RentNodeTransferObj.fromJson(Map<String, dynamic> json) {
    try {
      MinerID = StringUtils.parseString(json["MinerID"], "");
      TargetID = StringUtils.parseString(json["TargetID"], "");
      Buyer = StringUtils.parseString(json["Buyer"], "");
      State = StringUtils.parseString(json["State"], "");
    } catch (e, s) {
      print(e);
      print(s);
    }
  }
}
