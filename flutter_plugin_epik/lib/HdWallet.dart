import 'dart:typed_data';

import 'package:epikplugin/epikplugin.dart';

/// HD钱包静态方法
class HD {
  static HdWallet hdWallet;

  /// 用助记词创建HD钱包
  static Future<HdWallet> newFromMnemonic(String mnemonic) async {
    try {
      await EpikPlugin.channel.invokeMethod(
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
    try {
      return await EpikPlugin.channel
          .invokeMethod("hd_hd_newMnemonic", <String, dynamic>{"bits": bits});
    } catch (e) {
      print(e);
    }
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

/// HD钱包实例,, sdk中hdwallet是单例的
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

  Future<String> balance(String address) async {
    try {
      return await EpikPlugin.channel.invokeMethod(
          "hd_wallet_balance", <String, dynamic>{"address": address});
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

  Future<String> derive(String path, bool pin) async {
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

  Future<String> tokenBalance(String address, String p1) async {
    try {
      return await EpikPlugin.channel
          .invokeMethod("hd_wallet_tokenBalance", <String, dynamic>{
        "address": address,
        "text": p1,
      });
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<String> transactions(
      String address, String p1, int page, int offset, bool asc) async {
    try {
      return await EpikPlugin.channel
          .invokeMethod("hd_wallet_tokenBalance", <String, dynamic>{
        "address": address,
        "text": p1,
        "page": page,
        "offset": offset,
        "asc": asc,
      });
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<String> transfer(String from, String to, String amount) async {
    try {
      return await EpikPlugin.channel
          .invokeMethod("hd_wallet_transfer", <String, dynamic>{
        "from": from,
        "to": to,
        "amount": amount,
      });
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<String> transferToken(
      String from, String to, String p2, String amount) async {
    try {
      return await EpikPlugin.channel
          .invokeMethod("hd_wallet_transferToken", <String, dynamic>{
        "from": from,
        "to": to,
        "p2": p2,
        "amount": amount,
      });
    } catch (e) {
      print(e);
    }
    return null;
  }
}
