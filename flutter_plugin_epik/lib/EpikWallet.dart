import 'dart:typed_data';

import 'package:epikplugin/epikplugin.dart';

class Epik {
  static EpikWallet epikWallet;

  /// 在SDK中单例
  static Future<EpikWallet> newWallet() async {
    try {
      await EpikPlugin.channel.invokeMethod("epik_epik_newWallet");
      epikWallet = EpikWallet();
      return epikWallet;
    } catch (e) {
      print(e);
    }
    epikWallet = null;
    return epikWallet;
  }

  static Future<EpikWallet> newWalletFromSeed(Uint8List seed,
      {String t = "bls", String path = "m/44'/3924011'/1'/0/0"}) async {
    try {
      await newWallet();
      if (epikWallet != null) {
        await epikWallet.generateKey(seed, path, t: t);
        if (epikWallet != null) {
          return epikWallet;
        }
      }
    } catch (e) {
      print(e);
    }
    epikWallet = null;
    return epikWallet;
  }
}

class EpikWallet {
  String address;

  Future<String> balance(String addr) async {
    try {
      return await EpikPlugin.channel
          .invokeMethod("epik_wallet_balance", <String, dynamic>{"addr": addr});
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<String> export(String addr) async {
    try {
      String privateKey = await EpikPlugin.channel
          .invokeMethod("epik_wallet_export", <String, dynamic>{"addr": addr});
      return privateKey;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// t: bls , secp256k1
  Future<String> generateKey(Uint8List seed, String path,
      {String t = "bls"}) async {
    try {
      address = await EpikPlugin.channel.invokeMethod("epik_wallet_generateKey",
          <String, dynamic>{"t": t, "seed": seed, "path": path});
      return address;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<bool> hasAddr(String addr) async {
    try {
      return await EpikPlugin.channel
          .invokeMethod("epik_wallet_hasAddr", <String, dynamic>{"addr": addr});
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<String> import(String privateKey) async {
    try {
      return await EpikPlugin.channel.invokeMethod(
          "epik_wallet_import", <String, String>{"privateKey": privateKey});
    } catch (e) {
      print(e);
    }
    return null;
  }

  @Deprecated("2021-03-25 从SDK中删除")
  Future<String> messageList(int toHeight, String addr) async {
    // try {
    //   return await EpikPlugin.channel.invokeMethod("epik_wallet_messageList",
    //       <String, dynamic>{"toHeight": toHeight, "addr": addr});
    // } catch (e) {
    //   print(e);
    // }
    return null;
  }

  Future<ResultObj<String>> send(String to, String amount) async {
    try {
      String ret = await EpikPlugin.channel.invokeMethod(
          "epik_wallet_send", <String, dynamic>{"to": to, "amount": amount});
      return ResultObj<String>(data: ret);
    } catch (e) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  Future setDefault(String addr) async {
    try {
      await EpikPlugin.channel.invokeMethod(
          "epik_wallet_setDefault", <String, dynamic>{"addr": addr});
      return;
    } catch (e) {
      print(e);
    }
    return;
  }

  Future setRPC(String url, String token) async {
    try {
      await EpikPlugin.channel.invokeMethod(
          "epik_wallet_setRPC", <String, dynamic>{"url": url, "token": token});
      return;
    } catch (e) {
      print(e);
    }
    return;
  }

  Future<Uint8List> sign(String addr, Uint8List hash) async {
    try {
      return await EpikPlugin.channel.invokeMethod(
          "epik_wallet_sign", <String, dynamic>{"addr": addr, "hash": hash});
    } catch (e) {
      print(e);
    }
    return null;
  }

  // 2021-03-25 新增  epk  ------------------------------

  /// 创建领域专家
  Future<ResultObj<String>> createExpert(String applicationHash) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_createExpert", <String, dynamic>{
        "applicationHash": applicationHash,
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  /// 专家详情
  Future<ResultObj<String>> expertInfo(String addr) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_expertInfo", <String, dynamic>{
        "addr": addr,
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  /// 专家列表
  Future<String> expertList() async {
    try {
      return await EpikPlugin.channel.invokeMethod("epik_wallet_expertList");
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// 消息回执  pending success failed  error
  Future<ResultObj<String>> messageReceipt(String cidStr) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_messageReceipt", <String, dynamic>{
        "cidStr": cidStr,
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  /// 投票撤销
  Future<ResultObj<String>> voteRescind(String candidate, String amount) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_voteRescind", <String, dynamic>{
        "candidate": candidate,
        "amount": amount,
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  // 投票
  Future<ResultObj<String>> voteSend(String candidate, String amount) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_voteSend", <String, dynamic>{
        "candidate": candidate,
        "amount": amount,
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  /// 投票提现
  Future<ResultObj<String>> voteWithdraw(String to) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_voteWithdraw", <String, dynamic>{
        "to": to,
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  /// 投票信息
  Future<ResultObj<String>> voterInfo(String addr) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_voterInfo", <String, dynamic>{
        "addr": addr,
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  // 2021-04-19 新增  epik  ------------------------------
  /// 矿机信息
  Future<ResultObj<String>> minerInfo(String minerID) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_minerInfo", <String, dynamic>{
        "minerID": minerID,
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  ///矿机 基础抵押 添加
  Future<ResultObj<String>> minerPledgeAdd(String toMinerID, String amount) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_minerPledgeAdd", <String, dynamic>{
        "toMinerID": toMinerID,
        "amount": amount,
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  ///矿机 基础抵押 撤回
  Future<ResultObj<String>> minerPledgeWithdraw(String toMinerID, String amount) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_minerPledgeWithdraw", <String, dynamic>{
        "toMinerID": toMinerID,
        "amount": amount,
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  /// 矿机 访问抵押 添加
  Future<ResultObj<String>> retrievePledgeAdd(String target, String toMinerID, String amount) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_retrievePledgeAdd", <String, dynamic>{
        "toMinerID": toMinerID,
        "target": target,
        "amount": amount,
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  // 矿机 访问抵押 申请撤回  第一步     三天后解锁可以执行第二步  第一个参数改为owner
  Future<ResultObj<String>> retrievePledgeApplyWithdraw(String owner, String amount) async {
    try {
      String ret = await EpikPlugin.channel.invokeMethod(
          "epik_wallet_retrievePledgeApplyWithdraw", <String, dynamic>{
        "target": owner,
        "amount": amount,
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  // 矿机 访问抵押 撤回 第二步
  Future<ResultObj<String>> retrievePledgeWithdraw(/*String toMinerID,*/
      String amount) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_retrievePledgeWithdraw", <String, dynamic>{
        // "toMinerID": toMinerID, //20210624删除toMinerID
        "amount": amount,
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  Future<ResultObj<String>> retrievePledgeBind(String toMinerID, String amount) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_retrievePledgeBind", <String, dynamic>{
        "miner": toMinerID,
        "amount": amount,
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  Future<ResultObj<String>> retrievePledgeUnBind(String toMinerID, String amount) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_retrievePledgeUnBind", <String, dynamic>{
        "miner": toMinerID,
        "amount": amount,
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  //case "epik_wallet_coinbaseInfo":{
//    ret = currentEpikWallet.coinbaseInfo((String) call.argument("addr"));
//    break;
//}
  Future<ResultObj<String>> coinbaseInfo(String addr) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_coinbaseInfo", <String, dynamic>{
        "addr": addr,
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

//case "epik_wallet_coinbaseWithdraw":{
//    ret = currentEpikWallet.coinbaseWithdraw();
//    break;
//}
  Future<ResultObj<String>> coinbaseWithdraw() async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_coinbaseWithdraw", <String, dynamic>{});
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  // case "epik_wallet_minerPledgeOneClick":
  // {
  // currentEpikWallet.minerPledgeOneClick((String) call.argument("minerStr"));
  // ret = "ok";
  // break;
  // }

  Future<ResultObj<String>> minerPledgeOneClick(List<String> minerIds) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_minerPledgeOneClick", <String, dynamic>{
        "minerStr": minerIds.join(","),
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  /// 查询epik手续费  actor ：transfer交易
  Future<ResultObj<String>> gasEstimateGasLimit({String actor = "transfer"}) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_gasEstimateGasLimit", <String, dynamic>{
        "actor": actor,
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  ///----- 20210705 epik 新增
  ///
  //String signAndSendMessage(String addr, String message)
  // ret = currentEpikWallet.signAndSendMessage((String) call.argument("addr"),(String) call.argument("message"));
  Future<ResultObj<String>> signAndSendMessage(String addr, String message) async {
    try {
      String ret = await EpikPlugin.channel.invokeMethod(
          "epik_wallet_signAndSendMessage",
          <String, dynamic>{"addr": addr, "message": message});
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  //byte[] signCID(String addr, String message)
  // ret = currentEpikWallet.signCID((String) call.argument("addr"),(String) call.argument("cidStr"));
  Future<ResultObj<Uint8List>> signCID(String addr, String cidStr) async {
    try {
      Uint8List ret = await EpikPlugin.channel.invokeMethod(
          "epik_wallet_signCID",
          <String, dynamic>{"addr": addr, "cidStr": cidStr});
      return ResultObj<Uint8List>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<Uint8List>.fromError(e);
    }
    return null;
  }

  ///----- 20210923 epik 新增
  // case "epik_wallet_minerPledgeApplyWithdraw":
  // {
  // // 矿机基础抵押 申请提现撤回 返回cid
  // // String minerPledgeApplyWithdraw(String minerID)
  // ret = currentEpikWallet.minerPledgeApplyWithdraw((String) call.argument("minerID"));
  // break;
  // }
  /// 矿机基础抵押 申请提现撤回 返回cid
  Future<ResultObj<String>> minerPledgeApplyWithdraw(String minerID) async {
    try {
      String ret = await EpikPlugin.channel.invokeMethod(
          "epik_wallet_minerPledgeApplyWithdraw", <String, dynamic>{
        "minerID": minerID,
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  // case "epik_wallet_minerPledgeTransfer":
  // {
  //
  // // minerPledgeTransfer(String fromMinerID, String toMinerID)
  // ret = currentEpikWallet.minerPledgeTransfer((String) call.argument("fromMinerID"),(String) call.argument("toMinerID"));
  // break;
  // }
  /// 矿机基础抵押 转移抵押 转移到其他节点 返回cid
  Future<ResultObj<String>> minerPledgeTransfer(String fromMinerID, String toMinerID, String amount) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_minerPledgeTransfer", <String, dynamic>{
        "fromMinerID": fromMinerID,
        "toMinerID": toMinerID,
        "amount": amount,
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  ///矿机抵押批量申请赎回
  Future<ResultObj<String>> minerPledgeApplyWithdrawOneClick(List<String> minerIds) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_minerPledgeApplyWithdrawOneClick", <String, dynamic>{
        "minerStr": minerIds.join(","),
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  ///矿机抵押批量赎回提现
  Future<ResultObj<String>> minerPledgeWithdrawOneClick(List<String> minerIds) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_minerPledgeWithdrawOneClick", <String, dynamic>{
        "minerStr": minerIds.join(","),
      });
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }


  /// 流量抵押状态 String retrievePledgeState(String addr) throws Exception;
  Future<ResultObj<String>> retrievePledgeState(String addr) async {
    try {
      print("retrievePledgeState start");
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_retrievePledgeState", <String, dynamic>{
        "addr": addr,
      });
      // String retstr = utf8.decode(ret);
      print("retrievePledgeState end $ret");
      return ResultObj<String>(data: ret);
    } catch (e, s) {
      print("retrievePledgeState error");
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

}

