import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:epikwallet/widget/text/BlinkTextView.dart';
// import 'package:webview_flutter/webview_flutter.dart' as wf;

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
  // wf.WebViewController _wfWebViewController = null;

  bool webview_reload_btn = false;
  bool clearCache = false;

  int loadprogress = 0;

  initStateConfig() {
    isTopBarShow = true; //状态栏是否显示
    isAppBarShow = true; //导航栏是否显示
    setAppBarTitle(widget.title);

    weburl = widget.url;
    dlog(weburl);
    weburl_uri = Uri.tryParse(weburl);
  }

  Widget getAppBarCenter({Color color}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: Text(
        appBarTitle,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: appBarCenterTextSize - 4,
          color: color ?? appBarContentColor,
        ),
      ),
    );
  }


  Widget getAppBarRight({Color color}) {
    if (webview_reload_btn == true) {
      return InkWell(
        onTap: () {
          if (_webViewController != null) {
            _webViewController.reload();
          }
          // else if (_wfWebViewController != null) {
            // _wfWebViewController.reload();
          // }
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
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        width: 24.0 + 20 + 20,
        height: getAppBarHeight(),
        // child: Icon(
        //   OMIcons.arrowBackIos,
        //   color: color ?? _appBarContentColor,
        //   size: 20,
        // ),
        child: Center(
          child: Image.asset(
            "assets/img/ic_back.png",
            width: 24,
            height: 24,
            color: color ?? appBarContentColor,
          ),
        ),
      ),
    );
  }

  void clickAppBarBack() async {
    // finish();
    if (_webViewController != null && await _webViewController.canGoBack()) {
      _webViewController.goBack();
    }
    // else if (_wfWebViewController != null &&
    //     await _wfWebViewController.canGoBack()) {
    //   _wfWebViewController.goBack();
    // }
    else {
      finish();
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    Widget w = Container(
      width: double.infinity,
      height: double.infinity,
      // color: Colors.white,
      // child: GestureDetector(
      //   onTapDown: (event) {}, //虽然看着没啥用 但是解决 多指滑动报错问题 （android 8.1以下）
      //   child: (GeneralWebView.useWF) ? getWebView() : getWebView2(),
      // ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: (GeneralWebView.useWF) ? getWebView() : getWebView2(),
          ),
          if(loadprogress <100)
            Positioned(
              child:Scaffold(
                backgroundColor: ResColor.b_1,
                body: Center(
                  child: BlinkTextView("Loading..."),
                ),
              ),
            ),
          if (loadprogress > 0 && loadprogress < 100)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                height: 2,
                child: LinearPercentIndicator(
                  lineHeight: 2,
                  animation: true,
                  animationDuration: 200,
                  animateFromLastPercent: true,
                  // restartAnimation: true,
                  percent: loadprogress/100,
                  center: Text(""),
                  padding: EdgeInsets.only(
                    left: 2.5,
                    right: 2.5,
                  ),
                  backgroundColor: ResColor.black_10,
                  linearStrokeCap: LinearStrokeCap.roundAll,
                  // progressColor: const Color(0xff57B836),
                  linearGradient: ResColor.lg_1,
                ),
              ),
            ),
        ],
      ),
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
    // return wf.WebView(
    //   initialUrl: weburl,
    //   //JS运行模式
    //   javascriptMode: wf.JavascriptMode.unrestricted,
    //   // 请求拦截器
    //   navigationDelegate: (wf.NavigationRequest request) {
    //     // print("NavigationRequest request ${request}");
    //     //不需要拦截的操作
    //     dlog("WebView -> navigate -> ${request?.url}");
    //     if (request?.url != null) {
    //       String url = request.url;
    //       Dlog.p("webview", "onShouldOverrideUrlLoadingurl=$url");
    //       bool isHandle = false;
    //       try {
    //         // isHandle = SchemeLink.schemeUrl(context, url, autoWeb: false);
    //         isHandle = !url.startsWith("http");
    //       } catch (e) {
    //         print(e);
    //       }
    //       if (isHandle) {
    //         return wf.NavigationDecision.prevent; //拦截url 自行处理
    //       }
    //     }
    //     // 其他请求
    //     dlog("WebView -> prevent -> ${request?.url}");
    //     return wf.NavigationDecision.navigate;
    //   },
    //   onWebViewCreated: (wf.WebViewController webViewController) {
    //     dlog("onWebViewCreated " + webViewController.toString());
    //     _wfWebViewController = webViewController;
    //   },
    // );
  }

  Widget getWebView2() {
    return InAppWebView(
      // initialUrl: weburl,
      initialUrlRequest: URLRequest(url: weburl_uri),
//      contextMenu: contextMenu,
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          transparentBackground: true, //网页透明背景
          // debuggingEnabled: kReleaseMode ? false : true, // release模式下 没有日志,
          clearCache: clearCache, //自动清理缓存
          useShouldOverrideUrlLoading:
              true, //开启url拦截 配合shouldOverrideUrlLoading
        ),
        android: AndroidInAppWebViewOptions(
          useHybridComposition: true, //DeviceUtils().androidQ,
          mixedContentMode: AndroidMixedContentMode
              .MIXED_CONTENT_ALWAYS_ALLOW, //https的网站可以加载http的资源
        ),
      ),
      onWebViewCreated: (InAppWebViewController controller) {
        _webViewController = controller;
      },
      shouldOverrideUrlLoading: onShouldOverrideUrlLoading,
      onProgressChanged: (controller, progress) {
        dlog("onProgressChanged progress=$progress");
        setState(() {
          loadprogress=progress;
        });
      },
    );
  }

  // SystemUiOverlayStyle last;

  @override
  void onCreate() {
    // TODO: implement onCreate
    dlog("onCreate");
    // last = DeviceUtils.system_bar_current;
    // DeviceUtils.setSystemBarStyle(DeviceUtils.system_bar_dark);
  }

  @override
  void dispose() {
    // DeviceUtils.setSystemBarStyle(last);
    if (_webViewController != null) {
      if (clearCache == true) _webViewController.clearCache();
      _webViewController = null;
    }
    // if (_wfWebViewController != null) {
    //   if (clearCache == true) _wfWebViewController.clearCache();
    //   _wfWebViewController = null;
    // }
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
    }
    // else if (_wfWebViewController != null &&
    //     await _wfWebViewController.canGoBack()) {
    //   _wfWebViewController.goBack();
    //   return false;
    // }
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
