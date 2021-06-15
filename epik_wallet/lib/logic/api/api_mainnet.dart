import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/string_utils.dart';

class ApiMainNet {
  //  #EPIK测试网登录
//  POST {{HOST}}/testnet/login
//  Content-Type: application/json
//  {
//  "timestamp":123,
//  "address":"",
//  "signature":""
//  }
  static Future<HttpJsonRes> login(WalletAccount account) async {
    // epik_address
    // erc20_address
    // epik_signature
    // erc20_signature

    int timestamp =
        (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).toInt();
    //epik_address
    String epik_address = account.epik_EPK_address;
    //erc20_address
    String erc20_address = account.hd_eth_address;
    //epik_signature
    Digest digest = sha256.convert(utf8.encode("$timestamp"));
    Uint8List epik_signature_byte = await account.epikWallet
        .sign(epik_address, Uint8List.fromList(digest.bytes));
    String epik_signature = hex.encode(epik_signature_byte);
    //erc20_signature
    Uint8List erc20_signature_byte = await account.hdwallet
        .signHash(erc20_address, Uint8List.fromList(digest.bytes));
//          .signText(erc20_address, weixin);
    String erc20_signature = hex.encode(erc20_signature_byte);

    // String url = ServiceInfo.HOST + "/mainnet/login";
    String url =  ServiceInfo.makeHostUrl("/mainnet/login");
    Map<String, dynamic> params = new Map();
    params["timestamp"] = timestamp;
    params["epik_address"] = epik_address;
    params["erc20_address"] = erc20_address;
    params["epik_signature"] = epik_signature;
    params["erc20_signature"] = erc20_signature;
    String json = jsonEncode(params);
    Dlog.p("login", json);
    return HttpUtil.instance.requestJson(false, url, null, data: json);
  }

  static Future<HttpJsonRes> expertBaseInfomation() {
    String url = ServiceInfo.makeHostUrl("/baseInfomation");
    // String url = "http://116.63.146.223:3002/baseInfomation";// test
    Map<String, dynamic> params = new Map();
    return HttpUtil.instance.requestJson(true, url, params);
  }

//  #投票收益
//  GET {{HOST}}/mainnet/voterPorfit
//  Content-Type: application/json
//  ###
  static Future<HttpJsonRes> voterPorfit() {
    // String url = ServiceInfo.HOST + "/mainnet/voterPorfit";
    String url =  ServiceInfo.makeHostUrl("/mainnet/voterPorfit");
    Map<String, dynamic> params = new Map();
    return HttpUtil.instance.requestJson(true, url, params, needToken: true);
  }

//  #领域专家列表
//  GET {{HOST}}/mainnet/experts
//  Content-Type: application/json
//  ###
  static Future<HttpJsonRes> experts(int page, int size) {
    // String url = ServiceInfo.HOST + "/mainnet/experts";
    String url =  ServiceInfo.makeHostUrl("/mainnet/experts");
    Map<String, dynamic> params = new Map();
    params["page"] = size * page;
    params["pageSize"] = size;
    // String url = "http://47.92.64.50:3002/experts";
    // Map<String, dynamic> params = new Map();
    // params["offset"]=size*page;
    // params["offset"]=size;
    return HttpUtil.instance.requestJson(true, url, params,);
  }

//  #领域专家资料
//  GET {{HOST}}/mainnet/expertProfile
//  Content-Type: application/json
//  ###
  static Future<HttpJsonRes> expertProfile(
      {String hash, String expert_id, String owner}) {
    // String url = ServiceInfo.HOST + "/mainnet/expertProfile";
    String url =  ServiceInfo.makeHostUrl("/mainnet/expertProfile");
    Map<String, dynamic> params = new Map();
    if (StringUtils.isNotEmpty(hash)) {
      params["hash"] = hash; //资料地址
    } else if (StringUtils.isNotEmpty(owner)) {
      params["owner"] = owner; //epik地址
    } else if (StringUtils.isNotEmpty(expert_id)) {
      params["expert_id"] = expert_id; //专家ID
    }
    return HttpUtil.instance.requestJson(true, url, params,);
  }

  ///获取epik地址关联的矿机
  static Future<HttpJsonRes> getMiners(String epikAddress)
  {
    String url =  ServiceInfo.makeHostUrl("/mainnet/controlMiners");
    Map<String, dynamic> params = new Map();
    params["address"] = epikAddress;
    return HttpUtil.instance.requestJson(true, url, params);
  }

//  #领域专家资料注册
//  POST {{HOST}}/mainnet/registerExpert
//  Content-Type: application/json
//  {
//  "name":"",
//  "mobile":"",
//  "email":"",
//  "domain":"",
//  "introduction":"",
//  "license":""
//  }
//  ###
  static Future<HttpJsonRes> registerExpert({
    String name,
    String mobile,
    String email,
    String domain,
    String introduction,
    String license,
    String owner,
  }) {
    // String url = ServiceInfo.HOST + "/mainnet/registerExpert";
    String url =  ServiceInfo.makeHostUrl("/mainnet/registerExpert");
    Map<String, dynamic> params = {
      "name": name,
      "mobile": mobile,
      "email": email,
      "domain": domain,
      "introduction": introduction,
      "license": license,
      "owner": owner,
    };
    return HttpUtil.instance
        .requestJson(false, url, null, data: params,);
  }
}
