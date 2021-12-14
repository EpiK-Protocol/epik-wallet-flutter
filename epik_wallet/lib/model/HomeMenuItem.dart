import 'package:epikwallet/utils/string_utils.dart';

enum HomeMenuItemAction {
  swap, //epk跨链兑换
  dapp, //dapp列表
  uniswap, //uniswap
  airdrop, //测试网空投
  scan, //扫码
  setting, //设置
}

extension HomeMenuItemActionEx on HomeMenuItemAction {
  static HomeMenuItemAction fromString(String text) {
    switch (text) {
      case "swap":
        return HomeMenuItemAction.swap; //epk跨链兑换
      case "dapp": //dapp列表
        return HomeMenuItemAction.dapp;
      case "uniswap": //uniswap
        return HomeMenuItemAction.uniswap;
      case "airdrop": //测试网空投
        return HomeMenuItemAction.airdrop;
      case "scan": //扫码
        return HomeMenuItemAction.scan;
      case "setting": //设置
        return HomeMenuItemAction.setting;
    }
    return null;
  }

  String getLocalIcon() {
    switch (this) {
      case HomeMenuItemAction.swap:
        return "assets/img/ic_swap.png";
      case HomeMenuItemAction.dapp:
        return "assets/img/ic_dapp.png";
      case HomeMenuItemAction.uniswap:
        return "assets/img/ic_uniswap.png";
      case HomeMenuItemAction.airdrop:
        return "assets/img/ic_airdrop.png";
      case HomeMenuItemAction.scan:
        return "assets/img/ic_scan_3.png";
      case HomeMenuItemAction.setting:
        return "assets/img/ic_setting.png";
    }
    return null;
  }
}

class HomeMenuItem {
  String Name; //"知识大陆
  String Icon; //: "",
  String Action; //: "epikg"
  HomeMenuItemAction action_l;

  bool Invalid = false;

  HomeMenuItem();

  HomeMenuItem.fromJson(Map<String, dynamic> json) {
    try {
      Name = json["Name"];
      Icon = json["Icon"];
      Action = json["Action"];
      action_l = HomeMenuItemActionEx.fromString(Action);

      Invalid = json["Invalid"]?? false;
      // Invalid=false;//todo
    } catch (e, s) {
      print(s);
    }
  }

  bool get hasNetImg
  {
    if(StringUtils.isNotEmpty(Icon))
      return true;
    return false;
  }
}
