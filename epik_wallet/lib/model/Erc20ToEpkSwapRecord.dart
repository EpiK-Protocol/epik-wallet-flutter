import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/string_utils.dart';

enum SwapStatus {
  created, //已创建
  blocking, //等待确认
  pending, //确认中
  recieved, //已到账
  paying, //支付中
  success, //成功
  failed, //失败
}

extension SwapStatusEx on SwapStatus {
  static SwapStatus fromString(String text) {
    switch (text) {
      case "created": //已创建
        return SwapStatus.created;
      case "blocking": //等待确认
        return SwapStatus.blocking;
      case "pending": //确认中
        return SwapStatus.pending;
      case "recieved": //已到账
        return SwapStatus.recieved;
      case "paying": //支付中
        return SwapStatus.paying;
      case "success": //成功
        return SwapStatus.success;
      case "failed": //失败
        return SwapStatus.failed;
    }
    return null;
  }

  String getName()
  {
    switch(this){
      case SwapStatus.created:
        return RSID.er2ep_state_created.text;
      case SwapStatus.blocking:
        return RSID.er2ep_state_blocking.text;
      case SwapStatus.pending:
        return RSID.er2ep_state_pending.text;
      case SwapStatus.recieved:
        return RSID.er2ep_state_recieved.text;
      case SwapStatus.paying:
        return RSID.er2ep_state_paying.text;
      case SwapStatus.success:
        return RSID.er2ep_state_success.text;
      case SwapStatus.failed:
        return RSID.er2ep_state_failed.text;
    }
    return null;
  }
}

///erc20epk 兑换成 epk 的记录
class Erc20ToEpkSwapRecord {
  int id; // 1,
  String
      epik_address;
  String erc20_address;
  String
      erc20_tx_hash; //"0xf22a86c6a371abe2bea7a81ba7f08d6ba2454b3940304197f3a44419e5b22a8d",
  String epik_cid; //
  String amount; // "1.1",
  String fee; //5 手续费
  String created_at; // "2021-03-27T18:05:12.714079+08:00",
  String status; // failed  success  pending
  SwapStatus swapstatus;
  String err_message; //失败原因
  //兑换方向
  String direction; // erc202epik   epik2erc20
  // true 兑换epik    false 兑换erc20
  bool is2Epik = false;
  CurrencySymbol cs_from, cs_to;

  DateTime created_at_dt;

  double amount_d, fee_d, amount_actual_d;
  String amount_actual;

  int eth_height = 0;
  int epik_epoch = 0;

  Erc20ToEpkSwapRecord.fromJson(Map<String, dynamic> json) {
    try {
      id = json["id"];
      epik_address = json["epik_address"];
      erc20_address = json["erc20_address"];
      erc20_tx_hash = json["erc20_tx_hash"];
      epik_cid = json["epik_cid"];
      amount = json["amount"];
      fee = json["fee"];
      created_at = json["created_at"];
      status = json["status"];
      swapstatus= SwapStatusEx.fromString(status);
      err_message = json["err_message"] ?? null;
      direction = json["direction"];
      is2Epik = direction == "erc202epik" || direction == "";
      if (is2Epik) {
        cs_from = CurrencySymbol.EPKerc20;
        cs_to = CurrencySymbol.EPK;
      } else {
        cs_from = CurrencySymbol.EPK;
        cs_to = CurrencySymbol.EPKerc20;
      }

      amount_d = StringUtils.parseDouble(amount, 0);
      fee_d = StringUtils.parseDouble(fee, 0);
      if (amount_d > fee_d)
        // amount_actual_d = (amount_d-fee_d); // 浮点计算精度有问题 会出现0.00000001 或者 0.99999999
        amount_actual_d = (Decimal.parse(amount_d.toString()) -
                Decimal.parse(fee_d.toString()))
            .toDouble();
      else
        amount_actual_d = 0;
      amount_actual = StringUtils.formatNumAmount(amount_actual_d,
          point: 18, supply0: false);

      created_at_dt = DateUtil.getDateTime(created_at, isUtc: false);

      eth_height = StringUtils.parseInt(json["eth_height"], 0);
      epik_epoch = StringUtils.parseInt(json["epik_epoch"], 0);
    } catch (e, s) {
      print(e);
    }
  }

  int pendingHeight;

  int getPendingHeight(int all_eth_height, int all_epik_epoch) {
    if (pendingHeight == null) {
      if (is2Epik) {
        pendingHeight =
            eth_height == 0 ? 0 : (all_eth_height ?? 0) - eth_height;
      } else {
        pendingHeight =
            epik_epoch == 0 ? 0 : ((all_epik_epoch ?? 0) - epik_epoch);
      }
      pendingHeight = max(pendingHeight, 0);
    }
    return pendingHeight;
  }

  String getPendingProgressString(int all_eth_height, int all_epik_epoch,
      int eth_pending, int epik_pending) {
    if (swapstatus == SwapStatus.pending) {
      // erc20换epik，pending时用eth_height
      // epik换erc20，pending时用epik_height
      pendingHeight = getPendingHeight(all_eth_height, all_epik_epoch);
      int allpending = is2Epik ? eth_pending : epik_pending;
      String ret = " ${pendingHeight}/${allpending}";
      // Dlog.p("aaa","eth_height=$eth_height epik_epoch=$epik_epoch  all_eth_height=$all_eth_height all_epik_epoch=$all_epik_epoch eth_pending=$eth_pending epik_pending=$epik_pending");
      // Dlog.p("bbb","$ret");
      return ret;
    }
    return "";
  }
}
