import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/PopMenuDialog.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/loading_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_AIBot.dart';
import 'package:epikwallet/logic/loader/DL_TepkLoginToken.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/model/AIBotApp.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/ClickUtil.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/EnumEx.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/aibot/AIBotBillsView.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/rect_getter.dart';
import 'package:epikwallet/widget/text/BlinkTextView.dart';
import 'package:epikwallet/widget/text/diff_scale_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:synchronized/synchronized.dart';
import 'package:url_launcher/url_launcher.dart';

class AIBotWebView extends BaseWidget {
  AIBotApp aibotapp;
  String wallet_id;
  String wallet_token;

  String get title {
    return aibotapp.name;
  }

  String get url {
    return aibotapp.url;
  }

  int get ai_bot_id {
    return aibotapp.id;
  }

  AIBotWebView(
    this.aibotapp, {
    this.wallet_id,
    this.wallet_token,
  }) {
    // Dlog.p("AIBotWebView", "$title  $url  $ai_bot_id $wallet_token");

    // this.aibotapp.url = "http://192.168.31.204:62638/";//todo test
  }

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _AIBotWebViewState();
  }
}

class _AIBotWebViewState extends BaseWidgetState<AIBotWebView> with TickerProviderStateMixin {
  String weburl = "";
  Uri weburl_uri = null;

  Uri current_url = null;

  InAppWebViewController _webViewController = null;

  bool webview_reload_btn = true;
  bool clearCache = false;

  int loadprogress = 0;

  bool isInjectedSource = false;

  //顶部使用渐变色
  bool useGradientTop = true;

  String get wallet_id {
    if (widget.wallet_id != null) return widget.wallet_id;
    return AccountMgr().currentAccount.mining_id;
  }

  String get wallet_token {
    if (widget.wallet_token != null) return widget.wallet_token;
    return DL_TepkLoginToken?.getEntity()?.getToken();
  }

  initStateConfig() {
    isTopBarShow = true; //状态栏是否显示
    isAppBarShow = true; //导航栏是否显示
    setAppBarTitle(widget.title);

    if (DeviceUtils.isDebug && DeviceUtils.isAndroid) {
      //chrome://inspect/#devices
      AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
    }

    weburl = widget.url;
    dlog(weburl);
    weburl_uri = Uri.tryParse(weburl);

    resizeToAvoidBottomPadding = true;

    if (ApiAIBot.ai_bot_recharge_config == null) ApiAIBot.getRechargeConfig();

    loadPoint();
  }

  Widget getTopBar() {
    if (useGradientTop)
      return Container(
        height: getTopBarHeight(),
        width: double.infinity,
        // color: topBarColor,
        decoration: BoxDecoration(
          gradient: ResColor.lg_1_1,
        ),
      );

    return super.getTopBar();
  }

  ///导航栏 appBar 可以重写
  Widget getAppBar() {
    if (useGradientTop)
      return Container(
        height: getAppBarHeight(),
        width: double.infinity,
        // color: appBarColor,
        decoration: BoxDecoration(
          gradient: ResColor.lg_1_1,
        ),
        child: Stack(
          alignment: FractionalOffset(0, 0.5),
          children: <Widget>[
            Align(
              alignment: FractionalOffset(0.5, 0.5),
              child: getAppBarCenter(),
            ),
            Align(
              //左边返回导航 的位置，可以根据需求变更
              alignment: FractionalOffset(0, 0.5),
              child: Offstage(
                offstage: false,
                child: getAppBarLeft(),
              ),
            ),
            Align(
              alignment: FractionalOffset(0.98, 0.5),
              child: getAppBarRight(),
            ),
          ],
        ),
      );

    return super.getAppBar();
  }

  ///导航栏appBar中间部分 ，不满足可以自行重写
  Widget getAppBarCenter({Color color}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(100, 0, 100, 0),
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

  GlobalKey key_btn_menu = RectGetter.createGlobalKey();

  // 返回账号点数
  num getPointsNum() {
    return AccountMgr()?.currentAccount?.aibot_point;
  }

  Future loadPoint() async {
    WalletAccount wa = AccountMgr()?.currentAccount;
    if (wa?.isCompleteWallet == true) {
      await EpikWalletUtils.requestAiBotPoint(wa);
    }
  }

  eventcallback_point(arg) {
    if (arg != AccountMgr().currentAccount) return;
    setState(() {});
  }

  Widget getAppBarRight({Color color}) {
    if (webview_reload_btn == true) {
      Widget ret = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
            child: DiffScaleText(
              text: "${StringUtils.formatNumAmount(getPointsNum())}",
              textStyle: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontFamily: "DIN_Condensed_Bold",
              ),
            ),
          ),
          // InkWell(
          //   child:
          //   onTap: onClickMenu,
          // ),
          Container(
            key: key_btn_menu,
            width: 20,
            height: 50,
            child: Icon(
              Icons.more_vert,
              size: 20,
              color: color ?? appBarContentColor,
            ),
          ),
        ],
      );
      // return ret;
      return InkWell(
        child: ret,
        onTap: onClickMenu,
      );
    }
    return Container();
  }

  onClickMenu() {
    // _webViewController.webStorage.localStorage.getItems().then((List<WebStorageItem> list){
    //   print("WebStorageItem length ${list}");
    //   list.forEach((element) {print([element.key,element.value]);});
    // });

    loadPoint();

    Rect rect = RectGetter.getRectFromKey(key_btn_menu);
    List<BotWebMenu> menus = List.from(BotWebMenu.values);

    PopMenuDialog.show<BotWebMenu>(
      context: context,
      rect: rect,
      datas: menus,
      itemBuilder: (item, dialog) {
        Widget right = null;
        switch (item) {
          case BotWebMenu.REFRESH:
            break;
          case BotWebMenu.CLEARCACHE:
            break;
          case BotWebMenu.RECHARGE:
            break;
        }

        return InkWell(
          onTap: () {
            dialog?.dismiss();
            onClickMenuItem(item);
          },
          child: Container(
            // width: double.infinity,
            padding: EdgeInsets.fromLTRB(15, 10, 20, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.getName(),
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                if (right != null) right,
              ],
            ),
          ),
        );
      },
    );
  }

  onClickMenuItem(BotWebMenu item) async {
    switch (item) {
      case BotWebMenu.REFRESH:
        {
          _webViewController?.reload();
          loadPoint();
        }
        break;
      case BotWebMenu.CLEARCACHE:
        {
          _webViewController?.clearCache();
        }
        break;
      case BotWebMenu.RECHARGE:
        {
          onClickRecharge();
        }
        break;
    }
  }

  Future<String> getFavicon() async {
    String ico = null;
    try {
      List<Favicon> favicons = await _webViewController?.getFavicons();
      if (favicons != null && favicons.length > 0) {
        int size = -1;
        for (Favicon fav in favicons) {
          int _s = fav.width ?? 0;
          if (size < 0) {
            size = _s;
            ico = fav.url.toString();
          } else {
            if (_s > size) {
              ico = fav.url.toString();
            }
          }
        }
      }
    } catch (e, s) {
      print(s);
    }
    return ico;
  }

  ///导航栏appBar左边部分 ，不满足可以自行重写
  Widget getAppBarLeft({Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
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
        ),
      ],
    );
  }

  void clickAppBarBack() async {
    // finish();
    // _webViewController.getCopyBackForwardList().then((WebHistory webhistory) {
    //   print(webhistory);
    // });
    if (_webViewController != null && await _webViewController.canGoBack() && !await currentUrlIsFirst()) {
      dlog("back: goback");
      _webViewController.goBack();
    } else {
      finish();
      dlog("back: finish");
    }
  }

  Future<bool> currentUrlIsFirst() async {
    if (_webViewController == null) return true;
    WebHistory webhistory = await _webViewController.getCopyBackForwardList();
    dlog(webhistory.toString());
    if (webhistory == null) return true;
    int index = webhistory.currentIndex;
    WebHistoryItem webhistoryitem = webhistory.list[0];
    WebHistoryItem webhistoryitem_c = webhistory.list[index];
    if (webhistoryitem.originalUrl == webhistoryitem_c.originalUrl && webhistoryitem.url == webhistoryitem_c.url) {
      dlog(webhistoryitem.toString());
      dlog(webhistoryitem_c.toString());
      return true;
    } else {
      return false;
    }
    return true;
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
            child: getWebView2(),
          ),
          if (useGradientTop)
            Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: ResColor.lg_1_1,
                  ),
                )),
          if (loadprogress < 100 || _is_flutter_web_loading)
            Positioned(
              child: Scaffold(
                backgroundColor: ResColor.b_1,
                body: Center(
                  child: BlinkTextView("AI Bot Store"),
                ),
              ),
            ),
          if ((loadprogress > 0 && loadprogress < 100))
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
                  percent: loadprogress / 100,
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

  @override
  void onClickErrorWidget() async {
    setErrorWidgetVisible(false);
    _webViewController?.reload();
    setErrorWidgetVisible(false);
  }

  bool _is_flutter_web_loading = false;

  Future<bool> is_flutter_web_loading() async {
    bool ret = false;
    // List<MetaTag> metaList = await _webViewController?.getMetaTags();
    // if (metaList != null)
    //   for (MetaTag metatag in metaList) {
    //     if (metatag.name == "flutter_web_loading") {
    //       ret = StringUtils.parseBool(metatag.content, false);
    //       break;
    //     }
    //   }
    //
    // if (_is_flutter_web_loading != ret) {
    //   setState(() {});
    // }
    // _is_flutter_web_loading = ret;
    // dlog("flutter_web_loading=$ret");
    return ret;
  }

  Widget getWebView2() {
    dlog("getWebView2 --- 1");
    Widget webview = InAppWebView(
      // initialUrl: weburl,
      initialUrlRequest: URLRequest(url: weburl_uri),
//      contextMenu: contextMenu,
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          transparentBackground: true, //网页透明背景
          // debuggingEnabled: kReleaseMode ? false : true, // release模式下 没有日志,
          clearCache: clearCache, //自动清理缓存
          useShouldOverrideUrlLoading: true, //开启url拦截 配合shouldOverrideUrlLoading
          useOnDownloadStart: true, //允许下载文件
        ),
        android: AndroidInAppWebViewOptions(
          useHybridComposition: true, //DeviceUtils().androidQ,
          mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW, //https的网站可以加载http的资源
        ),
        ios: IOSInAppWebViewOptions(
            // disallowOverScroll: false,
            ),
      ),
      onWebViewCreated: (InAppWebViewController controller) {
        _webViewController = controller;
        _webViewController.addJavaScriptHandler(
          handlerName: "postMessage",
          callback: javaScriptHandler_postMessage,
        );
      },
      onLoadStart: (controller, url) {
        current_url = url;

        dlog("onLoadStart $url");
        isInjectedSource = false; //重新注入
        dlog("isInjectedSource = $isInjectedSource");
      },
      onLoadError: (controller, url, code, message) {
        dlog("onLoadError   $url  $code  $message");
        // -6
        // net::ERR_CONNECTION_RESET
        setErrorContent("The web page cannot be opened!\nCode=$code $message\nClick To Retry");
        setErrorWidgetVisible(true);
      },
      onLoadResource: (controller, resource) {
        dlog("LoadedResource ${resource.url}");
      },
      shouldOverrideUrlLoading: onShouldOverrideUrlLoading,
      onConsoleMessage: DeviceUtils.isDebug
          ? (controller, consoleMessage) {
              dlog("consoleMessage : ${consoleMessage.message}");
            }
          : null,
      onProgressChanged: (controller, progress) async {
        dlog("onProgressChanged progress=$progress");
        // controller.getUrl().then((value) {
        //   dlog("onProgressChanged progress=$progress url=$value");
        // });

        is_flutter_web_loading();

        setState(() {
          loadprogress = progress;
        });

        if (loadprogress >= 10 /*&& web3Client != null*/) {
          lock_jssource.synchronized(() async {
            if (isInjectedSource != true) {
              isInjectedSource = true;
              // await injectJS_source(_webViewController);
              // dlog("injectJS_source !!!!!!!!!!");
              injectJs_init(_webViewController);
              dlog("injectJs_init !!!!!!!!!!");
            }
          });
        }

        // if (loadprogress >= 50) {
        //   if (widget.lwo != null && StringUtils.isEmpty(widget.lwo.ico)) {
        //     controller.getUrl().then((cu) async {
        //       if (cu?.host == weburl_uri?.host) {
        //         dlog("find ico from " + weburl_uri?.host);
        //         String ico = await getFavicon();
        //         dlog("find ico = $ico");
        //         if (ico != null && StringUtils.isEmpty(widget.lwo.ico)) {
        //           widget.lwo.ico = ico;
        //           localwebsitemgr.save();
        //         }
        //       }
        //     });
        //   }
        // }
      },
      onTitleChanged: (controller, title) {
        controller.getUrl().then((cu) async {
          if (cu?.host != weburl_uri?.host) {
            setAppBarTitle(title);
          } else {
            setAppBarTitle(widget.title);
          }
        });
      },
      androidOnPermissionRequest: (controller, origin, resources) async {
        dlog("androidOnPermissionRequest origin=$origin resources=$resources");
        List<String> awplist = [];
        resources.forEach((element) {
          String str = AndroidWebPermission.getName(element);
          awplist.add(str);
        });
        String awps = awplist.join("\n");

        PermissionRequestResponseAction prra = null;

        YYDialog yydialog = MessageDialog.showMsgDialog(
          context,
          title: RSID.awp_permission_request.text,
          msg: "$origin\n${RSID.awp_ask.text}\n$awps",
          msgAlign: TextAlign.center,
          btnLeft: RSID.awp_deny.text,
          btnRight: RSID.awp_grant.text,
          backClose: false,
          touchOutClose: false,
          onClickBtnLeft: (dialog) {
            dialog.dismiss();
            prra = PermissionRequestResponseAction.DENY;
          },
          onClickBtnRight: (dialog) {
            dialog.dismiss();
            prra = PermissionRequestResponseAction.GRANT;
          },
        );

        int i = 60 * 5;
        while (prra == null) {
          // print(i);
          await Future.delayed(Duration(milliseconds: 200));
          i--;
          if (i <= 0) {
            if (yydialog?.isShowing) {
              yydialog?.dismiss();
            }
            break;
          }
        }

        PermissionRequestResponse ret =
            PermissionRequestResponse(resources: resources, action: prra ?? PermissionRequestResponseAction.DENY);
        return ret;
      },
      androidOnGeolocationPermissionsHidePrompt: (controller) {
        dlog("androidOnGeolocationPermissionsHidePrompt");
      },
      androidOnGeolocationPermissionsShowPrompt: (controller, origin) {
        dlog("androidOnGeolocationPermissionsShowPrompt $origin");
      },
      onDownloadStartRequest: (controller, DownloadStartRequest downloadStartRequest) {
        dlog("onDownloadStartRequest");
        print(downloadStartRequest);
      },
    );
    dlog("getWebView2 --- 2");
    return webview;
  }

  // SystemUiOverlayStyle last;

  @override
  void onCreate() {
    // TODO: implement onCreate
    dlog("onCreate");
    // last = DeviceUtils.system_bar_current;
    // DeviceUtils.setSystemBarStyle(DeviceUtils.system_bar_dark);
    eventMgr.add(EventTag.AI_BOT_POINT_UPDATE, eventcallback_point);
  }

  @override
  void dispose() {
    // DeviceUtils.setSystemBarStyle(last);
    eventMgr.remove(EventTag.AI_BOT_POINT_UPDATE, eventcallback_point);
    if (_webViewController != null) {
      if (clearCache == true) {
        _webViewController?.clearCache();
      }
      _webViewController = null;
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
    if (_webViewController != null && await _webViewController.canGoBack() && !await currentUrlIsFirst()) {
      _webViewController.goBack();
      return false;
    }
    return true;
  }

  Future<NavigationActionPolicy> onShouldOverrideUrlLoading(
      InAppWebViewController controller, NavigationAction navigationAction) async {
    Dlog.p("webview", "onShouldOverrideUrlLoading  request= ${navigationAction?.toString()}");
    if (navigationAction?.request?.url != null) {
      String url = navigationAction.request.url.toString();
      Dlog.p("webview", "onShouldOverrideUrlLoadingurl=$url");
      bool isHandle = false;
      try {
        // isHandle = !url.startsWith("http");
      } catch (e) {
        print(e);
      }
      if (isHandle) {
        return NavigationActionPolicy.CANCEL; //拦截url 自行处理
      }
    }
    return NavigationActionPolicy.ALLOW; //用webview打开,不拦截url
  }

  Lock lock_jssource = Lock();

  // Future injectJS_source(InAppWebViewController wvc) async {
  //   String jscodepath = "assets/js/trust-min_1.0.8.js"; //"assets/js/trust.js";
  //   String source_wallet = await rootBundle.loadString(jscodepath);
  //   String js = '''
  //   $source_wallet
  //   console.log("injectJS_source trustwallet=",trustwallet);
  //   ''';
  //   wvc.evaluateJavascript(source: js);
  // }

  String changeJsIdentifier(String text)
  {
    String ret= (text??"").replaceAll("'", "\\'");
    dlog("changeJsIdentifier = ${ret}");
    return ret;
  }

  Future injectJs_init(InAppWebViewController wvc) async {
    String js = '''
        (function(){
            console.log("js___ injectJs_init");
            console.log("js___ ",window);
       
        
            //定义epikwallet对象
            window.epikwallet={
        
                id:'${changeJsIdentifier(wallet_id)}',
                
                padding_bottom:'${MediaQuery.of(context).padding.bottom}',
                
                bot:{
                  id:${widget.ai_bot_id},          //int
                  name:'${changeJsIdentifier(widget.aibotapp.name)}',
                  description:'${changeJsIdentifier(widget.aibotapp.description)}',
                  description_en:'${changeJsIdentifier(widget.aibotapp.description_en)}',
                  icon:'${changeJsIdentifier(widget.aibotapp.icon)}',
                  hot: ${widget.aibotapp.hot},     //int
                  feature_cover: '${changeJsIdentifier(widget.aibotapp.feature_cover)}',  
                  feature_video: '${changeJsIdentifier(widget.aibotapp.feature_video)}',  
                },
                
                //向钱包浏览器发送消息 json:可序列化内容 
                sendMessage:async(json)=>{

                    console.log("sendMessage to wallet: ",json);

                    //等待浏览器webview注入的接口
                    var retry=100;
                    while(!window?.flutter_inappwebview?.callHandler && retry>0)
                    {
                        await new Promise((resolve) => setTimeout(resolve, 100));
                        retry--;
                        console.log("wait flutter_inappwebview",retry);

                    }
                    if(!window?.flutter_inappwebview?.callHandler)
                    {
                        console.log("sendMessage error: no callHandler");
                        return false;
                    }

                    //发送
                    jsonstr = JSON.stringify(json);
                    window.flutter_inappwebview.callHandler("postMessage",jsonstr);

                    console.log("sendMessage end");
                    return true;

                },
        
                //接收钱包浏览器发来的反馈，web需要自己重新赋值一个方法做接收 
                // int     id      发送消息时里面的id
                // string  method  发送消息时里面的method
                // string  message 浏览器反馈消息,也可能是json的字符串
                receiveResponse:(id, method, message)=>{
                    console.log("receiveResponse",id,message);
                },
        
            };
            
            
            console.log("js___ window.epikwalle ",window.epikwallet);
            console.log("js___ window.epikwalle.id",window.epikwallet.id);
            console.log("js___ window.epikwalle.bot",window.epikwallet.bot);
            
        })();
        ''';

    wvc.evaluateJavascript(source: js);
  }

  Map<AIBotMethod, bool> jsHandlerWorkLockMap = {};

  bool jsMethodIsWorking(AIBotMethod aibotmethod) {
    bool working = jsHandlerWorkLockMap[aibotmethod] ?? false;
    return working;
  }

  void setJsMethodWork(AIBotMethod aibotmethod, bool isworking) {
    jsHandlerWorkLockMap[aibotmethod] = isworking;
  }

  javaScriptHandler_postMessage(List<dynamic> arguments) async {
    try {
      dlog("jspostMessage arguments=$arguments");
      if (arguments != null && arguments.length > 0 && arguments[0] is String) {
        String jsonstr = arguments[0] as String;
        // dlog("jspostMessage jsonstr=$jsonstr");
        Map<String, dynamic> json = jsonDecode(jsonstr);
        int id = json["id"];
        String methodName = json["method"];
        Map<String, dynamic> body = json["body"];
        // print(id);
        // print(methodName);
        // print(body);
        AIBotMethod aibotmethod = AIBotMethodEx.fromValue(methodName);

        if (jsMethodIsWorking(aibotmethod)) {
          dlog("jsMethodIsWorking true return , ${aibotmethod.enumName}");
          webSendResult(id, methodName, jsonEncode({"code": -1, "msg": "method is working"}));
          return;
        }

        switch (aibotmethod) {
          case AIBotMethod.login:
            {
              //登录
              setJsMethodWork(aibotmethod, true);
              await pm_login(id, methodName, body);
              setJsMethodWork(aibotmethod, false);
            }
            break;
          case AIBotMethod.pay_order:
            {
              //支付点数
              setJsMethodWork(aibotmethod, true);
              pm_payorder(id, methodName, body);
            }
            break;
          case AIBotMethod.show_order_amount_dialog:
            {
              //订单金额确认、选择对话框
              setJsMethodWork(aibotmethod, true);
              pm_show_order_amount_dialog(id, methodName, body);
            }
            break;
          case AIBotMethod.close_browser:
            {
              //关闭页面
              setJsMethodWork(aibotmethod, true);
              await pm_closebrowser(id, methodName, body);
              setJsMethodWork(aibotmethod, false);
            }
            break;
          case AIBotMethod.apptitlebar:
            {
              setJsMethodWork(aibotmethod, true);
              await pm_apptitlebar(id, methodName, body);
              setJsMethodWork(aibotmethod, false);
            }
            break;
          case AIBotMethod.download_image:
            {
              setJsMethodWork(aibotmethod, true);
              checkPermission().then((value) async {
                if (value) {
                  await download_image(id, methodName, body);
                } else {
                  webSendResult(id, methodName, jsonEncode({"code": -1, "msg": "no permission"}));
                }
                setJsMethodWork(aibotmethod, false);
              });
            }
            break;
          case AIBotMethod.download_video:
            {
              setJsMethodWork(aibotmethod, true);
              checkPermission().then((value) async {
                if (value) {
                  await download_video(id, methodName, body);
                } else {
                  webSendResult(id, methodName, jsonEncode({"code": -1, "msg": "no permission"}));
                }
                setJsMethodWork(aibotmethod, false);
              });
            }
            break;
          case AIBotMethod.open_browser:
            {
              //
              setJsMethodWork(aibotmethod, true);
              pm_open_browser(id, methodName, body);
              setJsMethodWork(aibotmethod, false);
            }
            break;
          case AIBotMethod.points_balance:
            {
              setJsMethodWork(aibotmethod, true);
              await pm_points_balance(id, methodName, body);
              setJsMethodWork(aibotmethod, false);
            }
            break;
          case AIBotMethod.show_bot_feature:
            {
              setJsMethodWork(aibotmethod, true);
              await pm_show_bot_feature(id, methodName, body);
              setJsMethodWork(aibotmethod, false);
            }
            break;
          case AIBotMethod.show_bot_bills:
            {
              setJsMethodWork(aibotmethod, true);
              await pm_show_bot_bills(id, methodName, body);
              setJsMethodWork(aibotmethod, false);
            }
            break;
          case AIBotMethod.show_multiple_text_input_dialog:
            {
              setJsMethodWork(aibotmethod, true);
              await pm_show_multiple_text_input_dialog(id, methodName, body);
              setJsMethodWork(aibotmethod, false);
            }
            break;
          default:
            {
              MessageDialog.showMsgDialog(
                context,
                title: "Error",
                msg: "$methodName not implemented",
                btnRight: RSID.isee.text,
                onClickBtnRight: (dialog) {
                  dialog.dismiss();
                },
              );
            }
            break;
        }
      }
    } catch (e, s) {
      print(e);
      print(s);
    }
  }

  //向web发行请求的结果
  Future webSendResult(int id, String method, String message) async {
    String js = "window.epikwallet.receiveResponse($id, \'$method\', \'$message\')";
    dlog("receiveResponse : $js");

    if (isDestory) {
      dlog("webview isDestory = true ");
      return;
    }
    await _webViewController?.evaluateJavascript(source: js);
  }

  void onClickRecharge() {
    //充值
    if (ClickUtil.isFastDoubleClick()) return;

    BottomDialog.showAiBotPointRechargeDialog(context, AccountMgr().currentAccount, ApiAIBot.ai_bot_recharge_config,
        (bool ok_transfer, bool ok_recharge, CurrencySymbol cs, String txhash, String error) async {
      await Future.delayed(Duration(milliseconds: 500));

      dlog("ok_transfer=$ok_transfer  ok_recharge=$ok_recharge  cs=${cs.symbol}  txhash=$txhash  error=$error");
      if (ok_transfer && ok_recharge) {
        //充值成功
        MessageDialog.showMsgDialog(
          appContext,
          title: RSID.main_abv_7.text,
          msg: RSID.main_abv_20.text,
          btnLeft: RSID.confirm.text,
          onClickBtnLeft: (dialog) {
            dialog.dismiss();
          },
        );
      } else if (ok_transfer && ok_recharge != true) {
        //转账成功 但是上报失败
        showToast("Recharge error, please try to claim Point with transaction record.", length: Toast.LENGTH_LONG);
        BottomDialog.showAiBotPointClaimDialog(cs, txhash, null);
      } else if (ok_transfer != true && ok_recharge != true) {
        // 转账失败 也没上报
        MessageDialog.showMsgDialog(
          appContext,
          title: RSID.cwv_11.text,
          msg: error ?? "",
          btnLeft: RSID.confirm.text,
          onClickBtnLeft: (dialog) {
            dialog.dismiss();
          },
        );
      }
    });
  }

  Future<bool> checkPermission() async {
    Permission permission = Platform.isIOS ? Permission.photosAddOnly : Permission.storage;
    String permission_name = Platform.isIOS ? "album" : "storage";
    print("permission_name = $permission_name");
    PermissionStatus pstatus = await permission.request();
    print("pstatus= $pstatus");
    if (!pstatus.isGranted) {
      MessageDialog.showMsgDialog(
        appContext,
        title: RSID.awp_permission_request.text,
        msg: "Please go to your mobile phone to set the permission to open the corresponding $permission_name",
        msgAlign: TextAlign.center,
        btnLeft: RSID.cancel.text,
        btnRight: RSID.confirm.text,
        backClose: false,
        touchOutClose: false,
        onClickBtnLeft: (dialog) {
          dialog.dismiss();
        },
        onClickBtnRight: (dialog) {
          dialog.dismiss();
          openAppSettings();
        },
      );

      return false;
    }
    return true;
  }

  Future pm_login(int id, String methodName, Map<String, dynamic> body) async {
    showLoadDialog("");
    HttpJsonRes hjr = await ApiAIBot.getOauthTicket(wallet_token);
    String data = null;
    if (hjr.code == 0) {
      data = hjr.jsonMap["data"];
    }

    Map<String, dynamic> msgjson = {
      "code": hjr.code,
      "msg": hjr.msg,
      "wallet_id": wallet_id,
      "oauth_ticket": data,
    };
    closeLoadDialog();
    webSendResult(id, methodName, jsonEncode(msgjson));
  }

  void pm_payorder(int id, String methodName, Map<String, dynamic> body) async {
    // 支付
    if (body != null) {
      int order_id = StringUtils.parseInt(body["order_id"], 0);
      int timestamp = StringUtils.parseInt(body["timestamp"], 0);
      String bot_name = StringUtils.parseString(body["bot_name"], "");
      double amount = StringUtils.parseDouble(body["amount"], 0);
      String description = StringUtils.parseString(body["description"], "");

      if (order_id == 0 || timestamp == 0 || StringUtils.isEmpty(bot_name) || amount == 0) {
        Map<String, dynamic> msgjson = {
          "code": -2,
          "msg": "args error",
        };
        webSendResult(id, methodName, jsonEncode(msgjson));
        setJsMethodWork(AIBotMethod.pay_order, false);

        Future.delayed(Duration(seconds: 3)).then((value) {
          if (isDestory) return;
          loadPoint();
        });
        return;
      }

      bool hasCallback = false;
      BottomDialog.showAiBotPayOrderAmountConfirmDialog(
        context,
        verifyText: AccountMgr()?.currentAccount?.password,
        bot_name: bot_name,
        amount: amount,
        description: description,
        balance: AccountMgr().currentAccount?.aibot_point,
        onClickRecharge: () {
          try {
            onClickRecharge();
          } catch (e) {}
        },
        callback: (verifyText) async {
          hasCallback = true;
          Navigator.pop(context);

          await Future.delayed(Duration(milliseconds: 50));

          // print("showAiBotPayOrderAmountConfirmDialog  callback");

          showLoadDialog("");

          ApiAIBot.payOrder(
            wallet_id: wallet_id,
            order_id: order_id,
            timestamp: timestamp,
            wallet_token: wallet_token,
          ).then((hjr) {
            String data = "";
            if (hjr.code == 0) {
              data = hjr.jsonMap["data"];
            }

            closeLoadDialog();
            Map<String, dynamic> msgjson = {
              "code": hjr.code,
              "msg": hjr.msg,
              "data": data,
            };
            webSendResult(id, methodName, jsonEncode(msgjson));
            setJsMethodWork(AIBotMethod.pay_order, false);
          });
        },
      ).then((value) {
        if (hasCallback != true) {
          print("showAiBotPayOrderAmountConfirmDialog  close");
          Map<String, dynamic> msgjson = {
            "code": -1,
            "msg": "Cancel",
          };
          webSendResult(id, methodName, jsonEncode(msgjson));
          setJsMethodWork(AIBotMethod.pay_order, false);
        }
      });
    } else {
      Map<String, dynamic> msgjson = {
        "code": -2,
        "msg": "no body",
      };
      webSendResult(id, methodName, jsonEncode(msgjson));
      setJsMethodWork(AIBotMethod.pay_order, false);
    }
  }

  void pm_show_order_amount_dialog(int id, String methodName, Map<String, dynamic> body) async {
    try {
      String bot_name = StringUtils.parseString(body["bot_name"], ""); //ai bot 名称 收款方",
      String bot_id = StringUtils.parseString(body["bot_id"], ""); //ai bot id 收款方",
      String description = StringUtils.parseString(body["description"], ""); //""收款描述",
      List<String> options = List.from(JsonArray.obj2List(body["options"])); //["5","10","20","50","100"],
      String def_option = StringUtils.parseString(body["def_option"], ""); //:"10",
      bool confirm = false;
      BottomDialog.showAiBotMakeOrderAmountConfirmDialog(
        context,
        bot_id: bot_id,
        bot_name: bot_name,
        description: description,
        options: options,
        def_option: def_option,
        callback: (amount) {
          confirm = true;
          Map<String, dynamic> msgjson = {
            "code": 0,
            "amount": amount,
            "msg": "OK",
          };
          webSendResult(id, methodName, jsonEncode(msgjson));
          setJsMethodWork(AIBotMethod.show_order_amount_dialog, false);
        },
      ).then((value) {
        if (confirm) return;
        Map<String, dynamic> msgjson = {
          "code": -1, //取消
          "amount": "",
          "msg": "Cancel",
        };
        webSendResult(id, methodName, jsonEncode(msgjson));
        setJsMethodWork(AIBotMethod.show_order_amount_dialog, false);
      });
    } catch (e) {
      webSendResult(id, methodName, jsonEncode({"code": -2, "msg": e.toString()}));
      setJsMethodWork(AIBotMethod.show_order_amount_dialog, false);
    }
  }

  Future pm_closebrowser(int id, String methodName, Map<String, dynamic> body) async {
    finish();
    await webSendResult(id, methodName, jsonEncode({"code": 0, "msg": "OK"}));
  }

  Future pm_apptitlebar(int id, String methodName, Map<String, dynamic> body) async {
    if (body != null) {
      bool show = StringUtils.parseBool(body["show"], true);
      setAppBarVisible(show);

      bool gradient = StringUtils.parseBool(body["use_gradient"], true);
      setState(() {
        useGradientTop = gradient;
      });

      await webSendResult(id, methodName, jsonEncode({"code": 0, "msg": "OK"}));
    } else {
      await webSendResult(id, methodName, jsonEncode({"code": -2, "msg": "no body"}));
    }
  }

  void download_image(int id, String methodName, Map<String, dynamic> body) async {
    if (body == null) {
      webSendResult(id, methodName, jsonEncode({"code": -2, "msg": "no body"}));
      return;
    }

    String format = StringUtils.parseString(body["format"], "");
    String name = StringUtils.parseString(body["name"], "");
    String url = StringUtils.parseString(body["url"], "");
    String base64dstr = StringUtils.parseString(body["base64"], "");
    print("format = $format");
    print("name = $name");
    print("url = $url");
    print("base64 = $base64dstr");
    if (StringUtils.isEmpty(format) ||
        StringUtils.isEmpty(name) ||
        !(StringUtils.isNotEmpty(url) || StringUtils.isNotEmpty(base64dstr))) {
      webSendResult(id, methodName, jsonEncode({"code": -2, "msg": "args error"}));
      return;
    }

    bool downloadurl = StringUtils.isEmpty(base64dstr);

    if (!downloadurl) {
      // 保存 base64图片
      Uint8List bytes = base64Decode(base64dstr);
      final result = await ImageGallerySaver.saveImage(
        bytes,
        quality: 100, /*name: "$name.$format"*/
      ); //这个是核心的保存图片的插件
      if (result['isSuccess']) {
        showToast("Download Complete");
        webSendResult(id, methodName, jsonEncode({"code": 0, "msg": "OK"}));
      } else {
        showToast("Download save error");
        webSendResult(id, methodName, jsonEncode({"code": -1, "msg": "save error"}));
      }
    } else {
      await downloadTask(
        id: id,
        methodName: methodName,
        format: format,
        name: name,
        url: url,
      );
    }
  }

  void download_video(int id, String methodName, Map<String, dynamic> body) async {
    if (body == null) {
      webSendResult(id, methodName, jsonEncode({"code": -2, "msg": "no body"}));
      return;
    }

    String format = StringUtils.parseString(body["format"], "");
    String name = StringUtils.parseString(body["name"], "");
    String url = StringUtils.parseString(body["url"], "");
    if (StringUtils.isEmpty(format) || StringUtils.isEmpty(name) || StringUtils.isEmpty(url)) {
      webSendResult(id, methodName, jsonEncode({"code": -2, "msg": "args error"}));
      return;
    }
    //url下载视频
    await downloadTask(
      id: id,
      methodName: methodName,
      format: format,
      name: name,
      url: url,
    );
  }

  Future downloadTask({int id, String methodName, String format, String name, String url}) async {
    int ret_code = 0;
    String ret_msg = "OK";

    //本地存储路径
    Directory appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path + "/${name}.${format}";

    //进度
    GlobalKey<LoadingDialogViewState> loadingkey = GlobalKey();
    LoadingDialogView loadingdialogview = LoadingDialogView(
      "",
      key: loadingkey,
    );
    LoadingDialog.showLoadDialog(context, "0%", backClose: false, touchOutClose: false, dialogview: loadingdialogview);

    //开始下载
    int d_count = 0;
    int d_total = 0;
    int d_progress = 0; //0~100
    dio.CancelToken canceltoken = dio.CancelToken();
    dio.Response response = null;
    try {
      response = await dio.Dio().download(
        url,
        savePath,
        cancelToken: canceltoken,
        onReceiveProgress: (int count, int total) {
          //更新进度
          d_count = count;
          d_total = total;
          d_progress = StringUtils.parseInt(((count / total * 100).toStringAsFixed(0)), 0);
          String f_c = StringUtils.formatNumAmountLocaleUnit(d_count.toDouble(), context, needZhUnit: false);
          String f_t = StringUtils.formatNumAmountLocaleUnit(d_total.toDouble(), context, needZhUnit: false);
          // String progressStr = "${d_progress}% (${f_c}/${f_t})";
          String progressStr = "Download  ${f_t}  ${d_progress}%";
          dlog(progressStr);
          //更新进度
          loadingkey?.currentState?.text = progressStr;
          loadingkey?.currentState?.setState(() {});
        },
      );
    } catch (e, s) {
      print(e);
      print(s);
      ret_code = -1;
      ret_msg = "ERROR ${e.toString()}";
    }

    dlog("savePath=$savePath  exists=${await File(savePath).exists()}");

    LoadingDialog.cloasLoadDialog(context);

    if (response != null && d_progress >= 100) {
      //保存
      var result = null;
      try {
        result = await ImageGallerySaver.saveFile(savePath);
        dlog("savePath=$savePath  delete temp file");
      } catch (e, s) {
        print(e);
        print(s);
      }

      print(result);
      if (result != null && result['isSuccess']) {
        showToast("Download Complete");

        //删除缓存
        try {
          File f = File(savePath);
          if (await f.exists()) {
            f.delete();
          }
        } catch (e, s) {}
      } else {
        ret_code = -1;
        ret_msg = "ERROR";
        showToast("Download save error");
      }
    } else {
      ret_code = ret_code != 0 ? ret_code : -1;
      ret_msg = StringUtils.isNotEmpty(ret_msg) ? ret_msg : "ERROR";
      showToast("Download Error");
    }
    webSendResult(id, methodName, jsonEncode({"code": ret_code, "msg": ret_msg}));
  }

  void pm_open_browser(int id, String methodName, Map<String, dynamic> body) async {
    if (body == null) {
      webSendResult(id, methodName, jsonEncode({"code": -2, "msg": "no body"}));
      return;
    }

    String url = StringUtils.parseString(body["url"], "");
    String title = StringUtils.parseString(body["title"], "");
    bool outside = StringUtils.parseBool(body["outside"], false);
    if (StringUtils.isEmpty(url) || !url.startsWith("http")) {
      webSendResult(id, methodName, jsonEncode({"code": -2, "msg": "no url"}));
      return;
    }

    if (outside) {
      ViewGT.openOutUrl(url.trim());
    } else {
      // ViewGT.showGeneralWebView(context, title, url);
      ViewGT.openOutUrl(url.trim(), mode: LaunchMode.inAppWebView);
    }
    webSendResult(id, methodName, jsonEncode({"code": 0, "msg": "OK"}));
  }

  void pm_points_balance(int id, String methodName, Map<String, dynamic> body) async {
    if (body == null) {
      webSendResult(id, methodName, jsonEncode({"code": -2, "msg": "no body"}));
      return;
    }
    bool online = StringUtils.parseBool(body["online"], false);

    if (online) {
      await loadPoint();
    }

    webSendResult(id, methodName, jsonEncode({"code": 0, "msg": "OK", "points": getPointsNum()}));
  }

  void pm_show_bot_bills(int id, String methodName, Map<String, dynamic> body) {
    if (body == null) {
      webSendResult(id, methodName, jsonEncode({"code": -2, "msg": "no body"}));
      return;
    }
    String url = StringUtils.parseString(body["url"], "");
    Map<String, dynamic> header = body["header"] ?? {};
    if (StringUtils.isEmpty(url) || !url.startsWith("http")) {
      webSendResult(id, methodName, jsonEncode({"code": -2, "msg": "no url"}));
      return;
    }

    ViewGT.showView(
        context,
        AIBotBillsView(
          url: url,
          header: header,
        ));
    webSendResult(id, methodName, jsonEncode({"code": 0, "msg": "OK"}));
  }

  void pm_show_multiple_text_input_dialog(int id, String methodName, Map<String, dynamic> body) async {
    if (body == null) {
      webSendResult(id, methodName, jsonEncode({"code": -2, "msg": "no body"}));
      return;
    }
    List<TextInputConfigObj> objlist =
        JsonArray.parseList(body["objlist"], (json) => TextInputConfigObj.fromJson(json));
    if (objlist == null || objlist.length == 0) {
      webSendResult(id, methodName, jsonEncode({"code": -2, "msg": "no objlist"}));
      return;
    }

    String title = StringUtils.parseString(body["title"], "");
    bool autoChangeFocus = StringUtils.parseBool(body["autoChangeFocus"], true);
    bool autofocus = StringUtils.parseBool(body["autofocus"], true);
    bool dragClose = StringUtils.parseBool(body["dragClose"], true);
    bool outbackClose = StringUtils.parseBool(body["outbackClose"], true);

    bool confirm = false;

    await BottomDialog.showTextInputDialogMultiple(
      context: context,
      title: title,
      autoChangeFocus: autoChangeFocus,
      autofocus: autofocus,
      dragClose: dragClose,
      outbackClose: outbackClose,
      objlist: objlist,
      callback: (datas) {
        confirm = true;
        // if (datas != null && datas.length > 0)
        {
          webSendResult(id, methodName, jsonEncode({"code": 0, "msg": "OK", "data": datas}));
        }
      },
    );

    if (!confirm) {
      webSendResult(id, methodName, jsonEncode({"code": -1, "msg": "Cancel"}));
    }
  }

  void pm_show_bot_feature(int id, String methodName, Map<String, dynamic> body) {
    if (body == null) {
      webSendResult(id, methodName, jsonEncode({"code": -2, "msg": "no body"}));
      return;
    }
    String feature_cover = StringUtils.parseString(body["feature_cover"], "");
    String feature_video = StringUtils.parseString(body["feature_video"], "");

    if (StringUtils.isEmpty(feature_cover)) {
      feature_cover = widget.aibotapp.feature_cover;
    }
    if (StringUtils.isEmpty(feature_video)) {
      feature_video = widget.aibotapp.feature_video;
    }

    // String url = "https://www.epikg.com/video.html?src=${feature_video}";
    String url=feature_video;
    // ViewGT.openOutUrl(url, mode: LaunchMode.inAppWebView); //gif效果不好
    ViewGT.showGeneralWebView(context, "", url);

    webSendResult(id, methodName, jsonEncode({"code": 0, "msg": "OK"}));
  }
}

enum AIBotMethod {
  login, //登录
  pay_order, //支付
  show_order_amount_dialog, //通用创建订单金额确认 (选择)dialog
  close_browser, //关闭浏览器页面
  apptitlebar, //显示 隐藏 appbar
  download_image, //下载图片 url 或 base64数据
  download_video, //下载视频 url
  open_browser, // 打开新页面 或 app外部浏览器
  points_balance, //返回用户钱包有多少points
  show_bot_feature, // 客户端打开bot feature的展示页面
  show_bot_bills, // 客户端打开bot的交易记录页面
  show_multiple_text_input_dialog, //调用客户端的输入框dialog
}

extension AIBotMethodEx on AIBotMethod {
  static AIBotMethod fromValue(String value) {
    for (AIBotMethod abm in AIBotMethod.values) {
      if (abm.enumName == value) {
        return abm;
      }
    }
    return null;
  }
}

enum BotWebMenu {
  REFRESH,
  CLEARCACHE,
  RECHARGE,
}

extension BotWebMenuEx on BotWebMenu {
  String getName() {
    switch (this) {
      case BotWebMenu.REFRESH:
        return RSID.Web3Menu_REFRESH.text;
      case BotWebMenu.CLEARCACHE:
        return RSID.Web3Menu_CLEARCACHE.text;
      case BotWebMenu.RECHARGE:
        return RSID.main_abv_4.text;
      default:
        return "";
    }
  }
}

class AndroidWebPermission {
  //录音
  static const String RESOURCE_AUDIO_CAPTURE = "android.webkit.resource.AUDIO_CAPTURE";

  //MIDI SYSEX
  static const String RESOURCE_MIDI_SYSEX = "android.webkit.resource.MIDI_SYSEX";

  //媒体资源
  static const String RESOURCE_PROTECTED_MEDIA_ID = "android.webkit.resource.PROTECTED_MEDIA_ID";

  //摄像头
  static const String RESOURCE_VIDEO_CAPTURE = "android.webkit.resource.VIDEO_CAPTURE";

  static final List<String> values = [
    RESOURCE_AUDIO_CAPTURE,
    RESOURCE_MIDI_SYSEX,
    RESOURCE_PROTECTED_MEDIA_ID,
    RESOURCE_VIDEO_CAPTURE,
  ];

  static String getName(String permission) {
    String ret = "";
    switch (permission) {
      case RESOURCE_AUDIO_CAPTURE:
        {
          ret = RSID.awp_ask.text; //"录音";
        }
        break;
      case RESOURCE_MIDI_SYSEX:
        {
          ret = RSID.awp_midisysex.text; //"连接MIDI设备通信";
        }
        break;
      case RESOURCE_PROTECTED_MEDIA_ID:
        {
          ret = RSID.awp_media.text; //"访问媒体";
        }
        break;
      case RESOURCE_VIDEO_CAPTURE:
        {
          ret = RSID.awp_video.text; //"录像";
        }
        break;
      default:
        ret = permission;
    }
    return ret;
  }
}
