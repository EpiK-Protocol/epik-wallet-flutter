import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_dapp.dart';
import 'package:epikwallet/logic/model_cache_mgr.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/utils/toast/toast.dart';

class Dapp {
  String id;

  String name;

  //图标
  String icon;

  //api host
  String api_host;

  //下载地址网页
  // String app_url;

  //本地额外扩展的数据
  DappInfo dappInfo;

  Dapp();

  Dapp.fromJson(Map<String, dynamic> json) {
    parseJson(json);
  }

  parseJson(Map<String, dynamic> json) {
    try {
      id = json["id"];
      name = json["name"];
      icon = json["icon"];
      api_host = json["api_host"];
    } catch (e, s) {
      print(s);
    }
  }

  static Dapp createInCache(Map<String, dynamic> json) {
    String _id = StringUtils.parseString(json["id"], "");
    Dapp _dapp = modelCacheMgr.find(Dapp, _id);
    if (_dapp == null) _dapp = Dapp();
    _dapp.parseJson(json);
    modelCacheMgr.add(_id, _dapp);
    return _dapp;
  }

  String dappToken = null;

  String getDappToken() {
    if (dappToken == null) {
      dappToken = AccountMgr()?.currentAccount?.tokenMap[id] ?? "";
    }
    return dappToken;
  }

  bool hasDappToken() {
    return StringUtils.isNotEmpty(getDappToken());
  }

  setDappToken(String token) {
    dappToken = token;
    AccountMgr()?.currentAccount?.tokenMap[id] = dappToken;
    AccountMgr()?.currentAccount.saveDappTokens();
  }

  Future<int> loadDappinfo()async{
    // 需要加载info
    HttpJsonRes hjr = await ApiDapp.info(api_host, id, getDappToken());
    print(hjr.jsonMap);
    if (hjr?.code == 0) {
      DappInfo info = DappInfo.fromJson(hjr.jsonMap["info"]);
      dappInfo = info;
      return 0;
    } else if (hjr?.code == 401) {
      //鉴权失败
      setDappToken("");
      return 401;
    } else {
      //请求失败
      return hjr?.code ?? -1;
    }
  }
}


class DappInfo
{
  String id;//"id":"3703742f-e3d0-4be2-82e7-305a5738ca4c",
  String account;//"account":"+8618801146606",
  String name;//"name":"",
  String epk;//"epk":"5.5"
  String fee;
  String min;

  double epk_d=0;
  double fee_d=0;
  double min_d=0;

  DappInfo();

  DappInfo.fromJson(Map<String,dynamic> json)
  {
    try {
      id=json["id"];
      account=json["account"];
      name=json["name"];
      epk=json["epk"]??"0";
      fee=json["fee"]??"0";
      min=json["min"]??"0";

      epk_d = StringUtils.parseDouble(epk, 0);
      fee_d = StringUtils.parseDouble(fee, 0);
      min_d = StringUtils.parseDouble(min, 0);

    } catch (e, s) {
      print(s);
    }
  }
}