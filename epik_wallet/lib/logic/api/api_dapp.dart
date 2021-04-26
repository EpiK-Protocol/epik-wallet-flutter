import 'dart:convert';

import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/logic/loader/DL_TepkLoginToken.dart';
import 'package:epikwallet/utils/http/httputils.dart';

/// dapp相关
class ApiDapp {


  // dapp 列表
  static Future<HttpJsonRes> dappList() {
    // String url = ServiceInfo.HOST + "/dapp/list";
    String url =  ServiceInfo.makeHostUrl("/dapp/list");
    return HttpUtil.instance.requestJson(true, url, null);
  }

  // /dapp/info 可领取信息
  static Future<HttpJsonRes> info(String host,String dappid,String dappToken) {
    String url = ServiceInfo.makeUrl(host,"/info");

    Map<String, dynamic> params = new Map();
    params["dapp"] = dappid; // epikg

    Map<String, dynamic> headers = new Map();
    headers["token"] = dappToken;

    return HttpUtil.instance.requestJson(true, url, params,headers: headers);
  }

  // /dapp/withdraw 领取epk
  static Future<HttpJsonRes> withdrawEpk(String host,String amount,String token,String address) {
    String url = ServiceInfo.makeUrl(host,"/withdraw");

    Map<String, dynamic> params = new Map();
    params["amount"] = amount;
    params["address"] = address;

    Map<String, dynamic> headers = new Map();
    headers["token"] = token;

    return HttpUtil.instance.requestJson(false, url, null, data:jsonEncode(params),headers: headers);
  }

  // 领取记录
  static Future<HttpJsonRes> getFlowList(String host,String token)
  {
    String url = ServiceInfo.makeUrl(host,"/flow");

    Map<String, dynamic> headers = new Map();
    headers["token"] = token;
    return HttpUtil.instance.requestJson(true, url, null,headers: headers);
  }
}
