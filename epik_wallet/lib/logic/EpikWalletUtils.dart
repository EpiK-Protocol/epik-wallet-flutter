import 'dart:convert';
import 'dart:math';

import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/logic/UniswapHistoryMgr.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_mainnet.dart';
import 'package:epikwallet/logic/api/api_wallet.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/model/CoinbaseInfo.dart';
import 'package:epikwallet/model/CurrencyAsset.dart';
import 'package:epikwallet/model/EthOrder.dart';
import 'package:epikwallet/model/MinerCoinbaseList.dart';
import 'package:epikwallet/model/TepkOrder.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/model/prices.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/sp_utils/sp_utils.dart';
import 'package:epikwallet/utils/string_utils.dart';

class EpikWalletUtils {
  static final String TAG = "EpikWalletUtils";

  /// 创建钱包 并且初始化
  static Future<bool> initWalletAccount(WalletAccount waccount) async {
    try {
      // 助记词创建HD钱包,  ETH = hdwallet.balance
      HdWallet hdwallet = await HD.newFromMnemonic(waccount.mnemonic);
      hdwallet.seed = await HD.seedFromMnemonic(waccount.mnemonic); //助记词 转种子

      // ETH path
      String hdwallet_eth_path = await Bip44Path.getPath("ETH");
      // ETH address
      String eth_address = await hdwallet.derive(hdwallet_eth_path);

      // epik 钱包,   EPK = epikWallet.balance
      EpikWallet epikWallet =
          await Epik.newWalletFromSeed(hdwallet.seed, t: "bls");

      //    EPK-ERC20 = hd.tokenbalance("EPK")
      //    USDT = hd.tokenbalance("USDT")
      waccount.hd_eth_address = eth_address;
      waccount.epik_EPK_address = epikWallet.address;
      waccount.hdwallet = hdwallet;
      waccount.epikWallet = epikWallet;

      await setWalletConfig(waccount);

      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  static Future setWalletConfig(WalletAccount waccount) async {
    Dlog.p(TAG,
        "setWalletConfig ${waccount.account} hd_RpcUrl=${ServiceInfo.hd_RpcUrl} epik_RpcUrl=${ServiceInfo.epik_RpcUrl} epik_RpcUrl_token${ServiceInfo.epik_RpcUrl_token}");
    // hd 设置RPC地址
    await waccount.hdwallet.setRPC(ServiceInfo.hd_RpcUrl);
    // epik 设置RPC地址
    await waccount.epikWallet
        .setRPC(ServiceInfo.epik_RpcUrl, ServiceInfo.epik_RpcUrl_token);
  }

  static Future<Map<CurrencySymbol, String>> requestBalance(
      WalletAccount waccount) async {
    Dlog.p("requestBalance", "hd_eth_address ${waccount.hd_eth_address}");
    Dlog.p("requestBalance", "epik_EPK_address ${waccount.epik_EPK_address}");
    Future eth = waccount.hdwallet.balance(waccount.hd_eth_address);
    Future usdt =
        waccount.hdwallet.tokenBalance(waccount.hd_eth_address, "USDT");
    Future epk_erc20 =
        waccount.hdwallet.tokenBalance(waccount.hd_eth_address, "EPK");
    Future epk = waccount.epikWallet.balance(waccount.epik_EPK_address);
    Future prices = ApiWallet.getPriceList();
    List values = await Future.wait([eth, usdt, epk_erc20, epk, prices]);
    Map<CurrencySymbol, String> map = {
      CurrencySymbol.ETH: values[0] ?? "",
      CurrencySymbol.USDT: values[1] ?? "",
      CurrencySymbol.EPKerc20: values[2] ?? "",
      CurrencySymbol.EPK: values[3] ?? "",
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
        print("cs = $cs price=${price.dPrice}");
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

    eventMgr.send(EventTag.BALANCE_UPDATE, waccount);

    return map;
  }

  static Future<Map<String, dynamic>> getOrderList(
      WalletAccount waccount, CurrencySymbol cs, int page, int pagesize,
      {String lastTime, int epkHeight}) async {
    Map<String, dynamic> ret = {
      "list": null,
      "epkHeight": 0,
    };
    try {
      if (cs == CurrencySymbol.EPK) {
        // 从SDK读取
        // String json = await waccount.epikWallet
        //     .messageList(0, waccount.epik_tEPK_address);
        // print("getOrderList EPIK $json");
        // List jsonarray = jsonDecode(json);
        // List<TepkOrder> temp = JsonArray.parseList<TepkOrder>(
        //     jsonarray, (json) => TepkOrder.fromJson(json));
        // if (temp != null) {
        //   temp.forEach((element) {
        //     element.checkSelf(waccount.epik_tEPK_address);
        //   });
        // }
        // 从api接口读取 使用 lasttime
        List<TepkOrder> temp;
        HttpJsonRes hjr = await ApiWallet.getTepkOrderList(
            waccount.epik_EPK_address, lastTime, pagesize, epkHeight);
        if (hjr.code == 0) {
          temp = JsonArray.parseList<TepkOrder>(
              JsonArray.obj2List(hjr.jsonMap["list"]),
              (json) => TepkOrder.fromJsonTepk(json));
        }
        if (temp != null) {
          temp.forEach((element) {
            element.checkSelf(waccount.epik_EPK_address);
          });
        }
        // print("getTepkOrderList tempsize=${temp.length}");
        ret["list"] = temp ?? [];
        ret["epkHeight"] = hjr.jsonMap["endHeight"] ?? 0;
        return ret;
      } else {
        page += 1; //0是全部数据  1是开始分页
        String address = waccount.hd_eth_address;
//        String address = "0xe9fc6bf283383c17a1377d76df3a2b0a82ad854e"; //todo test
//         print("getOrderList ETH page=$page pagesize=$pagesize");
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
        // print("getOrderList ETH tempsize=${temp.length}");
        ret["list"] = temp ?? [];
        return ret;
      }
    } catch (e) {
      print("getOrderList error");
      print(e);
    }
    return ret;
  }
}

class BingAccountPlatform {
  static final String WEIXIN = "weixin";
  static final String TELEGRAM = "telegram";
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

  // epik钱包 EPK 地址
  String epik_EPK_address = "";

  HdWallet hdwallet;
  EpikWallet epikWallet;

  String eth_suggestGas = "0";
  double eth_suggestGas_d=0;
  double epik_gas_transfer = 0;
  //如果是很小的小数 会变成 0.29n 这样  后面需要拼接EPK显示
  String epik_gas_transfer_format = "";

  UniswapInfo uniswapinfo;

  UniswapHistoryMgr uhMgr;

  // 赏金任务的积分
  double bounty_score = 0;

  // 赏金任务的兑换比例
  double bounty_swap_rate = 1;

  // 赏金任务的兑换手续费 ERC20-EPK
  double bounty_swap_fee = 0;

  // 赏金任务最小兑换数量
  double bounty_swap_min = 1;

  // 挖矿的已报名才有的ID
  String mining_id = "";

  // 挖矿的已报名用户绑定的微信\telegram
  String mining_bind_account = "";
  String mining_account_platform = "";

  Map<String, dynamic> tokenMap = {};

  String get dappTokenKey {
    return epik_EPK_address?.hashCode?.toString() ?? "";
  }

  loadDappTokens() {
    Map<String, dynamic> temp = {};
    try {
      String text = SpUtils.getString("DappTokens_${dappTokenKey}");
      if (StringUtils.isNotEmpty(text) && text.startsWith("{")) {
        try {
          temp = jsonDecode(text);
        } catch (e, s) {
          print(e);
        }
      }
    } catch (e, s) {
      print(e);
    }
    tokenMap = temp ?? {};
  }

  saveDappTokens() {
    SpUtils.putString("DappTokens_${dappTokenKey}", jsonEncode(tokenMap ?? {}));
  }

  String minerCurrent = null;
  List<String> minerIdList = [];

  String get minerIdListKey {
    return epik_EPK_address?.hashCode?.toString() ?? "";
  }

  loadMinerIdList() {
    Map<String, dynamic> temp = {};
    try {
      String text = SpUtils.getString("MinerIds_${minerIdListKey}");
      Dlog.p("minerview", text ?? "");
      if (StringUtils.isNotEmpty(text) && text.startsWith("{")) {
        try {
          temp = jsonDecode(text);
        } catch (e, s) {
          print(e);
        }
      }
    } catch (e, s) {
      print(e);
    }
    temp = temp ?? {};
    minerIdList = List<String>.from(temp["list"] ?? []);
    minerCurrent = temp["current"];
    Dlog.p("minerview", "aa minerCurrent=$minerCurrent");
    if (StringUtils.isEmpty(minerCurrent)) minerCurrent = getFirstMinerId();
    Dlog.p("minerview", "bb minerCurrent=$minerCurrent");
    if (StringUtils.isEmpty(minerCurrent)) {
      if (minerCoinbaseList?.hasCoinbased == true) {
        minerCurrent = minerCoinbaseList.coinbased[0];
        Dlog.p("minerview", "cc minerCurrent=$minerCurrent");
      } else if (minerCoinbaseList?.haspledged == true) {
        minerCurrent = minerCoinbaseList.pledged[0];
        Dlog.p("minerview", "dd minerCurrent=$minerCurrent");
      }
    }
  }

  saveMinerIdList() {
    if (minerCurrent == null) minerCurrent = getFirstMinerId();
    SpUtils.putString(
        "MinerIds_${minerIdListKey}",
        jsonEncode(<String, dynamic>{
          "list": minerIdList ?? [],
          "current": minerCurrent,
        }));
  }

  String getFirstMinerId() {
    if (minerIdList != null && minerIdList.length > 0) return minerIdList[0];
    return null;
  }

  //在线保存的minerid
  MinerCoinbaseList minerCoinbaseList;

  Future<void> getMinerListOnline() async {
    String address = AccountMgr().currentAccount.epik_EPK_address;
    HttpJsonRes hjr = await ApiMainNet.getMiners(address);
    if (hjr.code == 0) {
      minerCoinbaseList = MinerCoinbaseList.from(hjr.jsonMap);
    }
  }

  //在线获取的 和本地的 全部 minerid 并且去重
  List<String> getAllMinerList() {
    List<String> ret = [];
    if (minerCoinbaseList?.coinbased != null) {
      ret.addAll(minerCoinbaseList?.coinbased);
    }
    if (minerCoinbaseList?.pledged != null) {
      ret.addAll(minerCoinbaseList?.pledged);
    }
    if (minerIdList != null) {
      ret.addAll(minerIdList);
    }
    print("minerview aaa");
    ret = ret.toSet().toList(); // 去重
    print("minerview bbb");
    return ret;
  }

  CoinbaseInfo coinbaseinfo;

  Future<void> getCoinbaseInfo() async {
    String address = AccountMgr().currentAccount.epik_EPK_address;
    // address = "f0100"; //todo test
    ResultObj<String> robj_ci =
        await AccountMgr().currentAccount.epikWallet.coinbaseInfo(address);
    Dlog.p("epikwalletutils", "coinbaseinfo=${robj_ci.data}");
    if (robj_ci?.isSuccess) {
      coinbaseinfo = CoinbaseInfo.fromJson(jsonDecode(robj_ci.data));
    }
    eventMgr.send(EventTag.COINBASEINFO_UPDATE);
  }

  WalletAccount();

  WalletAccount.fromJson(Map<String, dynamic> json) {
    try {
      Dlog.p("WalletAccount", "WalletAccount.fromJson json=$json");
      account = json['account'];
      password = json['password'];
      mnemonic = json['mnemonic'] ?? "";
      hd_eth_address = json['hd_eth_address'];
      epik_EPK_address = json['epik_tEPK_address'];
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
    data['epik_tEPK_address'] = this.epik_EPK_address;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  List<CurrencyAsset> currencyList = [];
  double total_usd = 0;
  double total_btc = 0;

  CurrencyAsset getCurrencyAssetByCs(CurrencySymbol cs) {
    if (currencyList != null) {
      for (CurrencyAsset ca in currencyList) {
        if (ca != null && ca.cs == cs) {
          return ca;
        }
      }
    }
    return null;
  }

  Future<String> uploadSuggestGas() async {
    String gas = await hdwallet?.suggestGas();
    if (gas != null) {
      eth_suggestGas = gas;
      eth_suggestGas_d = StringUtils.parseDouble(eth_suggestGas, 0);
      Dlog.p("uploadSuggestGas", "$gas");
    }
    eventMgr.send(EventTag.UPLOAD_SUGGESTGAS, eth_suggestGas);
    return gas;
  }

  Future<UniswapInfo> uploadUniswapInfo() async {
    UniswapInfo _uniswapinfo = await hdwallet?.uniswapinfo(hd_eth_address);
    uniswapinfo = _uniswapinfo;
    eventMgr.send(EventTag.UPLOAD_UNISWAPINFO, uniswapinfo);
    Dlog.p("uploadUniswapInfo",
        " epk=${uniswapinfo?.EPK}  usdt=${uniswapinfo?.USDT}  share=${uniswapinfo?.Share}  uni=${uniswapinfo.UNI}");
    return uniswapinfo;
  }

  Future<double> uploadEpikGasTransfer() async {
    ResultObj<String> robj = await epikWallet?.gasEstimateGasLimit();
    if (robj?.isSuccess == true) {
      String gas = robj.data;
      if (gas != null) {
        gas = StringUtils.bigNumDownsizing(gas ?? "0");
        epik_gas_transfer = StringUtils.parseDouble(gas, 0);

        // epik_gas_transfer_format

        if (epik_gas_transfer > 0.001) {
          epik_gas_transfer_format = StringUtils.formatNumAmountLocaleUnit(
              StringUtils.parseDouble(epik_gas_transfer, 0), appContext,
              needZhUnit: false);
        } else {
          String a = StringUtils.getRollupSize(
              (epik_gas_transfer * pow(10, 18)).toInt(),
              radix: 1000,
              extraUp: 100,
              units: StringUtils.RollupSize_Units3);
          epik_gas_transfer_format = a;
        }
        Dlog.p("epikgas", epik_gas_transfer_format);
      }
    }
    eventMgr.send(EventTag.UPLOAD_EPIK_GAS_TRANSFER, epik_gas_transfer);
    return epik_gas_transfer;
  }
}
