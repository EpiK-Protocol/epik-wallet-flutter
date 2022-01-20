import 'dart:convert';

import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/sp_utils/sp_utils.dart';
import 'package:epikwallet/utils/string_utils.dart';

var localwebsitemgr = new LocalWebsiteMgr();

class LocalWebsiteMgr {
  static const String TAG = "LocalWebsiteMgr";
  static LocalWebsiteMgr _LocalWebsiteMgr = LocalWebsiteMgr._internal();

  final String _KEY_ADDRESS_LIST = "local_website_list";

  factory LocalWebsiteMgr() {
    return _LocalWebsiteMgr;
  }

  LocalWebsiteMgr._internal() {
    // 单例初始化
    Dlog.p(TAG, "初始化");
  }

  List<LocalWebsiteObj> _data = [];

  List<LocalWebsiteObj> get data => _data;

  Future load() async {
    Dlog.p(TAG, " load");
    String jsonstr = SpUtils.getString(_KEY_ADDRESS_LIST);
    Dlog.p(TAG, " load => ${jsonstr}");

    List<LocalWebsiteObj> temp = [];
    if (jsonstr != null && jsonstr.length > 0) {
      try {
        List jarray = jsonDecode(jsonstr);
        temp = JsonArray.parseList(jarray, (j) => LocalWebsiteObj.fromJson(j));
      } catch (e, s) {
        print(e);
        print(s);
      }
    }

    _data = temp ?? [];

    Dlog.p(TAG, " load _data = ${_data}");
  }

  Future save() async {
    Dlog.p(TAG, " save");
    try {
      String save = "";
      if (_data != null && _data.length > 0) {
        save = jsonEncode(_data);
      } else {
        save = "[]";
      }
      Dlog.p(TAG, " save json => " + save);
      SpUtils.putString(_KEY_ADDRESS_LIST, save).then((res) {
        Dlog.p(TAG, " save res => $res");
      });
    } catch (e) {
      print(e);
    }
  }

  Future add(LocalWebsiteObj lwo, {bool toFirst = false}) {
    if (_data == null) {
      _data = [];
    }
    if (toFirst) {
      _data.insert(0, lwo);
    } else {
      _data.add(lwo);
    }
  }

  Future delete(LocalWebsiteObj lwo) {
    if (_data != null && _data.length > 0) {
      _data.remove(lwo);
    }
  }

  Future deleteAll(List<LocalWebsiteObj> data) {
    if (_data != null && _data.length > 0) {
      _data.removeWhere((element) {
        for (LocalWebsiteObj lwo in data) {
          if (element == lwo) return true;
        }
        return false;
      });
    }
  }

  LocalWebsiteObj findByUrl(String url)
  {
    LocalWebsiteObj ret = null;
    if (_data != null) {
      Uri u0=Uri.tryParse(url?.toLowerCase());
      if(u0.path=="/" || u0.path=="/#" || u0.path=="/#/")
        u0=u0.replace(path: "");
      for (LocalWebsiteObj lwo in _data) {
        Uri u1= Uri.tryParse(lwo.url?.toLowerCase());
        if(u1.path=="/" || u1.path=="/#" || u1.path=="/#/")
          u1=u1.replace(path: "");
        if(u0==u1)
        {
          ret = lwo;
          break;
        }
      }
    }
    return ret;
  }

  bool hasUrl(String url) {
    bool ret = false;
    if (_data != null) {
      Uri u0=Uri.tryParse(url?.toLowerCase());
      if(u0.path=="/" || u0.path=="/#" || u0.path=="/#/")
        u0=u0.replace(path: "");
      for (LocalWebsiteObj lwo in _data) {
        Uri u1= Uri.tryParse(lwo.url?.toLowerCase());
        if(u1.path=="/" || u1.path=="/#" || u1.path=="/#/")
          u1=u1.replace(path: "");
        if(u0==u1)
        {
          ret = true;
          break;
        }
      }
    }
    return ret;
  }
}

class LocalWebsiteObj {
  String name;
  String url;
  String ico;
  CurrencySymbol symbol;

  LocalWebsiteObj();

  LocalWebsiteObj.fromJson(Map<String, dynamic> json) {
    try {
      name = json["name"];
      url = json["url"];
      ico = json["ico"];
      String _symbol = json["symbol"];
      symbol = _symbol != null ? CurrencySymbolEx.fromCodeName(_symbol) : null;
    } catch (e, s) {
      print(s);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json["name"] = name;
    json["url"] = url;
    json["ico"] = ico;
    json["symbol"] = symbol?.codename ?? null;
    return json;
  }

  String _favicon = null;

  String getFaviconUrl() {
    // if(_favicon==null)
    {
      Uri uri = Uri.tryParse(url);
      if (uri != null) {
        _favicon = "${uri.scheme}://${uri.host}/favicon.ico";
      } else {
        _favicon = "";
      }
    }
    return _favicon;
  }

  String getIco() {
    if (StringUtils.isNotEmpty(ico)) return ico;
    return getFaviconUrl();
  }
}
