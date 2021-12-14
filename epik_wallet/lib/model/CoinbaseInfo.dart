import 'package:epikwallet/utils/string_utils.dart';

class CoinbaseInfo
{
  /// coinbaseinfo={"Total":"0","Vested":"0","Vesting":"0","Coinbase":"f06782"}
  String Coinbase="";//""":"f06782"
  String Total ="0";
  ///可提余额
  String Vested = "0";
  /// 锁定余额
  String Vesting = "0";

  //账户总数
  double total_d=0;
  //可提余额
  double vested_d=0;
  // 锁定余额
  double vesting_d=0;


  CoinbaseInfo();

  CoinbaseInfo.fromJson(Map<String,dynamic>json)
  {
    try {

      Coinbase = json["Coinbase"];

      Total = StringUtils.bigNumDownsizing(json["Total"]??"0");
      Vested = StringUtils.bigNumDownsizing(json["Vested"]??"0");
      Vesting = StringUtils.bigNumDownsizing(json["Vesting"]??"0");

      total_d = StringUtils.parseDouble(Total, 0);
      vested_d = StringUtils.parseDouble(Vested, 0);
      vesting_d = StringUtils.parseDouble(Vesting, 0);
    } catch (e, s) {
      print(s);
    }
  }

}