import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:epikwallet/localstring/LocaleConfig.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_server_config.dart';
import 'package:epikwallet/model/HomeMenuItem.dart';
import 'package:epikwallet/model/ServerConfig.dart';
import 'package:epikwallet/model/Upgrade.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/sp_utils/sp_utils.dart';
import 'package:epikwallet/utils/string_utils.dart';

class ServiceInfo {
  static const bool TEST_DEV_NET = false; //todo

  static const String TAG = "ServiceInfo";
  static const String LOCAL_KEY = "serverconfig";

  static const String _HOST = "https://explorer.epik-protocol.io/api";
  static const String _HOST_TEST = "http://116.63.146.223:3003";

  static final String _hd_RpcUrl = "https://mainnet.infura.io/v3/1bbd25bd3af94ca2b294f93c346f69cd";
  static final String _hd_RpcUrl_test = "wss://ropsten.infura.io/ws/v3/1bbd25bd3af94ca2b294f93c346f69cd";

  static final String _epik_RpcUrl = "ws://18.181.234.52:1234/rpc/v0";

  static final String _epik_RpcUrl_token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBbGxvdyI6WyJyZWFkIiwid3JpdGUiXX0.6lL7ayYWfLqEh0BqOtCwUvLVEJ5LJ1BMb3HFRRaHsVY";

  static final String schemename = "epikwallet";

  ///epik 浏览器 查看交易详情
  static final String epik_msg_web = "https://explorer.epik-protocol.io/#/message/detail?cid="; //
  ///eth 浏览器 查看交易详情
  static final String _ether_tx_web = "https://cn.etherscan.com/tx/";
  static final String _ether_tx_web_test = "https://ropsten.etherscan.io/tx/";

  static String get ether_tx_web => TEST_DEV_NET ? _ether_tx_web_test : _ether_tx_web;

  //HD ETH
  static final String _hd_ETH_RpcUrl = "https://mainnet.infura.io/v3/1bbd25bd3af94ca2b294f93c346f69cd";
  static final String _hd_ETH_RpcUrl_test = "https://ropsten.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161";

  //HD BSC
  static final String _hd_BSC_RpcUrl = "https://bsc-dataseed1.binance.org/";
  static final String _hd_BSC_RpcUrl_test = "https://data-seed-prebsc-1-s1.binance.org:8545/";
  static final String _bsc_tx_web = "https://bscscan.com/tx/";
  static final String _bsc_tx_web_test = "https://testnet.bscscan.com/tx/";

  static String get bsc_tx_web => TEST_DEV_NET ? _bsc_tx_web_test : _bsc_tx_web;

  //epk 在eth上的合约地址   //测试用ropsten
  static final String TOKEN_ADDRESS_ETH_EPK =
      TEST_DEV_NET ? "0x6936bae5b97c6eba746932e9cfa33931963cd333" : "0xac5B038058bcD0424C9c252c6487C25F032E5dDc";
  // static final String TOKEN_ADDRESS_ETH_EPK = TEST_DEV_NET ? "0x6936bae5b97c6eba746932e9cfa33931963cd333" : "0xdaf88906ac1de12ba2b1d2f7bfc94e9638ac40c4";

  //usdt 在eth上的合约地址  //测试用ropsten
  static final String TOKEN_ADDRESS_ETH_USDT =
      TEST_DEV_NET ? "0x110a13fc3efe6a245b50102d2d79b3e76125ae83" : "0xdac17f958d2ee523a2206206994597c13d831ec7";

  //epk 在bsc上的合约地址
  static final String TOKEN_ADDRESS_BSC_EPK =
      TEST_DEV_NET ? "0xD5ff1A29De6Ac0CA40Da97398C482C4Ac2c00Eba" : "0x87ecea8512516ced5db9375c63c23a0846c73a57";

  static final String TOKEN_ADDRESS_BSC_USDT =
      TEST_DEV_NET ? "0x38179046038147d9B2f70A8E27Ec771a0F38884A" : "0x55d398326f99059fF775485246999027B3197955";

  static String get server_wechat {
    return serverConfig?.SignWeixin ?? "Sigrid_EpiK"; //"fengyunbzb";
  }

  static String get server_telegram {
    return serverConfig?.SignTele ?? "https://t.me/EpikProtocol";
  }

  static String get HOST {
    return serverConfig?.WalletAPI ?? (TEST_DEV_NET ? _HOST_TEST : _HOST);
  }

  static String get codeHost {
    return TEST_DEV_NET ? _HOST_TEST : _HOST;
  }

  // static String get hd_RpcUrl {
  //   return serverConfig?.ETHAPI ?? (TEST_DEV_NET ? _hd_RpcUrl_test : _hd_RpcUrl); // 从服务器获取
  // }

  static String get hd_ETH_RpcUrl {
    return TEST_DEV_NET ? _hd_ETH_RpcUrl_test : (serverConfig?.ETHAPI ?? _hd_ETH_RpcUrl);
  }

  static String get hd_BSC_RpcUrl {
    return TEST_DEV_NET ? _hd_BSC_RpcUrl_test : (serverConfig?.BSCAPI ?? _hd_BSC_RpcUrl);
  }

  static String get epik_RpcUrl {
    return serverConfig?.EPKAPI ?? _epik_RpcUrl;
  }

  static String get epik_RpcUrl_token {
    return serverConfig?.EPKToken ?? _epik_RpcUrl_token;
  }

  //领域专家后台
  static final String EPIKG_DOMAIN_BACKEND_URL = "https://epikg.com/domainBackend/";

  static bool hideBSC = true;

  static ServerConfig serverConfig;
  static Upgrade upgrade;
  static Map<Locale, List<HomeMenuItem>> homeMenuMap;

  static Future<bool> loadConfig() async {
    Dlog.p(TAG, " load");
    String jsonstr = SpUtils.getString(LOCAL_KEY);
    Dlog.p(TAG, " load => ${jsonstr}");

    try {
      if (jsonstr != null && jsonstr.length > 0) {
        Map<String, dynamic> root = jsonDecode(jsonstr);
        Map<String, dynamic> json = root["config"];
        parseConfig(json);
        print("parseMenuList local");
        parseMenuList(root);
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  /// json解析成对象
  static parseConfig(Map<String, dynamic> json) {
    if (json != null && json.length > 0) {
      Map<String, dynamic> j_upgrade = Platform.isAndroid ? json["Android"] : json["IOS"];
      if (j_upgrade != null && j_upgrade.length > 0) {
        Dlog.p("Upgrade", "parseConfig +");
        upgrade = Upgrade.fromJson(j_upgrade);
      }

      serverConfig = ServerConfig.fromJson(json);
    }
  }

  static Future requestConfig() async {
    Dlog.p(TAG, " requestConfig ");
    HttpJsonRes httpJsonRes = await ApiServerConfig.getWalletConfig();
    if (httpJsonRes != null && httpJsonRes.code == 0) {
      String jsonstr = jsonEncode(httpJsonRes.jsonMap);
      Dlog.p(TAG, "requestConfig save $jsonstr");
      bool save_res = await SpUtils.putString(LOCAL_KEY, jsonstr);
      Dlog.p(TAG, "requestConfig save res => $save_res");
      Dlog.p(TAG, "test 1");
      Map<String, dynamic> json = httpJsonRes.jsonMap["config"];
      parseConfig(json);
      print("parseMenuList request");
      parseMenuList(httpJsonRes.jsonMap);

      Dlog.p(TAG, "test 2");
      if (AccountMgr().currentAccount != null) {
        Dlog.p(TAG, "test 3");
        EpikWalletUtils.setWalletConfig(AccountMgr().currentAccount).then((_) {
          Dlog.p(TAG, "test 4");
          eventMgr.send(EventTag.UPDATE_SERVER_CONFIG, null);
        });
      }
      Dlog.p(TAG, "test 5");
    }
  }

  static parseMenuList(Map<String, dynamic> json) {
    // home_list_ch //locale_zh
    // home_list_en //locale_en
    if (json?.containsKey("home_list_ch") == true) {
      try {
        homeMenuMap = {};
        List<HomeMenuItem> zh =
            JsonArray.parseList(JsonArray.obj2List(json["home_list_ch"]), (json) => HomeMenuItem.fromJson(json));
        List<HomeMenuItem> en =
            JsonArray.parseList(JsonArray.obj2List(json["home_list_en"]), (json) => HomeMenuItem.fromJson(json));
        homeMenuMap[LocaleConfig.locale_zh] = zh;
        homeMenuMap[LocaleConfig.locale_en] = en;

        print("parseMenuList $zh  ${json["home_list_ch"]}");

        //todo
        // HomeMenuItem test = HomeMenuItem.fromJson({
        //   "Name":"Human",
        //   // "Action":"http://192.168.31.178:4002/",
        //   // "Action":"https://play.cryptomines.app/",
        //   // "Action":"https://epik-protocol.io/farm",
        //   "Action":"https://play.human.game/",
        //   // "Action":"https://web3modal.com/",
        //   // "Action":"https://pancakeswap.finance/swap?inputCurrency=0x55d398326f99059ff775485246999027b3197955&outputCurrency=0x87ecea8512516ced5db9375c63c23a0846c73a57",
        //   "Web3net":"BSC",
        //   "Icon":"https://play.human.game/static/img/logo.9f68d85a.png",
        // });
        // zh.add(test);
        // en.add(test);

        // zh.add( HomeMenuItem.fromJson({
        //   "Name":"更多",
        //   "Action":"more",
        // }));
        // en.add( HomeMenuItem.fromJson({
        //   "Name":"More",
        //   "Action":"more",
        // }));
      } catch (e) {
        print(e);
      }
    }
  }

  static List<HomeMenuItem> getHomeMenuList() {
    if (homeMenuMap != null) {
      List<HomeMenuItem> data = homeMenuMap[LocaleConfig.currentAppLocale];
      if (ServiceInfo.hideBSC) {
        List<HomeMenuItem> ret = [];
        data.forEach((element) {
          if (element.Web3net != "BSC") ret.add(element);
        });
      }
      return data;
    }
    return null;
  }

  // 拼接http url
  static String makeHostUrl(String url) {
    return makeUrl(HOST.trim(), url);
  }

  static String makeUrl(String host, String url) {
    if (StringUtils.isEmpty(url)) return host;
    if (url.startsWith("http")) return url;

    if (host.endsWith("/")) host = host.substring(0, host.length - 1);

    if (url.startsWith("/"))
      return host + url;
    else
      return host + "/" + url;
  }
}
