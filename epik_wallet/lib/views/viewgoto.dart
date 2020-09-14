import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/model/CurrencyAsset.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/views/currency/currencydepositview.dart';
import 'package:epikwallet/views/currency/currencydetailview.dart';
import 'package:epikwallet/views/currency/currencywithdrawview.dart';
import 'package:epikwallet/views/mining/miningprofitview.dart';
import 'package:epikwallet/views/mining/miningsignupview.dart';
import 'package:epikwallet/views/qrcode/qrcodescanview.dart';
import 'package:epikwallet/views/uniswap/uniswappooladdview.dart';
import 'package:epikwallet/views/uniswap/uniswappoolremoveview.dart';
import 'package:epikwallet/views/uniswap/uniswapview.dart';
import 'package:epikwallet/views/wallet/accountdetailview.dart';
import 'package:epikwallet/views/wallet/create/createwalletview.dart';
import 'package:epikwallet/views/wallet/exprot/exportepikprivatekeyview.dart';
import 'package:epikwallet/views/wallet/fixpasswordview.dart';
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
      BuildContext context, WalletAccount walletAccount) {
    showView(context, AccountDetailView(walletAccount));
  }

  /// 挖矿报名
  static showMiningSignupView(BuildContext context) {
    showView(context, MiningSignupView());
  }

  /// 挖矿奖励
  static showMiningProfitView(BuildContext context,String mining_id) {
    showView(context, MiningProfitView(mining_id));
  }

  /// 充币
  static showCurrencyDepositView(BuildContext context, WalletAccount walletaccount, CurrencySymbol currencysymbol)
  {
    showView(context, CurrencyDepositView(walletaccount,currencysymbol));
  }

  /// 提币
  static showCurrencyWithdrawView(BuildContext context, WalletAccount walletaccount, CurrencyAsset currencyAsset)
  {
    showView(context, CurrencyWithdrawView(walletaccount,currencyAsset));
  }

  /// 扫描二维码
  static showQrcodeScanView(BuildContext context) {
    showView(context, QrcodeScanView());
  }

  /// 导出epik钱包的私钥
  static showExportEpikPrivateKeyView(BuildContext context, WalletAccount walletAccount)
  {
    showView(context, ExportEpikPrivateKeyView(walletAccount));
  }

  /// 修改钱包密码
  static showFixPasswordView(BuildContext context, WalletAccount walletAccount){
    showView(context, FixPasswordView(walletAccount));
  }

  static showUniswapView(BuildContext context, WalletAccount walletAccount){
    showView(context, UniswapView(walletAccount));
  }

  ///uniswap 注入资金
  static showUniswapPoolAddView(BuildContext context, WalletAccount walletAccount,UniswapInfo uniswapinfo)
  {
    showView(context,UniswapPoolAddView(walletAccount,uniswapinfo));
  }

  ///uniswap 撤回资金
  static showUniswapPoolRemoveView(BuildContext context, WalletAccount walletAccount,UniswapInfo uniswapinfo)
  {
    showView(context,UniswapPoolRemoveView(walletAccount,uniswapinfo));
  }

}
