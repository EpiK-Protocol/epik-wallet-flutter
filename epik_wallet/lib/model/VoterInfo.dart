import 'package:epikwallet/main.dart';
import 'package:epikwallet/utils/string_utils.dart';

class VoterInfo {

  //解锁中的投票
  String UnlockingVotes; //":"0",
  double unlockingvotes_d=0;

  //已解锁的投票
  String UnlockedVotes; //":"0",
  double unlockedvotes_d=0;

  // 可提现的所有投票收益
  String WithdrawableRewards; //":"4826461473838881500000",
  double withdrawablerewards_d;
  Map<String, String> Candidates = {};

  // "Candidates":{
  // "f01000":"10100000000000000000"
  //   }

  //个人已投
  double allvoter = 0;

  String getCandidateById(String id) {
    return Candidates[id] ?? "0";
  }

  VoterInfo();

  VoterInfo.fromjson(Map<String, dynamic> json) {
    parseJson(json);
  }

  parseJson(Map<String, dynamic> json) {
    try {
      String _UnlockingVotes = json["UnlockingVotes"];
      UnlockingVotes = StringUtils.bigNumDownsizing(_UnlockingVotes);
      unlockingvotes_d = StringUtils.parseDouble(UnlockingVotes, 0);

      String _UnlockedVotes = json["UnlockedVotes"];
      UnlockedVotes = StringUtils.bigNumDownsizing(_UnlockedVotes);
      unlockedvotes_d = StringUtils.parseDouble(UnlockedVotes, 0);

      String _WithdrawableRewards = json["WithdrawableRewards"];
      WithdrawableRewards = StringUtils.bigNumDownsizing(_WithdrawableRewards);
      withdrawablerewards_d = StringUtils.parseDouble(WithdrawableRewards, 0);

      allvoter = 0;
      Map<String, dynamic> _Candidates = json["Candidates"];
      Candidates.clear();
      if (_Candidates != null && _Candidates.length > 0) {
        _Candidates.forEach((key, value) {
          Candidates[key] = StringUtils.bigNumDownsizing(value);
          allvoter += StringUtils.parseDouble(Candidates[key], 0);
        });
      }


    } catch (e, s) {
      print(s);
    }
  }

  String getAllvoterF() {
    return StringUtils.formatNumAmountLocaleUnit(allvoter ?? 0, appContext,
        needZhUnit: false);
  }

  String getWithdrawableRewardsF() {
    return StringUtils.formatNumAmountLocaleUnit(
        StringUtils.parseDouble(WithdrawableRewards, 0), appContext,
        needZhUnit: false);
  }

  String getUnlockingVotesF() {
    return StringUtils.formatNumAmountLocaleUnit(unlockingvotes_d ?? 0, appContext,
        needZhUnit: false);
  }

  String getUnlockedVotesF() {
    return StringUtils.formatNumAmountLocaleUnit(unlockedvotes_d ?? 0, appContext,
        needZhUnit: false);
  }
}
