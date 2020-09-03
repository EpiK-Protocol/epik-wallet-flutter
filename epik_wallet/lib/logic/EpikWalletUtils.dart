import 'dart:convert';

import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/model/CurrencyAsset.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/Dlog.dart';


class EpikWalletUtils {
  static final String hd_RpcUrl =
      "https://mainnet.infura.io/v3/1bbd25bd3af94ca2b294f93c346f69cd";

  static final String epik_RpcUrl = "http://120.55.82.202:1234/rpc/v0";

  static final String epik_RpcUrl_token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBbGxvdyI6WyJyZWFkIl19.Oivn9CdQ_kB4TriYfoo2CzWQBeCbj9FbH2hVu4ogyBI";

  /// 创建钱包 并且初始化
  static Future<bool> initWalletAccount(WalletAccount waccount) async {
    try {
      // 助记词创建HD钱包,  ETH = hdwallet.balance
      HdWallet hdwallet = await HD.newFromMnemonic(waccount.mnemonic);
      hdwallet.seed = await HD.seedFromMnemonic(waccount.mnemonic); //助记词 转种子

      // hd 设置RPC地址
      await hdwallet.setRPC(hd_RpcUrl);

      // ETH path
      String hdwallet_eth_path = await Bip44Path.getPath("ETH");
      // ETH address
      String eth_address = await hdwallet.derive(hdwallet_eth_path);

      // epik 钱包,   tEPK = epikWallet.balance
      EpikWallet epikWallet = await Epik.newWalletFromSeed(hdwallet.seed);

      // epik 设置RPC地址
      await epikWallet.setRPC(epik_RpcUrl, epik_RpcUrl_token);

      //    EPK-ERC20 = hd.tokenbalance("EPK")
      //    USDT = hd.tokenbalance("USDT")

      waccount.hd_eth_address = eth_address;
      waccount.epik_tEPK_address = epikWallet.address;
      waccount.hdwallet = hdwallet;
      waccount.epikWallet = epikWallet;
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  static Future<Map<CurrencySymbol, String>> requestBalance(
      WalletAccount waccount) async {
    Future eth = waccount.hdwallet.balance(waccount.hd_eth_address);
    Future usdt =
        waccount.hdwallet.tokenBalance(waccount.hd_eth_address, "USDT");
    Future epk_erc20 =
        waccount.hdwallet.tokenBalance(waccount.hd_eth_address, "EPK");
//    Future tepk= waccount.epikWallet.balance(waccount.epik_tEPK_address);
    List values = await Future.wait([
      eth,
      usdt,
      epk_erc20, /*tepk*/
    ]);
    Map<CurrencySymbol, String> map = {
      CurrencySymbol.ETH: values[0] ?? "",
      CurrencySymbol.USDT: values[1] ?? "",
      CurrencySymbol.EPK: values[2] ?? "",
//     CurrencySymbol.TEPK:values[4]??"0",
    };
    Dlog.p("requestBalance", map.toString());
    if (waccount.currencyList == null || waccount.currencyList.length == 0) {
      waccount.currencyList = [];
      CurrencySymbol.values.forEach((cs) {
        waccount.currencyList.add(CurrencyAsset(
          symbol: cs.symbol,
          name: "",
          type: "",
          balance: map[cs] ?? "",
          icon_url: cs.iconUrl,
          networkType: cs.networkType,
        ));
      });
    } else {
      for (int i = 0; i < waccount.currencyList.length; i++) {
        CurrencyAsset ca = waccount.currencyList[i];
        ca.balance = map[CurrencySymbol.values[i]] ?? "0";
      }
    }
    return map;
  }
}

class WalletAccount {
  // 本地商户名
  String account = "";

  // 本地密码
  String password = "";

  // hd钱包助记词
  String mnemonic = "";

  // hd钱包 eth 地址
  String hd_eth_address = "";

  // epik钱包 tEPK 地址
  String epik_tEPK_address = "";

  HdWallet hdwallet;
  EpikWallet epikWallet;

  WalletAccount();

  WalletAccount.fromJson(Map<String, dynamic> json) {
    try {
      Dlog.p("WalletAccount", "WalletAccount.fromJson json=$json");
      account = json['account'];
      password = json['password'];
      mnemonic = json['mnemonic'] ?? "";
      hd_eth_address = json['hd_eth_address'];
      epik_tEPK_address = json['epik_tEPK_address'];
    } catch (e) {
      print(e);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['account'] = this.account;
    data['password'] = this.password;
    data['mnemonic'] = this.mnemonic;
    data['hd_eth_address'] = this.hd_eth_address;
    data['epik_tEPK_address'] = this.epik_tEPK_address;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  List<CurrencyAsset> currencyList = [];
}
