import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/PopMenuDialog.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/LocalWebsiteMgr.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/web/web3/Web3SendTransactionView.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/custom_checkbox.dart';
import 'package:epikwallet/widget/rect_getter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:synchronized/synchronized.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

class Web3GeneralWebView extends BaseWidget {
  String title;
  String url;
  CurrencySymbol web3nettype;
  LocalWebsiteObj lwo;

  Web3GeneralWebView(this.title, this.url, this.web3nettype, {this.lwo}) {
    Dlog.p("Web3GeneralWebView", "$title  $url  $web3nettype");
  }

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _Web3GeneralWebViewState();
  }
}

class _Web3GeneralWebViewState extends BaseWidgetState<Web3GeneralWebView> {
  String weburl = "";
  Uri weburl_uri = null;

  Uri current_url = null;

  InAppWebViewController _webViewController = null;

  bool webview_reload_btn = true;
  bool clearCache = false;

  int loadprogress = 0;

  bool isInjectedSource = false;

  //获取主网客户端
  Web3Client get web3Client {
    if (widget.web3nettype?.networkType == CurrencySymbol.ETH) {
      return EpikWalletUtils.ethClient;
    } else if (widget.web3nettype?.networkType == CurrencySymbol.BNB) {
      return EpikWalletUtils.bscClient;
    }
    return null;
  }

  EthPrivateKey get hdPrivateKey {
    return AccountMgr().currentAccount.credentials;
  }

  //获取当前选择的链ID
  int get chainId {
    if (widget.web3nettype?.networkType == CurrencySymbol.ETH) {
      return EpikWalletUtils?.eth_chainid?.toInt() ?? 1;
    } else if (widget.web3nettype?.networkType == CurrencySymbol.BNB) {
      return EpikWalletUtils?.bsc_chainid?.toInt() ?? 1;
    }
    return 1;
  }

  String get rpcUrl {
    if (widget.web3nettype?.networkType == CurrencySymbol.ETH) {
      return ServiceInfo.hd_ETH_RpcUrl;
    } else if (widget.web3nettype?.networkType == CurrencySymbol.BNB) {
      return ServiceInfo.hd_BSC_RpcUrl;
    }
    return "";
  }

  //获取当前HD钱包的地址
  String get hdAddress {
    // return AccountMgr()?.currentAccount?.hd_eth_address;
    return AccountMgr()?.currentAccount?.ethereumAddress.hex;
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

  Widget getAppBarRight({Color color}) {
    if (webview_reload_btn == true) {
      // return InkWell(
      //   onTap: () {
      //     if (_webViewController != null) {
      //       _webViewController.reload();
      //     }
      //   },
      //   child: Container(
      //     width: getAppBarHeight() * 0.8,
      //     height: getAppBarHeight(),
      //     child: Icon(
      //       Icons.refresh_outlined,
      //       color: color ?? Colors.white,
      //       size: 20,
      //     ),
      //   ),
      // );

      Widget ret = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            child: widget.web3nettype != null
                ? Container(
              height: 20,
              padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: ResColor.o_1,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    widget.web3nettype.networkType.iconUrl,
                    width: 20,
                    height: 20,
                  ),
                  Container(width: 5),
                  Text(
                    widget.web3nettype.networkType.networkTypeName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color ?? appBarContentColor,
//        fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
                : Container(
              height: 20,
              padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: ResColor.o_1,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    RSID.w3wv_network.text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color ?? appBarContentColor,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              //选择网络
              onClickNetwork();
            },
          ),
          InkWell(
            child: Container(
              key: key_btn_menu,
              width: 40,
              height: 50,
              child: Icon(
                Icons.menu,
                size: 20,
                color: color ?? appBarContentColor,
              ),
            ),
            onTap: onClickMenu,
          ),
        ],
      );
      return ret;
    }
    return Container();
  }

  onClickMenu() {
    Rect rect = RectGetter.getRectFromKey(key_btn_menu);
    List<Web3Menu> menus = List.from(Web3Menu.values);
    if (web3Client == null) {
      menus.remove(Web3Menu.GAS);
      menus.remove(Web3Menu.KEEP_PASSWORD);
    }

    PopMenuDialog.show<Web3Menu>(
      context: context,
      rect: rect,
      datas: menus,
      itemBuilder: (item, dialog) {
        Widget right = null;
        switch (item) {
          case Web3Menu.REFRESH:
            break;
          case Web3Menu.COLLECT:
            {
              String url = current_url?.toString();
              print(url);
              bool collected = localwebsitemgr.hasUrl(url);
              if (collected) {
                right = Icon(
                  Icons.star,
                  color: ResColor.o_1,
                  size: 20,
                );
              }
            }
            break;
          case Web3Menu.GAS:
            {
              if (preset_gasrate != null) {
                right = Text(
                  "${preset_gasrate}x",
                  style: TextStyle(
                    fontSize: 14,
                    color: ResColor.o_1,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }
            }
            break;
          case Web3Menu.KEEP_PASSWORD:
            {
              if (isKeepPassword) {
                right = Image.asset(
                  "assets/img/ic_checkmark.png",
                  width: 20,
                  height: 20,
                  color: keep_password_website_secret ? ResColor.r_1 : null,
                );
              }
            }
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

  onClickNetwork() {
    List<CurrencySymbol> data = [CurrencySymbol.ETH, CurrencySymbol.BNB];

    CurrencySymbol seleted = widget.web3nettype;

    Widget view = StatefulBuilder(
      builder: (context, setState) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: data.map((cs) {
              bool iscurrent = cs == seleted;

              Widget item = Container(
                width: double.infinity,
                height: 40,
                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                // decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(8),
                //     border: Border.all(color: ResColor.o_1, width: 1, style: BorderStyle.solid)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomCheckBox(
                      value: iscurrent,
                      color_check: ResColor.o_1,
                      color_border: ResColor.o_1,
                      borderRadius: 100,
                      width: 20,
                      height: 20,
                      margin: EdgeInsets.fromLTRB(15, 10, 0, 10),
                      onChanged: (value) {
                        // onSeletedAddressItem(lao, value);
                        if (value) {
                          seleted = cs;
                        } else {
                          seleted = null;
                        }
                        setState(() {});
                      },
                    ),
                    Container(width: 20),
                    Image.asset(
                      cs.networkType.iconUrl,
                      width: 24,
                      height: 24,
                    ),
                    Container(width: 10),
                    Text(
                      cs.networkType.networkTypeName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ResColor.o_1,
                      ),
                    ),
                  ],
                ),
              );

              return InkWell(
                child: item,
                onTap: () {
                  if (iscurrent) {
                    seleted = null;
                  } else {
                    seleted = cs;
                  }
                  setState(() {});
                },
              );
            }).toList(),
          ),
        );
      },
    );

    YYDialog yydialog = MessageDialog.showMsgDialog(
      context,
      title: RSID.w3wv_network.text,
      extend: view,
      btnLeft: RSID.cancel.text,
      onClickBtnLeft: (dialog) {
        dialog.dismiss();
      },
      btnRight: RSID.confirm.text,
      onClickBtnRight: (dialog) {
        dialog.dismiss();
        widget.web3nettype = seleted;
        setState(() {});

        isInjectedSource = false;
        lock_jssource.synchronized(() async {
          if (isInjectedSource != true) {
            isInjectedSource = true;
            await injectJS_source(_webViewController);
            dlog("injectJS_source !!!!!!!!!!");
            await injectJs_init(_webViewController);
            dlog("injectJs_init !!!!!!!!!!");
          }
        });
      },
    );
  }

  String keep_password_website = "";
  bool keep_password_website_secret = false;
  final String keep_password_website_secretkey = "admin";

  bool get isKeepPassword {
    String host = current_url?.host;
    return host == keep_password_website;
  }

  String preset_gasrate = null;
  String preset_maxgasrate = null;

  onClickMenuItem(Web3Menu item) async {
    switch (item) {
      case Web3Menu.REFRESH:
        _webViewController?.reload();
        break;
      case Web3Menu.CLEARCACHE:
        {
          _webViewController?.clearCache();
        }
        break;
      case Web3Menu.COLLECT:
        {
          LocalWebsiteObj collected_lwo = localwebsitemgr.findByUrl(current_url?.toString());

          if (collected_lwo != null) {
            localwebsitemgr.delete(collected_lwo);
            localwebsitemgr.save();
            showToast(RSID.w3wv_deteled.text);
          } else {
            String url = current_url.toString();
            String title = await _webViewController.getTitle();
            if (title == null) title = current_url.host;
            CurrencySymbol cs = widget.web3nettype;
            String ico = await getFavicon();
            LocalWebsiteObj lwo = LocalWebsiteObj()
              ..name = title
              ..url = url
              ..symbol = cs
              ..ico = ico;
            localwebsitemgr.add(lwo);
            localwebsitemgr.save();
            showToast(RSID.w3wv_added.text);
          }
        }
        break;
      case Web3Menu.GAS:
        {
          //创建有状态可以刷新的builder
          Widget extend = StatefulBuilder(
            builder: (context, setState) {
              List<Widget> views = [];

              // if (keep_password_website_secret == true)
                  {
                List<String> list_maxgas = ["1.5", "2.0", "2.5", "3.0"];
                Widget item_mg = Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 30),
                  child: Row(children: [
                    Text(
                      RSID.gasrate.text, //"加倍 : ",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...list_maxgas.map((e) {
                      bool isSeleted = preset_maxgasrate == e;
                      return Expanded(
                          child: LoadingButton(
                            height: 20,
                            text: e + "x",
                            textstyle: TextStyle(
                              fontSize: 11,
                              color: isSeleted ? ResColor.black : ResColor.o_1,
                              fontWeight: FontWeight.bold,
                            ),
                            margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                            bg_borderradius: BorderRadius.circular(4),
                            color_bg: isSeleted ? ResColor.o_1 : Colors.transparent,
                            disabledColor: Colors.transparent,
                            side: BorderSide(
                              color: ResColor.o_1,
                              width: 1,
                            ),
                            onclick: (lbtn) {
                              if (isSeleted) {
                                preset_maxgasrate = null;
                              } else {
                                preset_maxgasrate = e;
                              }
                              // Navigator.of(context).pop();
                              setState(() {});
                            },
                          ));
                    }).toList(),
                  ]),
                );
                views.add(Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Text(
                    "MaxGas",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ));
                views.add(item_mg);
              }

              {
                List<String> list_gasrate = ["1.1", "1.2", "1.3", "1.4", "1.5"];
                Widget item_gp = Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 30),
                  child: Row(children: [
                    Text(
                      RSID.gasrate.text, //"加倍 : ",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...list_gasrate.map((e) {
                      bool isSeleted = preset_gasrate == e;
                      return Expanded(
                          child: LoadingButton(
                            height: 20,
                            text: e + "x",
                            textstyle: TextStyle(
                              fontSize: 11,
                              color: isSeleted ? ResColor.black : ResColor.o_1,
                              fontWeight: FontWeight.bold,
                            ),
                            margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                            bg_borderradius: BorderRadius.circular(4),
                            color_bg: isSeleted ? ResColor.o_1 : Colors.transparent,
                            disabledColor: Colors.transparent,
                            side: BorderSide(
                              color: ResColor.o_1,
                              width: 1,
                            ),
                            onclick: (lbtn) {
                              if (isSeleted) {
                                preset_gasrate = null;
                              } else {
                                preset_gasrate = e;
                              }
                              // Navigator.of(context).pop();
                              setState(() {});
                            },
                          ));
                    }).toList(),
                  ]),
                );
                views.add(Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Text(
                    "GasPrice",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ));
                views.add(item_gp);
              }

              Widget extend = Column(
                mainAxisSize: MainAxisSize.min,
                children: views,
              );
              return extend;
            },
          );

          MessageDialog.showMsgDialog(
            context,
            title: Web3Menu.GAS.getName(),
            extend: extend,
            btnRight: RSID.confirm.text,
            onClickBtnRight: (dialog) {
              dialog.dismiss();
            },
          );
        }
        break;
      case Web3Menu.KEEP_PASSWORD:
        {
          if (isKeepPassword) {
            keep_password_website = null;
            showToast("${Web3Menu.KEEP_PASSWORD.getName()} ${RSID.w3wv_canceled.text}");
          } else {
            String host = current_url?.host;
            MessageDialog.showMsgDialog(
              context,
              title: Web3Menu.KEEP_PASSWORD.getName(),
              // msg: "交易时不用再次输入密码，但每次交易还需要确认才可以进行。是否临时授权当前站点$host可以预设交易密码？",
              msg: RSID.w3wv_auth_keep_password.replace(["($host)"]),
              btnLeft: RSID.cancel.text,
              onClickBtnLeft: (dialog) {
                dialog.dismiss();
              },
              btnRight: RSID.confirm.text,
              onClickBtnRight: (dialog) {
                dialog.dismiss();
                BottomDialog.showPassWordInputDialog(context, AccountMgr().currentAccount.password, (value) {
                  if (value == (AccountMgr().currentAccount.password + keep_password_website_secretkey)) {
                    //开启隐藏功能
                    keep_password_website_secret = true;
                  }

                  keep_password_website = host;
                  showToast("${Web3Menu.KEEP_PASSWORD.getName()} ${RSID.w3wv_authorized.text}");
                }, secretVerifyText: keep_password_website_secretkey);
              },
            );
          }
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
    if (_webViewController != null && await _webViewController.canGoBack()) {
      _webViewController.goBack();
    } else {
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
            child: getWebView2(),
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
          useShouldOverrideUrlLoading: true, //开启url拦截 配合shouldOverrideUrlLoading
        ),
        android: AndroidInAppWebViewOptions(
          useHybridComposition: true, //DeviceUtils().androidQ,
          mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW, //https的网站可以加载http的资源
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
        if (url?.host != keep_password_website) {
          keep_password_website = null;
          keep_password_website_secret = false;
        }
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
      onProgressChanged: (controller, progress) {
        dlog("onProgressChanged progress=$progress");
        // controller.getUrl().then((value) {
        //   dlog("onProgressChanged progress=$progress url=$value");
        // });
        setState(() {
          loadprogress = progress;
        });

        if (loadprogress >= 10 && web3Client != null) {
          lock_jssource.synchronized(() async {
            if (isInjectedSource != true) {
              isInjectedSource = true;
              await injectJS_source(_webViewController);
              dlog("injectJS_source !!!!!!!!!!");
              await injectJs_init(_webViewController);
              dlog("injectJs_init !!!!!!!!!!");
            }
          });
        }

        if (loadprogress >= 50) {
          if (widget.lwo != null && StringUtils.isEmpty(widget.lwo.ico)) {
            controller.getUrl().then((cu) async {
              if (cu?.host == weburl_uri?.host) {
                dlog("find ico from " + weburl_uri?.host);
                String ico = await getFavicon();
                dlog("find ico = $ico");
                if (ico != null && StringUtils.isEmpty(widget.lwo.ico)) {
                  widget.lwo.ico = ico;
                  localwebsitemgr.save();
                }
              }
            });
          }
        }
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
    if (_webViewController != null && await _webViewController.canGoBack()) {
      _webViewController.goBack();
      return false;
    }
    return true;
  }

  Future<NavigationActionPolicy> onShouldOverrideUrlLoading(InAppWebViewController controller,
      NavigationAction navigationAction) async {
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

  Future injectJS_source(InAppWebViewController wvc) async {
    String source_wallet = await rootBundle.loadString("assets/js/trust.js");
    String js = '''
    $source_wallet
    console.log("injectJS_source trustwallet=",trustwallet);
    ''';
    wvc.evaluateJavascript(source: js);
  }

  Future injectJs_init(InAppWebViewController wvc) async {
    String _chainId = '"0x${chainId.toRadixString(16)}"'; //hex字符串的chainid

    String url = current_url?.toString() ??  weburl_uri?.toString();
    if (url?.contains("uniswap") == true) //uniswap只支持整数chainid
      _chainId = "$chainId";

    String js = '''
        (function() {
          
            console.log("injectJs_init start----");
        
            var config = {
                chainId: $chainId,
                rpcUrl: "$rpcUrl",
                address:"$hdAddress",
                isDebug: ${DeviceUtils.isDebug}
            };
            window.ethereum = new trustwallet.Provider(config);
            window.web3 = new trustwallet.Web3(window.ethereum);
            web3.eth.setProvider=window.ethereum;
            window.ethereum.isMetaMask=true;
            window.ethereum.chainId=$_chainId;  //$chainId;  // 0x${chainId.toRadixString(16)}
            window.ethereum.selectedAddress="$hdAddress";
            
            console.log(window.ethereum.chainId);
            console.log("injectJs_init end----");
            
            trustwallet.postMessage = async (json) => {
                // window._tw_.postMessage(JSON.stringify(json));
                console.log("postMessage start");
                
                var retry=100;
                while(!window.flutter_inappwebview.callHandler && retry>0)
                {
                  await new Promise((resolve) => setTimeout(resolve, 100));
                  retry--;
                  console.log("wait flutter_inappwebview",retry);
                }
                
                window.flutter_inappwebview.callHandler("postMessage",JSON.stringify(json));
                console.log("postMessage end");
            };
            console.log("window.ethereum.isTrust=",window.ethereum.isTrust);
            console.log("window.ethereum.isMetaMask=",window.ethereum.isMetaMask);
            
            console.log("window.ethereum.selectedAddress=",window.ethereum.selectedAddress);
            console.log("window.ethereum.chainId=",window.ethereum.chainId);
        })();
        ''';

    // if(window.ethereum){
    //     web3.eth.getAccounts((error, accounts) => {
    //       web3.eth.defaultAccount = accounts[0];
    //       window.ethereum.selectedAddress=accounts[0];
    //       console.log("aa",window.ethereum.selectedAddress);
    //       console.log("bb",window.ethereum.chainId);
    //     });
    // }

    wvc.evaluateJavascript(source: js);
  }

  javaScriptHandler_postMessage(List<dynamic> arguments) async {
    dlog("jspostMessage arguments=$arguments");

    if (web3Client == null) return;

    if (arguments != null && arguments.length > 0 && arguments[0] is String) {
      String jsonstr = arguments[0] as String;
      // dlog("jspostMessage jsonstr=$jsonstr");
      Map<String, dynamic> json = jsonDecode(jsonstr);
      int id = json["id"];
      String methodName = json["name"];
      DAppMethod dappmethod = DAppMethodEx.fromValue(methodName);

      switch (dappmethod) {
        case DAppMethod.REQUESTACCOUNTS:
          {
            //网页请求钱包地址
            String setAddress = 'window.ethereum.setAddress("$hdAddress");';
            String callback = 'window.ethereum.sendResponse($id, ["$hdAddress"])';
            _webViewController?.evaluateJavascript(source: setAddress);
            _webViewController?.evaluateJavascript(source: callback).then((value) {
              // dlog("requestAccounts js return = ${value.toString()}");
            });
          }
          break;
        case DAppMethod.SIGNMESSAGE:
          {
            Uint8List data = extractMessage(json);
            handleSignMessage(id, data, addPrefix: false);
          }
          break;
        case DAppMethod.SIGNPERSONALMESSAGE:
          {
            Uint8List data = extractMessage(json);
            handleSignMessage(id, data, addPrefix: true);
          }
          break;
        case DAppMethod.SIGNTYPEDMESSAGE:
          {
            Uint8List data = extractMessage(json);
            String raw = extractRaw(json);
            handleSignMessage(id, data, addPrefix: false, raw: raw);
          }
          break;
        case DAppMethod.SIGNTRANSACTION:
          {
            handleSendTransaction(json, id, methodName);
          }
          break;
        case DAppMethod.ECRECOVER:
        case DAppMethod.WATCHASSET:
        case DAppMethod.ADDETHEREUMCHAIN:
        case DAppMethod.UNKNOWN:
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
  }

  Uint8List extractMessage(Map<String, dynamic> json) {
    try {
      Map<String, dynamic> j_param = json["object"];
      String data = j_param["data"];
      if (data != null && data.length > 0 && data.startsWith("0x")) data = data.substring(2);
      List<int> bytes = hex.decode(data);
      return Uint8List.fromList(bytes);
    } catch (e) {
      print(e);
    }
  }

  String extractRaw(Map<String, dynamic> json) {
    try {
      Map<String, dynamic> j_param = json["object"];
      String raw = j_param["raw"] ?? "";
      return raw;
    } catch (e) {
      print(e);
    }
  }

  //dialog
  handleSignMessage(int id, Uint8List data, {bool addPrefix = true, String raw}) {
    bool istyped = StringUtils.isNotEmpty(raw);
    String msg = null;
    if (istyped) {
      msg = raw;
    } else {
      if (addPrefix)
        msg = utf8.decode(data);
      else
        msg = "0x" + hex.encode(data);
    }
    BottomDialog.showWeb3PassWordInputDialog(
      appContext,
      verifyText: AccountMgr().currentAccount.password,
      title: istyped ? "Sign Typed Message" : "Sign Message",
      msg: msg,
      cancelCallback: () {
        webSendError("Cancel", id);
      },
      callback: (value) async {
        String sign = await signEthereumMessage(data, addPrefix);
        webSendResult(sign, id);
      },
    );
  }

  Future<String> signEthereumMessage(Uint8List message, bool addPrefix) async {
    try {
      Uint8List signdata = null;
      if (addPrefix) {
        signdata = await hdPrivateKey?.signPersonalMessage(message, chainId: chainId);
      } else {
        signdata = await hdPrivateKey?.sign(message, chainId: chainId);
      }
      String signatureData = "0x" + hex.encode(signdata);
      return signatureData;
    } catch (e) {
      print(e);
    }
  }

  //签名发送交易
  handleSendTransaction(Map<String, dynamic> json, int id, String methodName) async {
    send(Transaction _transaction, String _gasrate, String _maxgasrate) async {
      try {
        dlog("gasrate=$_gasrate");
        if (_gasrate != null && _transaction.gasPrice != null) {
          try {
            double gasrate_d = StringUtils.parseDouble(_gasrate, 1);
            double nesgasprice = _transaction.gasPrice.getInWei.toDouble() * gasrate_d;
            EtherAmount ea_gasrprice = EtherAmount.inWei(BigInt.from(nesgasprice.toInt()));
            dlog("new gasrate= ${_transaction.gasPrice.getInWei} * $gasrate_d = $nesgasprice");
            dlog("new gasrate etheramount = $ea_gasrprice");
            _transaction = _transaction.copyWith(gasPrice: ea_gasrprice);
          } catch (e) {
            print(e);
          }
        }
        dlog("maxgas=$_maxgasrate");
        if (_maxgasrate != null && _transaction.maxGas != null) {
          try {
            double maxgasrate_d = StringUtils.parseDouble(_maxgasrate, 1);
            int nesmaxgas = (_transaction.maxGas * maxgasrate_d).toInt();
            dlog("new maxgas= $nesmaxgas");
            _transaction = _transaction.copyWith(maxGas: nesmaxgas);
          } catch (e) {
            print(e);
          }
        }

        String txhash = await sendTransaction(_transaction);
        webSendResult(txhash, id);
      } catch (e, s) {
        print(s);
        webSendError(e.toString(), id);
      }
      if (keep_password_website_secret == true) closeLoadDialog();
    }

    if (keep_password_website_secret == true) {
      showLoadDialog("SendTransaction");
    }

    try {
      Map<String, dynamic> j_object = json["object"];
      String gas = j_object["gas"];
      String gasPrice = j_object["gasPrice"];
      String from = j_object["from"];
      String to = j_object["to"];
      String data = j_object["data"];
      String value = j_object["value"];
      Transaction transaction = Transaction(
        maxGas: gas != null ? BigInt.parse(EpikWalletUtils.strip0x(gas), radix: 16).toInt() : null,
        gasPrice:
        gasPrice != null ? EtherAmount.inWei(BigInt.parse(EpikWalletUtils.strip0x(gasPrice), radix: 16)) : null,
        from: from != null ? EthereumAddress.fromHex(from) : null,
        to: from != null ? EthereumAddress.fromHex(to) : null,
        data: data != null ? EpikWalletUtils.hexStringToBytes(data) : null,
        value: value != null ? EtherAmount.inWei(BigInt.parse(EpikWalletUtils.strip0x(value), radix: 16)) : null,
      );
      dlog(transaction?.maxGas?.toString());
      dlog(transaction?.gasPrice?.toString());
      dlog(transaction?.from?.toString());
      dlog(transaction?.to?.toString());
      dlog(transaction?.data?.toString());

      if (transaction.maxGas == null) {
        BigInt estimateGas = await web3Client.estimateGas(
          sender: transaction.from,
          to: transaction.to,
          data: transaction.data,
          value: transaction.value,
        );
        dlog("estimateGas=$estimateGas");
        //estimateGas=53000
        if (estimateGas != null) transaction = transaction.copyWith(maxGas: estimateGas.toInt());
      }

      dlog("gasPrice=${transaction.gasPrice}");
      if (transaction.gasPrice == null) {
        EtherAmount gp = await web3Client.getGasPrice();
        //getGasPrice=EtherAmount: 5000000000 wei
        dlog("getGasPrice=$gp");
        if (gp != null) transaction = transaction.copyWith(gasPrice: gp);
      }

      // List<String> list_gasrate = ["1.1", "1.2", "1.3", "1.4", "1.5"];
      String gasrate = preset_gasrate;
      String maxgasrate = preset_maxgasrate;

      if (keep_password_website_secret == true) {
        send(transaction, gasrate, maxgasrate);
      } else {
        Web3SendTransactionView transactionWidget =
        Web3SendTransactionView(transaction, widget.web3nettype.networkType, gasrate, maxgasrate);

        //dialog
        BottomDialog.showWeb3PassWordInputDialog(
          appContext,
          verifyText: AccountMgr().currentAccount.password,
          autoinputverifyText: isKeepPassword,
          title: "SendTransaction",
          // msg: json.toString(),
          header: transactionWidget,
          cancelCallback: () {
            webSendError("Cancel", id);
          },
          callback: (value) async {
            gasrate = transactionWidget.gasrate;
            maxgasrate = transactionWidget.maxgasrate;
            send(transaction, gasrate, maxgasrate);
          },
        );
      }
    } catch (e, s) {
      print(s);
      webSendError(e.toString(), id);
      if (keep_password_website_secret == true) closeLoadDialog();
    }
  }

  Future<String> sendTransaction(Transaction transaction) async {
    try {
      String txhash = await web3Client.sendTransaction(hdPrivateKey, transaction,
          chainId: chainId.toInt(), fetchChainIdFromNetworkId: false);
      dlog("sendTransaction txhash=$txhash");
      return txhash;
    } catch (e) {
      print(e);
    }
  }

  webSendError(String message, int methodId) {
    String js = "window.ethereum.sendError($methodId, \"$message\")";
    _webViewController?.evaluateJavascript(source: js);
  }

  webSendResult(String message, int methodId) {
    String js = "window.ethereum.sendResponse($methodId, \"$message\")";
    _webViewController?.evaluateJavascript(source: js);
  }

  webSendResults(List<String> messages, int methodId) {
    String message = messages.join(",");
    String js = "window.ethereum.sendResponse($methodId, \"$message\")";
    _webViewController?.evaluateJavascript(source: js);
  }
}

enum DAppMethod {
  REQUESTACCOUNTS,
  SIGNMESSAGE,
  SIGNPERSONALMESSAGE,
  SIGNTYPEDMESSAGE,
  SIGNTRANSACTION,
  ECRECOVER,
  WATCHASSET,
  ADDETHEREUMCHAIN,
  UNKNOWN,
}

extension DAppMethodEx on DAppMethod {
  static DAppMethod fromValue(String value) {
    switch (value) {
      case "signTransaction":
        return DAppMethod.SIGNTRANSACTION;
      case "signPersonalMessage":
        return DAppMethod.SIGNPERSONALMESSAGE;
      case "signMessage":
        return DAppMethod.SIGNMESSAGE;
      case "signTypedMessage":
        return DAppMethod.SIGNTYPEDMESSAGE;
      case "ecRecover":
        return DAppMethod.ECRECOVER;
      case "requestAccounts":
        return DAppMethod.REQUESTACCOUNTS;
      case "watchAsset":
        return DAppMethod.WATCHASSET;
      case "addEthereumChain":
        return DAppMethod.ADDETHEREUMCHAIN;
      default:
        DAppMethod.UNKNOWN;
    }
  }
}

enum Web3Menu {
  REFRESH,
  CLEARCACHE,
  COLLECT,
  GAS,
  KEEP_PASSWORD,
}

extension Web3MenuEx on Web3Menu {
  String getName() {
    switch (this) {
      case Web3Menu.REFRESH:
        return RSID.Web3Menu_REFRESH.text;
      case Web3Menu.CLEARCACHE:
        return RSID.Web3Menu_CLEARCACHE.text;
      case Web3Menu.COLLECT:
        return RSID.Web3Menu_COLLECT.text;
      case Web3Menu.GAS:
        return RSID.Web3Menu_GAS.text;
      case Web3Menu.KEEP_PASSWORD:
        return RSID.Web3Menu_KEEP_PASSWORD.text;
      default:
        return "";
    }
  }
}
