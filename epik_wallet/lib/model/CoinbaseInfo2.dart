import 'dart:math';

import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/string_utils.dart';

class CoinbaseInfo2 {
  // id
  String ID; //""":"f06782"
  // address
  String Address;

  //总余额
  CbBalance balance;

  //总算力
  CbPower power;

  //总质押
  CbPledged pledged;

  //所有节点统计
  CbMiner miner;

  //流量质押
  CbRetrieve retrieve;

  //当前主网高度
  int epoch = 0; //: "74941"

  CbTotalPower TotalPower;

  String power_percent = "0";

  CoinbaseInfo2();

  CoinbaseInfo2.fromJson(Map<String, dynamic> json) {
    try {
      epoch = StringUtils.parseInt(json["epoch"], 0);

      Map<String, dynamic> j_coinbase = json["coinbase"];

      ID = j_coinbase["ID"];
      Address = j_coinbase["Address"];

      Map<String, dynamic> j_Balance = j_coinbase["Balance"];
      balance = CbBalance.fromJson(j_Balance);

      Map<String, dynamic> j_Power = j_coinbase["Power"];
      power = CbPower.fromJson(j_Power);

      Map<String, dynamic> j_Pledged = j_coinbase["Pledged"];
      pledged = CbPledged.fromJson(j_Pledged);

      Map<String, dynamic> j_Miner = j_coinbase["Miner"];
      miner = CbMiner.fromJson(j_Miner);

      Map<String, dynamic> j_Retrieve = j_coinbase["Retrieve"];
      retrieve = CbRetrieve.fromJson(j_Retrieve);

      Map<String, dynamic> j_TotalPower = json["totalPower"];
      TotalPower = CbTotalPower.fromJson(j_TotalPower);

      double power_percent_d = (TotalPower?.RawBytePower_i ?? 0) == 0
          ? 0
          : power?.Total_i * 1.0 / (TotalPower?.RawBytePower_i ?? 0);
      power_percent =
          "${StringUtils.formatNumAmount(power_percent_d * 100, point: 2, supply0: false)}%";
    } catch (e, s) {
      print(s);
    }
  }

  ///流量质押解锁剩余高度
  int get retrieve_unlock_epoch {
    int unlockepoch = retrieve?.UnlockEpoch_i ?? 0;
    if (unlockepoch >= epoch)
      return unlockepoch - epoch;
    else
      return 0;
  }

  ///是否有已经解锁的流量质押
  bool get hasRetrieveUnlockEpk {
    return (retrieve?.Locked_d ?? 0) > 0 && retrieve_unlock_epoch <= 0;
  }
}

class CbTotalPower {
  ///全网原值算力
  String RawBytePower = "0"; // "0",
  int RawBytePower_i = 0;
  String RawBytePower_rs = "0"; // GB

  ///全网有效算力
  String QualityAdjPower = "0"; // "0"
  int QualityAdjPower_i = 0;
  String QualityAdjPower_rs = "0"; // GB

  CbTotalPower.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    try {
      RawBytePower = StringUtils.parseString(json["RawBytePower"], "0");
      QualityAdjPower = StringUtils.parseString(json["QualityAdjPower"], "0");

      RawBytePower_i = StringUtils.parseInt(RawBytePower, 0);
      QualityAdjPower_i = StringUtils.parseInt(QualityAdjPower, 0);

      RawBytePower_rs = StringUtils.getRollupSize(RawBytePower_i,
          units: StringUtils.RollupSize_Units1);
      QualityAdjPower_rs = StringUtils.getRollupSize(QualityAdjPower_i,
          units: StringUtils.RollupSize_Units1);
    } catch (e, s) {
      print(s);
    }
  }
}

class CbBalance {
  //账户总数
  String Total = "0";
  double Total_d = 0;

  // 锁定余额
  String Locked = "0";
  double Locked_d = 0;

  //可提余额
  String Unlocked = "0";
  double Unlocked_d = 0;

  CbBalance.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    try {
      Total = StringUtils.parseString(json["Total"], "0");
      Locked = StringUtils.parseString(json["Locked"], "0");
      Unlocked = StringUtils.parseString(json["Unlocked"], "0");

      Total_d = StringUtils.parseDouble(Total, 0);
      Locked_d = StringUtils.parseDouble(Locked, 0);
      Unlocked_d = StringUtils.parseDouble(Unlocked, 0);
    } catch (e, s) {
      print(s);
    }
  }
}

class CbPower {
  ///总算力
  String Total = "0"; // "1247805440",
  int Total_i = 0;

  ///算力平均值
  String Average = "0";
  int Average_i = 0;

  CbPower.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    try {
      Total = StringUtils.parseString(json["Total"], "0");
      Average = StringUtils.parseString(json["Average"], "0");

      Total_i = StringUtils.parseInt(Total, 0);
      Average_i = StringUtils.parseInt(Average, 0);
    } catch (e, s) {
      print(s);
    }
  }

  String total_rs;

  //算力  xxxGB
  String getTotalRs() {
    //retrieve_balance_d *10M
    if (total_rs == null) {
      int num = (Total_i).toInt(); // * 10 * 1024 * 1024
      total_rs =
          StringUtils.getRollupSize(num, units: StringUtils.RollupSize_Units1);
    }
    return total_rs;
  }
}

class CbPledged {
  ///总质押
  String Total = "0"; //"73000",
  double Total_d = 0;

  ///节点质押
  String Mining = "0"; //: "70000",
  double Mining_d = 0;

  ///流量质押
  String Retrieve = "0"; //: "3000"
  double Retrieve_d = 0;

  CbPledged.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    try {
      Total = StringUtils.parseString(json["Total"], "0");
      Mining = StringUtils.parseString(json["Mining"], "0");
      Retrieve = StringUtils.parseString(json["Retrieve"], "0");

      Total_d = StringUtils.parseDouble(Total, 0);
      Mining_d = StringUtils.parseDouble(Mining, 0);
      Retrieve_d = StringUtils.parseDouble(Retrieve, 0);
    } catch (e, s) {
      print(s);
    }
  }
}

class CbMiner {
  //节点总数
  String Count = "0"; //: "70",
  //活跃的节点数
  String Actived = "0"; //: "70",
  //算力不足的节点数
  String LowPower = "0"; //: "0",
  //错误节点数
  String Error = "0";

  //已质押的节点数
  String Pledged = "0"; //: "70",
  //我质押的节点数
  String MyPledged = "0"; //"70",

  //节点ID列表
  List<String> MinerIDs = [];

  CbMiner.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    try {
      Count = StringUtils.parseString(json["Count"], "0");
      Actived = StringUtils.parseString(json["Actived"], "0");
      LowPower = StringUtils.parseString(json["LowPower"], "0");
      Error = StringUtils.parseString(json["Error"], "0");
      Pledged = StringUtils.parseString(json["Pledged"], "0");
      MyPledged = StringUtils.parseString(json["MyPledged"], "0");

      List _MinerIDs = JsonArray.obj2List(json["MinerIDs"], def: []);
      MinerIDs = List.from(_MinerIDs);
      // MinerIDs.sort((left, right) => left?.compareTo(right));
      MinerIDs.sort((left, right){
        // f0242498  f0242498 去掉f 剩下转数字比较大小 升序排列
        int l = StringUtils.parseInt(left.toString().substring(1), 0);
        int r = StringUtils.parseInt(right.toString().substring(1), 0);
        return l?.compareTo(r);
      });
    } catch (e, s) {
      print(s);
    }
  }
}

class CbRetrieve {
  //总流量抵押 Total=Pledged+Locked
  String Total = "0"; // "3000",
  double Total_d = 0;

  // 质押中 (页面总流量抵押用这个)
  String Pledged = "0"; //  "3000",
  double Pledged_d = 0;

  //锁定中
  String Locked = "0"; //"0",
  double Locked_d = 0;

  // 解锁高度
  String UnlockEpoch = "0"; //"0",
  //解锁高度
  int UnlockEpoch_i = 0;

  //Onwer列表
  List<CbOwner> Owners = [];

  CbRetrieve.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    try {
      Total = StringUtils.parseString(json["Total"], "0");
      Total_d = StringUtils.parseDouble(Total, 0);

      Pledged = StringUtils.parseString(json["Pledged"], "0");
      Pledged_d = StringUtils.parseDouble(Pledged, 0);

      Locked = StringUtils.parseString(json["Locked"], "0");
      Locked_d = StringUtils.parseDouble(Locked, 0);

      UnlockEpoch = StringUtils.parseString(json["UnlockEpoch"], "0");
      UnlockEpoch_i = StringUtils.parseInt(UnlockEpoch, 0);

      Owners = JsonArray.parseList(JsonArray.obj2List(json["Owners"]),
              (json) => CbOwner.fromJson(json)) ??
          [];
      Owners.sort((left, right) => left?.ID?.compareTo(right?.ID));
    } catch (e, s) {
      print(s);
    }
  }

  ///合并CbRetrieveAlone里的数据
  mergeCbRetrieveAlone(CbRetrieveAlone cbretrievealone)
  {
    try{
      Locked=cbretrievealone.Locked;
      Locked_d=cbretrievealone.Locked_d;
      UnlockEpoch=cbretrievealone.UnlockedEpoch.toString();
      UnlockEpoch_i=cbretrievealone.UnlockedEpoch;

      Owners.forEach((owner) {
        if(cbretrievealone.pledges.containsKey(owner.ID))
        {
          owner.MyPledged =cbretrievealone.pledges[owner.ID].toString();
          owner.MyPledged_d =cbretrievealone.pledges[owner.ID];
        }
      });
    }catch(e,s){
      print(s);
    }
  }
}

class CbRetrieveAlone{
  // "Pledges":{
  // "f027799":"250000000000000000000",
  // "f037454":"250000000000000000000"
  // },
  String Locked="0";//"0",
  double Locked_d = 0;

  int UnlockedEpoch = 0; //0

  Map<String,double> pledges={};

  CbRetrieveAlone.fromJson(Map<String, dynamic> json){
    try{
      String _locked=StringUtils.parseString(json["Locked"], "0");
      Locked = StringUtils.bigNumDownsizing(_locked);
      Locked_d = StringUtils.parseDouble(Locked, 0);

      UnlockedEpoch= StringUtils.parseInt(json["UnlockedEpoch"], 0);

      Map<String,dynamic> j_Pledges = json["Pledges"];
      if(j_Pledges!=null){
        pledges={};
        j_Pledges.forEach((key, value) {
          pledges[key]=StringUtils.parseDouble(StringUtils.bigNumDownsizing(value??"0"), 0);
        });
      }

    }catch(e,s){
      print(s);
    }
  }

}


class CbOwner {
  String ID; //: "f039659",
  String
      Address; //: "f3sr7clftvx6gxhu37wb52enqquy5hukgrnb67wt6ji77jgzgpadl6sqef7jci6x6uizxfcwwzmjlazc3iidoq",
  String Balance = "0"; //: "1.997770631949959289",
  double Balance_d = 0;

  ///总抵押 epk 需要计算成Gb流量
  String Pledged = "0"; //: "601",
  double Pledged_d = 0;

  ///我个人抵押的  epk 需要计算成Gb流量
  String MyPledged = "0"; //: "600"
  double MyPledged_d = 0;

  ///当日已消耗流量 epk 需要计算成Gb流量
  String DayExpend = "0"; //: "4.5",
  double DayExpend_d = 0;

  ///owner下有多少节点
  String TotalMiner = "0";
  int TotalMiner_i = 0;

  CbOwner.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    try {
      ID = StringUtils.parseString(json["ID"], null);
      Address = StringUtils.parseString(json["Address"], null);

      Balance = StringUtils.parseString(json["Balance"], "0");
      Balance_d = StringUtils.parseDouble(Balance, 0);

      Pledged = StringUtils.parseString(json["Pledged"], "0");
      Pledged_d = StringUtils.parseDouble(Pledged, 0);

      MyPledged = StringUtils.parseString(json["MyPledged"], "0");
      MyPledged_d = StringUtils.parseDouble(MyPledged, 0);

      DayExpend = StringUtils.parseString(json["DayExpend"], "0");
      DayExpend_d = StringUtils.parseDouble(DayExpend, 0);

      TotalMiner = StringUtils.parseString(json["TotalMiner"], "0");
      TotalMiner_i = StringUtils.parseInt(TotalMiner, 0);
    } catch (e, s) {
      print(s);
    }
  }

  String r_Numerator;

  //流量分子
  String getRetrieveNumerator() {
    //retrieve_day_expend_d *10M
    if (r_Numerator == null) {
      int num = (DayExpend_d * 10 * 1024 * 1024).toInt();
      r_Numerator =
          StringUtils.getRollupSize(num, units: StringUtils.RollupSize_Units2);
    }
    return r_Numerator;
  }

  String r_Denominator;

  //流量分母
  String getRetrieveDenominator() {
    //retrieve_balance_d *10M
    if (r_Denominator == null) {
      int num = (Pledged_d * 10 * 1024 * 1024).toInt();
      r_Denominator =
          StringUtils.getRollupSize(num, units: StringUtils.RollupSize_Units2);
    }
    return r_Denominator;
  }

  double debrisPercent;

  double getRetrievePercent() {
    if (debrisPercent == null) {
      debrisPercent = Pledged_d == 0 ? 0 : DayExpend_d / Pledged_d;
      debrisPercent = max(0, min(debrisPercent, 1));
    }
    // Dlog.p("","debrisPercent = $debrisPercent");
    return debrisPercent;
  }
}

class CbMinerObj {
  ///是否被批量操作选中
  // bool isBatchSeleted = false;

  /// miner id
  String ID; //f038958",
  /// owner的地址
  // String OwnerAddress;//f3sp7khymjdvsc5iexxunpsml25b7z6ibycqjcfal6xynnu5hz6idcfknk2g5dhxhnnbhezmqm6bb4ntonisha",
  /// tag标识
  // String UserTag;//
  /// owner ID
  String Owner; //"f037454",
  ///worker ID
  // String Worker;//"f037454",
  /// Coinbase ID
  String Coinbase; //"f01114",
  ///节点的 peer ID
  // String PeerId;//"12D3KooWDszmaD3qEjxyPJZQzznWuEzVUMzr3gxuYwepR4WM7pH9",
  ///扇区大小 需要计算MB GB
  String SectorSize = "0"; //"8388608",
  int SectorSize_i = 0; //"8388608",
  ///String WindowPoStPartitionSectors;//2,
  ///String RetrievalPledger;//"<empty>",
  ///总产出 EPK
  String TotalMined = "0"; //"169.44",
  double TotalMined_d = 0;

  ///基础质押 EPK  节点总抵押
  String MiningPledge = "0"; //"1000",
  double MiningPledge_d = 0;

  ///是否满足出块最小算力 false不能出块
  bool HasMinPower = false; //true,
  ///是否已经绑定
  bool Binded = false; //true

  // "MiningPledgors":{
  // "f01114":"1000"
  // },
  ///节点被谁抵押过  key：coinbaseid  value:抵押了多少EPK
  Map<String, String> MiningPledgors = {};

  // "MiningLocked":{
// "f01114":{
// "Amount":"0",
// "UnlockEpoch":"111"
// }
// }
  Map<String, CbMinerBaseLockedObj> MiningLocked = {};

  // "MinerPower":{
  // "RawBytePower":"17825792",
  // "QualityAdjPower":"17825792"
  // },
  ///原值算力 json[MinerPower][RawBytePower]
  // String RawBytePower="0";//"17825792",
  ///有效算力  json[MinerPower][QualityAdjPower]
  String QualityAdjPower = "0"; //"17825792"
  int QualityAdjPower_i = 0;

  ///总算力
  // "TotalPower":{
  // "RawBytePower":"539829993472",
  // "QualityAdjPower":"541576921088"
  // },

  CbMinerObj.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    try {
      ID = StringUtils.parseString(json["ID"], null);
      Owner = StringUtils.parseString(json["Owner"], null);
      Coinbase = StringUtils.parseString(json["Coinbase"], null);
      SectorSize = StringUtils.parseString(json["SectorSize"], "0");
      SectorSize_i = StringUtils.parseInt(SectorSize, 0);
      TotalMined = StringUtils.parseString(json["TotalMined"], "0");
      TotalMined_d = StringUtils.parseDouble(TotalMined, 0);
      MiningPledge = StringUtils.parseString(json["MiningPledge"], "0");
      MiningPledge_d = StringUtils.parseDouble(MiningPledge, 0);
      HasMinPower = StringUtils.parseBool(json["HasMinPower"], false);
      Binded = StringUtils.parseBool(json["Binded"], false);

      ///节点被谁抵押过  key：coinbaseid  value:抵押了多少EPK
      MiningPledgors = Map.from(json["MiningPledgors"] ?? {});

      ///有效算力  json[MinerPower][QualityAdjPower]
      Map<String, dynamic> j_MinerPower = json["MinerPower"];
      if (j_MinerPower != null) {
        QualityAdjPower =
            StringUtils.parseString(j_MinerPower["QualityAdjPower"], "0");
      } else {
        QualityAdjPower = "0";
      }
      QualityAdjPower_i = StringUtils.parseInt(QualityAdjPower, 0);

      Map<String, dynamic> j_MiningLocked = json["MiningLocked"] ?? {};
      if (j_MiningLocked != null) {
        MiningLocked = {};
        j_MiningLocked.map((key, value) {
          MiningLocked[key] = CbMinerBaseLockedObj.fromJson(value);
        });
      }

      // MiningLocked['f01114'] = CbMinerBaseLockedObj.fromJson({"Amount":"1234","UnlockEpoch":"99999999"});//todo test

    } catch (e, s) {
      print(s);
    }
  }

  String QualityAdjPower_rs;

  //有效算力  xxxGB
  String getQualityAdjPowerRs() {
    //retrieve_balance_d *10M
    if (QualityAdjPower_rs == null) {
      int num = (QualityAdjPower_i).toInt(); // * 10 * 1024 * 1024
      QualityAdjPower_rs =
          StringUtils.getRollupSize(num, units: StringUtils.RollupSize_Units);
    }
    return QualityAdjPower_rs;
  }

  String getMyPledge({String coinbase}) {
    if (coinbase == null) coinbase = Coinbase;
    return MiningPledgors[coinbase] ?? "0";
  }

  double getMyPledgeD({String coinbase}) {
    if (coinbase == null) coinbase = Coinbase;
    return StringUtils.parseDouble(MiningPledgors[coinbase] ?? "0", 0);
  }

  CbMinerBaseLockedObj getMyMiningLocked({String coinbase}) {
    if (coinbase == null) coinbase = Coinbase;
    return MiningLocked[coinbase];
  }

  CbMinerBaseLockedObj myLockedObj=null;
}

class CbMinerBaseLockedObj {
  // {
// "Amount":"0",
// "UnlockEpoch":"111"
// }
  String Amount = "0"; //"0",
  double Amount_d = 0;
  String UnlockEpoch = "0"; //"111",
  int UnlockEpoch_i = 0;

  CbMinerBaseLockedObj();

  CbMinerBaseLockedObj.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    try {
      Amount = StringUtils.parseString(json["Amount"], "0");
      Amount_d = StringUtils.parseDouble(Amount, 0);

      UnlockEpoch = StringUtils.parseString(json["UnlockEpoch"], "0");
      UnlockEpoch_i = StringUtils.parseInt(UnlockEpoch, 0);
    } catch (e, s) {
      print(s);
    }
  }

  ///基础质押解锁剩余高度
  int  leftover_unlockepoch(int coinbase_epoch) {
    if (UnlockEpoch_i >= coinbase_epoch)
      return UnlockEpoch_i - coinbase_epoch;
    else
      return 0;
  }

}
