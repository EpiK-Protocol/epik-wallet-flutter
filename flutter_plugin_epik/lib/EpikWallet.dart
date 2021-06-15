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

  Future<String> send(String to, String amount) async {
    try {
      return await EpikPlugin.channel.invokeMethod(
          "epik_wallet_send", <String, dynamic>{"to": to, "amount": amount});
    } catch (e) {
      print(e);
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
      String ret =await EpikPlugin.channel.invokeMethod("epik_wallet_createExpert",<String,dynamic>{
        "applicationHash":applicationHash,
      });
      return ResultObj<String>(data:ret);
    } catch (e,s) {
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
      return ResultObj<String>(data:ret);
    } catch (e,s) {
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

  /// 消息回执
  Future<ResultObj<String>>  messageReceipt(String cidStr) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_messageReceipt", <String, dynamic>{
        "cidStr": cidStr,
      });
      return ResultObj<String>(data:ret);
    } catch (e,s) {
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
      return ResultObj<String>(data:ret);
    } catch (e,s) {
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
      return ResultObj<String>(data:ret);
    } catch (e,s) {
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
      return ResultObj<String>(data:ret);
    } catch (e,s) {
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
      return ResultObj<String>(data:ret);
    } catch (e,s) {
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
      return ResultObj<String>(data:ret);
    } catch (e,s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  ///矿机 基础抵押 添加
  Future<ResultObj<String>> minerPledgeAdd(String toMinerID,String amount) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_minerPledgeAdd", <String, dynamic>{
        "toMinerID": toMinerID,
        "amount":amount,
      });
      return ResultObj<String>(data:ret);
    } catch (e,s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  ///矿机 基础抵押 撤回
  Future<ResultObj<String>> minerPledgeWithdraw(String toMinerID,String amount) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_minerPledgeWithdraw", <String, dynamic>{
        "toMinerID": toMinerID,
        "amount":amount,
      });
      return ResultObj<String>(data:ret);
    } catch (e,s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  /// 矿机 访问抵押 添加
  Future<ResultObj<String>> retrievePledgeAdd(String target,String toMinerID,String amount) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_retrievePledgeAdd", <String, dynamic>{
        "toMinerID": toMinerID,
        "target":target,
        "amount":amount,
      });
      return ResultObj<String>(data:ret);
    } catch (e,s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  // 矿机 访问抵押 申请撤回  第一步     三天后解锁可以执行第二步
  Future<ResultObj<String>> retrievePledgeApplyWithdraw(String toMinerID,String amount) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_retrievePledgeApplyWithdraw", <String, dynamic>{
        "toMinerID": toMinerID,
        "amount":amount,
      });
      return ResultObj<String>(data:ret);
    } catch (e,s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  // 矿机 访问抵押 撤回 第二步
  Future<ResultObj<String>> retrievePledgeWithdraw(String toMinerID,String amount) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_retrievePledgeWithdraw", <String, dynamic>{
        "toMinerID": toMinerID,
        "amount":amount,
      });
      return ResultObj<String>(data:ret);
    } catch (e,s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  Future<ResultObj<String>> retrievePledgeBind(String toMinerID,String amount) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_retrievePledgeBind", <String, dynamic>{
        "miner": toMinerID,
        "amount":amount,
      });
      return ResultObj<String>(data:ret);
    } catch (e,s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }
  
  Future<ResultObj<String>> retrievePledgeUnBind(String toMinerID,String amount) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("epik_wallet_retrievePledgeUnBind", <String, dynamic>{
        "miner": toMinerID,
        "amount":amount,
      });
      return ResultObj<String>(data:ret);
    } catch (e,s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }
}
