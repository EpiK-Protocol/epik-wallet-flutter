import 'dart:ui';

import 'package:epikwallet/main.dart';
import 'package:epikwallet/utils/sp_utils/sp_utils.dart';
import 'package:flutter/widgets.dart';

class LocaleConfig {
  static Locale locale_en = Locale('en', 'US');
  static Locale locale_zh = const Locale('zh', 'CH');

  static Locale locale;


  static Locale get currentAppLocale {
    try {
      return Localizations.localeOf(appContext);
    } catch (e, s) {
      print(e);
    }
  }

  static setCurrentLocaleConfig(Locale locale)
  {
    LocaleConfig.locale = locale;
    SpUtils.putString("LocaleConfig",locale.toString());
  }

  static Locale getCurrentLocaleConfig()
  {
    if(LocaleConfig.locale ==null)
    {
      String a= SpUtils.getString("LocaleConfig");
      if(a!=null && a.contains("_"))//en_US
      {
        List<String> list = a.split("_");
        LocaleConfig.locale  =Locale(list[0], list[1]);
      }
    }
    return LocaleConfig.locale;
  }

  static bool currentIsZh()
  {
    Locale _locale_sys  =  LocaleConfig.currentAppLocale;//必须widget挂载
    // print("currentIsZh=${_locale_sys}");
    if(_locale_sys!=null)
    {
      if(_locale_sys.languageCode=="zh")
      {
        return true;
      }
    }
    return false;
  }

  static String getLanguageString()
  {
    String language = "";
      if(currentIsZh())
      {
        language = "中文";
      }else{
        language = "English";
      }
    return language;
  }
}
