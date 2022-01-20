// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:convert/convert.dart';
// import 'package:crypto/crypto.dart';
// import 'package:epikwallet/logic/EpikWalletUtils.dart';
// import 'package:epikwallet/logic/UniswapHistoryMgr.dart';
// import 'package:epikwallet/logic/account_mgr.dart';
// import 'package:epikwallet/logic/api/serviceinfo.dart';
// import 'package:epikwallet/model/prices.dart';
// import 'package:epikwallet/utils/Dlog.dart';
// import 'package:epikwallet/utils/JsonUtils.dart';
// import 'package:epikwallet/utils/data/date_util.dart';
// import 'package:epikwallet/utils/http/httputils.dart';
// import 'package:epikwallet/utils/string_utils.dart';
//
// class ApiTestNet {
// //  #EPIK测试网登录
// //  POST {{HOST}}/testnet/login
// //  Content-Type: application/json
// //  {
// //  "timestamp":123,
// //  "address":"",
// //  "signature":""
// //  }
//   static Future<HttpJsonRes> login(WalletAccount account) async {
//     int timestamp =
//         (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).toInt();
//     String address = account?.hd_eth_address;
//     String text = "address=${address}&timestamp=${timestamp}";
//     Digest digest = sha256.convert(utf8.encode(text));
//     String signature = hex.encode(await account?.hdwallet
//         ?.signHash(address, Uint8List.fromList(digest.bytes)));
//     Dlog.p("login", "text = $text");
//     String url = ServiceInfo.HOST + "/testnet/login";
//     Map<String, dynamic> params = new Map();
//     params["timestamp"] = timestamp;
//     params["address"] = address;
//     params["signature"] = signature;
// //    Dlog.p("login", params.toString());
//     String json = jsonEncode(params);
//     Dlog.p("login", json);
//     return HttpUtil.instance.requestJson(false, url, null, data: json);
//   }
//
//   //  #EPIK测试网活动报名
// //  POST {{HOST}}/testnet/signup
// //  Content-Type: application/json
// //
// //  {
// //  "weixin":"",
// //  "epik_address":"",
// //  "erc20_address":"",
// //  "epik_signature":"",
// //  "erc20_signature":"",
// //  "platform":"weixin/telegram"
// //  }
// //  ###
//
//   ///  EPIK测试网活动报名
//   static Future<HttpJsonRes> signup(String weixin, epik_address, erc20_address,
//       epik_signature, erc20_signature, platform) {
//     String url = ServiceInfo.HOST + "/testnet/signup";
//     Map<String, dynamic> params = new Map();
//     params["weixin"] = weixin;
//     params["epik_address"] = epik_address;
//     params["erc20_address"] = erc20_address;
//     params["epik_signature"] = epik_signature;
//     params["erc20_signature"] = erc20_signature;
//     params["platform"] = platform;
//     Dlog.p("signup", params.toString());
//     String json = jsonEncode(params);
//     Dlog.p("signup", json);
//     return HttpUtil.instance.requestJson(false, url, null, data: json);
//   }
//
//   //  #EPIK测试网状态
// //  GET {{HOST}}/testnet/home?address=
// //  Content-Type: application/json
// //  ###
//
//   ///  EPIK测试网状态
//   static Future<HttpJsonRes> home(String address) {
//     String url = ServiceInfo.HOST + "/testnet/home?address=${address ?? ""}";
//     return HttpUtil.instance.requestJson(true, url, null);
//   }
//
//   //  #EPIK用户收益
// //  GET {{HOST}}/testnet/profit?id=aabbccdd
// //  Content-Type: application/json
// //  ###
//
//   // #EPIK用户收益
//   static Future<HttpJsonRes> getProfit(String id) {
//     String url = ServiceInfo.HOST + "/testnet/profit?id=$id";
//     return HttpUtil.instance.requestJson(true, url, null);
//   }
//
//   //  #EPIK钱包币种报价
// //  GET {{HOST}}/wallet/price
// //  Content-Type: application/json
// //  ###
//
//   ///EPIK钱包币种报价
//   static Future<HttpJsonRes> getCurrencyPrice() {
//     String url = ServiceInfo.HOST + "/wallet/price";
//     return HttpUtil.instance.requestJson(true, url, null);
//   }
//
//   static List<Prices> _last_prices = [];
//
//   static Future<List<Prices>> getPriceList() async {
//     List<Prices> ret = [];
//     HttpJsonRes res = await getCurrencyPrice();
//     if (res != null && res.code == 0) {
//       ret = JsonArray.parseList<Prices>(
//           JsonArray.obj2List(res?.jsonMap["prices"]),
//           (json) => Prices.fromJson(json));
//     }
//     if (ret != null && ret.length > 0) {
//       _last_prices = ret;
//     } else {
//       ret = _last_prices;
//     }
//     return ret;
//   }
//
//   static Future<HttpJsonRes> checkUniswapOrder(UniswapOrder order) {
// //    https://tx.epik-protocol.io/api?module=transaction&action=getstatus&txhash=0x182a8257c552c79ba36d628f123f47bbcfda55482735d4ce433d97ddae1ea01a
//     String url =
//         "https://tx.epik-protocol.io/api?module=transaction&action=getstatus&txhash=${order.hash}";
//     return HttpUtil.instance.requestJson(true, url, null);
//   }
//
// //
//   static Future<HttpJsonRes> getUniswapEpkKline(DateTime start, DateTime end) {
//     DateTime dt0 = DateTime.now();
//     Dlog.p("cccmax", "本地 ${dt0.toIso8601String()}  isutc=${dt0.isUtc}");
//     // UTC时间
//     String time =
//         DateUtil.formatDate(dt0.toUtc(), format: "yyyy-MM-ddTHH:mm:ss") + "Z";
//     Dlog.p("cccmax", "转UTC " + time);
//     // 本地北京时间
//     DateTime dt = DateTime.tryParse(time).toLocal();
//     Dlog.p("cccmax", "转本地 ${dt.toIso8601String()}  isutc=${dt.isUtc}");
//
//     //https://explorer.epik-protocol.io/api/wallet/kline?start=2020-11-10T18:00:00Z&end=2020-11-15T14:00:00Z
//     String url = ServiceInfo.HOST + "/wallet/kline";
//     Map<String, dynamic> params = new Map();
//     params["start"] =
//         DateUtil.formatDate(start.toUtc(), format: "yyyy-MM-ddTHH:mm:ss") + "Z";
//     params["end"] =
//         DateUtil.formatDate(end.toUtc(), format: "yyyy-MM-ddTHH:mm:ss") + "Z";
//     return HttpUtil.instance.requestJson(true, url, params);
//   }
//
//   /// 挖矿页面取消了，账户数据用这个接口加载到钱包账户里
//   static Future<bool> getHome() async {
//     String address = AccountMgr()?.currentAccount?.hd_eth_address ?? "";
//
//     if (StringUtils.isEmpty(address)) return false;
//
//     HttpJsonRes httpjsonres = await ApiTestNet.home(address);
//
//     if (httpjsonres != null && httpjsonres.code == 0) {
//       String mining_id = httpjsonres.jsonMap["id"];
//       String mining_weixin = httpjsonres.jsonMap["weixin"];
//       String mining_platform = httpjsonres.jsonMap["platform"];
//       String mining_status =
//           httpjsonres.jsonMap["status"]; //等待审核pending/ 已经通过confirmed/ 拒绝reject
//
//       if (StringUtils.isEmpty(mining_platform))
//         mining_platform = BingAccountPlatform.WEIXIN;
//       Dlog.p("gethome", "platform = $mining_platform");
//
//       if (address == AccountMgr()?.currentAccount.hd_eth_address) {
//         AccountMgr()?.currentAccount?.mining_id = mining_id;
//         AccountMgr()?.currentAccount?.mining_bind_account = mining_weixin;
//         AccountMgr()?.currentAccount?.mining_account_platform = mining_platform;
//       }
//
//       return true;
//
//       // Map testnet = httpjsonres.jsonMap["testnet"];
//       // total_supply = StringUtils.parseDouble(testnet["total_supply"], 0);
//       // issuance = StringUtils.parseDouble(testnet["issuance"], 0);
//       //
//       // List<MiningRank> temp = JsonArray.parseList<MiningRank>(
//       //     testnet["top_list"], (json) => MiningRank.fromJson(json));
//       // datalist = temp ?? [];
//       //
//       // if (datalist.length == 0) {
//       //   headerList = [ListPageDefState(ListPageDefStateType.EMPTY)];
//       // } else {
//       //   headerList = [];
//       // }
//     }
//     return false;
//   }
// }
