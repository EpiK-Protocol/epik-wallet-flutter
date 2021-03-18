import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:webview_flutter/webview_flutter.dart' as wf;


class GeneralWebView extends BaseWidget {

  static bool useWF = false;

  String title;
  String url;

  GeneralWebView(this.title, this.url) {
    Dlog.p("httputils", url);
  }

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _GeneralWebViewState();
  }
}

class _GeneralWebViewState extends BaseWidgetState<GeneralWebView> {

  String weburl = "";
  Uri weburl_uri = null;

  InAppWebViewController _webViewController = null;
  wf.WebViewController _wfWebViewController = null;

  bool webview_reload_btn = false;
  bool clearCache = false;

  initStateConfig() {
    isTopBarShow = true; //状态栏是否显示
    isAppBarShow = true; //导航栏是否显示
    setAppBarTitle(widget.title);

    weburl = widget.url;
    dlog(weburl);
    weburl_uri = Uri.tryParse(weburl);
  }

  Widget getAppBarRight({Color color}) {
    if (webview_reload_btn == true) {
      return InkWell(
        onTap: () {
          if (_webViewController != null) {
            _webViewController.reload();
          } else if (_wfWebViewController != null) {
            _wfWebViewController.reload();
          }
        },
        child: Container(
          width: getAppBarHeight() * 0.8,
          height: getAppBarHeight(),
          child: Icon(
            Icons.refresh_outlined,
            color: color ?? Colors.black,
            size: 20,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  ///导航栏appBar左边部分 ，不满足可以自行重写
  Widget getAppBarLeft({Color color}) {
    return InkWell(
      onTap: clickAppBarBack,
      onLongPress: () {
        finish();
      },
      child: Container(
        width: getAppBarHeight() * 0.8,
        height: getAppBarHeight(),
        child: Icon(
          OMIcons.arrowBackIos,
          color: color ?? Colors.black,
          size: 20,
        ),
      ),
    );
  }

  void clickAppBarBack() async {
    // finish();
    if (_webViewController != null && await _webViewController.canGoBack()) {
      _webViewController.goBack();
    } else if (_wfWebViewController != null &&
        await _wfWebViewController.canGoBack()) {
      _wfWebViewController.goBack();
    } else {
      finish();
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    Widget w = Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: GeneralWebView.useWF ? getWebView() : getWebView2(),
    );
    return WillPopScope(
      onWillPop: () async {
        bool childCanPop = await onWillPop();
        return childCanPop;
      },
      child: w,
    );
  }

 Widget getWebView() {
   return wf.WebView(
     initialUrl: weburl,
     //JS运行模式
     javascriptMode: wf.JavascriptMode.unrestricted,
     // 请求拦截器
     navigationDelegate: (wf.NavigationRequest request) {
       print("cccmax NavigationRequest request ${request}");
       //不需要拦截的操作
       dlog("WebView -> navigate -> ${request?.url}");
       if (request?.url != null) {
         String url = request.url;
         Dlog.p("webview", "onShouldOverrideUrlLoadingurl=$url");
         bool isHandle = false;
         try {
           // isHandle = SchemeLink.schemeUrl(context, url, autoWeb: false);
           isHandle = !url.startsWith("http");
         } catch (e) {
           print(e);
         }
         if (isHandle) {
           return wf.NavigationDecision.prevent; //拦截url 自行处理
         }
       }
       // 其他请求
       dlog("WebView -> prevent -> ${request?.url}");
       return wf.NavigationDecision.navigate;
     },
     onWebViewCreated: (wf.WebViewController webViewController) {
       dlog("onWebViewCreated " + webViewController.toString());
       _wfWebViewController = webViewController;
     },
   );
 }

  Widget getWebView2() {
    return InAppWebView(
      // initialUrl: weburl,
      initialUrlRequest: URLRequest(url: weburl_uri),
//      contextMenu: contextMenu,
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          // debuggingEnabled: kReleaseMode ? false : true, // release模式下 没有日志,
          clearCache:clearCache, //自动清理缓存
          useShouldOverrideUrlLoading:
          true, //开启url拦截 配合shouldOverrideUrlLoading
        ),
        android: AndroidInAppWebViewOptions(
          useHybridComposition: true,//DeviceUtils().androidQ,
          mixedContentMode: AndroidMixedContentMode
              .MIXED_CONTENT_ALWAYS_ALLOW, //https的网站可以加载http的资源
        ),
      ),
      onWebViewCreated: (InAppWebViewController controller) {
        _webViewController = controller;
      },
      shouldOverrideUrlLoading: onShouldOverrideUrlLoading,
    );
  }

  SystemUiOverlayStyle last;

  @override
  void onCreate() {
    // TODO: implement onCreate
    dlog("onCreate");
    last = DeviceUtils.system_bar_current;
    DeviceUtils.setSystemBarStyle(DeviceUtils.system_bar_dark);
  }

  @override
  void dispose() {
    DeviceUtils.setSystemBarStyle(last);
    if (_webViewController != null) {
      if (clearCache == true) _webViewController.clearCache();
      _webViewController = null;
    }
    if (_wfWebViewController != null) {
      if (clearCache == true) _wfWebViewController.clearCache();
      _wfWebViewController = null;
    }
    super.dispose();
  }

  @override
  void onPause() {
    super.onPause();
  }

  @override
  void onResume() {
    super.onResume();
  }

  @override
  Future<bool> onWillPop() async {
    if (_webViewController != null && await _webViewController.canGoBack()) {
      _webViewController.goBack();
      return false;
    } else if (_wfWebViewController != null &&
        await _wfWebViewController.canGoBack()) {
      _wfWebViewController.goBack();
      return false;
    }
    return true;
  }

  Future<NavigationActionPolicy> onShouldOverrideUrlLoading(
      InAppWebViewController controller,
      NavigationAction navigationAction) async {
    Dlog.p("webview",
        "onShouldOverrideUrlLoading  request= ${navigationAction?.toString()}");
    if (navigationAction?.request?.url != null) {
      String url = navigationAction.request.url.toString();
      Dlog.p("webview", "onShouldOverrideUrlLoadingurl=$url");
      bool isHandle = false;
      try {
        // isHandle = SchemeLink.schemeUrl(context, url, autoWeb: false);
        isHandle = !url.startsWith("http");
      } catch (e) {
        print(e);
      }
      // Dlog.p("webview","isHandle=$isHandle");
      if (isHandle) {
        return NavigationActionPolicy.CANCEL; //拦截url 自行处理
      }
    }
    return NavigationActionPolicy.ALLOW; //用webview打开,不拦截url
  }
}
