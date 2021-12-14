import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/toast/toast.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class WalletMenu extends BaseInnerWidget {
  @override
  BaseInnerWidgetState<BaseInnerWidget> getState() {
    return _WalletMenuState();
  }

  @override
  int setIndex() {
    return 0;
  }
}

class _WalletMenuState extends BaseInnerWidgetState<WalletMenu> {
  List<WalletAccount> data = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void initStateConfig() {
    isTopBarShow = false; //状态栏是否显示
    isAppBarShow = false; //导航栏是否显示
    setTopBarBackColor(ResColor.b_4);
    setAppBarBackColor(ResColor.b_4);
    setAppBarContentColor(Colors.white);

    bodyBackgroundColor = ResColor.b_4;

    // setBackIconHinde(isHinde: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
//    setAppBarTitle("钱包");
    setAppBarTitle(ResString.get(context, RSID.main_mw_1));
  }

  @override
  void onCreate() {
    super.onCreate();

//    // todo test data
//    for (int i = 0; i < 3; i++) {
//      LocalKeyStore ks = LocalKeyStore();
//      ks.account = "TestAccount$i";
//      ks.user_id = "4OmubRiWEZhcGZv4vARSH8eZJZI7EfVEeXxYZVeg$i";
//      data.add(ks);
//    }

    data = AccountMgr().account_list;
  }

  @override
  Widget getAppBarRight({Color color}) {
    return Container();
//    return InkWell(
//      onTap: clickSetting,
//      child: Container(
//        width: getAppBarHeight() * 0.8,
//        height: getAppBarHeight(),
//        child: Icon(
//          OMIcons.settings,
//          color: Colors.black,
//          size: 20,
//        ),
//      ),
//    );
  }

  ///导航栏 appBar 可以重写
  Widget getAppBar() {
    return Container(
      height: getAppBarHeight(),
      width: double.infinity,
      color: appBarColor,
      child: Stack(
        alignment: FractionalOffset(0, 0.5),
        children: <Widget>[
          Align(
            alignment: FractionalOffset(0, 0.5),
            child: getAppBarCenter(),
          ),
          // Align(
          //   //左边返回导航 的位置，可以根据需求变更
          //   alignment: FractionalOffset(0, 0.5),
          //   child: Offstage(
          //     offstage: !_isBackIconShow,
          //     child: getAppBarLeft(),
          //   ),
          // ),
          // Align(
          //   alignment: FractionalOffset(0.98, 0.5),
          //   child: getAppBarRight(),
          // ),
        ],
      ),
    );
  }

  ///导航栏appBar中间部分 ，不满足可以自行重写
  Widget getAppBarCenter({Color color}) {
    return Row(
      children: [
        Container(width: 20),
        Image.asset(
          "assets/img/ic_main_menu_wallet_s.png",
          width: 40,
          height: 40,
        ),
        Container(width: 10),
        Text(
          appBarTitle,
          style: TextStyle(
            fontSize: appBarCenterTextSize,
            color: color ?? appBarContentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    List<Widget> items = [];
    for (int i = 0; i < data.length; i++) {
      // items.add(buildItem(data[i], i == 0));
      items.add(buildItem2(data[i], i == 0));
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        getTopBar(),
        getAppBar(),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
            children: items,
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(
              20, 15, 20, 10 + MediaQuery.of(context).padding.bottom),
          height: 44,
          child: Row(
            children: <Widget>[
              Expanded(
                child: LoadingButton(
                  color_bg: const Color(0xff3a3a3a),
                  disabledColor:const Color(0xff3a3a3a),
                  text: RSID.main_wv_2.text, //"创建钱包",
                  onclick: (lbtn) {
                    clickCreate();
                  },
                  textstyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  bg_borderradius: BorderRadius.circular(4),
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 10)),
              Expanded(
                child: LoadingButton(
                  color_bg: const Color(0xff3a3a3a),
                  disabledColor:const Color(0xff3a3a3a),
                  text: RSID.main_wv_4.text, //"导入钱包",
                  onclick: (lbtn) {
                    clickImport();
                  },
                  textstyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  bg_borderradius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildItem(WalletAccount lks, bool isCurrent) {
    return Column(
      children: <Widget>[
        Container(
          child: Material(
            color: Color(isCurrent ? 0xff1A1C1F : 0x193B3E44),
            child: InkWell(
              onTap: () {
                clickWallet(lks);
              },
              child: Container(
                height: 80,
                padding: EdgeInsets.fromLTRB(15, 12, 0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          lks?.account ?? "----",
                          style: TextStyle(
                            color: isCurrent ? Colors.white : ResColor.black_70,
                            fontSize: 16,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 15),
                        ),
                        if (isCurrent)
                          Container(
                            padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xff292B30),
                                    Color(0xff4D4F56)
                                  ],
                                  begin: Alignment.bottomRight,
                                  end: Alignment.topLeft,
                                )),
                            child: Text(
                              ResString.get(context, RSID.main_mw_2), //"当前钱包",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                    ),
                    Container(
                      width: 30,
                      height: 3,
                      color: isCurrent ? Colors.white : ResColor.black_50,
                    ),
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Address:${lks?.hd_eth_address}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isCurrent
                                    ? ResColor.white_80
                                    : Color(0xff666666),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                            height: double.infinity,
                            width: 30,
                            child: IconButton(
                              icon: Icon(
                                Icons.content_copy,
                                color: isCurrent
                                    ? ResColor.white_80
                                    : Color(0xff666666),
                                size: 15,
                              ),
                              onPressed: () {
                                clickCopyEther(lks);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        isCurrent
            ? Container(
                height: 15,
                margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  colors: [ResColor.black_20, ResColor.black_0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )),
              )
            : Container(height: 25),
      ],
    );
  }

  Widget buildItem2(WalletAccount lks, bool isCurrent) {
    Widget ret = Material(
      // color: isCurrent ? Colors.transparent : Color(0xff424242),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () {
          clickWallet(lks);
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(15, 15, 0, 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      (lks?.account ?? "----"),
                      style: TextStyle(
                        color: isCurrent ? Colors.white : ResColor.white_80,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Image.asset(
                      "assets/img/ic_checkmark.png",
                      width: 20,
                      height: 20,
                    ),
                  Container(width: 15),
                ],
              ),
              // Padding(
              //   padding: EdgeInsets.only(top: 5),
              // ),
              // Container(
              //   width: 30,
              //   height: 3,
              //   // color: isCurrent ? Colors.white : ResColor.black_50,
              // ),
              // InkWell(
              //   onTap: () {
              //     clickCopyEther(lks);
              //   },
              //   child: Row(
              //     children: <Widget>[
              //       Expanded(
              //         child: Text(
              //           "Ether:${lks?.hd_eth_address}",
              //           maxLines: 1,
              //           overflow: TextOverflow.ellipsis,
              //           style: TextStyle(
              //             color:
              //                 isCurrent ? ResColor.white_80 : ResColor.white_60,
              //             fontSize: 13,
              //           ),
              //         ),
              //       ),
              //       Container(
              //         margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
              //         height: 20,
              //         width: 30,
              //         alignment: Alignment.center,
              //         child: Icon(
              //           Icons.content_copy,
              //           color:
              //           isCurrent ? ResColor.white_80 : ResColor.white_60,
              //           size: 15,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // InkWell(
              //   onTap: () {
              //     clickCopyEther(lks);
              //   },
              //   child: Row(
              //     children: <Widget>[
              //       Expanded(
              //         child: Text(
              //           "EpiK:${lks?.epik_EPK_address}",
              //           maxLines: 1,
              //           overflow: TextOverflow.ellipsis,
              //           style: TextStyle(
              //             color:
              //             isCurrent ? ResColor.white_80 : ResColor.white_60,
              //             fontSize: 13,
              //           ),
              //         ),
              //       ),
              //       Container(
              //         margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
              //         height: 20,
              //         width: 30,
              //         alignment: Alignment.center,
              //         child: Icon(
              //           Icons.content_copy,
              //           color:
              //           isCurrent ? ResColor.white_80 : ResColor.white_60,
              //           size: 15,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );

    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: ret,
      decoration: isCurrent
          ? BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: ResColor.o_1, width: 2),
            )
          : BoxDecoration(
              color: Color(0xff424242),
              borderRadius: BorderRadius.circular(4),
            ),
    );
  }

  clickSetting() {
    dlog("clickSetting");
    clickAppBarBack();
    // todo
  }

  clickWallet(WalletAccount lks) {
    dlog("clickWallet");
    if (lks == AccountMgr().currentAccount) {
      clickAppBarBack();
      return;
    }

    showLoadDialog("", onShow: () {
      AccountMgr().setCurrentAccount(lks).then((ok) {
        if (ok) {
          closeLoadDialog();
          Future.delayed(Duration(milliseconds: 200))
              .then((value) => clickAppBarBack());
        } else {
          closeLoadDialog();
          MessageDialog.showMsgDialog(
            context,
            title: ResString.get(context, RSID.main_mw_3),
            //"无效钱包",
            msg: ResString.get(context, RSID.main_mw_6,
                replace: ["${lks.account}"]),
            //"检测【${lks.account}】为无效钱包，是否清除？",
            btnLeft: ResString.get(context, RSID.main_mw_4),
            //"暂不",
            btnRight: ResString.get(context, RSID.main_mw_5),
            //"确定清除",
            btnRightColor: Colors.red,
            onClickBtnLeft: (dialog) {
              dialog.dismiss();
            },
            onClickBtnRight: (dialog) {
              dialog.dismiss();
              AccountMgr().delAccount(lks);
              data = AccountMgr().account_list;
              if (data.length > 0) {
                setState(() {});
              } else {
                Future.delayed(Duration(milliseconds: 200))
                    .then((value) => clickAppBarBack());
              }
            },
          );
        }
      });
    });
  }

  clickCopyEther(WalletAccount lks) {
    dlog("clickCopy");
    DeviceUtils.copyText(lks.hd_eth_address);
//    ToastUtils.showToast("已复制到剪切板");
    ToastUtils.showToast(ResString.get(context, RSID.copied));
  }

  clickCopyEpiK(WalletAccount lks) {
    dlog("clickCopy");
    DeviceUtils.copyText(lks.epik_EPK_address);
//    ToastUtils.showToast("已复制到剪切板");
    ToastUtils.showToast(ResString.get(context, RSID.copied));
  }

  clickImport() {
    dlog("clickImport");
    clickAppBarBack();
    ViewGT.showImportWalletView(context);
  }

  clickCreate() {
    dlog("clickCreate");
    clickAppBarBack();
    ViewGT.showCreateWalletView(context);
  }
}
