import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:epikwallet/localstring/LocaleConfig.dart';
import 'package:epikwallet/localstring/resstringid.dart';
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

  Future<Response> getData() async {
    String url = "http://v.juhe.cn/toutiao/index";
    String key = "4c52313fc9247e5b4176aed5ddd56ad7";
    String type = "keji";

    print("开始请求数据");
    Response response =
        await Dio().get(url, queryParameters: {"type": type, "key": key});

    print("请求完成");

    return response;
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
  }) async {
    if (packageinfo == null) packageinfo = await PackageInfo.fromPlatform();

    HttpJsonRes mHttpJsonRes = new HttpJsonRes();
    Response response;

    Map<String, dynamic> def_headers = {
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
      if (value != null &&
          RegExpUtil.re_ascii_00_7f_not.hasMatch(value.toString())) {
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
    print("def_headers=$def_headers");

    RequestOptions options = RequestOptions(headers: def_headers);
    print("options=$options");

    try {
      if (isGet) {
        print("httputils get=" +
            url +
            "  params=" +
            params.toString() +
            "  headers=" +
            def_headers.toString());
        response =
            await _dio.get(url, queryParameters: params, options: options);
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
        response = await _dio.post(url,
            data: formData ?? data, queryParameters: params, options: options);

        print("response code=" + response.statusCode.toString());
      }
    } catch (err) {
      print("http error $err");
      try {
        if (err is DioError) {
          if (err.type == DioErrorType.CANCEL) {
//            print("---请求取消---");
            mHttpJsonRes.code = -3; //取消
            mHttpJsonRes.msg = RSID.cancel_request.text;//"取消请求";
          } else if (err.type == DioErrorType.CONNECT_TIMEOUT ||
              err.type == DioErrorType.RECEIVE_TIMEOUT) {
            mHttpJsonRes.code = -2; //超时
            mHttpJsonRes.msg = RSID.connect_timeout.text;//"连接超时";
          }
        } else if (err is SocketException) {
          mHttpJsonRes.code = -2; //网络异常
          mHttpJsonRes.msg = RSID.network_exception.text;//"网络异常";
        } else {
          mHttpJsonRes.code = -1; //请求错误
          mHttpJsonRes.msg = RSID.request_error.text;//"请求错误";
        }
      } catch (err2) {
        mHttpJsonRes.code = -2; //网络异常
        mHttpJsonRes.msg = RSID.network_exception_retry.text;//"网络异常,请稍后重试";
      }
    }

    Dlog.p("httputils",
        "httputils response=" + response.toString() + "  from=" + url,
        printAll: true);

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
      var code = mHttpJsonRes.jsonMap["code"];
      if (code is Map) {
        mHttpJsonRes.code =
            StringUtils.parseInt(StringUtils.parseString(code["code"], ""), -1);
        mHttpJsonRes.msg = StringUtils.parseString(code["message"], "");
      } else {
        mHttpJsonRes.code = -1;
        mHttpJsonRes.msg = "";
      }
    } else {
      if (mHttpJsonRes.msg.isEmpty) {
        mHttpJsonRes.code = -1; //请求错误
        mHttpJsonRes.msg = RSID.request_error.text;//"请求错误";
      }
    }

    return mHttpJsonRes;
  }
}

class HttpJsonRes {
  int code = 0;
  String msg = "";
  Map<String, dynamic> jsonMap;

  int httpStatusCode;
  String httpStatusMessage;
}
