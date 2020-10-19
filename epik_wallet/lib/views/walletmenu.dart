import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/toast/toast.dart';
import 'package:epikwallet/views/viewgoto.dart';
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
    isTopBarShow = true; //状态栏是否显示
    isAppBarShow = true; //导航栏是否显示
    setTopBarBackColor(Colors.white);
    setAppBarBackColor(Colors.white);
    setAppBarContentColor(Colors.black);
    setAppBarTitle("钱包");
    setBackIconHinde(isHinde: false);
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

  @override
  Widget buildWidget(BuildContext context) {
    List<Widget> items = [];
    for (int i = 0; i < data.length; i++) {
      items.add(buildItem(data[i], i == 0));
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            children: items,
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(
              15, 15, 15, 15 + MediaQuery.of(context).padding.bottom),
          height: 44,
          child: Row(
            children: <Widget>[
              Expanded(
                child: FlatButton(
                  highlightColor: Colors.white24,
                  splashColor: Colors.white24,
                  onPressed: () {
                    clickImport();
                  },
                  child: Text(
                    "导入钱包",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  color: Color(0xff393E45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(22)),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 10)),
              Expanded(
                child: FlatButton(
                  highlightColor: Colors.white24,
                  splashColor: Colors.white24,
                  onPressed: () {
                    clickCreate();
                  },
                  child: Text(
                    "创建钱包",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  color: Color(0xff1A1C1F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(22)),
                  ),
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
                              "当前钱包",
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
                                clickCopy(lks);
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
            title: "无效钱包",
            msg: "检测【${lks.account}】为无效钱包，是否清除？",
            btnLeft: "暂不",
            btnRight: "确定清除",
            btnRightColor: Colors.red,
            onClickBtnLeft: (dialog){dialog.dismiss();},
            onClickBtnRight: (dialog){
              dialog.dismiss();
              AccountMgr().delAccount(lks);
              data = AccountMgr().account_list;
              if(data.length>0)
              {
                setState(() {
                });
              }else{
                Future.delayed(Duration(milliseconds: 200))
                    .then((value) => clickAppBarBack());
              }
            },
          );
        }
      });
    });
  }

  clickCopy(WalletAccount lks) {
    dlog("clickCopy");
    DeviceUtils.copyText(lks.hd_eth_address);
    ToastUtils.showToast("已复制到剪切板");
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
