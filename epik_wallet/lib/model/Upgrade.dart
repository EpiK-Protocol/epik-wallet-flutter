import 'package:epikwallet/utils/string_utils.dart';
import 'package:package_info/package_info.dart';

class Upgrade {
  String latest_version = ""; //: "1.0.0",
  String required_version = ""; //: "1.0.1",
  String description = ""; //: "更新描述",
  String upgrade_url = ""; //: "https://cdn.aivideo.tech/apk/AiInvestment.apk"

  int latest_version_num = 100;
  int required_version_num = 100;

  bool needUpgrade = false;
  bool needRequired = false;

  Upgrade.fromJson(Map<String, dynamic> json) {
    parseJson(json);
  }

  parseJson(Map<String, dynamic> json) {
    try {
      latest_version =
          StringUtils.parseString(json["latest_version"], latest_version);
      required_version =
          StringUtils.parseString(json["required_version"], required_version);
      description = StringUtils.parseString(json["description"], description);
      upgrade_url = StringUtils.parseString(json["upgrade_url"], upgrade_url);

      latest_version_num = version2Num(latest_version);
      required_version_num = version2Num(required_version);

    } catch (e) {
      print(e);
    }
  }

  Future checkVersion() async
  {
    PackageInfo packageinfo =  await PackageInfo.fromPlatform();
    int currentversion = version2Num(packageinfo.version);
    needUpgrade = currentversion<latest_version_num;
    needRequired = currentversion<required_version_num;
  }

  static int version2Num(String version) {
    try {
      String numstr = version.replaceAll(".", "");
      int num = int.parse(numstr);
      return num;
    } catch (e) {
      print(e);
    }
    return 0;
  }
}
