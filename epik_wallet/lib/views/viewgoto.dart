import 'package:epikwallet/model/CurrencyAsset.dart';
import 'package:epikwallet/model/LocalKeyStore.dart';
import 'package:epikwallet/views/currency/currencydetailview.dart';
import 'package:epikwallet/views/mining/miningprofitview.dart';
import 'package:epikwallet/views/mining/miningsignupview.dart';
import 'package:epikwallet/views/wallet/accountdetailview.dart';
import 'package:epikwallet/views/wallet/create/createwalletview.dart';
import 'package:epikwallet/views/wallet/import/importwalletview.dart';
import 'package:epikwallet/views/web/generalwebview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ViewPushModel {
  /// 新页面
  Push,

  /// 新页面替换当前页面，无转场动画
  PushReplacement,

  /// 新页面,删除之前所有页面
  PushAndRemoveUntil,
}

class ViewGT {
  ///打开新页面 model
  static showView(BuildContext context, Widget view,
      {ViewPushModel model = ViewPushModel.Push}) {
    MaterialPageRoute route = MaterialPageRoute(builder: (context) {
      return view;
    });

    switch (model) {
      case ViewPushModel.PushReplacement:
        Navigator.pushReplacement(context, route);
        break;
      case ViewPushModel.PushAndRemoveUntil:
        Navigator.pushAndRemoveUntil(context, route, (route) => route == null);
        break;
      case ViewPushModel.Push:
      default:
        Navigator.push(context, route);
        break;
    }
  }

  /// 通用网页
  static showGeneralWebView(BuildContext context, String title, String url) {
    showView(context, GeneralWebView(title, url));
  }

  /// 创建钱包
  static showCreateWalletView(BuildContext context) {
    showView(context, CreateWalletView());
  }

  /// 导入钱包
  static showImportWalletView(BuildContext context) {
    showView(context, ImportWalletView());
  }

  /// 币种详情
  static showCurrencyDetailView(
      BuildContext context, CurrencyAsset currencyasset) {
    showView(context, CurrencyDetailView(currencyasset));
  }

  /// 账号详情
  static showAccountDetailView(
      BuildContext context, LocalKeyStore localKeyStore) {
    showView(context, AccountDetailView(localKeyStore));
  }

  /// 挖矿报名
  static showMiningSignupView(BuildContext context) {
    showView(context, MiningSignupView());
  }

  /// 挖矿奖励
  static showMiningProfitView(BuildContext context) {
    showView(context, MiningProfitView());
  }


}
