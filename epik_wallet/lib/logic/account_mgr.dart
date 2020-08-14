import 'dart:convert';

import 'package:epikwallet/model/LocalKeyStore.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/sp_utils/sp_utils.dart';

class AccountMgr {

  static  final String TAG ="AccountMgr";

  static const String _KEY_ACCOUNT_LIST = "am_account_list";

  static AccountMgr _AccountMgr = AccountMgr._internal();

  factory AccountMgr() {
    return _AccountMgr;
  }

  AccountMgr._internal() {
    // 单例初始化
    Dlog.p(TAG,"初始化");
//    load();
  }

  List<LocalKeyStore> _account_list = [];
  LocalKeyStore _currentAccount;

  LocalKeyStore get currentAccount {
    Dlog.p(TAG," get currentAccount");

    Dlog.p(TAG," get _account_list=${_account_list.length}");
    if (_account_list != null && _account_list.length > 0) {
      _currentAccount = _account_list[0];
    }
    return _currentAccount;
  }

  List<LocalKeyStore> get account_list {
    Dlog.p(TAG," get account_list");
    if (_account_list == null) _account_list = [];
    return _account_list;
  }

  Future load() async {
    Dlog.p(TAG," load");
    String jsonstr = SpUtils.getString(_KEY_ACCOUNT_LIST);
    Dlog.p(TAG," load => ${jsonstr}");

    List<LocalKeyStore> temp = [];
    if (jsonstr != null && jsonstr.length > 0) {
      try {
        temp = JsonArray<LocalKeyStore>().parseList(
            JsonArray.obj2List(jsonDecode(jsonstr)),
            (json) => LocalKeyStore.fromJson(json));
        Dlog.p(TAG," load => ${temp}");
      } catch (e) {
        print(e);
      }
    }

    _account_list = temp ?? [];

    Dlog.p(TAG," load size = ${_account_list.length}");
  }

  Future save() async {
    Dlog.p(TAG," save");
    try {
      String save = "";
      if (_account_list != null && _account_list.length > 0) {
        List<Map> temp = [];
        _account_list.forEach((lks) {
          temp.add(lks.toJson());
        });
        save = jsonEncode(temp);
      } else {
        save = "[]";
      }
      Dlog.p(TAG," save json => " + save);
      SpUtils.putString(_KEY_ACCOUNT_LIST, save).then((res) {
        Dlog.p(TAG," save res => $res");
      });
    } catch (e) {
      print(e);
    }
  }

  addAccount(LocalKeyStore account, {bool toFrist = true}) {
    if (toFrist) {
      account_list.insert(0, account);
    } else {
      account_list.add(account);
    }

    save().then((value) {
      eventMgr.send(EventTag.LOCAL_ACCOUNT_LIST_CHANGE);
    });
  }

  /* 删除账号 */
  delAccount(LocalKeyStore account) {
    LocalKeyStore nextAccount = null;
    List<LocalKeyStore> temp = List.from(account_list);

    temp.remove(account);
    if (temp.length > 0) nextAccount = temp[0];

    _currentAccount = nextAccount;
    account_list.remove(account);
    save();
    eventMgr.send(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, account);
  }

  setCurrentAccount(LocalKeyStore account) {
    this._currentAccount = account;

    try {
      if (account != null) {
        account_list.remove(account);
        account_list.insert(0, account);
        save();
        eventMgr.send(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, account);
      }
    } catch (e) {
      print(e);
    }
  }
}
