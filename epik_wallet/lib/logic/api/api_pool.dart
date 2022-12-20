import 'dart:convert';

import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/views/nodepool/NodePoolManageView.dart';

//矿池接口 20220420
class ApiPool {

  // GET {{HOST}}/pool/whiteList
  // Content-Type: application/json
  //矿商白名单
  static Future<HttpJsonRes> whiteList() async {
    String url = ServiceInfo.makeHostUrl("/pool/whiteList") + "?timestamp=${DateUtil.getNowDateS()}";
    return await HttpUtil.instance.requestJson(true, url, null, headerSignatureUrlBody: true);
  }

  // POST {{HOST}}/pool/update
  // Content-Type: application/json
  // {
  // "FeeAddress":"",   //收益地址
  // "Name":"LONGWANG", //名称
  // "Description":"",  //描述
  // "Fee":0.3          //抽成比例 0<x<1
  // "Enable":true,     //是否开放
  // }
  // 创建矿池 更新矿池信息
  static Future<HttpJsonRes> pool_CreateOrUpdate({String FeeAddress, String Name, String Description, double Fee,bool Enable}) async {
    String url = ServiceInfo.makeHostUrl("/pool/update") + "?timestamp=${DateUtil.getNowDateS()}";
    Map<String, dynamic> params = new Map();
    params["FeeAddress"] = FeeAddress;
    params["Name"] = Name;
    params["Description"] = Description;
    params["Fee"] = Fee;
    params["Enable"] = Enable;
    String jsondata = jsonEncode(params);
    return await HttpUtil.instance.requestJson(false, url, null, data: jsondata, headerSignatureUrlBody: true);
  }

  // POST {{HOST}}/pool/addOwner
  // Content-Type: application/json
  // {
  // "OwnerID":"",
  // "Signature":""
  // }
  //添加owner
  static Future<HttpJsonRes> pool_addOwner({String OwnerID, String Signature}) async {
    //signature  =  用户在矿机里签名以下内容   epik wallet sign $OwnerID hex(wallet address)

    String url = ServiceInfo.makeHostUrl("/pool/addOwner") + "?timestamp=${DateUtil.getNowDateS()}";
    Map<String, dynamic> params = new Map();
    params["OwnerID"] = OwnerID;
    params["Signature"] = Signature;
    String jsondata = jsonEncode(params);
    return await HttpUtil.instance.requestJson(false, url, null, data: jsondata, headerSignatureUrlBody: true);
  }

  // POST {{HOST}}/pool/removeOwner
  // Content-Type: application/json
  // {
  // "OwnerID":""
  // }
  //删除owner
  static Future<HttpJsonRes> pool_removeOwner({String OwnerID}) async {
    String url = ServiceInfo.makeHostUrl("/pool/removeOwner") + "?timestamp=${DateUtil.getNowDateS()}";
    Map<String, dynamic> params = new Map();
    params["OwnerID"] = OwnerID;
    String jsondata = jsonEncode(params);
    return await HttpUtil.instance.requestJson(false, url, null, data: jsondata, headerSignatureUrlBody: true);
  }

  // GET {{HOST}}/pool/list
  // Content-Type: application/json
  // ###
  // 列表
  static Future<HttpJsonRes> list() async {
    String url = ServiceInfo.makeHostUrl("/pool/list") + "?timestamp=${DateUtil.getNowDateS()}";
    return await HttpUtil.instance.requestJson(true, url, null, headerSignatureUrlBody: true);
  }

  // POST {{HOST}}/pool/transfer
  // Content-Type: application/json
  // [
  //    {
  //      "MinerID":"",
  //      "TargetID":""
  //    },
  //    ......
  // ]
  //矿商节点转移  死节点转移到新的节点
  static Future<HttpJsonRes> pool_node_transfer(List<NodeTransferObj> data) async {
    String url = ServiceInfo.makeHostUrl("/pool/transfer") + "?timestamp=${DateUtil.getNowDateS()}";
    // Map<String, dynamic> params = new Map();
    // params["MinerID"] = MinerID;
    // params["TargetID"] = TargetID;
    // String jsondata = jsonEncode(params);
    String jsondata = jsonEncode(data);
    return await HttpUtil.instance.requestJson(false, url, null, data: jsondata, headerSignatureUrlBody: true);
  }

  // GET {{HOST}}/pool/myTransferList
  // Content-Type: application/json
  // 租节点用户 被迁移的节点列表  需要用户手动转移质押
  static Future<HttpJsonRes> myTransferList() async {
    String url = ServiceInfo.makeHostUrl("/pool/myTransferList") + "?timestamp=${DateUtil.getNowDateS()}";
    return await HttpUtil.instance.requestJson(true, url, null, headerSignatureUrlBody: true);
  }

  // POST {{HOST}}/pool/createNode
  // Content-Type: application/json
  // {
  // "PoolCreator":""
  // }
  // 用户申请新节点
  static Future<HttpJsonRes> createNode({String PoolCreator}) async {
    String url = ServiceInfo.makeHostUrl("/pool/createNode") + "?timestamp=${DateUtil.getNowDateS()}";
    Map<String, dynamic> params = new Map();
    params["PoolCreator"] = PoolCreator;
    String jsondata = jsonEncode(params);
    return await HttpUtil.instance.requestJson(false, url, null, data: jsondata, headerSignatureUrlBody: true);
  }
}
