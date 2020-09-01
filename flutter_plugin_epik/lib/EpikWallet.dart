import 'dart:typed_data';

import 'package:epikplugin/PrivateKey.dart';
import 'package:epikplugin/epikplugin.dart';

class Epik {

  /// 在SDK中单例
  static Future<EpikWallet> newWallet() async {
    try {
      await EpikPlugin.channel.invokeMethod("epik_epik_newWallet");
      return EpikWallet();
    } catch (e) {
      print(e);
    }
    return null;
  }
}

class EpikWallet {
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
      Map<String, String> reslut = await EpikPlugin.channel
          .invokeMethod("epik_wallet_export", <String, dynamic>{"addr": addr});

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

  Future<String> generateKey(String t, Uint8List seed) async {
    try {
      return await EpikPlugin.channel.invokeMethod(
          "epik_wallet_generateKey", <String, dynamic>{"t": t, "seed": seed});
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
