import 'package:epikwallet/model/Asset.dart';

class CurrencyOrder {
  /**交易量*/
  double amount = 0;
  Asset asset = Asset();
  String created_at_str = "";
  int created_at = 0; // local
  /**交易快照*/
  String snapshot_id = "";
  String source = "";
  String type = "";
  String user_id = "";

  /**交易id*/
  String trace_id = "";

  /**对方MIXIN的ID*/
  String opponent_id = "";

  // 备注
  String data = "";
}
