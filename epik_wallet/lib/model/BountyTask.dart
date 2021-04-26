import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:flutter/material.dart';

class BountyTask {
//  "ID":2,
//  "title":"测试任务标",
//  "description":"一条测试描述",
//  "type":"spread",
//  "admin":"xxxx",
//  "bonus_min":5,
//  "bonus_max":15,
//  "status":"running",
//  "content":"",
//  "admin_weixin":"asdf1234",
//  "result":"",
//  "publicity_time":null

  int id;

//  String cover;
  String title;
  String description;

  /// 管理员UUID  是挖矿报名后的ID  如果和自己的ID一致 需要在详情页面显示编辑按钮
  String admin;

  /// 管理员的微信号
  String admin_weixin;

  /// 奖励区间
  double bonus_min = 0;

  /// 奖励区间
  double bonus_max = 0;

  /// html详情
  String content;

  /// 公示结果 BountyTaskUser
  String result;
  BountyStateType status = BountyStateType.AVAILABLE;
  BountyFilterType type = BountyFilterType.ALL;

  /// 公示结束时间
  String publicity_time;

  /// 公示结束时间毫秒
  int _publicity_time_ms;

  String _reward;

  /// 奖励区间
  String get reward {
    if (_reward == null) {
//      _reward =
//          "${StringUtils.formatNumAmount(bonus_min, point: 8, supply0: false)}-${StringUtils.formatNumAmount(bonus_max, point: 8, supply0: false)} 积分";
      _reward = ResString.get(appContext, RSID.bts_10, replace: [
        StringUtils.formatNumAmount(bonus_min, point: 8, supply0: false),
        StringUtils.formatNumAmount(bonus_max, point: 8, supply0: false)
      ]);
    }
    return _reward;
  }

  BountyTask();

  BountyTask.fromJson(Map<String, dynamic> json) {
    parseJson(json);
  }

  parseJson(Map<String, dynamic> json) {
    try {
      id = json["id"] ?? 0;
      title = json["title"] ?? "";
      description = json["description"] ?? "";
      admin = json["admin"] ?? "";
      admin_weixin = json["admin_weixin"] ?? "";
      bonus_min = StringUtils.parseDouble(json["bonus_min"], 0);
      bonus_max = StringUtils.parseDouble(json["bonus_max"], 0);
      content = json["content"] ?? "";
      result = json["result"] ?? "";

      type = BountyFilterTypeEx.requestTypeToLocal(json["type"] ?? "");
      status = BountyStateTypeEx.requestTypeToLocal(json["status"] ?? "");

      publicity_time = json["publicity_time"];
      DateTime _dt = DateUtil.getDateTime(publicity_time, isUtc: false);
      _publicity_time_ms = _dt?.millisecondsSinceEpoch ?? 0;
    } catch (e) {
      print(e);
    }
  }

  int getCountdownTimeNum() {
    return _publicity_time_ms - DateUtil.getNowDateMs();
  }

  String getCountdownString() {
    // 公示状态
    if (status == BountyStateType.PUBLICITY) {
      int msTime = getCountdownTimeNum();
      // 倒计时大于0
      if (msTime >= 0)
//        return "(剩余: ${DateUtil.getCountdownString(msTime)})";
//         return ResString.get(appContext, RSID.bts_1,
//             replace: ["${DateUtil.getCountdownString(msTime)}"]);
        return "${DateUtil.getCountdownString(msTime)}";
    }

    return "";
  }
}

enum BountyStateType {
  AVAILABLE, // 可认领
  PUBLICITY, // 公示中
  END, // 已完成
}

extension BountyStateTypeEx on BountyStateType {
  String getName() {
    switch (this) {
      case BountyStateType.AVAILABLE:
        return ResString.get(appContext, RSID.bts_2); //"可认领";
      case BountyStateType.PUBLICITY:
        return ResString.get(appContext, RSID.bts_3); //"公示中";
      case BountyStateType.END:
        return ResString.get(appContext, RSID.bts_4); //"已完成";
      default:
        return "";
    }
  }

  String getRequestState() {
//{running|finish|publicity}
    switch (this) {
      case BountyStateType.AVAILABLE:
        return "running";
      case BountyStateType.PUBLICITY:
        return "publicity";
      case BountyStateType.END:
        return "finish";
      default:
        return "";
    }
  }

  Color getColorTag() {
    switch (this) {
      case BountyStateType.AVAILABLE:
        return Colors.lightGreen[600]; //"可认领";
      case BountyStateType.PUBLICITY:
        return Colors.orangeAccent[400]; //"公示中";
      case BountyStateType.END:
        return Colors.redAccent; //"已完成";
      default:
        return Colors.transparent;
    }
  }

  static BountyStateType requestTypeToLocal(String state) {
//{running|finish|publicity}
    switch (state) {
      case "running":
        return BountyStateType.AVAILABLE;
      case "publicity":
        return BountyStateType.PUBLICITY;
      case "finish":
        return BountyStateType.END;
      default:
        return null;
    }
  }

  Color getColorTagShadow() {
    Color ret = Colors.transparent;
    switch (this) {
      case BountyStateType.AVAILABLE:
        ret = Colors.lightGreen[600]; //"可认领";
        break;
      case BountyStateType.PUBLICITY:
        ret = Colors.orangeAccent[400]; //"公示中";
        break;
      case BountyStateType.END:
        ret = Colors.redAccent; //"已完成";
        break;
    }
    return ret.withOpacity(0.3);
  }
}

enum BountyFilterType {
  ALL, //全部
  COMMUNITY, //社群,
  SPREAD, //推广,
  DEVELOP, //开发,
  BUSINESS, //商务,
}

extension BountyFilterTypeEx on BountyFilterType {
  String getName() {
    switch (this) {
      case BountyFilterType.ALL:
        return ResString.get(appContext, RSID.bts_5); //"全部";
      case BountyFilterType.COMMUNITY:
        return ResString.get(appContext, RSID.bts_6); //"社群";
      case BountyFilterType.SPREAD:
        return ResString.get(appContext, RSID.bts_7); //"推广";
      case BountyFilterType.DEVELOP:
        return ResString.get(appContext, RSID.bts_8); //"开发";
      case BountyFilterType.BUSINESS:
        return ResString.get(appContext, RSID.bts_9); //"商务";
      default:
        return "";
    }
  }

  String getRequestType() {
//    community\spread\development\business
    switch (this) {
      case BountyFilterType.ALL:
        return "";
      case BountyFilterType.COMMUNITY:
        return "community";
      case BountyFilterType.SPREAD:
        return "spread";
      case BountyFilterType.DEVELOP:
        return "development";
      case BountyFilterType.BUSINESS:
        return "business";
      default:
        return "";
    }
  }

  static BountyFilterType requestTypeToLocal(String type) {
//    community\spread\development\business
    switch (type) {
      case "community":
        return BountyFilterType.COMMUNITY;
      case "spread":
        return BountyFilterType.SPREAD;
      case "development":
        return BountyFilterType.DEVELOP;
      case "business":
        return BountyFilterType.BUSINESS;
      default:
        return BountyFilterType.ALL;
    }
  }
}
