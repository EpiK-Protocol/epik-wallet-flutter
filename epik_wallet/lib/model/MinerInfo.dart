import 'package:epikwallet/utils/string_utils.dart';

class MinerInfo {
  String minerid;

  String owner;

  String coin_base; //":"f022188",
  //算力 分子
  String mining_power; //":"755266048",
  //算力 分母
  String total_power; //":"1204382580224",
  // 可提现余额
  String available_balance; //":"7598.847093537273407846",
  // 锁定余额
  String vesting; //":"2023.939270287592628892",
  // 基础抵押
  String mining_pledged; //":"1000",
  // 我的基础抵押
  String my_mining_pledge; //":"0",
  // 流量抵押余额
  String retrieve_balance; //":"0",
  // 流量抵押锁定
  String retrieve_locked; //":"0",
  // 今日使用流量份额
  String retrieve_day_expend; //":"0"

  int mining_power_i=0;
  int total_power_i=0;
  String mining_power_s="0";
  String total_power_s="0";

  double power_percent_d=0;
  String power_percent="";

  double   available_balance_d,vesting_d,mining_pledged_d,retrieve_balance_d,retrieve_locked_d;

  double getBalance()
  {
    // 可提现余额 锁定余额 基础抵押
    double ret= available_balance_d+ vesting_d +mining_pledged_d;
    // print("getBalance=$ret = ${available_balance_d} + ${vesting_d} + ${mining_pledged_d} + ");
    return ret;
  }

  MinerInfo();

  MinerInfo.fromJson(Map<String, dynamic> json) {
    try {
      owner=json["owner"]??"";
      coin_base = json["coin_base"];
      mining_power = json["mining_power"];
      total_power = json["total_power"];
      available_balance = json["available_balance"];
      vesting = json["vesting"];
      mining_pledged = json["mining_pledged"];
      my_mining_pledge = json["my_mining_pledge"];
      retrieve_balance = json["retrieve_balance"];
      retrieve_locked = json["retrieve_locked"];
      retrieve_day_expend = json["retrieve_day_expend"];

      mining_power_i=StringUtils.parseInt(mining_power, 0);
      total_power_i=StringUtils.parseInt(total_power, 0);
      mining_power_s=StringUtils.getRollupSize(mining_power_i,units: StringUtils.RollupSize_Units1);
      total_power_s=StringUtils.getRollupSize(total_power_i,units: StringUtils.RollupSize_Units1);

      power_percent_d= total_power_i==0 ?0 : mining_power_i*1.0/total_power_i;
      power_percent="${StringUtils.formatNumAmount(power_percent_d*100,point: 4,supply0: false)}%";

      available_balance_d=StringUtils.parseDouble(available_balance, 0);
      vesting_d=StringUtils.parseDouble(vesting, 0);
      mining_pledged_d=StringUtils.parseDouble(mining_pledged, 0);
      retrieve_balance_d=StringUtils.parseDouble(retrieve_balance, 0);
      retrieve_locked_d=StringUtils.parseDouble(retrieve_locked, 0);

    } catch (e, s) {
      print(s);
    }
  }

  // double debrisPercent=0;

  double getRetrievePercent() {
    // debrisPercent = debrisTotal == 0 ? 0 : debrisCount / debrisTotal;
    // debrisPercent = max(0, min(debrisPercent, 1));
    return 0.5;
  }
}
