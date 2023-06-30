//import 'dart:convert';
//import 'dart:typed_data';
//
//import 'package:bip32/bip32.dart';
//import 'package:bip39/bip39.dart' as bip39;
//import 'package:bitcoin_flutter/bitcoin_flutter.dart';
//import 'package:epikwallet/utils/Dlog.dart';
//import 'package:epikwallet/utils/string_utils.dart';
//import 'package:hex/hex.dart';
//
//class Bip32Path {
//  static final String filecoin = "m/44'/461'/0/0/0";
//}
//
//class WalletUtils {
//  /// 生成助记词
//  static Future<String> createMnemonic() async {
//    String mnemonic = bip39.generateMnemonic();
//    print("createMnemonic = $mnemonic");
//    return mnemonic;
//  }
//
//  /// 助记词生成种子
//  static Future<Uint8List> createSeedFormMnemonic(String mnemonic) async {
//    Uint8List seed = bip39.mnemonicToSeed(mnemonic);
//    return seed;
//  }
//
//  /// 生成HD钱包 ，用种子和path    path是具体某个链
//  static Future<HDWallet> createHdWallet(Uint8List seed, String path) async {
//    try {
//      HDWallet hdWallet = new HDWallet.fromSeed(seed);
//      HDWallet wallet_path = hdWallet.derivePath(path);
//      Dlog.p("WalletUtils","createHdWallet.address = ${wallet_path.address}");
//      Dlog.p("WalletUtils","createHdWallet.pubKey = ${wallet_path.pubKey}");
//      Dlog.p("WalletUtils","createHdWallet.privkey = ${wallet_path.privKey}");
//      Dlog.p("WalletUtils","createHdWallet.wif = ${wallet_path.wif}");
//      Dlog.p("WalletUtils","createHdWallet.networktype = ${wallet_path.network.toString()}");
//      return wallet_path;
//    } catch (e) {
//      print(e);
//    }
//    return null;
//  }
//
//  static Future<HDWallet> createFromMnemonic(
//      String mnemonic, String bip32path) async {
//    try {
//      // 生成种子
//      Uint8List seed = await WalletUtils.createSeedFormMnemonic(mnemonic);
//      // 种子按路径创建hd子钱包
//      HDWallet hdwallet = await WalletUtils.createHdWallet(seed, bip32path);
//      return hdwallet;
//    } catch (e) {
//      print(e);
//    }
//    return null;
//  }
//
//  static HDWallet createFromBip32Base58(String bip32base58) {
//    // 种子按路径创建hd子钱包
//    HDWallet hdwallet = HDWallet.fromBase58(bip32base58);
//    return hdwallet;
//  }
//
//  /// 私钥导入钱包 但是缺少chainCode， 不能再创建hd的子钱包
//  static Future<HDWallet> ImportFromPrivKey(String privKey) async {
//    try {
//      final network = bitcoin;
//      Uint8List chainCode = utf8.encode("00000000000000000000000000000000");
//      BIP32 bip32 = BIP32.fromPrivateKey(HEX.decode(privKey), chainCode);
//      P2PKH p2pkh = new P2PKH(
//          data: new PaymentData(pubkey: bip32.publicKey), network: network);
//
//      HDWallet wallet_path =
//          HDWallet(bip32: bip32, p2pkh: p2pkh, network: network, seed: null);
//      Dlog.p("WalletUtils","import.address = ${wallet_path.address}");
//      Dlog.p("WalletUtils","import.pubKey = ${wallet_path.pubKey}");
//      Dlog.p("WalletUtils","import.privkey = ${wallet_path.privKey}");
//      Dlog.p("WalletUtils","import.wif = ${wallet_path.wif}");
//      Dlog.p("WalletUtils","import.networktype = ${wallet_path.network.toString()}");
//
//      if (StringUtils.isNotEmpty(wallet_path.privKey) &&
//          StringUtils.isNotEmpty(wallet_path.pubKey)) {
//        return wallet_path;
//      }
//    } catch (e) {
//      print(e);
//    }
//    return null;
//  }
//}
