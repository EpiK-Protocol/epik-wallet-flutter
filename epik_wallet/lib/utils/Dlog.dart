
import 'package:epikwallet/base/buildConfig.dart';

class Dlog
{
  static bool logOpen= BuildConfig.isDebug;

  static p(String tag, String log)
  {
    if(logOpen)
    {
      print("$tag: $log");
    }
  }
}