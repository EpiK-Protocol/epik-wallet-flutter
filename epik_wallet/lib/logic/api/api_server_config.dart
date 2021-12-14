

import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/utils/http/httputils.dart';

class ApiServerConfig{

  static Future<HttpJsonRes> getWalletConfig() {
    String url =  ServiceInfo.makeUrl(ServiceInfo.codeHost, "/wallet/config");
    Map<String, dynamic> params = new Map();
    return HttpUtil.instance.requestJson(true, url, params);
  }

}

