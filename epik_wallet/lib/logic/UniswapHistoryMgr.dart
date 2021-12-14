import 'dart:convert';

import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/api/api_testnet.dart';
import 'package:epikwallet/logic/api/api_wallet.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/sp_utils/sp_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UniswapHistoryMgr {
  final String TAG = "UniswapHistoryMgr";
  final String _KEY = "uhmgr_";

  String user = "";
  String key = "";

  List<UniswapOrder> _orderList = [];

  UniswapHistoryMgr(String user) {
    this.user = user ?? "";
    key = _KEY + this.user.hashCode.toString();

    load();
  }

  Future load() async {
    Dlog.p(TAG, " load");
    String jsonstr = SpUtils.getString(key);
    Dlog.p(TAG, " load => ${jsonstr}");

    List<UniswapOrder> temp = [];
    if (jsonstr != null && jsonstr.length > 0) {
      try {
        temp = JsonArray.parseList<UniswapOrder>(
            JsonArray.obj2List(jsonDecode(jsonstr)),
            (json) => UniswapOrder.fromJson(json));
        Dlog.p(TAG, " load => ${temp}");
      } catch (e) {
        print(e);
      }
    }

    _orderList = temp ?? [];

    Dlog.p(TAG, " load size = ${_orderList.length}");
  }

  Future save() async {
    Dlog.p(TAG, " save");
    try {
      String save = "";
      if (_orderList != null && _orderList.length > 0) {
        save = jsonEncode(_orderList);
      } else {
        save = "[]";
      }
      Dlog.p(TAG, " save json => " + save);
      SpUtils.putString(key, save).then((res) {
        Dlog.p(TAG, " save res => $res");
      });
    } catch (e) {
      print(e);
    }
  }

  List<UniswapOrder> get orderList {
    Dlog.p(TAG, " get orderList");
    if (_orderList == null) _orderList = [];
    return _orderList;
  }

  addOrder(UniswapOrder uorder, {bool toTop = true}) {
    if (toTop) {
      orderList.insert(0, uorder);
    } else {
      orderList.add(uorder);
    }
  }

  List<UniswapOrder> getPendingList() {
    List<UniswapOrder> pendingList = [];
    orderList.forEach((order) {
      if (order.state == 0) pendingList.add(order);
    });
    return pendingList;
  }

  Future requestState(UniswapOrder order) async {
    HttpJsonRes httpJsonRes = await ApiWallet.checkUniswapOrder(order);
    if (httpJsonRes != null &&
        httpJsonRes.jsonMap != null &&
        httpJsonRes.jsonMap.length > 0) {
      Map j_result = httpJsonRes.jsonMap["result"];
      if (j_result != null) {
//        result: {
//          isError: "1",
//    errDescription: "Bad jump destination"
//  }
        String isError = j_result["isError"] ?? "";
        String errDescription = j_result["errDescription"] ?? "";
        if (isError == "0") {
          // 成功
          order.state = 1;
        } else {
          order.state = 2;
        }
        order.errormsg = errDescription;
      }
    }
  }

  Future requestStateAll() async {
    List<Future> futurelist = [];
    List<UniswapOrder> data = getPendingList();
    if (data.length > 0) {
      data.forEach((item) {
        futurelist.add(requestState(item));
      });
      await Future.wait(futurelist);
      await save();
    }
  }
}

class UniswapOrder {
  /// 交易id
  String hash;

  /// 0 等待结果，1成功，2失败
  int state;

  /// 失败时的错误说明
  String errormsg;

  /// 0 兑换， 1 注入， 2撤回
  int type;

  /// 提交时间 毫秒
  int time;

  /// 币种A
  String token_a;

  /// 币种B
  String token_b;

  /// 币种A 数量
  String amount_a;

  /// 币种B 数量
  String amount_b;

  UniswapOrder({
    this.hash,
    this.state,
    this.type,
    this.time,
    this.token_a,
    this.token_b,
    this.amount_a,
    this.amount_b,
  });

  UniswapOrder.fromJson(Map<String, dynamic> json) {
    try {
      hash = json["hash"] ?? "--";
      state = json["state"] ?? 0;
      errormsg = json["errormsg"] ?? "";
      type = json["type"] ?? 0;
      time = json["time"] ?? 0;
      token_a = json["token_a"] ?? "--";
      token_b = json["token_b"] ?? "--";
      amount_a = json["amount_a"] ?? "--";
      amount_b = json["amount_b"] ?? "--";
    } catch (e) {
      print(e);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json["hash"] = hash;
    json["state"] = state;
    json["errormsg"] = errormsg;
    json["type"] = type;
    json["time"] = time;
    json["token_a"] = token_a;
    json["token_b"] = token_b;
    json["amount_a"] = amount_a;
    json["amount_b"] = amount_b;
    return json;
  }

  IconData getStateIcon() {
    switch (state) {
      case 1:
        return Icons.check_circle_outline;
      case 2:
        return Icons.error_outline;
      case 0:
      default:
        return Icons.access_time;
    }
  }

  Color getStateIconColor() {
    switch (state) {
      case 1:
        return Colors.lightGreen;
      case 2:
        return Colors.redAccent;
      case 0:
      default:
        return Colors.lightBlue;
    }
  }

  String info;

  String getInfo() {
    /// 0 兑换， 1 注入， 2撤回
    if (info == null) {
      switch (type) {
        case 1:
          {
//            return "注入资金 $amount_a $token_a + $amount_b $token_b";
            return "${ResString.get(appContext, RSID.uhm_1)} $amount_a $token_a + $amount_b $token_b";
          }
          break;
        case 2:
          {
//            return "撤回资金 $amount_a $token_a + $amount_b $token_b";
            return "${ResString.get(appContext, RSID.uhm_2)} $amount_a $token_a + $amount_b $token_b";
          }
          break;
        case 0:
        default:
          {
//            return "$amount_a $token_a 兑换成 $amount_b $token_b";
            return "$amount_a $token_a ${ResString.get(appContext, RSID.uhm_3)} $amount_b $token_b";
          }
          break;
      }
    }
    return info;
  }

  String timeString;

  String getTime() {
    if (timeString == null) {
      timeString =
          DateUtil.formatDateMs(time, isUtc: false, format: DataFormats.full);
    }
    return timeString;
  }
}
