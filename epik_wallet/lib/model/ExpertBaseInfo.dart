import 'package:epikwallet/main.dart';
import 'package:epikwallet/utils/string_utils.dart';

class ExpertInfomation {
  String TotalExperts; //: "1",  //专家总数
  String ActiveExperts; //: "0",// 活跃专家数
  String TotalVote; //: "0",//总票数
  String AvgVote; //: "0",//平均票数
  String TopExpertVote; //: "0", //排名第一的专家票数
  String TotalDataSize; //: "8388608", //总数据量
  String TotalExpertReward; //;: "0", //总专家奖励
  String TotalCrowdsourcingReward; //: "0", //总众包奖励
  String TotalVoteReward; //: "0", //总投票收益
  String AnnualizedRate; //: "0" // 年华收益率

  double AnnualizedRate_d = 0;
  String TotalVote_f="0";
  String AvgVote_f="0";
  String TotalVoteReward_f = "0";

  ExpertInfomation.fromJson(Map<String, dynamic> json) {
    try {
      TotalExperts = json["TotalExperts"];
      ActiveExperts = json["ActiveExperts"];
      TotalVote = json["TotalVote"];
      AvgVote = json["AvgVote"];
      TopExpertVote = json["TopExpertVote"];
      TotalDataSize = json["TotalDataSize"];
      TotalExpertReward = json["TotalExpertReward"];
      TotalCrowdsourcingReward = json["TotalCrowdsourcingReward"];
      TotalVoteReward = json["TotalVoteReward"];
      AnnualizedRate = json["AnnualizedRate"];

      AnnualizedRate_d = StringUtils.parseDouble(AnnualizedRate, 0) * 100;

      // TotalVote_f=StringUtils.formatNumAmount(TotalVote);
      TotalVote_f = StringUtils.formatNumAmountLocaleUnit(StringUtils.parseDouble(TotalVote, 0), appContext,needZhUnit: false);
      // AvgVote_f=StringUtils.formatNumAmount(AvgVote);
      AvgVote_f = StringUtils.formatNumAmountLocaleUnit(StringUtils.parseDouble(AvgVote, 0), appContext,needZhUnit: false);
      // TotalVoteReward_f =StringUtils.formatNumAmount(TotalVoteReward);
      TotalVoteReward_f = StringUtils.formatNumAmountLocaleUnit(StringUtils.parseDouble(TotalVoteReward, 0), appContext,needZhUnit: false);

    } catch (e, s) {
      print(s);
    }
  }
}

//   {
//   baseInfomation: {
//   Height: "0",
//   AvgTipSetTime: "0",
//   TotalBlocks: "0",
//   TotalEPK: "1000000000", // 总epk
//   CirculationEPK: "28124000",  //循环 epk
//   EPK_USDTPrice: "1.2687166546995974"
//   },
//   code: {
//   code: 0,
//   message: "OK"
//   },
//   expertInfomation: {
//   TotalExperts: "1",  //专家总数
//   ActiveExperts: "0",// 活跃专家数
//   TotalVote: "0",//总票数
//   AvgVote: "0",//平均票数
//   TopExpertVote: "0", //排名第一的专家票数
//   TotalDataSize: "8388608", //总数据量
//   TotalExpertReward: "0", //总专家奖励
//   TotalCrowdsourcingReward: "0", //总众包奖励
//   TotalVoteReward: "0", //总投票收益
//   AnnualizedRate: "0" // 年华收益率
//   },
//   minerInfomation: {
//   TotalMiners: "1", // 总矿机数量
//   PledgedMiners: "1",
//   ActiveMiners: "1",
//   TotalPower: "16777216",
//   TopMinerPower: "16777216",
//   MinerMinWinPower: "1677.7216",
//   TotalMinerPledged: "1000",
//   TotalRetrievalPledged: "0",
//   TotalPledged: "1000",
//   TotalMiningReward: "0",
//   TotalRetrievalReward: "0",
//   DataFlowPerEPK: "10485760"
//   }
// }
