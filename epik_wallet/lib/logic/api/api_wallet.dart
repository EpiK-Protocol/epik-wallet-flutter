import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/utils/http/httputils.dart';

class ApiWallet {
  // GET {{HOST}}/messages?address=t3v2m2rkfoaqcqavhazvuplnqjpn4tgfgrej5r7sjrv27sa2ulftepflbcjakzk3pw3fysrdznz6kw6l4aamja&from=&size=50
  static Future<HttpJsonRes> getTepkOrderList(
      String address, String from, int size) async {
    String url = ServiceInfo.HOST + "/messages";
    Map<String, dynamic> params = new Map();
    // address="t3v2m2rkfoaqcqavhazvuplnqjpn4tgfgrej5r7sjrv27sa2ulftepflbcjakzk3pw3fysrdznz6kw6l4aamja";
    params["address"] = address;
    params["from"] = from??""; //Time: "2020-12-28T04:04:27Z"
    params["size"] = size;
    return await HttpUtil.instance.requestJson(true, url, params);
  }
}
