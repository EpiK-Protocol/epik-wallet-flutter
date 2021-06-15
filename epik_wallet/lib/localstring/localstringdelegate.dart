import 'package:epikwallet/localstring/resstring_en.dart';
import 'package:epikwallet/localstring/resstring_zh.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class ResStringDelegate extends LocalizationsDelegate<ResString> {
  const ResStringDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<ResString> load(Locale locale) {
    return new SynchronousFuture<ResString>(new ResString(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<ResString> old) {
    return false;
  }

  static ResStringDelegate delegate = const ResStringDelegate();
}

class ResString {
  final Locale locale;

  ResString(this.locale);

  static Map<String, Map<RSID, String>> _localizedValues = {
    'en': map_en,
    'zh': map_zh, //todo
  };

  static ResString of(BuildContext context) {
//    Dlog.p("rs", "context= ${context}");
    if (context != null) {
      return Localizations.of(context, ResString);
    }
    return null;
  }

  String getString(RSID key, {List<String> replace}) {
    String ret = "";

    ret = _localizedValues[locale.languageCode][key];

    if (replace != null && replace.length > 0) {
      int i = 0;
      ret = ret.replaceAllMapped("%s", (match) {
        return replace[i++] ?? "";
      });
    }

    return ret;
  }

  static String get(BuildContext context, RSID key, {List<String> replace}) {
    String ret = ResString.of(context)?.getString(key, replace: replace);
    return ret ?? "";
  }
}
