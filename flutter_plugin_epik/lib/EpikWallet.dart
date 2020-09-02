import 'dart:typed_data';

import 'package:epikplugin/PrivateKey.dart';
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
      {String t = "bls"}) async {
    try {
      await newWallet();
      if (epikWallet != null) {
        await epikWallet.generateKey(seed, t: t);
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

  Future<PrivateKey> export(String addr) async {
    try {
      
      var map = await EpikPlugin.channel
          .invokeMethod("epik_wallet_export", <String, dynamic>{"addr": addr});

      Map<String, dynamic> reslut = new Map<String, dynamic>.from(map);

      if (reslut != null && reslut.length > 0) {
        String keyType = reslut["keyType"];
        String privateKey = reslut["privateKey"];
        PrivateKey pkey = PrivateKey(keyType, privateKey);
        return pkey;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// t: bls , secp256k1
  Future<String> generateKey(Uint8List seed, {String t = "bls"}) async {
    try {
      address = await EpikPlugin.channel.invokeMethod(
          "epik_wallet_generateKey", <String, dynamic>{"t": t, "seed": seed});
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

  Future<String> messageList(int toHeight, String addr) async {
    try {
      return await EpikPlugin.channel.invokeMethod("epik_wallet_messageList",
          <String, dynamic>{"toHeight": toHeight, "addr": addr});
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future setDefault(String addr) async {
    try {
      return await EpikPlugin.channel.invokeMethod(
          "epik_wallet_setDefault", <String, dynamic>{"addr": addr});
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future setRPC(String url, String token) async {
    try {
      return await EpikPlugin.channel.invokeMethod(
          "epik_wallet_setRPC", <String, dynamic>{"url": url, "token": token});
    } catch (e) {
      print(e);
    }
    return null;
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
}
