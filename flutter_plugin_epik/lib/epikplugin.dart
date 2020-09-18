import 'dart:async';

import 'package:flutter/services.dart';

export 'HdWallet.dart' show HD, HdWallet;
export 'EpikWallet.dart';
export 'PrivateKey.dart';
export 'Bip44Path.dart';
export 'UniswapInfo.dart';
export 'Amounts.dart';
export 'ResultObj.dart';


class EpikPlugin {
  static const MethodChannel channel = const MethodChannel('epikplugin');

  static Future<String> get platformVersion async {
    final String version = await channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
