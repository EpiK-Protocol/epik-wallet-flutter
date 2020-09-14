import 'dart:convert';

import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/logic/api/api_testnet.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/CurrencyAsset.dart';
import 'package:epikwallet/model/EthOrder.dart';
import 'package:epikwallet/model/TepkOrder.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/model/prices.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';

class EpikWalletUtils {
  /// 创建钱包 并且初始化
  static Future<bool> initWalletAccount(WalletAccount waccount) async {
    try {
      // 助记词创建HD钱包,  ETH = hdwallet.balance
      HdWallet hdwallet = await HD.newFromMnemonic(waccount.mnemonic);
      hdwallet.seed = await HD.seedFromMnemonic(waccount.mnemonic); //助记词 转种子

      // hd 设置RPC地址
      await hdwallet.setRPC(ServiceInfo.hd_RpcUrl);

      // ETH path
      String hdwallet_eth_path = await Bip44Path.getPath("ETH");
      // ETH address
      String eth_address = await hdwallet.derive(hdwallet_eth_path);

      // epik 钱包,   tEPK = epikWallet.balance
      EpikWallet epikWallet =
          await Epik.newWalletFromSeed(hdwallet.seed, t: "bls");

      // epik 设置RPC地址
      await epikWallet.setRPC(
          ServiceInfo.epik_RpcUrl, ServiceInfo.epik_RpcUrl_token);

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
    Dlog.p("requestBalance", "hd_eth_address ${waccount.hd_eth_address}");
    Dlog.p("requestBalance", "epik_tEPK_address ${waccount.epik_tEPK_address}");
    Future eth = waccount.hdwallet.balance(waccount.hd_eth_address);
    Future usdt =
        waccount.hdwallet.tokenBalance(waccount.hd_eth_address, "USDT");
    Future epk_erc20 =
        waccount.hdwallet.tokenBalance(waccount.hd_eth_address, "EPK");
    Future tepk = waccount.epikWallet.balance(waccount.epik_tEPK_address);
    Future prices = ApiTestNet.getPriceList();
    List values = await Future.wait([eth, usdt, epk_erc20, tepk, prices]);
    Map<CurrencySymbol, String> map = {
      CurrencySymbol.ETH: values[0] ?? "",
      CurrencySymbol.USDT: values[1] ?? "",
      CurrencySymbol.EPKerc20: values[2] ?? "",
      CurrencySymbol.tEPK: values[3] ?? "",
    };
    //todo test
//    Map<CurrencySymbol, String> map = {
//      CurrencySymbol.ETH: "33",//values[0] ?? "",
//      CurrencySymbol.USDT:"44",// values[1] ?? "",
//      CurrencySymbol.EPK:"22",// values[2] ?? "",
//      CurrencySymbol.tEPK:"11",// values[3] ?? "",
//    };
    Dlog.p("requestBalance", map.toString());

    List<Prices> priceslist = values[4];

    if (waccount.currencyList == null || waccount.currencyList.length == 0) {
      // 新价格
      waccount.currencyList = [];
      CurrencySymbol.values.forEach((cs) {
        Prices price = cs.getPriceUSD(priceslist);
        waccount.currencyList.add(CurrencyAsset(
          symbol: cs.symbol,
          name: "",
          type: "",
          balance: map[cs] ?? "",
          icon_url: cs.iconUrl,
          cs: cs,
          networkType: cs.networkType,
          price_usd_str: price.price,
          price_usd: price.dPrice,
          change_usd: price.dChange,
        ));
      });
    } else {
      // 更新数据
      for (int i = 0; i < waccount.currencyList.length; i++) {
        CurrencySymbol cs = CurrencySymbol.values[i];
        Prices price = cs.getPriceUSD(priceslist);
        CurrencyAsset ca = waccount.currencyList[i];
        ca.balance = map[cs] ?? "";
        ca.price_usd_str = price.price;
        ca.price_usd = price.dPrice;
        ca.change_usd = price.dChange;
      }
    }

    // 计算余额
    if (waccount.currencyList != null) {
      double total_usd = 0;
      double total_btc = 0;
      waccount.currencyList.forEach((currencyasset) {
        total_usd += currencyasset.getUsdValue();
      });
      waccount.total_usd = total_usd;

      if (priceslist != null) {
        priceslist.forEach((price) {
          if (price.id == "BTC") {
            if (price.dPrice != 0) {
              try {
                total_btc = total_usd / price.dPrice;
              } catch (e) {
                print(e);
              }
            }
          }
        });
      }
      waccount.total_btc = total_btc;
    }

    eventMgr.send(EventTag.BALANCE_UPDATE,waccount);

    return map;
  }

  static Future<List> getOrderList(
      WalletAccount waccount, CurrencySymbol cs, int page, int pagesize) async {
    try {
      if (cs == CurrencySymbol.tEPK) {
        String json = await waccount.epikWallet
            .messageList(0, waccount.epik_tEPK_address);
        print("getOrderList EPIK $json");
        List jsonarray = jsonDecode(json);
        List<TepkOrder> temp = JsonArray.parseList<TepkOrder>(
            jsonarray, (json) => TepkOrder.fromJson(json));
        if (temp != null) {
          temp.forEach((element) {
            element.checkSelf(waccount.epik_tEPK_address);
          });
        }
        return temp ?? [];
      } else {
        String address = waccount.hd_eth_address;
//        String address = "0xe9fc6bf283383c17a1377d76df3a2b0a82ad854e"; //todo test
        String json = await waccount.hdwallet
            .transactions(address, cs.symbolToNetWork, page, pagesize, false);
        print("getOrderList ETH $json");
        Map jsonmap = jsonDecode(json);
        List jsonarray = JsonArray.obj2List(jsonmap["result"], def: []);
        List<EthOrder> temp = JsonArray.parseList<EthOrder>(
            jsonarray, (json) => EthOrder.fromJson(json));
        if (temp != null) {
          temp.forEach((element) {
            element.checkSelf(address);
          });
        }
        return temp ?? [];
      }
    } catch (e) {
      print("getOrderList error");
      print(e);
    }
    return null;
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
  double total_usd = 0;
  double total_btc = 0;

  CurrencyAsset getCurrencyAssetByCs(CurrencySymbol cs)
  {
    if(currencyList!=null)
    {
      for(CurrencyAsset ca in currencyList)
      {
        if(ca!=null && ca.cs == cs)
        {
          return ca;
        }
      }
    }
    return null;
  }

}
