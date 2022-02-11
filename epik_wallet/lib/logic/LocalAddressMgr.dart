import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/sp_utils/sp_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jazzicon/jazzicon.dart';
import 'package:jazzicon/jazziconshape.dart';
import 'package:lpinyin/lpinyin.dart';

var localaddressmgr = new LocalAddressMgr();

class LocalAddressMgr {
  static const String TAG = "LocalAddressMgr";
  static LocalAddressMgr _LocalAddressMgr = LocalAddressMgr._internal();

  final String _KEY_ADDRESS_LIST = "local_address_list";

  factory LocalAddressMgr() {
    return _LocalAddressMgr;
  }

  LocalAddressMgr._internal() {
    // 单例初始化
    Dlog.p(TAG, "初始化");
  }

  Map<String, List<LocalAddressObj>> _datamap = {};

  Map<String, List<LocalAddressObj>> get datamap => _datamap;

  Map<String, LocalAddressObj> _datamap_kv = {};

  Future load() async {
    Dlog.p(TAG, " load");
    String jsonstr = SpUtils.getString(_KEY_ADDRESS_LIST);
    Dlog.p(TAG, " load => ${jsonstr}");

    Map<String, List<LocalAddressObj>> temp = {};
    Map<String, LocalAddressObj> temp2 = {};
    if (jsonstr != null && jsonstr.length > 0) {
      try {
        Map<String, dynamic> json = jsonDecode(jsonstr);
        json.forEach((key, value) {
          List<LocalAddressObj> items = [];
          items = JsonArray.parseList(value, (j) => LocalAddressObj.fromJson(j));
          sort(items);
          temp[key] = items;

          for (LocalAddressObj lao in items) {
            temp2[lao.address.toLowerCase()] = lao;
          }
        });
      } catch (e, s) {
        print(e);
        print(s);
      }
    }

    _datamap = temp ?? {};
    _datamap_kv = temp2 ?? {};

    Dlog.p(TAG, " load _datamap = ${_datamap}");
  }

  Future save() async {
    Dlog.p(TAG, " save");
    try {
      String save = "";
      if (_datamap != null && _datamap.length > 0) {
        save = jsonEncode(_datamap);
      } else {
        save = "{}";
      }
      Dlog.p(TAG, " save json => " + save);
      SpUtils.putString(_KEY_ADDRESS_LIST, save).then((res) {
        Dlog.p(TAG, " save res => $res");
      });
    } catch (e) {
      print(e);
    }
  }

  Future add(LocalAddressObj lao, {bool toFirst = false}) {
    List<LocalAddressObj> list = _datamap[lao.symbol.codename];
    if (list == null) {
      list = [];
      _datamap[lao.symbol.codename] = list;
    }
    if (toFirst) {
      list.insert(0, lao);
    } else {
      list.add(lao);
      sort(list);
    }
    _datamap_kv[lao.address.toLowerCase()] = lao;
  }

  sort(List<LocalAddressObj> data) {
    data?.sort((left, right) => left.sortName?.compareTo(right.sortName));
  }

  Future delete(LocalAddressObj lao) {
    List<LocalAddressObj> list = _datamap[lao.symbol.codename];
    if (list != null && list.length > 0) {
      list.removeWhere((element) => element?.address == lao?.address);
    }
    _datamap_kv.remove(lao.address.toLowerCase());
  }

  Future deleteAll(List<LocalAddressObj> data) {
    List<LocalAddressObj> list = _datamap[data[0].symbol.codename];
    if (list != null && list.length > 0) {
      list.removeWhere((element) {
        for (LocalAddressObj lao in data) {
          if (element?.address == lao?.address) return true;
        }
        return false;
      });
    }
    for (LocalAddressObj lao in data) {
      _datamap_kv.remove(lao.address.toLowerCase());
    }
  }

  LocalAddressObj findObjByAddress(String address) {
    return _datamap_kv[address.toLowerCase()];
  }
}

class LocalAddressObj {
  String name;
  String address;
  CurrencySymbol symbol;

  LocalAddressObj();

  LocalAddressObj.fromJson(Map<String, dynamic> json) {
    try {
      name = json["name"];
      address = json["address"];
      String _symbol = json["symbol"];
      symbol = CurrencySymbolEx.fromCodeName(_symbol);
    } catch (e, s) {
      print(s);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json["name"] = name;
    json["address"] = address;
    json["symbol"] = symbol.codename;
    return json;
  }

  Gradient _gradient = null;

  Gradient get gradientCover {
    if (_gradient != null) {
      return _gradient;
    }

    List<Color> colors = [];
    int r1 = 0;

    List<Color> clist_b = [
      Colors.blue,
      Colors.blue[200],
      Colors.blue[300],
      Colors.blue[400],
      Colors.blue[500],
      Colors.blue[600],
      Colors.blue[700],
      Colors.blue[800],
      Colors.blueAccent,
      Colors.indigo,
      Colors.indigoAccent,
      Colors.lightBlue,
      Colors.lightBlueAccent,
      // Colors.deepPurple,
      // Colors.deepPurpleAccent,
    ];
    List<Color> clist_g = [
      // Colors.cyan,
      Colors.cyanAccent,
      // Colors.green,
      Colors.greenAccent,
      // Colors.lightGreen,
      Colors.lightGreenAccent,
      Colors.lime,
      Colors.limeAccent,
      // Colors.teal,
      // Colors.tealAccent,
    ];
    List<Color> clist_r = [
      // Colors.deepOrangeAccent,
      Colors.orange,
      Colors.orangeAccent,
      Colors.pink,
      Colors.pinkAccent,
      // Colors.purple,
      Colors.purpleAccent,
      // Colors.red,
      Colors.redAccent,
    ];

    Digest digest = sha256.convert(utf8.encode(address));
    r1 = digest.bytes.last;

    List<List<Color>> colorgroup = [clist_r, clist_g, clist_b];
    int cl1 = digest.bytes[(digest.bytes.length / 2 + 0).toInt()] % 3;
    int cl2 = digest.bytes[(digest.bytes.length / 2 + 2).toInt()] % 3;
    int cl3 = min(0, max(3 - cl1 - cl2, 2));
    // print("$cl1   $cl2   $cl1");
    Color c1 = colorgroup[cl1][(digest.bytes[0] + digest.bytes[1] + digest.bytes[2]) % colorgroup[cl1].length];
    Color c2 = colorgroup[cl2][(digest.bytes[5] + digest.bytes[1] + digest.bytes[2]) % colorgroup[cl2].length];
    Color c3 = colorgroup[cl3][(digest.bytes[8] + digest.bytes[1] + digest.bytes[2]) % colorgroup[cl3].length];
    colors.addAll([c1, c2, c3]);

    switch (r1 % 10) {
      case 0:
      case 1:
      case 2:
      case 3:
      case 4:
        {
          _gradient = LinearGradient(
            colors: colors,
            stops: [0.1, 0.6, 0.9],
            begin: [
              Alignment.centerLeft,
              Alignment.topLeft,
              Alignment.topCenter,
              Alignment.topRight,
              Alignment.centerRight
            ][r1 % 5],
            end: [
              Alignment.centerRight,
              Alignment.bottomRight,
              Alignment.bottomCenter,
              Alignment.bottomLeft,
              Alignment.centerLeft
            ][r1 % 5],
          );
        }
        break;
      case 5:
      case 6:
      case 7:
      case 8:
      case 9:
      default:
        {
          _gradient = RadialGradient(
            colors: colors,
            radius: 1.3,
            center: [
              Alignment.centerLeft,
              Alignment.topLeft,
              Alignment.topCenter,
              Alignment.topRight,
              Alignment.centerRight,
              Alignment.bottomRight,
              Alignment.bottomCenter,
              Alignment.bottomLeft,
              Alignment.center
            ][r1 % 9],
          );
        }
        break;
    }

    return _gradient;
  }

  String _sortName = null;

  String get sortName {
    if (_sortName == null) {
      try {
        _sortName = PinyinHelper.getShortPinyin(name);
        print(_sortName);
      } catch (e) {
        print(e);
      }
    }
    return _sortName ?? name;
  }

  JazziconData _jd;

  JazziconData get jazziconData {
    if (_jd == null && useJazzicon) {
      _jd = Jazzicon.getJazziconData(30, address: address);
    }
    return _jd;
  }

  bool get useJazzicon {
    return symbol?.networkType == CurrencySymbol.ETH || symbol?.networkType == CurrencySymbol.BNB;
  }
}
