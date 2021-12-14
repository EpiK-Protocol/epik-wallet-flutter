import 'package:epikwallet/utils/data/date_util.dart';

///Dapp 领取epk记录
class DappEpkSwapRecord{

  int id;// 1,
  String created_at;// "2021-03-27T18:05:12.714079+08:00",
  String updated_at;
  String user_id; //"cf9c95fa-53d5-4e4d-b47d-242c724bdd09"
  String type; //withdraw
  String status;// "failed" success  pending
  String error;
  String asset;//"EPK"
  String hash;//
  String address;// 5
  String amount;// "1.1",
  String balance;// 995
  String fee;//0

  DateTime created_at_dt;
  DateTime updated_at_dt;

  DappEpkSwapRecord.fromJson(Map<String,dynamic> json){
    try {
      id=json["id"];
      created_at=json["created_at"];
      created_at=json["updated_at"];
      user_id=json["user_id"];
      status=json["status"];
      error=json["error"];
      asset=json["asset"];
      hash=json["hash"];
      address=json["address"];
      amount=json["amount"];
      balance=json["balance"];
      fee=json["fee"];

      created_at_dt = DateUtil.getDateTime(created_at, isUtc: false);
      updated_at_dt = DateUtil.getDateTime(updated_at, isUtc: false);
    } catch (e, s) {
      print(e);
    }
  }


}