import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/UniswapHistoryMgr.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/EpikErc20SwapConfig.dart';
import 'package:epikwallet/model/auth/RemoteAuth.dart';
import 'package:epikwallet/model/prices.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/http/httputils.dart';

class ApiWallet {
  // GET {{HOST}}/messages?address=t3v2m2rkfoaqcqavhazvuplnqjpn4tgfgrej5r7sjrv27sa2ulftepflbcjakzk3pw3fysrdznz6kw6l4aamja&from=&size=50
  static Future<HttpJsonRes> getEpkOrderList(String address, String from, int size, int epkHeight) async {
    String url = ServiceInfo.makeHostUrl("/messages");
    // String url = "http://116.63.146.223:3002" + "/messages"; // test
    // String url = "https://explorer.epik-protocol.io/api" + "/messages"; //todo
    Map<String, dynamic> params = new Map();
    // address="t3v2m2rkfoaqcqavhazvuplnqjpn4tgfgrej5r7sjrv27sa2ulftepflbcjakzk3pw3fysrdznz6kw6l4aamja";
    params["address"] = address;
    params["from"] = from ?? ""; //Time: "2020-12-28T04:04:27Z"
    params["size"] = size;
    params["height"] = epkHeight;
    return await HttpUtil.instance.requestJson(true, url, params);
  }

  static Future<Map<String, dynamic>> getEthOrderList(
      String contractaddress, String address, String currency, int page, int offset, bool asc) async {
    String url = "http://tx.epik-protocol.io/api";

    Map<String, dynamic> params = {
      "module": "account",
      "page": page,
      "offset": offset,
      "sort": asc ? "asc" : "desc",
      // "action": currency == "ERC20-EPK" || currency == "USDT" ? "tokentx" : "txlist", // ||currency=="BSC-EPK"
      "action": currency !="ETH"? "tokentx" : "txlist", // ||currency=="BSC-EPK"
      "address": address,
      "contractaddress": contractaddress,
    };
    HttpJsonRes hjr = await HttpUtil.instance.requestJson(true, url, params);
    return hjr?.jsonMap??{};
  }

  static Future<Map<String, dynamic>> getBscOrderList(
      String contractaddress, String address, String currency, int page, int offset, bool asc) async {
    String url = ServiceInfo.TEST_DEV_NET?"https://api-testnet.bscscan.com/api":"https://api.bscscan.com/api";

    Map<String, dynamic> params = {
      "module": "account",
      "page": page,
      "offset": offset,
      "sort": asc ? "asc" : "desc",
      // "action": currency=="BSC-EPK" || currency == "USDT" ? "tokentx" : "txlist",
      "action": currency!="BNB" ? "tokentx" : "txlist",
      "address": address,
      "contractaddress": contractaddress,
      "apikey":"3NX3IR5QQI2YWM3GMN3ATT9BA2V11US2KI",
    };
    HttpJsonRes hjr = await HttpUtil.instance.requestJson(true, url, params);
    return hjr?.jsonMap??{};
  }

  //  #EPIK提交兑换成功交易
//  POST {{HOST}}/wallet/submitTx
//  Content-Type: application/json
//  {
//  "timestamp":111111111,
//  "erc20_address":"",
//  "epik_address":"",
//  "tx_hash":"",
//  "epik_signature":"",
//  "erc20_signature":""
//  }
//  ###
  static Future<HttpJsonRes> Erc2EpkSubmitTx(String tx_hash) async {
    // String url = ServiceInfo.HOST + "/wallet/submitTx";
    String url = ServiceInfo.makeHostUrl("/wallet/submitTx");
    Map<String, dynamic> params = new Map();

    int timestamp = (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).toInt();

    String text = "timestamp=${timestamp}&tx_hash=${tx_hash}";
    Digest digest = sha256.convert(utf8.encode(text));

    String erc20_address = AccountMgr()?.currentAccount?.hd_eth_address;
    String epik_address = AccountMgr()?.currentAccount?.epik_EPK_address;

    Uint8List epik_signature_byte =
        await AccountMgr()?.currentAccount?.epikWallet?.sign(epik_address, Uint8List.fromList(digest.bytes));
    String epik_signature = hex.encode(epik_signature_byte);

    // Uint8List erc20_signature_byte = await AccountMgr()?.currentAccount?.hdwallet.signHash(erc20_address, Uint8List.fromList(digest.bytes));
    Uint8List erc20_signature_byte = await EpikWalletUtils.hdWalletSignHash(AccountMgr()?.currentAccount?.credentials, Uint8List.fromList(digest.bytes));
    String erc20_signature = hex.encode(erc20_signature_byte);

    params["timestamp"] = timestamp;
    params["erc20_address"] = erc20_address ?? "";
    params["epik_address"] = epik_address ?? "";
    params["tx_hash"] = tx_hash;
    params["epik_signature"] = epik_signature; //epk钱包签名 timestamp=%d&tx_hash=%s
    params["erc20_signature"] = erc20_signature; //hd钱包签名 timestamp=%d&tx_hash=%s

    String jsondata = jsonEncode(params);

    return await HttpUtil.instance.requestJson(false, url, null, data: jsondata);
  }

//  #正在执行中的EPIK兑换记录
//  GET {{HOST}}/wallet/runningSwap
//  Content-Type: application/json
//  ###
  static Future<HttpJsonRes> Erc2EpkRunningSwap() {
    // String url = ServiceInfo.HOST + "/wallet/runningSwap";
    String url = ServiceInfo.makeHostUrl("/wallet/runningSwap");
    Map<String, dynamic> params = new Map();
    params["erc20_address"] = AccountMgr()?.currentAccount?.hd_eth_address;
    return HttpUtil.instance.requestJson(true, url, params);
  }

//  #EPIK兑换记录
//  GET {{HOST}}/wallet/swapRecords
//  Content-Type: application/json
//  ###
//   static Future<HttpJsonRes> Erc2EpkSwapRecords() {
//     // String url = ServiceInfo.HOST + "/wallet/swapRecords";
//     String url = ServiceInfo.makeHostUrl("/wallet/swapRecords");
//     Map<String, dynamic> params = new Map();
//     params["erc20_address"] = AccountMgr()?.currentAccount?.hd_eth_address;
//     return HttpUtil.instance.requestJson(true, url, params);
//   }

  ///EPIK钱包币种报价
  static Future<HttpJsonRes> getCurrencyPrice() {
    // String url = ServiceInfo.HOST + "/wallet/price";
    String url = ServiceInfo.makeHostUrl("/wallet/price");
    return HttpUtil.instance.requestJson(true, url, null);
  }

  static List<Prices> _last_prices = [];

  static Future<List<Prices>> getPriceList() async {
    List<Prices> ret = [];
    HttpJsonRes res = await getCurrencyPrice();
    if (res != null && res.code == 0) {
      ret = JsonArray.parseList<Prices>(JsonArray.obj2List(res?.jsonMap["prices"]), (json) => Prices.fromJson(json));
    }
    if (ret != null && ret.length > 0) {
      _last_prices = ret;
    } else {
      ret = _last_prices;
    }
    return ret;
  }

  static Future<HttpJsonRes> checkUniswapOrder(UniswapOrder order) {
//    https://tx.epik-protocol.io/api?module=transaction&action=getstatus&txhash=0x182a8257c552c79ba36d628f123f47bbcfda55482735d4ce433d97ddae1ea01a
    String url = "https://tx.epik-protocol.io/api?module=transaction&action=getstatus&txhash=${order.hash}";
    return HttpUtil.instance.requestJson(true, url, null);
  }

  static Future<HttpJsonRes> getUniswapEpkKline(DateTime start, DateTime end) {
    DateTime dt0 = DateTime.now();
    // Dlog.p("test", "本地 ${dt0.toIso8601String()}  isutc=${dt0.isUtc}");
    // UTC时间
    String time = DateUtil.formatDate(dt0.toUtc(), format: "yyyy-MM-ddTHH:mm:ss") + "Z";
    // Dlog.p("test", "转UTC " + time);
    // 本地北京时间
    DateTime dt = DateTime.tryParse(time).toLocal();
    // Dlog.p("test", "转本地 ${dt.toIso8601String()}  isutc=${dt.isUtc}");

    //https://explorer.epik-protocol.io/api/wallet/kline?start=2020-11-10T18:00:00Z&end=2020-11-15T14:00:00Z
    // String url = ServiceInfo.HOST+"/wallet/kline";
    String url = ServiceInfo.makeHostUrl("/wallet/kline");
    Map<String, dynamic> params = new Map();
    params["start"] = DateUtil.formatDate(start.toUtc(), format: "yyyy-MM-ddTHH:mm:ss") + "Z";
    params["end"] = DateUtil.formatDate(end.toUtc(), format: "yyyy-MM-ddTHH:mm:ss") + "Z";
    return HttpUtil.instance.requestJson(true, url, params);
  }

  /// ERC20EPK<->EPIK, 双向兑换的config设置
  static Future<EpikErc20SwapConfig> getSwapConfig() async {
    String url = ServiceInfo.makeHostUrl("/wallet/swapConfig");

    Map<String, dynamic> params = new Map();

    Map<String, dynamic> headers = {"token": null};

    HttpJsonRes hjr = await HttpUtil.instance.requestJson(true, url, params, headers: headers);
    if (hjr?.code == 0) {
      return EpikErc20SwapConfig.fromJson(hjr.jsonMap["config"]);
    }
    return null;
  }

  //ERC20EPK<->EPIK 兑换记录 失败时 可以用这个接口重提交
  static Future<HttpJsonRes> retrySwapTx(
    int swapID,
    String token,
  ) {
    String url = ServiceInfo.makeHostUrl("/wallet/retrySwapTx");
    Map<String, dynamic> headers = {"token": token};
    Map<String, dynamic> body = {"id": swapID};
    return HttpUtil.instance.requestJson(false, url, null, data: jsonEncode(body), headers: headers);
  }

  /// ERC20EPK->EPIK, 提交erc20epk交易记录
  static Future<HttpJsonRes> swap2EPIK(WalletAccount wa, String token, String erc20_txhash) async {
    String url = ServiceInfo.makeHostUrl("/wallet/submitERC20Tx");

    // tx_hash            string `json:"tx_hash"`
    // EpikAddress    string `json:"epik_address"`
    // Erc20Address   string `json:"erc20_address"`
    // EpikSignature  string `json:"epik_signature"` // epik签名eth地址
    // Erc20Signature string `json:"erc20_signature"`// eth签名epik地址

    Map<String, dynamic> params = new Map();

    params["tx_hash"] = erc20_txhash;

    params["epik_address"] = wa.epik_EPK_address;
    params["erc20_address"] = wa.hd_eth_address;

    Digest digest_epik = sha256.convert(utf8.encode(wa.hd_eth_address));
    Uint8List epik_signature_byte =
        await wa.epikWallet.sign(wa.epik_EPK_address, Uint8List.fromList(digest_epik.bytes));
    params["epik_signature"] = hex.encode(epik_signature_byte); // epik 签名 eth地址

    Digest digest_eth = sha256.convert(utf8.encode(wa.epik_EPK_address));
    // Uint8List erc20_signature_byte = await wa.hdwallet.signHash(wa.hd_eth_address, Uint8List.fromList(digest_eth.bytes));
    Uint8List erc20_signature_byte = await EpikWalletUtils.hdWalletSignHash(wa.credentials, Uint8List.fromList(digest_eth.bytes));
    params["erc20_signature"] = hex.encode(erc20_signature_byte); // eht 签名 epik地址

    Map<String, dynamic> headers = {"token": token};

    return HttpUtil.instance.requestJson(false, url, null, data: jsonEncode(params), headers: headers);
  }

  /// EPIK->ERC20EPK, 提交epik交易记录
  static Future<HttpJsonRes> swap2ERC20EPK(WalletAccount wa, String token, String epik_cid) async {
    String url = ServiceInfo.makeHostUrl("/wallet/submitEPIKTx");

    // Cid            string `json:"Cid"`
    // EpikAddress    string `json:"epik_address"`
    // Erc20Address   string `json:"erc20_address"`
    // EpikSignature  string `json:"epik_signature"`
    // Erc20Signature string `json:"erc20_signature"`

    Map<String, dynamic> params = new Map();
    params["cid"] = epik_cid;

    params["epik_address"] = wa.epik_EPK_address;
    params["erc20_address"] = wa.hd_eth_address;

    Digest digest_epik = sha256.convert(utf8.encode(wa.hd_eth_address));
    Uint8List epik_signature_byte =
        await wa.epikWallet.sign(wa.epik_EPK_address, Uint8List.fromList(digest_epik.bytes));
    params["epik_signature"] = hex.encode(epik_signature_byte); // epik 签名 eth地址

    Digest digest_eth = sha256.convert(utf8.encode(wa.epik_EPK_address));
    // Uint8List erc20_signature_byte = await wa.hdwallet.signHash(wa.hd_eth_address, Uint8List.fromList(digest_eth.bytes));
    Uint8List erc20_signature_byte = await EpikWalletUtils.hdWalletSignHash(wa.credentials, Uint8List.fromList(digest_eth.bytes));
    params["erc20_signature"] = hex.encode(erc20_signature_byte); // eht 签名 epik地址

    Map<String, dynamic> headers = {"token": token};

    return HttpUtil.instance.requestJson(false, url, null, data: jsonEncode(params), headers: headers);
  }

  /// EPIK <-> ERC20  双向兑换记录
  static Future<HttpJsonRes> swapRecords(String token, String erc20_address, String epik_address,
      {int page = 0, int size = 20}) {
    String url = ServiceInfo.makeHostUrl("/wallet/swapRecords");

    Map<String, dynamic> params = new Map();
    params["erc20_address"] = erc20_address;
    params["epik_address"] = epik_address;
    params["page"] = page;
    params["size"] = size;

    Map<String, dynamic> headers = {"token": token};

    return HttpUtil.instance.requestJson(true, url, params, headers: headers);
  }

  /// EPIK <-> ERC20  查询单个兑换记录  erc20 或 epik 任何一个交易记录 就可以查询
  // static Future<HttpJsonRes> swapRecord(String token,
  //     {String erc20_tx_hash, String epik_cid}) {
  //   String url = ServiceInfo.makeHostUrl("/wallet/swapRecords");
  //
  //   Map<String, dynamic> params = new Map();
  //   if (erc20_tx_hash != null) params["erc20_tx_hash"] = erc20_tx_hash;
  //   if (epik_cid != null) params["epik_cid"] = epik_cid;
  //
  //   Map<String, dynamic> headers = {"token": token};
  //
  //   return HttpUtil.instance.requestJson(true, url, params, headers: headers);
  // }

  static Future<HttpJsonRes> sendRemoteAuth(RemoteAuth ra) async {
    try {
      String url = ra.c; //ra.callback;
      String epik_address = AccountMgr()?.currentAccount?.epik_EPK_address;

      //原文解base64得bytes
      Uint8List plain_bytes = base64.decode(ra.p); //base64.decode(ra.plain);
      Dlog.p("sendRemoteAuth", "plain=${ra.p}");
      Dlog.p("sendRemoteAuth", "decodedPlain=${plain_bytes}");

      //原文的bytes提取sha256摘要
      Digest digest = sha256.convert(plain_bytes);
      Uint8List plain_sha256 = Uint8List.fromList(digest.bytes);

      //钱包签名
      Uint8List epik_signature_byte = await AccountMgr()?.currentAccount?.epikWallet?.sign(epik_address, plain_sha256);
      Dlog.p("sendRemoteAuth", "epik_signature_byte=${epik_signature_byte}");

      //签名做base64
      String epik_signature_base64 = base64.encode(epik_signature_byte);
      Dlog.p("sendRemoteAuth", "epik_signature_base64=${epik_signature_base64}");

      Map<String, dynamic> headers = {
        "address": epik_address,
        "signature": epik_signature_base64,
        "plain": ra.p, //ra.plain,
      };

      HttpJsonRes hjr = await HttpUtil.instance.requestJson(false, url, null, data: "", headers: headers);
      Dlog.p("sendRemoteAuth", "hjr code=${hjr.code}");
      Dlog.p("sendRemoteAuth", "httpstate ${hjr.httpStatusCode} ${hjr.httpStatusMessage}");

      // if(hjr.code!=0)
      // {
      // if(hjr.httpStatusCode==200)
      // {
      //   hjr.code=0;
      // }
      // }

      return hjr;
    } catch (e, s) {
      print(e);
      print(s);
      HttpJsonRes hjr = HttpJsonRes();
      hjr.code = -1;
      if (e is FormatException) {
        hjr.msg = "BASE64 DECODE ERROR";
      } else {
        hjr.msg = e.toString();
      }
      return hjr;
    }
  }
}
