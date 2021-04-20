import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/string_utils.dart';

enum ExpertStatus {
  ///新申请的
  registered,

  ///审核通过
  nominated,

  ///正常可用状态
  normal,

  ///被锁 不可用的
  blocked,

  ///被取消资格
  disqualified,
}

extension ExpertStatusEx on ExpertStatus {
  static ExpertStatus ofString(String text) {
    if (text.contains("registered")) return ExpertStatus.registered;
    if (text.contains("nominated")) return ExpertStatus.nominated;
    if (text.contains("normal")) return ExpertStatus.normal;
    if (text.contains("blocked")) return ExpertStatus.blocked;
    if (text.contains("disqualified")) return ExpertStatus.disqualified;

    return null;
  }

  String getString() {
    switch (this) {
      case ExpertStatus.registered:
        return "已注册";
      case ExpertStatus.nominated:
        return "已审核";
      case ExpertStatus.normal:
        return "活跃的";
      case ExpertStatus.blocked:
        return "黑名单";
      case ExpertStatus.disqualified:
        return "黑名单";
    }
  }
}

class Expert {
  String id; //"ID": "f01000",
  //已投
  String vote; //"VoteAmount": "8500",
  // 收益
  String income; //"Reward" :"0",
  //状态
  String status; //"normal(votes not enough)"
  //差多少票
  String required_vote; // "100000"
  //数据量？
  int data_count; //1
  //hash
  String application_hash;

  ExpertStatus status_e;

  double vote_d = 0;
  double required_vote_d = 0;

  String getRequiredVoteStr() {
    if (required_vote_d > 0)
      return "  /  ${StringUtils.formatNumAmount(required_vote)}";
    return "";
  }

  Expert.fromJson(Map<String, dynamic> json) {
    try {
      id = json["id"]; //json["ID"];//"ID": "f01000",
      vote = json["vote"]; //json["VoteAmount"]; //"VoteAmount": "8500",
      income = json["income"]; //json["Reward"]; //"Reward" :"0",
      status = json["status"];
      required_vote = json["required_vote"];
      data_count = json["data_count"];
      application_hash = json["application_hash"];

      status_e = ExpertStatusEx.ofString(status);

      vote_d = StringUtils.parseDouble(vote, 0);
      required_vote_d = StringUtils.parseDouble(required_vote, 0);
    } catch (e, s) {
      print(s);
    }
  }

  parseJsonFromExpertInfo(Map<String, dynamic> json) {
    try {
    //   "Owner":"f023119",
    // "Type":1,
    // "ApplicationHash":"",
    // "Proposer":"f023119",
    // "ApplyNewOwner":"f023119",
    // "ApplyNewOwnerEpoch":-1,
    // "LostEpoch":-1,
    // "Status":0,
    // "StatusDesc":"registered",
    // "ImplicatedTimes":0,
    // "DataCount":0,
    // "CurrentVotes":"0",
    // "RequiredVotes":"100000 000000000000000000",
    // "TotalReward":"0"
    // }

      String CurrentVotes = json["CurrentVotes"];
      vote = StringUtils.bigNumDownsizing(CurrentVotes);
      vote_d = StringUtils.parseDouble(vote,0);

      String RequiredVotes = json["RequiredVotes"];
      required_vote = StringUtils.bigNumDownsizing(RequiredVotes);
      required_vote_d = StringUtils.parseDouble(required_vote,0);


      String TotalReward = json["TotalReward"];
      income=StringUtils.bigNumDownsizing(TotalReward);

      status = json["StatusDesc"];
      status_e = ExpertStatusEx.ofString(status);

      data_count = json["DataCount"];

    } catch (e, s) {
      print(s);
    }
  }
}

enum ExpertInfoStatus{
  pre_regist,//已经保存资料
  regist,// 已提交审核
  nomal,// 审核通过
  reject,// 审核已被拒绝
}

extension ExpertInfoStatusEx on ExpertInfoStatus {

  static ExpertInfoStatus ofString(String text) {
    if (text.contains("pre_regist")) return ExpertInfoStatus.pre_regist;
    if (text.contains("regist")) return ExpertInfoStatus.regist;
    if (text.contains("nomal")) return ExpertInfoStatus.nomal;
    if (text.contains("reject")) return ExpertInfoStatus.reject;
    return ExpertInfoStatus.regist;
  }
}

class ExpertInfo {
  String
      hash; //":"e1997d001e95a0a0cceb5828bb999cdff2ec3d80d4ff2ba3f3993cfc3163d644",
  String name; //":"程宇",
  String mobile; //":"18801146606",
  String email; //":"121312981@qq.com",
  String domain; //":"1111",
  String introduction; //":"2222",
  String license; //":"",
  String
      plain; //":"Name:程宇\nMobile:18801146606\nEmail:121312981@qq.coDomain:1111\nIntroduction:2222\nLicense:",
  String created_at; //":"2021-04-12T17:23:22.122801+08:00"

  DateTime dt_created_at;

  // pre_regist   regist   nomal   reject
  String status;
  String reason;

  ExpertInfoStatus status_t;

  ExpertInfo();

  ExpertInfo.fromJson(Map<String, dynamic> json) {
    try {
      hash = json["hash"];
      name = json["name"];
      mobile = json["mobile"];
      email = json["email"];
      domain = json["domain"];
      introduction = json["introduction"];
      license = json["license"];
      plain = json["plain"];
      created_at = json["created_at"];

      status= json["status"];//资料审核状态
      reason=json["reason"];//原因

      dt_created_at = DateUtil.getDateTime(created_at,isUtc: false) ?? DateTime.now();

      status_t = ExpertInfoStatusEx.ofString(status);

    } catch (e, s) {
      print(s);
    }
  }
}
