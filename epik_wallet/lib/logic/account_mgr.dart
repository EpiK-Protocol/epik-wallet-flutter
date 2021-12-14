import 'dart:convert';

import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/UniswapHistoryMgr.dart';
import 'package:epikwallet/logic/loader/DL_TepkLoginToken.dart';
import 'package:epikwallet/utils/AesCryptUtil.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/RecyclXOR.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/sp_utils/sp_utils.dart';

class AccountMgr {
  static final String TAG = "AccountMgr";

  static const String _KEY_ACCOUNT_LIST = "am_account_list";

  static AccountMgr _AccountMgr = AccountMgr._internal();

  factory AccountMgr() {
    return _AccountMgr;
  }

  AccountMgr._internal() {
    // 单例初始化
    Dlog.p(TAG, "初始化");
//    load();
  }

  List<WalletAccount> _account_list = [];
  WalletAccount _currentAccount;

  WalletAccount get currentAccount {
    // Dlog.p(TAG, " get currentAccount");
//    if(_currentAccount==null)
//    {
//      Dlog.p(TAG, " get _account_list=${_account_list.length}");
//      if (_account_list != null && _account_list.length > 0) {
//        _currentAccount = _account_list[0];
//      }
//    }
    return _currentAccount;
  }

  List<WalletAccount> get account_list {
    Dlog.p(TAG, " get account_list");
    if (_account_list == null) _account_list = [];
    return _account_list;
  }

  Future load() async {
    Dlog.p(TAG, " load");
    String jsonstr = SpUtils.getString(_KEY_ACCOUNT_LIST);
    Dlog.p(TAG, " load => ${jsonstr}");

    bool needsave = false;
    if (jsonstr != null) {
      if (jsonstr.startsWith("[") && jsonstr.endsWith("]")) {
        //V1 jsonarray
        needsave = true;
      }else if (jsonstr.startsWith("V3:")) {
        //V3 String encode = "V3:${RecyclXOR.XORCryptoBase64(save, "ERC20-EPK",iv: "EpiK Portal")}";
        String decode = RecyclXOR.XORDecryptBase64(
            jsonstr.substring(3) ?? "", "ERC20-EPK",
            iv: "EpiK Portal");
        jsonstr = decode ?? jsonstr;
      } else {
        //V2
        String decode = await AesCryptUtil.aesDecodeBase64CBC(jsonstr,
            aes_key: "ERC20-EPK<->EPIK", aes_iv: "EPIK<->ERC20-EPK");
        jsonstr = decode ?? jsonstr;
        needsave = true;
      }
    }

    List<WalletAccount> temp = [];
    if (jsonstr != null && jsonstr.length > 0) {
      try {
        temp = JsonArray.parseList<WalletAccount>(
            JsonArray.obj2List(jsonDecode(jsonstr)),
            (json) => WalletAccount.fromJson(json));
        Dlog.p(TAG, " load => ${temp}");
      } catch (e) {
        print(e);
      }
    }

    _account_list = temp ?? [];

    // 设置当前使用账号
    if (_account_list != null && _account_list.length > 0) {
      setCurrentAccount(_account_list[0]);
    }

    Dlog.p(TAG, " load size = ${_account_list.length}");

    if (needsave) {
      await save();
    }
  }

  Future save() async {
    Dlog.p(TAG, " save");
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
      Dlog.p(TAG, " save json => " + save);
      // String encode = await AesCryptUtil.aesEncodeBase64CBC(save,aes_key: "ERC20-EPK<->EPIK",aes_iv: "EPIK<->ERC20-EPK");
      String encode =
          "V3:${RecyclXOR.XORCryptoBase64(save, "ERC20-EPK", iv: "EpiK Portal")}";
      SpUtils.putString(_KEY_ACCOUNT_LIST, encode ?? save).then((res) {
        Dlog.p(TAG, " save res => $res");
      });
    } catch (e) {
      print(e);
    }
  }

  addAccount(WalletAccount account, {bool toFrist = true}) {
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
  Future delAccount(WalletAccount account) async {
    WalletAccount nextAccount = null;
    _account_list.remove(account);
    if (_account_list.length > 0) {
      nextAccount = _account_list[0];
    }

    if (nextAccount == null) {
//      print("没有账号了");
      _currentAccount = null;
      save();
      eventMgr.send(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, account);
    } else if (_currentAccount != nextAccount) {
      // 下一个账号 与当前账号不同
//      print("下一个账号 与当前账号不同");
      await setCurrentAccount(nextAccount);
    } else {
//      print("aaaaaa");
      save();
      eventMgr.send(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, account);
    }
  }

  Future<bool> setCurrentAccount(WalletAccount account) async {
    /// 初始化账户中的钱包对象
    bool ok = await EpikWalletUtils.initWalletAccount(account);
    if (ok) {
      if (this._currentAccount != null) {
        this._currentAccount.hdwallet = null;
        this._currentAccount.epikWallet = null;
        DL_TepkLoginToken.destroyIns();
      }

      this._currentAccount = account;

      try {
        if (account != null) {
          if (account_list.length > 0 && account_list[0] == account) {
            // 已经是第一个了
          } else {
            account_list.remove(account);
            account_list.insert(0, account);
          }
          save();
          print("set AccountMgr");
          account.uhMgr = UniswapHistoryMgr(account.hd_eth_address);

          account.loadDappTokens();

          DL_TepkLoginToken.ins(account);
          DL_TepkLoginToken.getEntity().refreshData(false);

          eventMgr.send(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, account);
        }
      } catch (e) {
        print(e);
      }
    }
    return ok;
  }
}
