import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:epikwallet/localstring/LocaleConfig.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/model/Upgrade.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:package_info/package_info.dart';

class HttpUtil {
  // 工厂模式
  factory HttpUtil() => _getInstance();

  static HttpUtil get instance => _getInstance();
  static HttpUtil _instance;

  Dio _dio;

  static final int CONNECR_TIME_OUT = 1000 * 30;
  static final int RECIVE_TIME_OUT = 1000 * 30;
  static final CONTENT_TYPE_JSON = "application/json;charset=UTF-8";
  static final CONTENT_TYPE_FORM = "application/x-www-form-urlencoded";

  HttpUtil._internal() {
    // 初始化
    _dio = Dio();
    // 添加拦截器
    // _dio.interceptors.add(new MyIntercept());
    // 配置dio实例
//    _dio.options.baseUrl = "http://gank.io/api/";
    _dio.options.connectTimeout = CONNECR_TIME_OUT; //10s
    _dio.options.receiveTimeout = RECIVE_TIME_OUT;

    /// 请求的Content-Type，默认值是"application/json; charset=utf-8".
    /// 如果您想以"application/x-www-form-urlencoded"格式编码请求数据,
    /// 可以设置此选项为 `Headers.formUrlEncodedContentType`,  这样[Dio]
    /// 就会自动编码请求体.
//    _dio.options.contentType = ContentType.parse(CONTENT_TYPE_JSON);
    _dio.options.contentType = CONTENT_TYPE_JSON;
  }

  static HttpUtil _getInstance() {
    if (_instance == null) {
      _instance = new HttpUtil._internal();
    }
    return _instance;
  }

  //get请求
  Future<Response> get(String url, Map<String, dynamic> params) async {
    Future future = _dio.get(url, queryParameters: params);
    return future;
  }

  //get请求
  Future<HttpJsonRes> post(String url, Map<String, dynamic> params) async {
    Future future = _dio.post(url, queryParameters: params);
    return future;
  }

  PackageInfo packageinfo;

//get请求
  Future<HttpJsonRes> requestJson(
    bool isGet,
    String url,
    Map<String, dynamic> params, {
    Map<String, dynamic> headers,
    FormData formData,
    data,
    bool needToken = false,
    bool sendLanguageType = true,
    bool headerSignatureUrlBody = false,
  }) async {
    if (packageinfo == null) packageinfo = await PackageInfo.fromPlatform();

    HttpJsonRes mHttpJsonRes = new HttpJsonRes();
    Response response;

    Map<String, dynamic> def_headers = {
      "Accept-Encoding": "gzip",
      "os": Platform.operatingSystem,
      //android ios ...
      "osversion": DeviceUtils().getSysVersion(),
      //系统版本
      "appversion": packageinfo?.version,
      //应用版本
      "appbuildnum": packageinfo.buildNumber,
      //编译序号(小版本号)
      "codeversion": code_version,
      //代码版本
      "manufacturer": DeviceUtils().getManufacturer(),
      //厂商
      "physical": DeviceUtils().isPhysicalDevice(),
      //是否为真实设备
      "deviceid": DeviceUtils().getDeviceId(),
      //设备ID，ios是uuid ，android是设备+应用签名的ID
      "devicename": DeviceUtils().getDeviceName(),
      //设备名
    };

    def_headers.forEach((key, value) {
      // print(key);
      // print(value);
      if (value != null && RegExpUtil.re_ascii_00_7f_not.hasMatch(value.toString())) {
        def_headers[key] = Uri.encodeFull(value); //非基础字符 转义
        // print("$value--->${def_headers[key]}");
      }
    });

    // if (needToken) {
    //   if (StringUtils.isNotEmpty(AccountMgr().currentAccount.access_token)) {
    //     def_headers["token"] = AccountMgr().currentAccount.access_token;
    //   } else {
    //     print("httputils  requestJson  no token");
    //   }
    // }

    if (sendLanguageType) {
      // language:zh-cn
      def_headers["language"] = LocaleConfig.currentIsZh() ? "zh-cn" : "en-us";
    }

    if (headers != null && headers.length > 0) {
      def_headers.addEntries(headers.entries);
    }

    if (headerSignatureUrlBody && AccountMgr()?.currentAccount?.epik_EPK_address != null) {
      try {
        String urlpath = "";
        Uri _uri = Uri.tryParse(url);
        urlpath = _uri.path;
        if(_uri.hasQuery)
          urlpath+="?"+_uri.query;
        String text = urlpath;
        if(text.startsWith("/api"))
          text=text.substring(4);
        // print(text);
        if (!isGet && data != null && data is String) {
          text += "\n" + data;
        }
        Digest digest = sha256.convert(utf8.encode(text));
        String epik_address = AccountMgr()?.currentAccount?.epik_EPK_address;
        Uint8List epik_signature_byte =
            await AccountMgr()?.currentAccount?.epikWallet?.sign(epik_address, Uint8List.fromList(digest.bytes));
        String epik_signature = hex.encode(epik_signature_byte);
        def_headers["signature"] = epik_signature;
        def_headers["address"] = epik_address;
      } catch (e, s) {
        print(e);
        print(s);
      }
    }

    print("def_headers=$def_headers");

    Options options = Options(headers: def_headers);
    print("options=$options");

    try {
      if (isGet) {
        print("httputils get=" + url + "  params=" + params.toString() + "  headers=" + def_headers.toString());
        response = await _dio.get(url, queryParameters: params, options: options);
      } else {
        print("httputils post=" +
            url +
            "  headers=" +
            headers.toString() +
            "  params=" +
            params.toString() +
            " formData=" +
            formData.toString() +
            " data=" +
            data?.toString());

        if (params != null) {
          params.keys.forEach((key) {
            var v = params[key];
            if (v != null && v is String) {
              params[key] = v.replaceAll("\n", "\\n");
            }
          });
        }
        response = await _dio.post(url, data: formData ?? data, queryParameters: params, options: options);

        print("response code=" + response.statusCode.toString());
      }
    } catch (err) {
      print("http error $err");

      try {
        if (err is DioError) {
          print("http error DioError ${err.type}");
          response = err.response;
          if (err.type == DioErrorType.cancel) {
//            print("---请求取消---");
            mHttpJsonRes.code = -3; //取消
            mHttpJsonRes.msg = RSID.cancel_request.text; //"取消请求";
            // UmengAnalyticsPlugin.event("DioErrorType.CANCEL",label:"$err\n${isGet?"Get":"Post"}=$url headers=${getReportHeader(def_headers)?.toString()}");
          } else if (err.type == DioErrorType.response) {
            mHttpJsonRes.code = -2; //404, 503
            mHttpJsonRes.msg = RSID.request_error.text + (response?.statusCode?.toString() ?? ""); //"请求错误";
            // UmengAnalyticsPlugin.event("DioErrorType.RESPONSE",label:"$err\n${isGet?"Get":"Post"}=$url headers=${getReportHeader(def_headers)?.toString()}");
          } else if (err.type == DioErrorType.connectTimeout ||
              err.type == DioErrorType.receiveTimeout ||
              err.type == DioErrorType.sendTimeout) {
            mHttpJsonRes.code = -2; //超时
            mHttpJsonRes.msg = RSID.connect_timeout.text; //"连接超时";
            // UmengAnalyticsPlugin.event("DioErrorType.CONNECT_TIMEOUT",label:"$err\n${isGet?"Get":"Post"}=$url headers=${getReportHeader(def_headers)?.toString()}");
          } else {
            //DioErrorType.DEFAULT;
            // UmengAnalyticsPlugin.event("DioErrorType.DEFAULT",label:"$err\n${isGet?"Get":"Post"}=$url headers=${getReportHeader(def_headers)?.toString()}");
            DioError dioerror = err;
            print("dioerror.message = ${dioerror.message}");
            if (dioerror?.error != null) {
              if (dioerror?.error is SocketException) {
                mHttpJsonRes.code = -2; //断网的情况
                mHttpJsonRes.msg = RSID.network_exception.text; //"网络异常";
                SocketException socketexception = dioerror?.error;
                if (socketexception?.osError != null) //Network is unreachable
                {
                  mHttpJsonRes.msg = socketexception?.osError?.message ?? mHttpJsonRes.msg;
                }
              }
            }
          }
        } else if (err is SocketException) {
          // UmengAnalyticsPlugin.event("SocketException",label:"$err\n${isGet?"Get":"Post"}=$url headers=${getReportHeader(def_headers)?.toString()}");
          mHttpJsonRes.code = -2; //网络异常
          mHttpJsonRes.msg = RSID.network_exception.text; //"网络异常"; else {
          mHttpJsonRes.code = -1; //请求错误
          mHttpJsonRes.msg = RSID.request_error.text; //"请求错误";
        } else {
          // UmengAnalyticsPlugin.event("other",label:"$err\n${isGet?"Get":"Post"}=$url headers=${getReportHeader(def_headers)?.toString()}");
        }
      } catch (err2) {
        // UmengAnalyticsPlugin.event(err2?.runtimeType?.toString()??"error",label:"$err2\n${isGet?"Get":"Post"}=$url headers=${getReportHeader(def_headers)?.toString()}");
        mHttpJsonRes.code = -2; //网络异常
        mHttpJsonRes.msg = RSID.network_exception_retry.text; //"网络异常,请稍后重试";
      }
    }

    Dlog.p("httputils", "httputils response=" + response.toString() + "  from=" + url, printAll: true);

    if (response != null) {
      mHttpJsonRes.httpStatusCode = response.statusCode;
      mHttpJsonRes.httpStatusMessage = response.statusMessage;
    }

    if (response?.data != null) {
      try {
        if (response.data is String) {
          print("requestJson ---- string = ${response.data}");
          String ddd = response.data;
          ddd = ddd.replaceAll("\n", "\\n");
          mHttpJsonRes.jsonMap = jsonDecode(ddd);
        } else if (response.data is List) {
          print("requestJson ---- list");
          mHttpJsonRes.jsonMap = Map<String, dynamic>();
          mHttpJsonRes.jsonMap["code"] = "0";
          mHttpJsonRes.jsonMap["data"] = response.data;
        } else {
          print("requestJson ---- data");
          mHttpJsonRes.jsonMap = response.data;
        }
      } catch (e) {
        print("requestJson error---------");
        print(e);
        mHttpJsonRes.jsonMap = null;
      }
    }

    if (mHttpJsonRes.jsonMap != null) {
      var code = mHttpJsonRes.jsonMap["code"] ?? mHttpJsonRes.jsonMap["Code"];
      if (code is Map) {
        mHttpJsonRes.code = StringUtils.parseInt(StringUtils.parseString(code["code"] ?? code["Code"], ""), -1);
        mHttpJsonRes.msg = StringUtils.parseString(code["message"] ?? code["Message"], "");
      } else {
        mHttpJsonRes.code = -1;
        mHttpJsonRes.msg = "";
      }
    } else {
      if (mHttpJsonRes.msg.isEmpty) {
        mHttpJsonRes.code = -1; //请求错误
        mHttpJsonRes.msg = RSID.request_error.text; //"请求错误";
      }
    }

    return mHttpJsonRes;
  }
}

Map<String, dynamic> getReportHeader(Map<String, dynamic> def_headers) {
  if (def_headers == null) return {};

  Map<String, dynamic> ret = {
    // "os": Platform.operatingSystem,
    //android ios ...
    // "osversion": DeviceUtils().getSysVersion(),
    //系统版本
    // "manufacturer": DeviceUtils().getManufacturer(),
    //厂商
    "appversion": def_headers["appversion"], //应用版本
    "appbuildnum": def_headers["appbuildnum"], //编译序号(小版本号)
    "codeversion": def_headers["codeversion"], //代码版本
    "physical": def_headers["physical"], //是否为真实设备
    // "deviceid": def_headers["deviceid"], //设备ID，ios是uuid ，android是设备+应用签名的ID
    // "devicename": DeviceUtils().getDeviceName(),
    //设备名
  };
  return ret;
}

class HttpJsonRes {
  int code = 0;
  String msg = "";
  Map<String, dynamic> jsonMap;

  int httpStatusCode;
  String httpStatusMessage;
}
