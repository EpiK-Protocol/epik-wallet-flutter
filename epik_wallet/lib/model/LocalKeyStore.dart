//import 'dart:convert';
//
//import 'package:bitcoin_flutter/bitcoin_flutter.dart';
//import 'package:epikwallet/logic/WalletUtils.dart';
//import 'package:bip32/bip32.dart';
//import 'package:epikwallet/utils/Dlog.dart';
//
//class LocalKeyStore {
//  String account = "";
//  String password = "";
//  HDWallet mHDWallet = null;
//
//  String user_id = "";
//  String session_id = "";
//  String pin_token = "";
//  String _publickey = "";
//  String _privatekey = "";
//
//  String get publickey
//  {
//    if(_publickey==null && mHDWallet!=null)
//      _publickey = mHDWallet.pubKey;
//    return _publickey;
//  }
//
//  String get privatekey
//  {
//    if(_privatekey==null && mHDWallet!=null)
//      _privatekey = mHDWallet.privKey;
//    return _privatekey;
//  }
//
//  LocalKeyStore();
//
//  LocalKeyStore.fromJson(Map<String, dynamic> json) {
//    try{
//      Dlog.p("KeyStore","LocalKeyStore.fromJson json=$json");
//      account = json['account'];
//      password = json['password'];
//      String bip32Base58 = json["bip32Base58"];
//      mHDWallet = WalletUtils.createFromBip32Base58(bip32Base58);
//    }catch(e){
//      print(e);
//    }
//  }
//
//  Map<String, dynamic> toJson() {
//    final Map<String, dynamic> data = new Map<String, dynamic>();
//    data['account'] = this.account;
//    data['password'] = this.password;
//    data['bip32Base58'] = mHDWallet.base58Priv;
//    return data;
//  }
//
//  String toJsonString() {
//    return jsonEncode(toJson());
//  }
//}
