import 'dart:typed_data';

import 'package:epikplugin/Amounts.dart';
import 'package:epikplugin/ResultObj.dart';
import 'package:epikplugin/UniswapInfo.dart';
import 'package:epikplugin/epikplugin.dart';

/// HD钱包静态方法
class HD {
  static HdWallet hdWallet;

  /// 用助记词创建HD钱包
  static Future<HdWallet> newFromMnemonic(String mnemonic) async {
    try {
      var ret = await EpikPlugin.channel.invokeMethod(
          "hd_hd_newFromMnemonic", <String, dynamic>{"mnemonic": mnemonic});
      hdWallet = HdWallet(mnemonic: mnemonic);
      return hdWallet;
    } catch (e) {
      print(e);
    }
    hdWallet = null;
    return hdWallet;
  }

  /// 用种子创建HD钱包
  static Future<HdWallet> newFromSeed(Uint8List seed) async {
    try {
      await EpikPlugin.channel
          .invokeMethod("hd_hd_newFromSeed", <String, dynamic>{"seed": seed});
      hdWallet = HdWallet(seed: seed);
      return hdWallet;
    } catch (e) {
      print(e);
    }
    hdWallet = null;
    return hdWallet;
  }

  /// 创建助记词 bits = 128 生成12个助记词单词
  static Future<String> newMnemonic({int bits = 128}) async {
    print("hd_wallet_newMnemonic start");
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("hd_hd_newMnemonic", <String, dynamic>{"bits": bits});
      return ret;
    } catch (e) {
      print("hd_wallet_newMnemonic error");
      print(e);
    }
    print("hd_wallet_newMnemonic null");
    return null;
  }

  /// 创建随机种子
  static Future<Uint8List> newSeed() async {
    try {
      return await EpikPlugin.channel.invokeMethod("hd_hd_newSeed");
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// 助记词生成种子
  static Future<Uint8List> seedFromMnemonic(String mnemonic) async {
    try {
      return await EpikPlugin.channel.invokeMethod(
          "hd_hd_seedFromMnemonic", <String, dynamic>{"mnemonic": mnemonic});
    } catch (e) {
      print(e);
    }
    return null;
  }
}

/// HD钱包实例, sdk中hdwallet是单例的
class HdWallet {
  String mnemonic;
  Uint8List seed;

  HdWallet({this.mnemonic, this.seed});

  @override
  int get hashCode {
    if (mnemonic != null) return mnemonic.hashCode;
    if (seed != null) return seed.hashCode;
    return super.hashCode;
  }

  Future<String> accounts() async {
    try {
      String ret = await EpikPlugin.channel.invokeMethod("hd_wallet_accounts");
      return ret;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<String> balance(String address) async {
    try {
      String ret = await EpikPlugin.channel.invokeMethod(
          "hd_wallet_balance", <String, dynamic>{"address": address});
      return ret;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<bool> contains(String address) async {
    try {
      return await EpikPlugin.channel.invokeMethod(
          "hd_wallet_contains", <String, dynamic>{"address": address});
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<String> derive(String path, {bool pin = true}) async {
    try {
      return await EpikPlugin.channel
          .invokeMethod("hd_wallet_derive", <String, dynamic>{
        "path": path,
        "pin": pin,
      });
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future setRPC(String url) async {
    try {
      return await EpikPlugin.channel
          .invokeMethod("hd_wallet_setRPC", <String, dynamic>{"url": url});
    } catch (e) {
      print(e);
    }
  }

  Future<Uint8List> signHash(String address, Uint8List hash) async {
    try {
      return await EpikPlugin.channel
          .invokeMethod("hd_wallet_signHash", <String, dynamic>{
        "address": address,
        "hash": hash,
      });
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<Uint8List> signText(String address, String text) async {
    try {
      return await EpikPlugin.channel
          .invokeMethod("hd_wallet_signText", <String, dynamic>{
        "address": address,
        "text": text,
      });
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<String> tokenBalance(String address, String currency) async {
    try {
      print("tokenBalance address=$address currency=$currency" );
      return await EpikPlugin.channel
          .invokeMethod("hd_wallet_tokenBalance", <String, dynamic>{
        "address": address,
        "currency": currency,
      });
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<String> transactions(
      String address, String currency, int page, int offset, bool asc) async {
    try {
      return await EpikPlugin.channel
          .invokeMethod("hd_wallet_transactions", <String, dynamic>{
        "address": address,
        "currency": currency,
        "page": page,
        "offset": offset,
        "asc": asc,
      });
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<ResultObj<String>> transfer(String from, String to, String amount) async {
    try {
      String ret =  await EpikPlugin.channel
          .invokeMethod("hd_wallet_transfer", <String, dynamic>{
        "from": from,
        "to": to,
        "amount": amount,
      });
      return ResultObj<String>(data:ret);
    } catch (e) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  Future<ResultObj<String>> transferToken(
      String from, String to, String currency, String amount) async {
    try {
      String ret =  await EpikPlugin.channel
          .invokeMethod("hd_wallet_transferToken", <String, dynamic>{
        "from": from,
        "to": to,
        "currency": currency,
        "amount": amount,
      });
      return ResultObj<String>(data:ret);
    } catch (e,s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  Future<UniswapInfo> uniswapinfo(String address) async {
    try {
      var ret = await EpikPlugin.channel
          .invokeMethod("hd_wallet_uniswapinfo", <String, dynamic>{
        "address": address,
      });
      if (ret != null) {
        Map<String, dynamic> json = Map<String, dynamic>.from(ret);
        if (json != null && json.length > 0) {
          return UniswapInfo.fromJson(json);
        }
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<Amounts> uniswapGetAmountsOut(
      String tokenA, String tokenB, String amountIn) async {
    try {
      var ret = await EpikPlugin.channel
          .invokeMethod("hd_wallet_uniswapgetamountsout", <String, dynamic>{
        "tokenA": tokenA,
        "tokenB": tokenB,
        "amountIn": amountIn,
      });
      if (ret != null) {
        Map<String, dynamic> json = Map<String, dynamic>.from(ret);
        if (json != null && json.length > 0) {
          Amounts amounts = Amounts.fromJson(json);
          amounts.tokenA=tokenA;
          amounts.tokenB=tokenB;
          return amounts;
        }
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// 兑换 A->B
  Future<ResultObj<String>> uniswapExactTokenForTokens(
      String address, //hd钱包地址
      String tokenA, // from 币种
      String tokenB,// to 币种
      String amountIn, //from 数量
      String amountOutMin, // to 期望兑换到的最少数量
      String deadline,// 最晚成交时间 时间戳 秒
      ) async {

    try {
      String ret = await EpikPlugin.channel.invokeMethod(
          "hd_wallet_uniswapexacttokenfortokens", <String, dynamic>{
        "address": address,
        "tokenA": tokenA,
        "tokenB": tokenB,
        "amountIn": amountIn,
        "amountOutMin": amountOutMin,
        "deadline": deadline,
      });
      return ResultObj<String>(data:ret);
    } catch (e) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
  }

  Future<ResultObj<String>>  uniswapAddLiquidity(
      String address,
      String tokenA,
      String tokenB,
      String amountADesired,
      String amountBDesired,
      String amountAMin,
      String amountBMin,
      String deadline) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("hd_wallet_uniswapaddliquidity", <String, dynamic>{
        "address": address,
        "tokenA": tokenA,
        "tokenB": tokenB,
        "amountADesired": amountADesired,
        "amountBDesired": amountBDesired,
        "amountAMin": amountAMin,
        "amountBMin": amountBMin,
        "deadline": deadline,
      });
      return ResultObj<String>(data:ret);
    } catch (e) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
  }

  Future<ResultObj<String>>  uniswapRemoveLiquidity(
      String address,
      String tokenA,
      String tokenB,
      String liquidity,
      String amountAMin,
      String amountBMin,
      String deadline) async {
    try {
      String ret = await EpikPlugin.channel
          .invokeMethod("hd_wallet_uniswapremoveliquidity", <String, dynamic>{
        "address": address,
        "tokenA": tokenA,
        "tokenB": tokenB,
        "liquidity": liquidity,
        "amountAMin": amountAMin,
        "amountBMin": amountBMin,
        "deadline": deadline,
      });
      return ResultObj<String>(data:ret);
    } catch (e) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
  }

  /// uniswap gas
  Future<String> suggestGas() async {
    try {
      return await EpikPlugin.channel.invokeMethod("hd_wallet_suggestgas");
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// uniswap gas price
  Future<String> suggestGasPrice() async {
    try {
      return await EpikPlugin.channel.invokeMethod("hd_wallet_suggestgasprice",);
    } catch (e) {
      print(e);
    }
    return null;
  }

  // 2021-03-25 新增  hd  ------------------------------

  /// AccelerateTx 加速交易
  Future<ResultObj<String>> accelerateTx(String srcTxHash, double gasRate) async {
    try {
      String ret =await EpikPlugin.channel.invokeMethod("hd_wallet_accelerateTx",<String, dynamic>{
        "srcTxHash": srcTxHash,
        "gasRate": gasRate,
      });
      return ResultObj<String>(data:ret);
    } catch (e,s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  /// CancelTx 取消交易
  Future<String> cancelTx(String srcTxHash) async {
    try {
      return await EpikPlugin.channel.invokeMethod("hd_wallet_cancelTx",<String, dynamic>{
        "srcTxHash": srcTxHash,
      });
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// receipt查询交易结果
  /// ResultObj.data
  /// success交易成功、failed交易失败、pending交易等待中
  Future<ResultObj<String>> receipt(String txHash) async {
    try {
      String ret = await EpikPlugin.channel.invokeMethod("hd_wallet_receipt",<String, dynamic>{
          "txHash": txHash,
        });
      return ResultObj<String>(data:ret);
    } catch (e,s) {
      print(e);
      return ResultObj<String>.fromError(e);
    }
    return null;
  }

  // // hd钱包导出私钥
  Future<String> export(String addr) async {
    try {
      String privateKey = await EpikPlugin.channel
          .invokeMethod("hd_wallet_export", <String, dynamic>{"addr": addr});
      return privateKey;
    } catch (e) {
      print(e);
    }
    return null;
  }


  ///设置以外网络dev环境
  static Future<void> setDebug(bool debug) async {
    try {
       String ret = await EpikPlugin.channel
          .invokeMethod("hd_setDebug", <String, dynamic>{"debug": debug});
       print("hd_setDebug $debug ret=${ret==null? "error" : "ok"}");
    } catch (e) {
      print(e);
    }
  }
}
