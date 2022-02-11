import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:convert/convert.dart';
import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
import 'package:epikplugin/Bip44Path.dart';
import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/abi/ERC20.g.dart';
import 'package:epikwallet/logic/UniswapHistoryMgr.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_mainnet.dart';
import 'package:epikwallet/logic/api/api_wallet.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/model/CoinbaseInfo.dart';
import 'package:epikwallet/model/CurrencyAsset.dart';
import 'package:epikwallet/model/EpkOrder.dart';
import 'package:epikwallet/model/EthOrder.dart';
import 'package:epikwallet/model/MinerCoinbaseList.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/model/prices.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/sp_utils/sp_utils.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/src/crypto/secp256k1.dart' as secp256k1;
import 'package:web3dart/web3dart.dart';

class EpikWalletUtils {
  static final String TAG = "EpikWalletUtils";

  static Web3Client ethClient;
  static Web3Client bscClient;
  static BigInt eth_chainid;
  static BigInt bsc_chainid;

  /// 创建钱包 并且初始化
  static Future<bool> initWalletAccount(WalletAccount waccount) async {
    try {
      // 助记词创建HD钱包,
      // HdWallet hdwallet = await HD.newFromMnemonic(waccount.mnemonic);
      // hdwallet.seed = await HD.seedFromMnemonic(waccount.mnemonic); //助记词 转种子
      // // ETH path
      // String hdwallet_eth_path = await Bip44Path.getPath("ETH");
      // // ETH address
      // String eth_address = await hdwallet.derive(hdwallet_eth_path);
      // waccount.hd_eth_address = eth_address;
      // waccount.epik_EPK_address = epikWallet.address;
      // waccount.hdwallet = hdwallet;

      //新的钱包客户端 dart库
      if (ethClient == null) {
        ethClient = new Web3Client(ServiceInfo.hd_ETH_RpcUrl, Client());
        ethClient.getChainId().then((value) {
          eth_chainid = value;
        });
      }
      if (bscClient == null) {
        bscClient = new Web3Client(ServiceInfo.hd_BSC_RpcUrl, Client());
        bscClient.getChainId().then((value) {
          bsc_chainid = value;
        });
      }

      //-----------------新构造方法

      //助记词转种子
      waccount.mnemonic = waccount.mnemonic.replaceAll(RegExp(r"\s+"), " ");
      String seed = bip39.mnemonicToSeedHex(waccount.mnemonic);
      // Uint8List seedbytes= await HD.seedFromMnemonic(waccount.mnemonic); //助记词 转种子
      // String seed = hex.encode(seedbytes);

      //种子转私钥
      Chain chain = Chain.seed(seed);
      String path_eth = Bip44Path.getPath("ETH"); // "m/44'/60'/0'/0/0";
      ExtendedPrivateKey key = chain.forPath(path_eth);
      String pk = key.privateKeyHex();
      //私钥创建钱包授权
      waccount.credentials = EthPrivateKey.fromHex(pk);
      waccount.ethereumAddress = await waccount.credentials.extractAddress();
      //添加代币
      waccount.hdTokenMap[CurrencySymbol.EPKbsc] =
          ERC20(address: EthereumAddress.fromHex(ServiceInfo.TOKEN_ADDRESS_BSC_EPK), client: bscClient);
      waccount.hdTokenMap[CurrencySymbol.EPKerc20] =
          ERC20(address: EthereumAddress.fromHex(ServiceInfo.TOKEN_ADDRESS_ETH_EPK), client: ethClient);
      waccount.hdTokenMap[CurrencySymbol.USDT] =
          ERC20(address: EthereumAddress.fromHex(ServiceInfo.TOKEN_ADDRESS_ETH_USDT), client: ethClient);
      waccount.hdTokenMap[CurrencySymbol.USDTbsc] =
          ERC20(address: EthereumAddress.fromHex(ServiceInfo.TOKEN_ADDRESS_BSC_USDT), client: bscClient);

      // print("sdk  seed =" + hex.encode(hdwallet.seed));
      // print("web3 seed =" + seed);

      // epik 钱包,   EPK = epikWallet.balance
      // EpikWallet epikWallet = await Epik.newWalletFromSeed(hdwallet.seed, t: "bls");
      EpikWallet epikWallet = await Epik.newWalletFromSeed(hex.decode(seed), t: "bls");
      waccount.epikWallet = epikWallet;

      // if(StringUtils.isEmpty(waccount.epik_EPK_address))
      waccount.epik_EPK_address = waccount?.epikWallet?.address;
      // if(StringUtils.isEmpty(waccount.hd_eth_address))
      waccount.hd_eth_address = waccount.ethereumAddress.toString();

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
    // hd 设置RPC地址 todo del
    // await waccount.hdwallet.setRPC(ServiceInfo.hd_RpcUrl);
    // epik 设置RPC地址
    await waccount.epikWallet.setRPC(ServiceInfo.epik_RpcUrl, ServiceInfo.epik_RpcUrl_token);
  }

  static Future<Map<CurrencySymbol, String>> requestBalance(WalletAccount waccount) async {
    Dlog.p("requestBalance", "hd_eth_address ${waccount.hd_eth_address}");
    Dlog.p("requestBalance", "epik_EPK_address ${waccount.epik_EPK_address}");

    Future prices = ApiWallet.getPriceList();

    //EPIK net
    Future epk = waccount.epikWallet.balance(waccount.epik_EPK_address);

    //ETH net
    // Future eth = waccount.hdwallet.balance(waccount.hd_eth_address);
    
    Future eth = ethClient.getBalance(waccount.ethereumAddress).then((balance)
    // Future eth = ethClient.getBalance(EthereumAddress.fromHex("0xea7521a859e2c2b3dcac8764f46d37e4f7a1e962")).then((balance)
    {
      Dlog.p("EWU", "eth balance=${balance}");
      return balance.getValueInUnit(EtherUnit.ether).toString();
    });

    // Future usdt = waccount.hdwallet.tokenBalance(waccount.hd_eth_address, "USDT");
    Future usdt = waccount.hdTokenMap[CurrencySymbol.USDT].balanceOf(waccount.ethereumAddress).then((bint) async {
      Dlog.p("EWU", "usdt bint=${bint}");
      // EtherAmount balance = EtherAmount.fromUnitAndValue(EtherUnit.wei, bint);
      // return balance.getValueInUnit(EtherUnit.mwei).toString(); //usdt Decimals = 6

      EtherAmount balance = EtherAmount.fromUnitAndValue(EtherUnit.wei, bint);
      BigInt decimals = await waccount.hdTokenMap[CurrencySymbol.USDT].decimals(); //获取token的精度
      EtherUnit eu = EtherAmountEx.getEtherUnitByDecimals(decimals);
      return balance.getValueInUnit(eu).toString();
    });

    // Future epk_erc20 = waccount.hdwallet.tokenBalance(waccount.hd_eth_address, "EPK");
    Future epk_erc20 =
        waccount.hdTokenMap[CurrencySymbol.EPKerc20].balanceOf(waccount.ethereumAddress).then((bint) async {
      Dlog.p("EWU", "epk_erc20 bint=${bint}");
      // EtherAmount balance = EtherAmount.fromUnitAndValue(EtherUnit.wei, bint);
      // return balance.getValueInUnit(EtherUnit.ether).toString();

      EtherAmount balance = EtherAmount.fromUnitAndValue(EtherUnit.wei, bint);
      BigInt decimals = await waccount.hdTokenMap[CurrencySymbol.EPKerc20].decimals(); //获取token的精度
      EtherUnit eu = EtherAmountEx.getEtherUnitByDecimals(decimals);
      return balance.getValueInUnit(eu).toString();
    });

    //BSC net
    Future bsc_bnb = bscClient.getBalance(waccount.ethereumAddress).then((balance) {
      return balance.getValueInUnit(EtherUnit.ether).toString();
    });

    Future bsc_epk = waccount.hdTokenMap[CurrencySymbol.EPKbsc].balanceOf(waccount.ethereumAddress).then((bint) async {
      // EtherAmount balance = EtherAmount.fromUnitAndValue(EtherUnit.wei, bint);
      // return balance.getValueInUnit(EtherUnit.ether).toString();

      EtherAmount balance = EtherAmount.fromUnitAndValue(EtherUnit.wei, bint);
      BigInt decimals = await waccount.hdTokenMap[CurrencySymbol.EPKbsc].decimals(); //获取token的精度
      EtherUnit eu = EtherAmountEx.getEtherUnitByDecimals(decimals);
      return balance.getValueInUnit(eu).toString();
    });

    Future bsc_usdt =
        waccount.hdTokenMap[CurrencySymbol.USDTbsc].balanceOf(waccount.ethereumAddress).then((bint) async {
      Dlog.p("EWU", "bscusdt bint=${bint}");
      EtherAmount balance = EtherAmount.fromUnitAndValue(EtherUnit.wei, bint);
      BigInt decimals = await waccount.hdTokenMap[CurrencySymbol.USDTbsc].decimals(); //获取token的精度
      EtherUnit eu = EtherAmountEx.getEtherUnitByDecimals(decimals);
      return balance.getValueInUnit(eu).toString();
    });

    List values = await Future.wait([eth, usdt, epk_erc20, epk, bsc_bnb, bsc_epk, bsc_usdt, prices]);
    Map<CurrencySymbol, String> map = {
      CurrencySymbol.ETH: values[0] ?? "",
      CurrencySymbol.USDT: values[1] ?? "",
      CurrencySymbol.EPKerc20: values[2] ?? "",
      CurrencySymbol.EPK: values[3] ?? "",
      CurrencySymbol.BNB: values[4] ?? "",
      CurrencySymbol.EPKbsc: values[5] ?? "",
      CurrencySymbol.USDTbsc: values[6] ?? "",
    };
    //todo test
//    Map<CurrencySymbol, String> map = {
//      CurrencySymbol.ETH: "33",//values[0] ?? "",
//      CurrencySymbol.USDT:"44",// values[1] ?? "",
//      CurrencySymbol.EPK:"22",// values[2] ?? "",
//      CurrencySymbol.tEPK:"11",// values[3] ?? "",
//    };
    Dlog.p("requestBalance", map.toString());

    List<Prices> priceslist = values.last;

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
        Dlog.p("EWU", "cs = $cs price=${price.dPrice}");
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

  static Future<Map<String, dynamic>> getOrderList(WalletAccount waccount, CurrencySymbol cs, int page, int pagesize,
      {String lastTime, int epkHeight}) async {
    Map<String, dynamic> ret = {
      "list": null,
      "epkHeight": 0,
    };
    try {
      if (cs == CurrencySymbol.EPK) {
        // 从api接口读取 使用 lasttime
        List<EpkOrder> temp;
        HttpJsonRes hjr = await ApiWallet.getEpkOrderList(waccount.epik_EPK_address, lastTime, pagesize, epkHeight);
        if (hjr.code == 0) {
          temp = JsonArray.parseList<EpkOrder>(
              JsonArray.obj2List(hjr.jsonMap["list"]), (json) => EpkOrder.fromJsonTepk(json));
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
      } else if (cs.networkType == CurrencySymbol.ETH) {
        page += 1; //0是全部数据  1是开始分页
        String address = waccount.hd_eth_address;
        // String address = "0xea7521a859e2c2b3dcac8764f46d37e4f7a1e962";
        // String json = await waccount.hdwallet.transactions(address, cs.symbolToNetWork, page, pagesize, false);
        // print("getOrderList ETH $json");
        // Map jsonmap = jsonDecode(json);
        Map jsonmap = await ApiWallet.getEthOrderList(
            cs.tokenContractaddress, address, cs.symbolToNetWork, page, pagesize, false);
        List jsonarray = JsonArray.obj2List(jsonmap["result"], def: []);
        List<EthOrder> temp = JsonArray.parseList<EthOrder>(jsonarray, (json) => EthOrder.fromJson(json));
        if (temp != null) {
          temp.forEach((element) {
            element.checkSelf(address);
          });
        }
        // print("getOrderList ETH tempsize=${temp.length}");
        ret["list"] = temp ?? [];
        return ret;
      } else if (cs.networkType == CurrencySymbol.BNB) {
        page += 1; //0是全部数据  1是开始分页
        String address = waccount.hd_eth_address;
        Map jsonmap = await ApiWallet.getBscOrderList(
            cs.tokenContractaddress, address, cs.symbolToNetWork, page, pagesize, false);
        List jsonarray = JsonArray.obj2List(jsonmap["result"], def: []);
        List<EthOrder> temp = JsonArray.parseList<EthOrder>(jsonarray, (json) => EthOrder.fromJson(json));
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
      Dlog.p("EWU", "getOrderList error");
      print(e);
    }
    return ret;
  }

  // hd钱包转账 主网币或token
  static Future<ResultObj<String>> hdTransfer(
      WalletAccount walletaccount, CurrencySymbol cs, String to_address, String amount_d) async {
    ResultObj<String> result = null;
    if (cs.isToken) {
      //代币
      // result = await widget.walletaccount.hdwallet.transferToken(from_address,
      //     to_address, widget.currencyAsset.cs.symbolToNetWork, amount);

      result = ResultObj();
      try {
        ERC20 erc20 = walletaccount.hdTokenMap[cs];
        BigInt decimals = await erc20.decimals(); //获取token的精度

        // BigInt value = BigInt.from((amount_d * pow(10, decimals.toInt())).toDouble());
        BigInt value = StringUtils.numUpsizingBigint(amount_d, bit: decimals.toInt());
        Dlog.p("hdTransfer", "value = $value");
        String tx =
            await erc20.transfer(EthereumAddress.fromHex(to_address), value, credentials: walletaccount.credentials);
        result.code = 0;
        result.data = tx;
      } catch (e) {
        print(e);
        result = ResultObj.fromError(e);
      }
    } else {
      //主网币
      // result = await widget.walletaccount.hdwallet.transfer(from_address, to_address, amount);

      Web3Client web3client = null;
      if (cs.networkType == CurrencySymbol.ETH) {
        web3client = EpikWalletUtils.ethClient;
      } else if (cs.networkType == CurrencySymbol.BNB) {
        web3client = EpikWalletUtils.bscClient;
      }

      result = ResultObj();

      try {
        if (web3client != null) {
          // EtherAmount value = EtherAmount.fromUnitAndValue(EtherUnit.wei, BigInt.from((amount_d * pow(10, 18)).toDouble()));
          BigInt bi_value = StringUtils.numUpsizingBigint(amount_d, bit: 18);
          EtherAmount value = EtherAmount.fromUnitAndValue(EtherUnit.wei, bi_value);
          Dlog.p("hdTransfer", "EtherAmount =${EtherAmount}  getValueInUnit=${value.getValueInUnit(EtherUnit.ether)}");

          Transaction transaction = Transaction(
            from: walletaccount.ethereumAddress,
            to: EthereumAddress.fromHex(to_address),
            maxGas: null,
            gasPrice: null,
            value: value,
            data: null,
            nonce: null,
          );

          BigInt chainid = await web3client.getChainId();
          // dlog("chainid=$chainid");
          String tx =
              await web3client.sendTransaction(walletaccount.credentials, transaction, chainId: chainid.toInt());

          result.code = 0;
          result.data = tx;
        } else {
          result.code = -2;
          result.errorMsg = "Not Found Web3Client";
        }
      } catch (e) {
        print(e);
        result = ResultObj.fromError(e);
      }
    }
    return result;
  }

  // hd钱包交易加速
  static Future<ResultObj<String>> hdAccelerateTx(CurrencySymbol cs, String tx, double gasrate) async {
    Web3Client web3client;
    if (cs.networkType == CurrencySymbol.ETH) {
      web3client = EpikWalletUtils.ethClient;
    } else if (cs.networkType == CurrencySymbol.BNB) {
      web3client = EpikWalletUtils.bscClient;
    }

    if (web3client == null) {
      return ResultObj<String>()
        ..code = -2
        ..errorMsg = "Not Found Web3Client";
    }

    ResultObj<String> resultObj = ResultObj();
    try {
      TransactionInformation tinfo = await EpikWalletUtils.ethClient.getTransactionByHash(tx);
      Dlog.p("hdAccelerateTx", "hash=" + tinfo?.hash);
      Dlog.p("hdAccelerateTx", "from=" + tinfo?.from.hex);
      Dlog.p("hdAccelerateTx", "to=" + tinfo?.to.hex);
      Dlog.p("hdAccelerateTx", "gas=" + tinfo?.gas.toString());
      Dlog.p("hdAccelerateTx", "gasPrice=" + tinfo?.gasPrice.toString());
      Dlog.p("hdAccelerateTx", "value=" + tinfo?.value.toString());
      Dlog.p("hdAccelerateTx", "input=" + tinfo?.input.toString());
      Dlog.p("hdAccelerateTx", "nonce=" + tinfo?.nonce.toString());

      EtherAmount gasPrice = EtherAmount.inWei(BigInt.from((tinfo.gasPrice.getInWei.toInt() * gasrate).toDouble()));
      Dlog.p("hdAccelerateTx", "new gasPrice=" + gasPrice.toString());

      Transaction transaction = Transaction(
        from: tinfo.from,
        to: tinfo.to,
        value: tinfo.value,
        nonce: tinfo.nonce,
        data: tinfo.input,
        gasPrice: gasPrice,
      );
      String txhash = await web3client.sendTransaction(AccountMgr().currentAccount.credentials, transaction,
          chainId: null, fetchChainIdFromNetworkId: true);

      resultObj.code = 0;
      resultObj.data = txhash;
    } catch (e) {
      print(e);
      resultObj = ResultObj.fromError(e);
    }
    return resultObj;
  }

  //hash :  Digest digest = sha256.convert(text);
  static Future<Uint8List> hdWalletSignHash(EthPrivateKey credentials, Uint8List hash) async {
    try {
      MsgSignature signature = secp256k1.sign(hash, credentials.privateKey);
      int sig_v = signature.v - 27;
      String a = signature.r.toRadixString(16).padLeft(64, '0');
      String b = signature.s.toRadixString(16).padLeft(64, '0'); //.padLeft(2, '0');
      String c = sig_v.toRadixString(16).padLeft(2, '0');
      // String signstr = signature.r.toRadixString(16).padLeft(64, '0') +
      //     signature.s.toRadixString(16).padLeft(2, '0') +
      //     sig_v.toRadixString(16).padLeft(2, '0');
      String signstr = a + b + c;
      // Dlog.p("EWU",a);
      // Dlog.p("EWU",b);
      // Dlog.p("EWU",c);
      // Dlog.p("EWU",signstr);
      return hex.decode(signstr);

      // print(hex.decode(signstr));
      // Uint8List r = padUint8ListTo32(unsignedIntToBytes(signature.r));
      // Uint8List s = padUint8ListTo32(unsignedIntToBytes(signature.s));
      // Uint8List v = unsignedIntToBytes(BigInt.from(sig_v));
      // Uint8List ret = uint8ListFromList(r + s + v);
      // print("\n\n");
      // print(ret);
      // print(hex.encode(ret));
    } catch (e, s) {
      print(e);
      print(s);
    }
  }

  static String strip0x(String hexstr) {
    if (hexstr?.startsWith('0x')) return hexstr.substring(2);
    return hexstr;
  }

  static Uint8List hexStringToBytes(String hexstr) {
    try {
      hexstr = strip0x(hexstr);
      List<int> bytes = hex.decode(hexstr);
      return Uint8List.fromList(bytes);
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Map<CurrencySymbol, HdGas> hdgasMap = {};

  static Future<HdGas> getHdTransferGas(CurrencySymbol cs,
      {String value = "0.00001", String toAddress = "0x000000000000000000000000000000000000dead"}) async {
    if (cs == CurrencySymbol.EPK) return null;

    ERC20 erc20 = AccountMgr().currentAccount.hdTokenMap[cs];

    Web3Client web3client;
    if (cs.networkType == CurrencySymbol.ETH) {
      web3client = EpikWalletUtils.ethClient;
    } else if (cs.networkType == CurrencySymbol.BNB) {
      web3client = EpikWalletUtils.bscClient;
    }

    EthereumAddress to = EthereumAddress.fromHex(toAddress);

    BigInt decimals;

    BigInt bi_value;

    EtherAmount gp = await web3client.getGasPrice();
    // print("GasPrice=$gp");

    BigInt maxgas;

    try {
      if (cs.isToken != true) {
        //主网币

        decimals = BigInt.from(18); //获取token的精度
        bi_value = StringUtils.numUpsizingBigint(value, bit: decimals.toInt());

        maxgas = await web3client.estimateGas(
          sender: AccountMgr().currentAccount.ethereumAddress,
          to: to,
          value: EtherAmount.inWei(bi_value),
        );
      } else {
        decimals = await erc20?.decimals();//获取token的精度
        bi_value = StringUtils.numUpsizingBigint(value, bit: decimals.toInt());

        // a9059cbb
        final function = erc20?.self?.abi?.functions[10]; //ERC20
        final params = [to, bi_value];
        Transaction transaction =
            Transaction.callContract(contract: erc20?.self, function: function, parameters: params);

        Dlog.p("getHdTransferGas"," transaction.data=0x${hex.encode(transaction.data)}");

        maxgas = await web3client.estimateGas(
          sender: AccountMgr().currentAccount.ethereumAddress,
          to: transaction.to,
          value: transaction.value,
          data: transaction?.data,
        );
      }
    } catch (e, s) {
      print(e);
      print(s);
    }

    double dcg = (gp?.getValueInUnit(EtherUnit.ether) ?? 0) * (maxgas?.toInt() ?? 0);
    String currencygas = StringUtils.formatNumAmount(dcg, point: 8, supply0: false);

    HdGas hdgas = HdGas()
      ..cs = cs
      ..decimals = decimals
      ..maxgas = maxgas
      ..gasPrice = gp
      ..gas = currencygas
      ..gas_d = dcg;

    if (maxgas == null) {
      hdgas.gas = null;
      hdgas.gas_d = null;
    }

    print(
        "HdGas cs=${hdgas.cs} decimals=${hdgas.decimals}  maxgas=${hdgas.maxgas}  gasPrice=${hdgas.gasPrice}  gas=${hdgas.gas}  gas_d=${hdgas.gas_d}");

    hdgasMap[cs] = hdgas;

    eventMgr.send(EventTag.UPLOAD_SUGGESTGAS, hdgas);

    return hdgas;
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

  // HdWallet hdwallet;
  EpikWallet epikWallet;

  //web3钱包私钥
  EthPrivateKey credentials;
  EthereumAddress ethereumAddress;
  Map<String, dynamic> tokenMap = {};

  // String eth_suggestGas = "0";
  // double eth_suggestGas_d = 0;
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

  Map<CurrencySymbol, ERC20> hdTokenMap = {};

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
    ret = ret.toSet().toList(); // 去重
    return ret;
  }

  CoinbaseInfo coinbaseinfo;

  Future<void> getCoinbaseInfo() async {
    String address = AccountMgr().currentAccount.epik_EPK_address;
    // address = "f0100"; //todo test
    ResultObj<String> robj_ci = await AccountMgr().currentAccount.epikWallet.coinbaseInfo(address);
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

  // Future<String> uploadSuggestGas() async {
  //   // EtherAmount ea = await EpikWalletUtils.ethClient.getGasPrice();
  //
  //   // String gas = await hdwallet?.suggestGas();
  //   String gas = "0"; //TODO 需要获取eth转账gas费用 需要加入bsc的gas
  //   if (gas != null) {
  //     eth_suggestGas = gas;
  //     eth_suggestGas_d = StringUtils.parseDouble(eth_suggestGas, 0);
  //     Dlog.p("uploadSuggestGas", "$gas");
  //   }
  //   eventMgr.send(EventTag.UPLOAD_SUGGESTGAS, eth_suggestGas);
  //   return gas;
  // }

  // Future<UniswapInfo> uploadUniswapInfo() async {
  //   UniswapInfo _uniswapinfo = await hdwallet?.uniswapinfo(hd_eth_address);
  //   uniswapinfo = _uniswapinfo;
  //   eventMgr.send(EventTag.UPLOAD_UNISWAPINFO, uniswapinfo);
  //   Dlog.p("uploadUniswapInfo",
  //       " epk=${uniswapinfo?.EPK}  usdt=${uniswapinfo?.USDT}  share=${uniswapinfo?.Share}  uni=${uniswapinfo.UNI}");
  //   return uniswapinfo;
  // }

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
          String a = StringUtils.getRollupSize((epik_gas_transfer * pow(10, 18)).toInt(),
              radix: 1000, extraUp: 100, units: StringUtils.RollupSize_Units3);
          epik_gas_transfer_format = a;
        }
        Dlog.p("epikgas", epik_gas_transfer_format);
      }
    }
    eventMgr.send(EventTag.UPLOAD_EPIK_GAS_TRANSFER, epik_gas_transfer);
    return epik_gas_transfer;
  }
}

extension EtherAmountEx on EtherAmount {
  static EtherUnit getEtherUnitByDecimals(BigInt decimals) {
    //   EtherUnit.wei: BigInt.one,
    // EtherUnit.kwei: BigInt.from(10).pow(3),
    // EtherUnit.mwei: BigInt.from(10).pow(6),
    // EtherUnit.gwei: BigInt.from(10).pow(9),
    // EtherUnit.szabo: BigInt.from(10).pow(12),
    // EtherUnit.finney: BigInt.from(10).pow(15),
    // EtherUnit.ether: BigInt.from(10).pow(18)
    switch (decimals.toInt()) {
      case 0:
        return EtherUnit.wei;
      case 3:
        return EtherUnit.kwei;
      case 6:
        return EtherUnit.mwei;
      case 9:
        return EtherUnit.gwei;
      case 12:
        return EtherUnit.szabo;
      case 15:
        return EtherUnit.finney;
      case 18:
        return EtherUnit.ether;
    }
  }
}

class HdGas {
  CurrencySymbol cs;

  BigInt maxgas;
  EtherAmount gasPrice;
  BigInt decimals; //货币精度 主网币是18位

  String gas;
  double gas_d;
}
