import 'dart:convert';

import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/prices.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/http/httputils.dart';

class ApiTestNet {
  //  #EPIK测试网活动报名
//  POST {{HOST}}/testnet/signup
//  Content-Type: application/json
//
//  {
//  "weixin":"",
//  "epik_address":"",
//  "erc20_address":"",
//  "epik_signature":"",
//  "erc20_signature":""
//  }
//  ###

  ///  EPIK测试网活动报名
  static Future<HttpJsonRes> signup(
      String weixin, epik_address,erc20_address, epik_signature, erc20_signature) {
    String url = ServiceInfo.HOST + "/testnet/signup";
    Map<String, dynamic> params = new Map();
    params["weixin"] = weixin;
    params["epik_address"] = epik_address;
    params["erc20_address"] = erc20_address;
    params["epik_signature"] = epik_signature;
    params["erc20_signature"] = erc20_signature;
    Dlog.p("signup", params.toString());
    String json = jsonEncode(params);
    Dlog.p("signup",json);
    return HttpUtil.instance.requestJson(false, url, null,data:json);
  }

  //  #EPIK测试网状态
//  GET {{HOST}}/testnet/home
//  Content-Type: application/json
//  ###

  ///  EPIK测试网状态
  static Future<HttpJsonRes> home() {
    String url = ServiceInfo.HOST + "/testnet/home";
    return HttpUtil.instance.requestJson(true, url, null);
  }

  //  #EPIK用户收益
//  GET {{HOST}}/testnet/profit?id=aabbccdd
//  Content-Type: application/json
//  ###

  /// #EPIK用户收益
  static Future<HttpJsonRes> getProfit(String id) {
    String url = ServiceInfo.HOST + "/testnet/profit?id=$id";
    return HttpUtil.instance.requestJson(true, url, null);
  }

  //  #EPIK钱包币种报价
//  GET {{HOST}}/wallet/price
//  Content-Type: application/json
//  ###

  ///EPIK钱包币种报价
  static Future<HttpJsonRes> getCurrencyPrice() {
    String url = ServiceInfo.HOST + "/wallet/price";
    return HttpUtil.instance.requestJson(true, url, null);
  }

  static Future<List<Prices>> getPriceList() async {
    List<Prices> ret = [];
    HttpJsonRes res = await getCurrencyPrice();
    if (res != null && res.code == 0) {
      ret = JsonArray<Prices>().parseList(
          JsonArray.obj2List(res?.jsonMap["prices"]),
          (json) => Prices.fromJson(json));
    }
    return ret;
  }
}
