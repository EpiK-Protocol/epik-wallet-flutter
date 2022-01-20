import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:package_info/package_info.dart';

String code_version = "1.2.3"; //ios签发固定在1.2.5

class Upgrade {
  /// 当前最新版本
  String latest_version = ""; //: "1.0.0",
  /// 强制升级版本
  String required_version = ""; //: "1.0.1",
  String description = ""; //: "更新描述", 暂无字段
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
          StringUtils.parseString(json["LatestVersion"], latest_version);
      required_version =
          StringUtils.parseString(json["RequiredVersion"], required_version);
      description = StringUtils.parseString(json["description"], "");
      upgrade_url = StringUtils.parseString(json["UpdateURL"], upgrade_url);
      if (StringUtils.isEmpty(latest_version)) {
        latest_version = required_version;
      }
      latest_version_num = version2Num(latest_version);
      required_version_num = version2Num(required_version);
    } catch (e) {
      print("Upgrade.fromJson error");
      print(e);
    }
  }

  Future checkVersion() async {
    PackageInfo packageinfo = await PackageInfo.fromPlatform();
    int currentversion = version2Num(packageinfo.version);
    // int currentversion = version2Num(code_version);
    Dlog.p("Upgrade",
        "checkVersion currentversion=$currentversion latest_version_num=$latest_version_num required_version_num=$required_version_num");
    needUpgrade = currentversion < latest_version_num;
    needRequired = currentversion < required_version_num;
    if (needRequired) needUpgrade = needRequired;

    // todo test
   // needUpgrade = true;
   // needRequired= true;

    if (StringUtils.isEmpty(description)) {
//      description = "有新版本V${latest_version}${needRequired?"需要升级\n如不升级可能会影响正常功能":"可以升级\n是否现在升级?"}";
      description = ResString.get(appContext, RSID.upgrade_des,
          replace: ["V$latest_version"]);
      if (needRequired) {
        description += ResString.get(appContext, RSID.upgrade_des_1);
      } else {
        description += ResString.get(appContext, RSID.upgrade_des_2);
      }
    }
  }

  static int version2Num(String version) {
    try {
      // 1.0.0  ==  1 00 00
      int num = 0;
      List<String> array = version.split(".");
      if (array != null && array.length > 0) {
        String numString = "";
        for (int i = 0; i < array.length; i++) {
          if (i == 0) {
            numString += array[i];
          } else {
            String ss = array[i];
            if (ss.length == 1) ss = "0" + ss;
            numString += ss;
          }
        }
        num = StringUtils.parseInt(numString, 0);
      }
      return num;
    } catch (e) {
      print("version2Num error");
      print(e);
    }
    return 0;
  }

  static PackageInfo packageinfo;

  static bool has_10100() {
    int currentversion = version2Num(packageinfo.version);
    // int currentversion = version2Num(code_version);
    return currentversion >= 10100;
  }
}
