import 'dart:io';

import 'package:epikwallet/model/HomeMenuItem.dart';
import 'package:epikwallet/utils/sp_utils/sp_utils.dart';

class LimitedPlatform {
  static bool get isLimited {
    return Platform.isIOS;
    // return Platform.isAndroid;
  }

  static String sp_key_main_bot = "main_bot";
  static double bot_threshold = 100;

  static String sp_key_main_swap = "fun_swap";
  static double swap_threshold = 100;

  static List<HomeMenuItem> limitedSwapMenuList(List<HomeMenuItem> data) {
    bool fun_swap = SpUtils.getBool(LimitedPlatform.sp_key_main_swap, defValue: true);
    // print("limitedSwapMenuList  $fun_swap");
    if (!fun_swap) {
      List<HomeMenuItem> ret = [];
      // for (HomeMenuItem item in data) {
      //   switch (item.Name.toLowerCase()) {
      //     case "uniswap":
      //     case "pancake":
      //     case "ploy bridge":
      //     case "biswap":
      //       break;
      //     default:
      //       {
      //         if (item.action_l != null && item.action_l == HomeMenuItemAction.swap) {
      //
      //         } else {
      //           ret.add(item);
      //         }
      //       }
      //   }
      // }
      return ret;
    }
    return data;
  }
}
