import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/logic/loader/DL_TepkLoginToken.dart';
import 'package:epikwallet/model/AIBotApp.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/string_utils.dart';

class ApiAIBot {
  static bool TESTNET = false;

  static String makeHostUrl(String path) {
    if (TESTNET) {
      // return ServiceInfo.makeUrl("http://54.168.138.255:3003", path);
      return ServiceInfo.makeUrl("http://43.206.212.148:3003", path);
    } else {
      return ServiceInfo.makeHostUrl(path);
    }
  }

  // /aibot/list   page从0开始
  static Future<HttpJsonRes> getAibotList(
    int page,
    int size,
    /*int offset*/
  ) async {
    String url = makeHostUrl("/aibot/list");
    Map<String, dynamic> params = new Map();
    params["page"] = page;
    params["size"] = size;
    // params["offset"] = offset;
    HttpJsonRes hjr = await HttpUtil.instance.requestJson(true, url, params);
    return hjr;
  }

  // /aibot/points   //AccountMgr()?.currentAccount?.mining_id
  // 获取充值账户里的点数
  static Future<HttpJsonRes> getAccountPoints(String wallet_id) async {
    String url = makeHostUrl("/aibot/points");
    Map<String, dynamic> params = new Map();
    params["wallet_id"] = wallet_id;
    HttpJsonRes hjr = await HttpUtil.instance.requestJson(true, url, params);
    return hjr; //json["data"]="0"
  }

  static AIBotRechargeConfig ai_bot_recharge_config;

  // 充值配置
  static Future<AIBotRechargeConfig> getRechargeConfig() async {
    String url = makeHostUrl("/aibot/recharge_config");
    Map<String, dynamic> params = new Map();
    HttpJsonRes hjr = await HttpUtil.instance.requestJson(true, url, params);
    if (hjr?.code == 0) {
      AIBotRechargeConfig aibotrechargeconfig = AIBotRechargeConfig.fromJson(hjr.jsonMap["data"]);
      ai_bot_recharge_config = aibotrechargeconfig;
      // print("${ai_bot_recharge_config.min} - ${ai_bot_recharge_config.max}");
      return aibotrechargeconfig;
    }
    return null;
  }

  //广告位
  static Future<List<AIBotBanner>> getBanners() async {
    String url = makeHostUrl("/aibot/banners");
    Map<String, dynamic> params = new Map();
    HttpJsonRes hjr = await HttpUtil.instance.requestJson(true, url, params);
    if (hjr?.code == 0) {
      List<AIBotBanner> banners =
          JsonArray.parseList(JsonArray.obj2List(hjr.jsonMap["data"]), (json) => AIBotBanner.fromJson(json));
      return banners;
    }
    return null;
  }

  //order 充值消费记录
  static Future<HttpJsonRes> getOrderList(
    String walletID,
    int page,
    int size,
    /*int offset*/
  ) async {
    String url = makeHostUrl("/aibot/orders");
    url += "/$walletID";
    Map<String, dynamic> params = new Map();
    params["id"] = walletID;
    params["page"] = page;
    params["size"] = size;
    // params["offset"] = offset;
    HttpJsonRes hjr = await HttpUtil.instance.requestJson(true, url, params);
    return hjr;
  }

  //单个订单的数据
  static Future<HttpJsonRes> getOrder(int orderId) async {
    String url = makeHostUrl("/aibot/order");
    url += "/${orderId}";
    Map<String, dynamic> params = new Map();
    HttpJsonRes hjr = await HttpUtil.instance.requestJson(true, url, params);
    return hjr;
  }

  //充值报账  本地钱包转账之后 把链名和hash上报出去
  // chain: epik bsc eth
  static Future<HttpJsonRes> recharge(CurrencySymbol cs, String tx_hash, String amount) {
    String url = makeHostUrl("/aibot/recharge");

    String chain;
    switch (cs) {
      case CurrencySymbol.AIEPK:
        chain = "epik";
        break;
      case CurrencySymbol.EPKerc20:
        chain = "eth";
        break;
      case CurrencySymbol.EPKbsc:
        chain = "bsc";
        break;
    }

    Map<String, dynamic> params = new Map();
    params["chain"] = chain;
    params["tx_hash"] = tx_hash;
    params["amount"] = amount;

    Map<String, dynamic> header = new Map();

    if (TESTNET) {
      header["token"] = AccountMgr().currentAccount.test_wallet_token;
    } else {
      header["token"] = DL_TepkLoginToken?.getEntity()?.getToken();
    }

    return HttpUtil.instance.requestJson(false, url, null, data: jsonEncode(params), headers: header);
  }

  //创建订单  web创建订单
  static Future<HttpJsonRes> makeOrder({
    String wallet_id, // 钱包ID
    int bot_id, //bot ID
    String title, //订单名称
    double amount, //金额
    int timestamp, //时间戳
    String memo, //备注
    String callback, //充值结果服务回调
  }) {
    String url = makeHostUrl("/aibot/makeorder");

    Map<String, dynamic> params = new Map();
    params["wallet_id"] = wallet_id;
    params["bot_id"] = bot_id;
    params["title"] = title;
    params["amount"] = amount;
    params["timestamp"] = timestamp;
    params["memo"] = memo;
    params["callback"] = callback;

    return HttpUtil.instance.requestJson(false, url, null, data: jsonEncode(params));
  }

  // web创建订单后  钱包post支付
  static Future<HttpJsonRes> payOrder({
    String wallet_id, // 钱包ID
    int order_id, //bot ID
    int timestamp, //时间戳
    String wallet_token,
  }) async {
    String url = makeHostUrl("/aibot/pay_order");

    Map<String, dynamic> params = new Map();
    params["wallet_id"] = wallet_id;
    params["order_id"] = order_id;
    params["timestamp"] = timestamp;
    String jsonStr = jsonEncode(params);

    //epik_signature
    WalletAccount account = AccountMgr().currentAccount;
    Digest digest = sha256.convert(utf8.encode(jsonStr));
    print("hash = " + hex.encode(Uint8List.fromList(digest.bytes)));
    print("address = " + account.epik_EPK_address);

    Uint8List epik_signature_byte =
        await account.epikWallet.sign(account.epik_EPK_address, Uint8List.fromList(digest.bytes));
    String epik_signature = hex.encode(epik_signature_byte);
    print("epik_signature = " + epik_signature);

    Map<String, dynamic> headers = new Map();
    headers["token"] = wallet_token;
    headers["signature"] = epik_signature;

    return HttpUtil.instance.requestJson(
      false,
      url,
      null,
      data: jsonStr,
      headers: headers, /*needToken: true*/
    );
  }

  static Future<HttpJsonRes> getOauthTicket(String token) async {
    String url = makeHostUrl("/mainnet/oauth_ticket");
    Map<String, dynamic> headers = {"token": token};
    return HttpUtil.instance.requestJson(true, url, null, headers: headers);
  }

  static Future<Map<String, String>> loginToTest(WalletAccount account) async {
    // epik_address
    // erc20_address
    // epik_signature
    // erc20_signature

    int timestamp = (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).toInt();
    //epik_address
    String epik_address = account.epik_EPK_address;
    //erc20_address
    String erc20_address = account.hd_eth_address;
    //epik_signature
    Digest digest = sha256.convert(utf8.encode("$timestamp"));
    Uint8List epik_signature_byte = await account.epikWallet.sign(epik_address, Uint8List.fromList(digest.bytes));
    String epik_signature = hex.encode(epik_signature_byte);
    //erc20_signature
    // Uint8List erc20_signature_byte = await account.hdwallet.signHash(erc20_address, Uint8List.fromList(digest.bytes));
    Uint8List erc20_signature_byte =
        await EpikWalletUtils.hdWalletSignHash(account.credentials, Uint8List.fromList(digest.bytes));
    // print("erc20_signature_byte0 =${hex.encode(erc20_signature_byte)}");
    // print("erc20_signature_byte1 =${hex.encode(erc20_signature_byte1)}");

    String erc20_signature = hex.encode(erc20_signature_byte);

    String url = makeHostUrl("/mainnet/login");
    Map<String, dynamic> params = new Map();
    params["timestamp"] = timestamp;
    params["epik_address"] = epik_address;
    params["erc20_address"] = erc20_address;
    params["epik_signature"] = epik_signature;
    params["erc20_signature"] = erc20_signature;
    String json = jsonEncode(params);
    Dlog.p("login", json);
    HttpJsonRes hjr = await HttpUtil.instance.requestJson(false, url, null, data: json);
    if (hjr.code == 0) {
      String token = StringUtils.parseString(hjr.jsonMap["token"], "");
      String mining_id = StringUtils.parseString(hjr.jsonMap['id'], "");
      return {"token": token, "id": mining_id};
    }
    return null;
  }

  //获取账户在各个Bot中的余额   key bot_id  value balance
  static Future<Map<String, String>> getBotBalanceList(String wallet_id) async {
    String url = makeHostUrl("/aibot/balance/$wallet_id");
    HttpJsonRes hjr = await HttpUtil.instance.requestJson(true, url, null);
    Map<String, String> map;
    if (hjr.code == 0) {
      List data = hjr.jsonMap["data"] ?? [];
      data.forEach((element) {
        if (map == null) map = {};
        map[element["bot_id"]] = element["balance"];
      });
    }
    return map;
  }
}
