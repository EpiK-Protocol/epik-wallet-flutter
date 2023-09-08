import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/EnumEx.dart';
import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/string_utils.dart';

class AIBotApp {
  String app_key;
  int id;

  String name;
  String description;
  String description_en;

  String icon;
  String url;

  bool enabled;
  bool pinned=false;
  int hot = 0;

  String feature_cover; //视频封面
  String feature_video; // 视频地址

  AIBotApp();

  AIBotApp.fromJson(Map<String, dynamic> json) {
    try {
      app_key = json["app_key"];
      id = json["id"];
      name = json["name"];
      icon = json["icon"];
      url = StringUtils.parseString(json["url"], "").trim();
      description = json["description"]??"";
      description_en = json["description_en"]??"";
      enabled = json["enabled"];
      pinned = json["pinned"]??false;
      hot = StringUtils.parseInt(json["hot"], 0);

      feature_cover=json["feature_cover"]??"";
      feature_video=json["feature_video"]??"";

    } catch (e, s) {
      print(e);
      print(s);
    }
  }


  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json["app_key"] = app_key;
    json["id"] = id;
    json["name"] = name;
    json["description"] = description;
    json["description_en"] = description_en;
    json["icon"] = icon;
    json["url"] = url;
    json["enabled"] = enabled;
    json["hot"] = hot;
    json["pinned"] =pinned;
    return json;
  }
}

// 充值配置  地址、最大最小值
class AIBotRechargeConfig {
  String bsc_address;
  String epik_address;
  String eth_address;
  double max = 0;
  double min = 0;

  AIBotRechargeConfig();

  AIBotRechargeConfig.fromJson(Map<String, dynamic> json) {
    try {
      bsc_address = json["bsc_address"];
      epik_address = json["epik_address"];
      eth_address = json["eth_address"];

      max = StringUtils.parseDouble(json["max"], 0);
      min = StringUtils.parseDouble(json["min"], 0);
    } catch (e, s) {
      print(s);
    }
  }

  bool hasChainAddress(CurrencySymbol cs) {
    switch (cs) {
      case CurrencySymbol.AIEPK:
        return StringUtils.isNotEmpty(epik_address);
      case CurrencySymbol.EPKerc20:
        return StringUtils.isNotEmpty(eth_address);
      case CurrencySymbol.EPKbsc:
        return StringUtils.isNotEmpty(bsc_address);
    }
    return false;
  }
}

class AIBotBanner {
  int id = 0;
  String image;
  String title;
  String url;
  bool outside = false;

  AIBotBanner();

  AIBotBanner.fromJson(Map<String, dynamic> json) {
    try {
      id = StringUtils.parseInt(json["id"], 0);
      image = json["image"];
      title = json["title"];
      url = json["url"];
      outside = StringUtils.parseBool(json["outside"], false);
    } catch (e, s) {
      print(s);
    }
  }
}

class AIBotOrder {
  int id; //": 6,
  int bot_id; //": 0,
  String wallet_id; //": "dc82f73a-2b29-5153-84a6-2101f93d06e6",

  String created_at; //": "2023-02-15T04:08:33.575025Z",
  String updated_at; //": "2023-02-15T04:08:33.575464Z",
  // String deleted_at;//": null,

  String title; //";//: "Recharge By Admin",
  String memo; //": "",

  AIBotOrderType type; //": "recharge",
  String Amount; //": "1000",
  AIBotOrderStatus status; //": "success",
  int timestamp; //": 0, 秒级
  String timestamp_str_local; //本地转化 yyyy-MM-dd HH:mm:ss

  String callback; //": "",
  String tx_hash; //": "",
  String chain; //": ""

  AIBotOrder();

  AIBotOrder.fromJson(Map<String, dynamic> json) {
    try {
      id = StringUtils.parseInt(json["id"], 0);
      bot_id = StringUtils.parseInt(json["bot_id"], 0);
      wallet_id = json["wallet_id"];

      title = json["title"];
      memo = json["memo"];

      String _type = json["type"];
      type = AIBotOrderTypeEx.ofString(_type);

      Amount = json["Amount"];

      String _status = json["status"];
      status = AIBotOrderStatusEx.ofString(_status);

      timestamp = StringUtils.parseInt(timestamp, 0);
      timestamp_str_local =
          DateUtil.formatDate(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000), format: DataFormats.full);

      DateTime dt_created = DateUtil.getDateTime(json["created_at"], isUtc: false) ?? DateTime.now();
      created_at = DateUtil.formatDate(dt_created, format: DataFormats.full);

      DateTime dt_updated = DateUtil.getDateTime(json["updated_at"], isUtc: false) ?? DateTime.now();
      updated_at = DateUtil.formatDate(dt_updated, format: DataFormats.full);
    } catch (e, s) {
      print(s);
    }
  }
}

enum AIBotOrderStatus {
  pending, //等待
  success, //成功,
  failed, //失败,
  close, //关闭,
}

extension AIBotOrderStatusEx on AIBotOrderStatus {
  String getName() {
    return enumName?.toUpperCase();
  }

  static AIBotOrderStatus ofString(String text) {
    for (AIBotOrderStatus abos in AIBotOrderStatus.values) {
      if (abos.enumName == text) {
        return abos;
      }
    }
    return null;
  }
}

enum AIBotOrderType {
  recharge, //充值
  trade, //消费交易
}

extension AIBotOrderTypeEx on AIBotOrderType {
  String getName() {
    return enumName;
  }

  static AIBotOrderType ofString(String text) {
    for (AIBotOrderType abot in AIBotOrderType.values) {
      if (abot.enumName == text) {
        return abot;
      }
    }
    return null;
  }
}

