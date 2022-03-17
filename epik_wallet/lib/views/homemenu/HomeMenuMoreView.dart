import 'dart:ui';

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/PopMenuDialog.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/LocalWebsiteMgr.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/HomeMenuItem.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/ClickUtil.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/views/homemenu/EditWebsiteView.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:epikwallet/widget/rect_getter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class HomeMenuMoreView extends BaseWidget {
  String title;

  HomeMenuMoreView(this.title) {}

  @override
  BaseWidgetState<BaseWidget> getState() {
    return HomeMenuMoreViewState();
  }
}

class HomeMenuMoreViewState extends BaseWidgetState<HomeMenuMoreView> {
  List<HomeMenuItem> menumore = [];

  @override
  void initStateConfig() {
    super.initStateConfig();
    setTopBarVisible(false);
    List<HomeMenuItem> datas = ServiceInfo.getHomeMenuList();
    if (datas != null && datas.length >= 7) {
      menumore = datas.sublist(7);
    }
    // for(HomeMenuItem hmi in datas)
    // {
    //   if(hmi?.Action?.toLowerCase()?.startsWith("http")==true)
    //   {
    //     menumore.add(hmi);
    //   }
    // }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(widget.title);
  }

  @override
  Widget getAppBar() {
    return Container(
      width: double.infinity,
      height: getTopBarHeight() + getAppBarHeight(),
      padding: EdgeInsets.fromLTRB(0, getTopBarHeight(), 0, 0),
      decoration: BoxDecoration(
        gradient: ResColor.lg_1,
      ),
      child: super.getAppBar(),
    );
  }

  GlobalKey key_btn_menu = RectGetter.createGlobalKey();

  Widget getAppBarRight({Color color}) {
    Widget ret = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          child: Container(
            key: key_btn_menu,
            width: 40,
            height: 50,
            child: Icon(
              inBatch ? Icons.close : Icons.menu,
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

  bool _inBatch = false;

  bool get inBatch => _inBatch;

  set inBatch(v) {
    _inBatch = v;

    setState(() {});
  }

  @override
  Widget buildWidget(BuildContext context) {
    List<LocalWebsiteObj> data = localwebsitemgr?.data ?? [];

    Widget view = getListView(data, menumore);

    return WillPopScope(
      onWillPop: () async {
        if (inBatch) {
          setState(() {
            inBatch = false;
          });
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: view,
    );
  }

  Widget getListView(List<LocalWebsiteObj> data, List<HomeMenuItem> menumore) {
    return ListPage(
      data,
      itemWidgetCreator: (context, index) {
        LocalWebsiteObj lwo = data[index];
        bool isLocalWalletSupport = AccountMgr().currentAccount.isSupportCurrency(lwo?.symbol) ?? true;
        Widget item = Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: lwo.getIco(),
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                    placeholder: (context, url) {
                      return Container(
                        color: ResColor.white_0,
                        child: Icon(
                          Icons.language,
                          size: 20,
                          color: ResColor.white_40,
                        ),
                      );
                    },
                    errorWidget: (context, url, error) {
                      return Container(
                        color: ResColor.white_0,
                        child: Icon(
                          Icons.language, //broken_image
                          size: 20,
                          color: ResColor.white_40,
                        ),
                      );
                    },
                  ),
                  Container(width: 5),
                  Expanded(
                    child: Text(
                      lwo.name,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  if (lwo.symbol != null)
                    Container(
                      height: 20,
                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: isLocalWalletSupport ? ResColor.o_1 : ResColor.white_40,
                              width: 1,
                              style: BorderStyle.solid)),
                      child: Text(
                        lwo.symbol.networkTypeName,
                        style: TextStyle(fontSize: 12, color: isLocalWalletSupport ? ResColor.o_1 : ResColor.white_40),
                      ),
                    ),
                ],
              ),
              Container(
                height: 5,
              ),
              Text(
                lwo.url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 14, color: Colors.white60),
              ),
              Container(
                height: 10,
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: ResColor.white_60,
              ),
            ],
          ),
        );
        Widget batchview = Container();
        // if (inBatch) {
        //   batchview = CustomCheckBox(
        //     value: isSeletedLwo(lwo),
        //     color_check: ResColor.o_1,
        //     color_border: ResColor.o_1,
        //     borderRadius: 100,
        //     width: 20,
        //     height: 20,
        //     margin: EdgeInsets.fromLTRB(15, 10, 0, 10),
        //     onChanged: (value) {
        //       onSeletedAddressItem(lao, value);
        //     },
        //   );
        // }
        return InkWell(
          child: Row(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSizeAndFade(
                child: batchview,
              ),
              Expanded(child: item),
            ],
          ),
          onTap: () {
            if (ClickUtil.isFastDoubleClick()) return;
            onClickWebsiteItem(lwo);
          },
          onLongPress: () {
            onLongClickWebsiteItem(lwo);
          },
        );
      },
      headerList: menumore,
      headerCreator: (context, index) {
        bool last = index >= menumore.length - 1;
        HomeMenuItem mmi = menumore[index];
        bool isLocalWalletSupport = mmi?.action_l?.isLocalWalletSupport(AccountMgr().currentAccount) ??
            AccountMgr().currentAccount.isSupportCurrency(mmi?.web3nettype) ??
            true;
        Widget img = CachedNetworkImage(
          imageUrl: mmi.Icon,
          width: 36,
          height: 36,
          fit: BoxFit.contain,
          placeholder: (context, url) {
            return Container(
              color: ResColor.white_0,
              child: Icon(
                Icons.language,
                size: 36,
                color: ResColor.white_40,
              ),
            );
          },
          errorWidget: (context, url, error) {
            return Container(
              color: ResColor.white_0,
              child: Icon(
                Icons.language, //broken_image
                size: 36,
                color: ResColor.white_40,
              ),
            );
          },
        );
        Widget item = Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: (mmi?.Invalid == true || isLocalWalletSupport != true)
                        ? ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  ResColor.b_1, //ResColor.white_90,
                                  ResColor.b_1, //ResColor.black_90,
                                ],
                              ).createShader(bounds);
                            },
                            child: img,
                            blendMode: BlendMode.hue, //BlendMode.saturation, //灰度模式
                          )
                        : img,
                  ),
                  Container(width: 5),
                  Expanded(
                    child: Text(
                      mmi.Name,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  if (mmi.Web3net != null)
                    Container(
                      height: 20,
                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: isLocalWalletSupport ? ResColor.o_1 : ResColor.white_40,
                              width: 1,
                              style: BorderStyle.solid)),
                      child: Text(
                        mmi.Web3net,
                        style: TextStyle(fontSize: 12, color: isLocalWalletSupport ? ResColor.o_1 : ResColor.white_40),
                      ),
                    ),
                ],
              ),
              // Container(
              //   height: 5,
              // ),
              // Text(
              //   mmi.Action,
              //   maxLines: 1,
              //   overflow: TextOverflow.ellipsis,
              //   textAlign: TextAlign.start,
              //   style: TextStyle(fontSize: 14, color: Colors.white60),
              // ),
              Container(
                height: 10,
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: ResColor.white_60,
              ),
              // if(last)
              //   Container(
              //     height: 10,
              //   ),
            ],
          ),
        );
        Widget batchview = Container();
        // if (inBatch) {
        //   batchview = CustomCheckBox(
        //     value: isSeletedLwo(lwo),
        //     color_check: ResColor.o_1,
        //     color_border: ResColor.o_1,
        //     borderRadius: 100,
        //     width: 20,
        //     height: 20,
        //     margin: EdgeInsets.fromLTRB(15, 10, 0, 10),
        //     onChanged: (value) {
        //       onSeletedAddressItem(lao, value);
        //     },
        //   );
        // }
        return InkWell(
          child: Row(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSizeAndFade(
                child: batchview,
              ),
              Expanded(child: item),
            ],
          ),
          onTap: () {
            if (ClickUtil.isFastDoubleClick()) return;
            if (isLocalWalletSupport != true) return;
            onClickWebsiteMenuItem(mmi);
          },
          // onLongPress: () {
          // },
        );
      },
    );
    // return ListView.builder(
    //   padding: EdgeInsets.zero,
    //   itemCount: data.length,
    //   itemBuilder: (context, index) {
    //     LocalWebsiteObj lwo = data[index];
    //
    //     Widget item = Container(
    //       width: double.infinity,
    //       margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
    //       padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
    //       child: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Row(
    //             children: [
    //               CachedNetworkImage(
    //                 imageUrl: lwo.getIco(),
    //                 width: 20,
    //                 height: 20,
    //                 fit: BoxFit.contain,
    //                 placeholder: (context, url) {
    //                   return Container(
    //                     color: ResColor.white_0,
    //                     child: Icon(
    //                       Icons.language,
    //                       size: 20,
    //                       color: ResColor.white_40,
    //                     ),
    //                   );
    //                 },
    //                 errorWidget: (context, url, error) {
    //                   return Container(
    //                     color: ResColor.white_0,
    //                     child: Icon(
    //                       Icons.language, //broken_image
    //                       size: 20,
    //                       color: ResColor.white_40,
    //                     ),
    //                   );
    //                 },
    //               ),
    //               Container(width: 5),
    //               Expanded(
    //                 child: Text(
    //                   lwo.name,
    //                   style: TextStyle(fontSize: 16, color: Colors.white),
    //                 ),
    //               ),
    //               if (lwo.symbol != null)
    //                 Container(
    //                   height: 20,
    //                   padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
    //                   margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
    //                   decoration: BoxDecoration(
    //                       borderRadius: BorderRadius.circular(4),
    //                       border: Border.all(color: ResColor.o_1, width: 1, style: BorderStyle.solid)),
    //                   child: Text(
    //                     lwo.symbol.networkTypeName,
    //                     style: TextStyle(fontSize: 12, color: ResColor.o_1),
    //                   ),
    //                 ),
    //             ],
    //           ),
    //           Container(
    //             height: 5,
    //           ),
    //           Text(
    //             lwo.url,
    //             maxLines: 1,
    //             overflow: TextOverflow.ellipsis,
    //             textAlign: TextAlign.start,
    //             style: TextStyle(fontSize: 14, color: Colors.white60),
    //           ),
    //           Container(
    //             height: 10,
    //           ),
    //           Divider(
    //             height: 1,
    //             thickness: 1,
    //             color: ResColor.white_60,
    //           ),
    //         ],
    //       ),
    //     );
    //
    //     Widget batchview = Container();
    //     // if (inBatch) {
    //     //   batchview = CustomCheckBox(
    //     //     value: isSeletedLwo(lwo),
    //     //     color_check: ResColor.o_1,
    //     //     color_border: ResColor.o_1,
    //     //     borderRadius: 100,
    //     //     width: 20,
    //     //     height: 20,
    //     //     margin: EdgeInsets.fromLTRB(15, 10, 0, 10),
    //     //     onChanged: (value) {
    //     //       onSeletedAddressItem(lao, value);
    //     //     },
    //     //   );
    //     // }
    //
    //     return InkWell(
    //       child: Row(
    //         // crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           AnimatedSizeAndFade(
    //             child: batchview,
    //           ),
    //           Expanded(child: item),
    //         ],
    //       ),
    //       onTap: () {
    //         if (ClickUtil.isFastDoubleClick()) return;
    //         onClickWebsiteItem(lwo);
    //       },
    //       onLongPress: () {
    //         onLongClickWebsiteItem(lwo);
    //       },
    //     );
    //   },
    // );
  }

  void onClickMenu() {
    if (inBatch) {
      setState(() {
        inBatch = false;
      });
      return;
    }

    Rect rect = RectGetter.getRectFromKey(key_btn_menu);
    PopMenuDialog.show<HmmMenu>(
      context: context,
      rect: rect,
      datas: HmmMenu.values,
      itemBuilder: (item, dialog) {
        Widget right = null;
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

  onClickMenuItem(HmmMenu menu) {
    switch (menu) {
      case HmmMenu.addnew:
        {
          ViewGT.showView(context, EditWebsiteView()).then((value) {
            if (value != null && value is LocalWebsiteObj) {
              dlog(value.url);
              localwebsitemgr.add(value);
              localwebsitemgr.save();
              setState(() {});
            }
          });
        }
        break;
      // case HmmMenu.batch:
      //   {
      //     setState(() {
      //       inBatch = !inBatch;
      //     });
      //   }
      //   break;
    }
  }

  onClickWebsiteItem(LocalWebsiteObj lwo) {
    dlog("onClickWebsiteItem ${lwo.url}");

    // if (inBatch) {
    //   bool isSeleted = isSeletedLao(lao);
    //   onSeletedAddressItem(lao, !isSeleted);
    //   setState(() {});
    //   return;
    // }

    ViewGT.showWeb3GeneralWebView(context, lwo.name, lwo.url, lwo.symbol, lwo: lwo);
  }

  onClickWebsiteMenuItem(HomeMenuItem mmi) {
    dlog("onClickWebsiteMenuItem ${mmi.Action}");

    ViewGT.showWeb3GeneralWebView(context, mmi.Name, mmi.Action, mmi.web3nettype);
  }

  onLongClickWebsiteItem(LocalWebsiteObj lwo) {
    dlog("onLongClickWebsiteItem ${lwo.url}");
    showModalBottomSheet(
        context: context,
        backgroundColor: ResColor.b_5,
        builder: (BuildContext context) {
          Widget view = Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(height: 1),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    // edit
                    ViewGT.showView(
                        context,
                        EditWebsiteView(
                          lwo: lwo,
                        )).then((value) {
                      if (value != null && value is LocalWebsiteObj) {
                        dlog(value.url);
                        localwebsitemgr.delete(lwo);
                        localwebsitemgr.add(value);
                        localwebsitemgr.save();
                        setState(() {});
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                    width: double.infinity,
                    child: Text(RSID.hmmv_4.text,
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: ResColor.white_80)),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: ResColor.white_10,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    //delete
                    localwebsitemgr.delete(lwo);
                    localwebsitemgr.save();
                    setState(() {});
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                    width: double.infinity,
                    child: Text(RSID.hmmv_7.text,
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: ResColor.white_80)),
                  ),
                ),
                Container(height: 1),
              ],
            ),
          );
          return SafeArea(
            bottom: true,
            left: false,
            right: false,
            top: false,
            child: view,
          );
        });
  }
}

enum HmmMenu {
  addnew,
  // batch,
}

extension HmmMenuEx on HmmMenu {
  String getName() {
    switch (this) {
      case HmmMenu.addnew:
        return RSID.hmmv_1.text;
      // case HmmMenu.batch:
      //   return RSID.hmmv_2.text;
      default:
        return "";
    }
  }
}
