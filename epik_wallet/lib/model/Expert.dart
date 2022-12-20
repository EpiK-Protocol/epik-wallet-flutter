import 'package:epikwallet/localstring/resstringid.dart';
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
    //0
    if (text.contains("registered")) return ExpertStatus.registered;
    // 0  2
    if (text.contains("nominated") || text.contains("no enough votes")) return ExpertStatus.nominated;
    //1
    if (text.contains("normal") || text.contains("qualified")) return ExpertStatus.normal;
    if (text.contains("blocked")) return ExpertStatus.blocked;
    if (text.contains("disqualified")) return ExpertStatus.disqualified;

    return null;
  }

  String getString() {
    switch (this) {
      case ExpertStatus.registered:
        return RSID.expertview_9.text; //"已注册";
      case ExpertStatus.nominated:
        return RSID.expertview_10.text; //"已审核";
      case ExpertStatus.normal:
        return RSID.expertview_11.text; //"活跃的";
      case ExpertStatus.blocked:
        return RSID.expertview_12.text; //"黑名单";
      case ExpertStatus.disqualified:
        return RSID.expertview_13.text; //"黑名单";
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
  int status = 0;
  String statusDesc;

  //差多少票
  String required_vote; // "100000"
  //数据量？
  int data_count; //1
  //hash
  String application_hash;

  ExpertStatus status_e;

  double vote_d = 0;
  double required_vote_d = 0;

  String domain;

  String getRequiredVoteStr() {
    if (required_vote_d > 0) return "  /  ${StringUtils.formatNumAmount(required_vote)}";
    return "";
  }

  Expert.fromJson(Map<String, dynamic> json) {
    try {
      id = json["id"]; //json["ID"];//"ID": "f01000",
      vote = json["vote"]; //json["VoteAmount"]; //"VoteAmount": "8500",
      income = json["income"]; //json["Reward"]; //"Reward" :"0",

      // "Status":1,"StatusDesc":"qualified",
      status = StringUtils.parseInt(json["status"], 0);
      statusDesc = json["status_desc"];

      required_vote = json["required_vote"];
      data_count = json["data_count"];
      application_hash = json["application_hash"];

      status_e = ExpertStatusEx.ofString(statusDesc);

      vote_d = StringUtils.parseDouble(vote, 0);
      required_vote_d = StringUtils.parseDouble(required_vote, 0);

      String TotalReward = json["total_reward"];
      income = StringUtils.bigNumDownsizing(TotalReward);

      domain = json["domain"];
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
      vote_d = StringUtils.parseDouble(vote, 0);

      String RequiredVotes = json["RequiredVotes"];
      required_vote = StringUtils.bigNumDownsizing(RequiredVotes);
      required_vote_d = StringUtils.parseDouble(required_vote, 0);

      String TotalReward = json["TotalReward"];
      income = StringUtils.bigNumDownsizing(TotalReward);

      status = StringUtils.parseInt(json["Status"], 0);
      statusDesc = json["StatusDesc"];
      // "Status":1,"StatusDesc":"qualified"
      status_e = ExpertStatusEx.ofString(statusDesc);

      data_count = json["DataCount"];
    } catch (e, s) {
      print(s);
    }
  }
}

enum ExpertInfoStatus {
  pre_regist, //已经保存资料
  regist, // 已提交审核
  nomal, // 审核通过
  reject, // 审核已被拒绝
}

extension ExpertInfoStatusEx on ExpertInfoStatus {
  static ExpertInfoStatus ofString(String text) {
    // 0 Registered 已提交
    // 1 Qualified  已通过（投票达标）
    // 2 Unqualified 未通过（投票未达标）
    // 3 Blocked  被拒绝 需要重新申请

    if (text.contains("pre_regist")) {
      return ExpertInfoStatus.pre_regist;
    }
    if (text.contains("regist") || text.contains("registered") || text.contains("unqualified")) {
      return ExpertInfoStatus.regist; // 已提交
    }
    if (text.contains("nomal") || text.contains("qualified")) {
      return ExpertInfoStatus.nomal; //通过
    }
    if (text.contains("reject") || text.contains("blocked")) {
      return ExpertInfoStatus.reject; // 未通过  被拒绝
    }
    return ExpertInfoStatus.regist;
  }
}

class ExpertInfo {
  String hash; //":"e1997d001e95a0a0cceb5828bb999cdff2ec3d80d4ff2ba3f3993cfc3163d644",
  String email; //":"121312981@qq.com",
  String name; //":"程宇",
  String domain; //":"1111",
  String plain; //":"Name:程宇\nMobile:18801146606\nEmail:121312981@qq.coDomain:1111\nIntroduction:2222\nLicense:",
  String created_at; //":"2021-04-12T17:23:22.122801+08:00"
  // 资料审核状态  pre_regist   regist   nomal   reject
  String status; //"status":"0", //"status_desc":"registered",
  String status_desc;
  String reason;

  DateTime dt_created_at;
  ExpertInfoStatus status_t;

  // 2021-10-10 删除
  // String mobile; //":"18801146606",  删除 手机号
  // String introduction; //":"2222",  删除 自我介绍
  // String license; //":"",  删除 开源协议

  // 2021-10-10 新增
  String language; //语言
  String twitter; //推特
  String linkedin; //领英
  String why; //为什么我能做好这个领域
  String how; //如何推动
  String owner; // f3rivtflppymnpcmqn66a4wb6gx3323xcybw7bop72zj5qbi2hyr7hxznxgocxbj4kwqij2vr55kijc6ls7jva
  String ex_id; // f0641448

  ExpertInfo();

  ExpertInfo.fromJson(Map<String, dynamic> json) {
    try {
      hash = json["hash"];
      name = json["name"];
      // mobile = json["mobile"];
      email = json["email"];
      domain = json["domain"];
      // introduction = json["introduction"];
      // license = json["license"];
      plain = json["plain"];
      created_at = json["created_at"];

      language = json["language"];
      twitter = json["twitter"];
      linkedin = json["linkedin"];
      why = json["why"];
      how = json["how"];

      owner = json["owner"];
      ex_id = json["expert_id"];//json["ex_id"];

      // "Status":1,"StatusDesc":"qualified"
      status = json["status"]; //资料审核状态

      reason = json["reason"]; //原因

      dt_created_at = DateUtil.getDateTime(created_at, isUtc: false) ?? DateTime.now();

      status_desc = json["status_desc"];
      status_t = ExpertInfoStatusEx.ofString(status_desc);

      print(status_t);
    } catch (e, s) {
      print(s);
    }
  }
}
