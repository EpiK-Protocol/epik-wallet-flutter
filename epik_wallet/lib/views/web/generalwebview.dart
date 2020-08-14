import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';


class GeneralWebView extends BaseWidget {
  String title;
  String url;

  GeneralWebView(this.title, this.url) {
    print(url);
  }

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _GeneralWebViewState();
  }
}

class _GeneralWebViewState extends BaseWidgetState<GeneralWebView> {
  initStateConfig() {
    isTopBarShow = true; //状态栏是否显示
    isAppBarShow = true; //导航栏是否显示
    setAppBarTitle(widget.title);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: getWebView2(),
    );
  }

//  Widget getWebView() {
//    return WebView(
//      initialUrl: widget.url,
//      //JS运行模式
//      javascriptMode: JavascriptMode.unrestricted,
//      // 请求拦截器
//      navigationDelegate: (NavigationRequest request) {
//        if (request.url.startsWith("http")) {
//          //不需要拦截的操作
//          dlog("WebView -> navigate -> " + request.url);
////            Application.push(context, request.url);
//          return NavigationDecision.navigate;
//        }
//        // 拦截不认识的请求
//        dlog("WebView -> prevent -> " + request.url);
//        return NavigationDecision.prevent;
//      },
//      onWebViewCreated: (WebViewController webViewController) {
//        dlog("onWebViewCreated " + webViewController.toString());
//      },
//    );
//  }

  Widget getWebView2() {
    return InAppWebView(
      initialUrl: widget.url,
//      contextMenu: contextMenu,
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          debuggingEnabled: kReleaseMode?false:true, // release模式下 没有日志,
        ),
      ),
      onWebViewCreated: (InAppWebViewController controller) {
//        _webViewController = controller;
      },
    );
  }

  SystemUiOverlayStyle last;

  @override
  void onCreate() {
    // TODO: implement onCreate
    dlog("onCreate");
    last = DeviceUtils.system_bar_current;
    DeviceUtils.setSystemBarStyle(DeviceUtils.system_bar_light);
  }

  @override
  void dispose() {
    DeviceUtils.setSystemBarStyle(last);
    super.dispose();
  }

  @override
  void onPause() {
    // TODO: implement onPause
    dlog("onPause");
  }

  @override
  void onResume() {
    // TODO: implement onResume
    dlog("onResume");
  }
}
