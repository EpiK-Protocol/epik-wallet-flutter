import 'dart:convert';
import 'dart:io';

import 'package:epikwallet/utils/string_utils.dart';
import 'package:dio/dio.dart';

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

//get请求
  Future<HttpJsonRes> requestJson(
      bool isGet, String url, Map<String, dynamic> params,
      {Map<String, dynamic> headers,
      FormData formData,
        data,
      bool needToken = false}) async {
    HttpJsonRes mHttpJsonRes = new HttpJsonRes();
    Response response;

    Map<String, dynamic> def_headers = Map();

//    if (needToken) {
//      if (StringUtils.isNotEmpty(AccountMgr().currentAccount.access_token)) {
//        def_headers["token"] = AccountMgr().currentAccount.access_token;
//      } else {
//        print("httputils  requestJson  no token");
//      }
//    }

    if (headers != null && headers.length > 0) {
      def_headers.addEntries(headers.entries);
      print("def_headers=$def_headers");
    }

    Options options = Options(headers: def_headers);
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
            formData.toString());

        if (params != null) {
          params.keys.forEach((key) {
            var v = params[key];
            if (v != null && v is String) {
              params[key] = v.replaceAll("\n", "\\n");
            }
          });
        }
        response = await _dio.post(url,
            data: formData??data, queryParameters: params, options: options);

        print("response code="+response.statusCode.toString());
      }
    } catch (err) {
      print("http error $err");
      try {
        if (err is DioError) {
          if (err.type == DioErrorType.CANCEL) {
//            print("---请求取消---");
            mHttpJsonRes.code = -3; //取消
            mHttpJsonRes.msg = "取消请求";
          } else if (err.type == DioErrorType.CONNECT_TIMEOUT ||
              err.type == DioErrorType.RECEIVE_TIMEOUT) {
            mHttpJsonRes.code = -2; //超时
            mHttpJsonRes.msg = "连接超时";
          }
        } else if (err is SocketException) {
          mHttpJsonRes.code = -2; //网络异常
          mHttpJsonRes.msg = "网络异常";
        } else {
          mHttpJsonRes.code = -1; //请求错误
          mHttpJsonRes.msg = "请求错误";
        }
      } catch (err2) {
        mHttpJsonRes.code = -2; //网络异常
        mHttpJsonRes.msg = "网络异常,请稍后重试";
      }
    }

    print("httputils response=" + response.toString() + "  from="+url);

    if (response != null && response.data != null) {
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
      if (mHttpJsonRes.jsonMap.length == 1 &&
          mHttpJsonRes.jsonMap.containsKey("data")) {
        var ddd = mHttpJsonRes.jsonMap["data"];
        if (ddd != null && ddd is Map<String, dynamic>) {
          if (ddd.containsKey("code") && ddd.containsKey("msg")) {
            mHttpJsonRes.jsonMap = ddd;
          }
        }
      }

      var code = mHttpJsonRes.jsonMap["code"];
      if (code is String) {
        mHttpJsonRes.code = int.parse(code);
      } else {
        mHttpJsonRes.code = code;
      }

      if (mHttpJsonRes.jsonMap.containsKey("msg")) {
        mHttpJsonRes.msg = StringUtils.def(mHttpJsonRes.jsonMap["msg"], "");
      }else if(mHttpJsonRes.jsonMap.containsKey("message")) {
        mHttpJsonRes.msg = StringUtils.def(mHttpJsonRes.jsonMap["message"], "");
      }
      if (mHttpJsonRes.msg.isEmpty && mHttpJsonRes.code != 0) {
        mHttpJsonRes.msg = "code : ${mHttpJsonRes.code}";
      }
    } else {
      if (mHttpJsonRes.msg.isEmpty) {
        mHttpJsonRes.code = -1; //请求错误
        mHttpJsonRes.msg = "请求错误";
      }
    }

    return mHttpJsonRes;
  }
}

class HttpJsonRes {
  int code = 0;
  String msg = "";
  Map<String, dynamic> jsonMap;
}
