import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/api/api_mainnet.dart';
import 'package:epikwallet/logic/loader/DataLoader.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/string_utils.dart';

class DL_TepkLoginToken extends DataLoader<String> {
  static final String TAG = "DL_TepkLoginToken";

  static DL_TepkLoginToken _mSelf;

  static DL_TepkLoginToken getEntity() {
    return _mSelf;
  }

  static DL_TepkLoginToken ins(WalletAccount account) {
    if (_mSelf != null &&
        account.hd_eth_address != _mSelf.account.hd_eth_address) destroyIns();

    // 双重校验单例
    if (_mSelf == null) {
      _mSelf = DL_TepkLoginToken(account);
    }
    return _mSelf;
  }

  WalletAccount account;

  String access_token;
  String msg;
  int code;

  DL_TepkLoginToken(this.account) {}

  /** 销毁实例 */
  static void destroyIns() {
    if (_mSelf != null) {
      _mSelf.destroy();
      _mSelf = null;
    }
  }

  @override
  Future<void>  requestData(bool readCache, JResponse callback) {
    // ApiTestNet.login(account).then((httpjsonres) {
    //   callback(httpjsonres, false);
    // });
    ApiMainNet.login(account).then((httpjsonres) {
      callback(httpjsonres, false);
    });
  }

  @override
  void parseData(HttpJsonRes hjr, bool cached) {
    hasMore = false;

    code = hjr?.code ?? "-1";
    msg = hjr?.msg ?? "error";

    Dlog.p(TAG, "parseData  code=${code} msg=${msg}");

    if (hjr != null && hjr.code == 0) {
      String token = StringUtils.parseString(hjr.jsonMap["token"], "");
      String mining_id = StringUtils.parseString(hjr.jsonMap['id'], "");
      Dlog.p(TAG, "parseData  token=${token}");
      Dlog.p(TAG, "parseData  mining_id=${mining_id}");
      if (StringUtils.isNotEmpty(token)) {
        access_token = token;
      }
      if(StringUtils.isNotEmpty(mining_id))
      {
        account.mining_id = mining_id;
      }
    }
    requestComplete(code, msg, 0, 0, null);
  }

  String getToken() {
    return access_token;
  }

  bool hasToken() {
    return !StringUtils.isEmpty(access_token);
  }

  /**
   * 获取token
   *
   * @param request
   *            true 重新在线获取，false 如果本地有token 就用本地的
   * @param dlcallback
   */
  void getTokenOnline(
      bool request, OnRequestComplete<String> onRequestComplete) {
    if (hasToken() && !request) {
      onRequestComplete(this, 0, "", 0, 0, null);
    } else {
      addOnceCallback(DlCallback(onRequestComplete));
      if (!isRequesting()) refreshData(false);
    }
  }
}
