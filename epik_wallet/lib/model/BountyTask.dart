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

  String _reward;

  /// 奖励区间
  String get reward {
    if (_reward == null)
      _reward =
          "${StringUtils.formatNumAmount(bonus_min, point: 8, supply0: false)}-${StringUtils.formatNumAmount(bonus_max, point: 8, supply0: false)} 积分";
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
    } catch (e) {
      print(e);
    }
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
        return "可认领";
      case BountyStateType.PUBLICITY:
        return "公示中";
      case BountyStateType.END:
        return "已完成";
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
        return "全部";
      case BountyFilterType.COMMUNITY:
        return "社群";
      case BountyFilterType.SPREAD:
        return "推广";
      case BountyFilterType.DEVELOP:
        return "开发";
      case BountyFilterType.BUSINESS:
        return "商务";
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
