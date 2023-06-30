import 'dart:convert';

import 'package:epikwallet/model/AIBotApp.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/sp_utils/sp_utils.dart';

var aibotlatestmgr = new AIBotLatestMgr();

class AIBotLatestMgr {
  static const String TAG = "AIBotLatestMgr";
  static AIBotLatestMgr _AIBotLatestMgr = AIBotLatestMgr._internal();

  final String _KEY_AI_BOT_LIST = "local_latest_ai_bots";

  int maxLength = 6;

  factory AIBotLatestMgr() {
    return _AIBotLatestMgr;
  }

  AIBotLatestMgr._internal() {
    // 单例初始化
    Dlog.p(TAG, "初始化");
  }

  List<AIBotApp> _data = [];

  List<AIBotApp> get data => _data;

  Future load() async {
    Dlog.p(TAG, " load");
    String jsonstr = SpUtils.getString(_KEY_AI_BOT_LIST);
    Dlog.p(TAG, " load => ${jsonstr}");

    List<AIBotApp> temp = [];
    if (jsonstr != null && jsonstr.length > 0) {
      try {
        List jarray = jsonDecode(jsonstr);
        temp = JsonArray.parseList(jarray, (j) => AIBotApp.fromJson(j));
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
      SpUtils.putString(_KEY_AI_BOT_LIST, save).then((res) {
        Dlog.p(TAG, " save res => $res");
      });
    } catch (e) {
      print(e);
    }
  }

  AIBotApp findBotByID(int bot_id) {
    if (_data != null)
      for (AIBotApp bot in _data) {
        if (bot.id == bot_id) {
          return bot;
        }
      }
    return null;
  }

  bool hasBotId(int bot_id) {
    return findBotByID(bot_id) != null;
  }

  void delBotByID(int bot_id) {
    if (_data != null)
      _data.removeWhere((bot) {
        return bot.id == bot_id;
      });
  }

  void add(AIBotApp bot, {bool toFirst = true}) {
    if (_data == null) {
      _data = [];
    }

    delBotByID(bot.id);

    if (toFirst) {
      _data.insert(0, bot);
    } else {
      _data.add(bot);
    }

    if (_data.length > maxLength) {
      _data.removeRange(maxLength, _data.length);
    }
  }

  void updata(List<AIBotApp> bots) {
    if (bots != null && bots.length > 0 && _data != null && _data.length > 0) {
      Map<int, AIBotApp> map = {};
      _data.forEach((e) {
        map[e.id] = e;
      });
      bots.forEach((bot) {
        if (map.keys.contains(bot.id)) {
          map[bot.id]
            ..app_key = bot.app_key
            ..url = bot.url
            ..name = bot.name
            ..description = bot.description
            ..description_en = bot.description_en
            ..icon = bot.icon
            ..hot = bot.hot
            ..enabled = bot.enabled
            ..feature_cover = bot.feature_cover
            ..feature_video = bot.feature_video
            ..pinned = bot.pinned
          ;
          // print("AIBotApp updata ${bot.id}");
        }
      });
    }
  }
}
