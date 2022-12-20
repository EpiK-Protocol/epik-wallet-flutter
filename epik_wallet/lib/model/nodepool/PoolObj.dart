import 'package:decimal/decimal.dart';
import 'package:epikwallet/utils/string_utils.dart';

class PoolObj {
  //是否启用
  bool Enable = true;
  String Coinbase; //": "f3rbef6kxr2zwztscia2p2dw55bqifaudqcvpgymhbx2u6cmqhhzyqxebzdfmh3pqb6ek5r2zlpmx3a7capsqa",
  String CoinbaseID; //": "f01022",
  // String CoinbasePK; //": null,
  //抽成收益地址
  String FeeAddress; //": "f01021",
  //名称
  String Name; //": "Rainer",
  //描述
  String Description; //": "test",
  //收益比例
  String Fee; //": "0.3",
  //矿池创建人地址
  String Creator; //": "f3vzgff2zlhfclhvycmxojc3c3kgrqj524u4bpmyl4ww5aaxwuv7pess2fv2qkj5vcvxnhiqva3moh6zjp63hq",

  //活跃节点数
  int Actived = 0;

  //空闲节点数量
  int Available = 0; //1,

  //节点总数
  int Count = 0; //1

  //年化收益率
  String APY ="0";

  String apy_f="0%";

  //owner列表
  List<String> Owners;
  // "Owners": [
  // "f01006"
  // ],

  //节点列表
  List<String> Nodes;//{"f01017": "f01017"},
  //可用节点列表
  List<String> AvailableNodes;//{"f01017": "f01017"},
  //锁定节点列表
  List<String> LockedNodes;//{"f01017": "f01017"},


  bool myCreated=false;
  bool opendes=false;

  PoolObj(){}

  PoolObj.fromJson(Map<String,dynamic> json)
  {
    parseJson(json);
  }

  parseJson(Map<String, dynamic> json) {
    try {
      Coinbase = StringUtils.parseString(json["Coinbase"], null);
      CoinbaseID = StringUtils.parseString(json["CoinbaseID"], null);
      FeeAddress = StringUtils.parseString(json["FeeAddress"], null);
      Name = StringUtils.parseString(json["Name"], null);
      Description = StringUtils.parseString(json["Description"], null);
      Fee = StringUtils.parseString(json["Fee"], null);
      Creator = StringUtils.parseString(json["Creator"], null);

      Enable = StringUtils.parseBool(json["Enable"], false);
      Actived = StringUtils.parseInt(json["Actived"], 0);
      Available = StringUtils.parseInt(json["Available"], 0);
      Count = StringUtils.parseInt(json["Count"], 0);
      APY=StringUtils.parseString(json["APY"], "0");
      Decimal d_apy=Decimal.parse(APY);//小数 0.34
      apy_f = StringUtils.formatNumAmount((d_apy*Decimal.fromInt(100)).toString())+"%"; //百分数

      Owners =  List<String>.from(json["Owners"] ?? []);

      // Nodes;//{"f01017": "f01017"},
      Map<String,dynamic> j_Nodes = json["Nodes"]??{};
      Nodes = List<String>.from(j_Nodes?.keys??[]);

      Map<String,dynamic> j_AvailableNodes = json["AvailableNodes"]??{};
      AvailableNodes = List<String>.from(j_AvailableNodes?.keys??[]);

    // "LockedNodes": {
    //    "f01018": {
    //    "MinerID": "f01018",
    //    "Buyer": "f3xg24peuvgql2sbiukxqelxhknvf3neu6dm52so4bvqdbzh64dj5rhcbwur6pbtqrnrm25chfg372hekh6fua",
    //    "LockedTime": "2022-04-24T12:17:04.347629147+08:00"
    //    },
    // },
      Map<String,dynamic> j_LockedNodes = json["LockedNodes"]??{};
      LockedNodes = List<String>.from(j_LockedNodes?.keys??[]);
    } catch (e) {
      print(e);
    }
  }

}
