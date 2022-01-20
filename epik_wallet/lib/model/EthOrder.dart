import 'dart:math';

import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/utils/string_utils.dart';

class EthOrder {
//  "blockNumber": "9702810",
//  "timeStamp": "1584630273",
//  "hash": "0xfefc50539d6ea315750b91be86be0f6874debe436655d38b754de0673f948a45",
//  "nonce": "805",
//  "blockHash": "0x68fc655936695ba3a503e4dfee619453000a22275e23086c923770fc33234867",
//  "from": "0x745daa146934b27e3f0b6bff1a6e36b9b90fb131",
//  "contractAddress": "0x9f8f72aa9304c8b593d555f12ef6589cc3a579a2",
//  "to": "0x4e83362442b8d1bec281594cea3050c8eb01311c",
//  "value": "100000000000000000000",
//  "tokenName": "Maker",
//  "tokenSymbol": "MKR",
//  "tokenDecimal": "18",
//  "transactionIndex": "104",
//  "gas": "1086402",
//  "gasPrice": "20000000000",
//  "gasUsed": "824131",
//  "cumulativeGasUsed": "3650266",
//  "input": "deprecated",
//  "confirmations": "1093466"

  String from = "";
  String to = "";
  String tokenDecimal = "";
  int tokenDecimal_int = 0;
  String value = "0";
  double value_d = 0;
  String hash = "";
  int timeStamp = 0;
  double gasUsedCoin_d=0;

  EthOrder.fromJson(Map<String, dynamic> json) {
    try {
      from = json["from"] ?? "";
      to = json["to"] ?? "";
      tokenDecimal = json["tokenDecimal"] ?? "18";
      tokenDecimal_int = StringUtils.parseInt(tokenDecimal, 0);
      double x = 1;
      x = pow(10,tokenDecimal_int).toDouble();
      value = json["value"] ?? "0";
      double v = StringUtils.parseDouble(value, 0);
      value_d = v / x;
      hash=json["hash"]??"";
      timeStamp = StringUtils.parseInt(json["timeStamp"], 0);

      double gasUsed=StringUtils.parseDouble(json["gasUsed"], 0);
      double gasPrice=StringUtils.parseDouble(json["gasPrice"], 0);
      gasUsedCoin_d = gasUsed*gasPrice/x;
      // print("gasUsedCoin = $gasUsedCoin_d");


      if(timeStamp!=0)
        timeStamp*=1000;
    } catch (e) {
      print(e);
    }
  }

  bool isWithdraw = true;

  checkSelf(String selfaddress)
  {
    isWithdraw = from?.toLowerCase()==selfaddress?.toLowerCase();
  }

  String get numDirection
  {
    if(value_d==0)
      return "";
    if(isWithdraw && from==to)
      return "";
    if(isWithdraw)
      return "-";
    else
      return "+";
  }

  RSID get actionStrId
  {
    // if(value_d==0 || from==to)
    //   return RSID.unknown;
    if(isWithdraw)
      return RSID.withdraw;
    else
      return RSID.deposit;
  }

  bool get isGas{
    return value_d==0 && gasUsedCoin_d>0;
  }
}
