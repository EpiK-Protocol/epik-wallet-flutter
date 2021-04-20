import 'package:epikwallet/utils/data/date_util.dart';

///erc20epk 兑换成 epk 的记录
class Erc20ToEpkSwapRecord{

  int id;// 1,
  String epik_address;//"f3rivtflppymnpcmqn66a4wb6gx3323xcybw7bop72zj5qbi2hyr7hxznxgocxbj4kwqij2vr55kijc6ls7jva",
  String erc20_address;//"0x576C3F273bE7d218A6Eb040D421b51237945ce10",
  String erc20_tx_hash;//"0xf22a86c6a371abe2bea7a81ba7f08d6ba2454b3940304197f3a44419e5b22a8d",
  String epik_cid;//
  String amount;// "1.1",
  String created_at;// "2021-03-27T18:05:12.714079+08:00",
  String status;// "failed" success  pending

  DateTime created_at_dt;

  Erc20ToEpkSwapRecord.fromJson(Map<String,dynamic> json){
    try {
      id=json["id"];
      epik_address=json["epik_address"];
      erc20_address=json["erc20_address"];
      erc20_tx_hash=json["erc20_tx_hash"];
      epik_cid=json["epik_cid"];
      amount=json["amount"];
      created_at=json["created_at"];
      status=json["status"];

      created_at_dt = DateUtil.getDateTime(created_at, isUtc: false);
    } catch (e, s) {
      print(e);
    }
  }


}