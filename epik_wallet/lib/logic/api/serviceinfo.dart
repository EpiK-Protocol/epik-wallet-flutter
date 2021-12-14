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
  static const bool TEST_DEV_NET = false;//todo

  static const String TAG = "ServiceInfo";
  static const String LOCAL_KEY = "serverconfig";

  static const String _HOST = "https://explorer.epik-protocol.io/api";
  static const String _HOST_TEST = "http://116.63.146.223:3003";

  static final String _hd_RpcUrl =
      "https://mainnet.infura.io/v3/1bbd25bd3af94ca2b294f93c346f69cd";

  static final String _hd_RpcUrl_test =
      "wss://ropsten.infura.io/ws/v3/1bbd25bd3af94ca2b294f93c346f69cd";

  static final String _epik_RpcUrl = "ws://18.181.234.52:1234/rpc/v0";

  static final String _epik_RpcUrl_token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBbGxvdyI6WyJyZWFkIiwid3JpdGUiXX0.6lL7ayYWfLqEh0BqOtCwUvLVEJ5LJ1BMb3HFRRaHsVY";

  static final String schemename = "epikwallet";

  ///epik 浏览器 查看交易详情
  static final String epik_msg_web =
      "https://explorer.epik-protocol.io/#/message/detail?cid="; //
  ///eth 浏览器 查看交易详情
  static final String ether_tx_web = "https://cn.etherscan.com/tx/";

  static String get server_wechat {
    return serverConfig?.SignWeixin ?? "Sigrid_EpiK"; //"fengyunbzb";
  }

  static String get server_telegram {
    return serverConfig?.SignTele ?? "https://t.me/EpikProtocol";
  }

  static String get HOST {
    return serverConfig?.WalletAPI ?? (TEST_DEV_NET? _HOST_TEST : _HOST  );
  }

  static String get codeHost {
    return TEST_DEV_NET? _HOST_TEST : _HOST ;
  }

  static String get hd_RpcUrl {
   // return _hd_RpcUrl;
    return serverConfig?.ETHAPI ?? _hd_RpcUrl; // 正式地址
//    return serverConfig?.ETHAPI ?? _hd_RpcUrl_test; //测试地址
  }

  static String get epik_RpcUrl {
    return serverConfig?.EPKAPI ?? _epik_RpcUrl;
  }

  static String get epik_RpcUrl_token {
    return serverConfig?.EPKToken ?? _epik_RpcUrl_token;
  }

  static ServerConfig serverConfig;
  static Upgrade upgrade;
  static Map<Locale,List<HomeMenuItem>> homeMenuMap;

  static Future<bool> loadConfig() async {
    Dlog.p(TAG, " load");
    String jsonstr = SpUtils.getString(LOCAL_KEY);
    Dlog.p(TAG, " load => ${jsonstr}");

    try {
      if (jsonstr != null && jsonstr.length > 0) {
        Map<String, dynamic> root = jsonDecode(jsonstr);
        Map<String, dynamic> json = root["config"];
        parseConfig(json);
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
      Map<String, dynamic> j_upgrade =
          Platform.isAndroid ? json["Android"] : json["IOS"];
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
      SpUtils.putString(LOCAL_KEY, jsonstr).then((res) {
        Dlog.p(TAG, "requestConfig save res => $res");
      });
      Map<String, dynamic> json = httpJsonRes.jsonMap["config"];
      parseConfig(json);
      parseMenuList(httpJsonRes.jsonMap);

      if (AccountMgr().currentAccount != null) {
        EpikWalletUtils.setWalletConfig(AccountMgr().currentAccount).then((_) {
          eventMgr.send(EventTag.UPDATE_SERVER_CONFIG, null);
        });
      }
    }
  }

  static parseMenuList(Map<String,dynamic> json)
  {
    // home_list_ch //locale_zh
    // home_list_en //locale_en
    if(json?.containsKey("home_list_ch")==true)
    {
      try{
        homeMenuMap={};
        List<HomeMenuItem> zh = JsonArray.parseList(JsonArray.obj2List(json["home_list_ch"]), (json) => HomeMenuItem.fromJson(json));
        List<HomeMenuItem> en = JsonArray.parseList(JsonArray.obj2List(json["home_list_en"]), (json) => HomeMenuItem.fromJson(json));
        homeMenuMap[LocaleConfig.locale_zh]=zh;
        homeMenuMap[LocaleConfig.locale_en]=en;
      }catch(e){
        print(e);
      }
    }
  }

  static List<HomeMenuItem> getHomeMenuList()
  {
    if(homeMenuMap!=null)
    {
      return homeMenuMap[LocaleConfig.currentAppLocale];
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
