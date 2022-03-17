import 'dart:convert';

import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/BountyTask.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/string_utils.dart';

class ApiBounty {

  static Future<WalletAccount> getBountyScore(String token,WalletAccount account)async
  {
    // String url = ServiceInfo.HOST + "/bounty/score";
    String url =  ServiceInfo.makeHostUrl("/bounty/score");
    Map<String, dynamic> headers = {"token": token};
    HttpJsonRes hjr = await HttpUtil.instance.requestJson(true, url, null, headers: headers);
    if(hjr!=null && hjr.code==0)
    {
//  "score":0, // 积分数
//  "swap_rate":0.1, // 兑换比例 1积分=0.1epk
//  "swap_fee": 5,// 手续费
//  "swap_min":10, // 最小兑换数 积分
      account?.bounty_score = StringUtils.parseDouble(hjr.jsonMap["score"], 0);
      account?.bounty_swap_rate = StringUtils.parseDouble(hjr.jsonMap["swap_rate"], 1);
      account?.bounty_swap_fee = StringUtils.parseDouble(hjr.jsonMap["swap_fee"], 0);
      account?.bounty_swap_min = StringUtils.parseDouble(hjr.jsonMap["swap_min"], 0);
    }
    return account;
  }

  /// 获取积分任务列表
  static Future<HttpJsonRes> getBountyTaskList(String token, int page,
      int pageSize, BountyStateType state, BountyFilterType filtertype) async {
    // Dlog.p("cccmax", "${state}  ${filtertype}");

    // String url = ServiceInfo.HOST + "/bounty/list";
    String url =  ServiceInfo.makeHostUrl("/bounty/list");

    Map<String, dynamic> params = new Map();

    //{running|finish|publicity}
    params["status"] = state?.getRequestState() ?? "";

    //community\spread\development\business
    params["type"] = filtertype?.getRequestType() ?? "";

    params["page"] = page;
    params["size"] = pageSize;
    params["offset"] = ""; // ???

    Map<String, dynamic> headers = {"token": token};

    return HttpUtil.instance.requestJson(true, url, params, headers: headers);

    // test
//    await Future.delayed(Duration(milliseconds: 500));
//    List<BountyTask> ret = [];
//    for (int i = page * pageSize; i < page * pageSize + pageSize; i++) {
//      BountyTask bt = BountyTask();
//      bt.title = "Bounty任务$i,Bounty任务$i,Bounty任务$i,Bounty任务$i";
//      bt.description = "只有两种状态，可认领和已完成。社群、推广这些类型可以动态扩增和重命名";
//      bt.content =
//          '<img src="${ImageUtils.getRandomImageUrl()}">只有两种状态，可认领和已完成。社群、推广这些类型可以动态扩增和重命名只有两种状态，\n\n<img src="${ImageUtils.getRandomImageUrl()}">\n\n可认领和已完成。社群、推广这些类型可以动态扩增和重命名只有两种状态，可认领和已完成。社群、推广这些类型可以动态扩增和重命名\n<a href="https://explorer.epik-protocol.io/">https://explorer.epik-protocol.io/</a>\n\n只有两种状态，可认领和已完成。社群、推广这些类型可以动态扩增和重命名';
//      bt.status = state ?? BountyStateType.values[i % 3];
//      bt.admin = "微信xxxxxxx";
//      bt.reward = "xxx - xxx 积分";
////      bt.cover = i % 2 == 0 ? "" : ImageUtils.getRandomImageUrl();
//      ret.add(bt);
//    }
//    return ret;
  }

  /// 管理员保存任务结果并公示
  static Future<HttpJsonRes> adminSaveTaskPublicity(
      String token, int taskId,String data) async {
    // String url = ServiceInfo.HOST + "/bounty/publicity";
    String url =  ServiceInfo.makeHostUrl("/bounty/publicity");
//
//    "id":1,
//    "result":"xxx,12\nxxx,15\nxxxx,10"
    Map<String, dynamic> params = new Map();
    params["id"] = taskId;
    params["result"] =data;
    String json = jsonEncode(params);

    Map<String, dynamic> headers = {"token": token};

    return HttpUtil.instance
        .requestJson(false, url, null, data: json, headers: headers);
  }

  /// 个人任务列表
  static Future<HttpJsonRes> getUserTaskList(
      String token, int page, int pageSize) {
    // String url = ServiceInfo.HOST + "/bounty/tasklist";
    String url =  ServiceInfo.makeHostUrl("/bounty/tasklist");
    Map<String, dynamic> params = new Map();
    params["page"] = page;
    params["size"] = pageSize;

    Map<String, dynamic> headers = {"token": token};

    return HttpUtil.instance.requestJson(true, url, params, headers: headers);
  }

  /// 个人兑换列表
  static Future<HttpJsonRes> getUserSwaplist(
      String token, int page, int pageSize) {
    // String url = ServiceInfo.HOST + "/bounty/swaplist";
    String url =  ServiceInfo.makeHostUrl("/bounty/swaplist");

    Map<String, dynamic> params = new Map();
    params["page"] = page;
    params["size"] = pageSize;

    Map<String, dynamic> headers = {"token": token};

    return HttpUtil.instance.requestJson(true, url, params, headers: headers);
  }

  ///兑换积分
  static Future<HttpJsonRes> bountySwap(String token, double amount) {
    // String url = ServiceInfo.HOST + "/bounty/swap";
    String url =  ServiceInfo.makeHostUrl("/bounty/swap");
    Map<String, dynamic> params = new Map();
    params["amount"] = amount;
    String json = jsonEncode(params);
    Map<String, dynamic> headers = {"token": token};

    return HttpUtil.instance
        .requestJson(false, url, null, data: json, headers: headers);
  }

  ///#任务详情
  static Future<HttpJsonRes> getBountyInfo(String token, int taskId) {
    // String url = ServiceInfo.HOST + "/bounty/info";
    String url =  ServiceInfo.makeHostUrl("/bounty/info");
    Map<String, dynamic> params = new Map();
    params["id"] = taskId;
    Map<String, dynamic> headers = {"token": token};
    return HttpUtil.instance.requestJson(true, url, params, headers: headers);
  }
}
