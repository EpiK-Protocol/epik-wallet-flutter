import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/toast/toast.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:epikwallet/localstring/resstringid.dart';

class AccountDetailView extends BaseWidget {
  WalletAccount walletaccount;

  AccountDetailView(this.walletaccount);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _AccountDetailViewState();
  }
}

class _AccountDetailViewState extends BaseWidgetState<AccountDetailView> {
  List<AccountMenu> menudata;

  Color color_icon = Color(0xff41454a);

  @override
  void initState() {
    super.initState();
  }

  LinearGradient gradient_header = LinearGradient(
    colors: [Color(0xff2C3036), Color(0xff1A1C1F)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  void initStateConfig() {
    isTopBarShow = false; //状态栏是否显示
    isAppBarShow = false; //导航栏是否显示
    isTopFloatWidgetShow = true;
    setAppBarTitle("");
    setBackIconHinde(isHinde: false);
    setAppBarContentColor(Colors.white);
    setAppBarBackColor(Colors.transparent);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
//    menudata = [
//      AccountMenu(Icons.lock_outline, "修改密码", MenuType.FIXPASSWORD),
//      AccountMenu(Icons.security, "导出tEPK私钥", MenuType.PRIVATEKEY),
//    ];
    menudata = [
      AccountMenu(Icons.lock_outline, ResString.get(context, RSID.adv_1),
          MenuType.FIXPASSWORD),
      AccountMenu(Icons.security, ResString.get(context, RSID.eepkv_1),
          MenuType.PRIVATEKEY),
    ];
  }

  SystemUiOverlayStyle oldSystemUiOverlayStyle;

  @override
  void onCreate() {
    super.onCreate();

    oldSystemUiOverlayStyle = DeviceUtils.system_bar_current;
    DeviceUtils.setSystemBarStyle(DeviceUtils.system_bar_light);
  }

  @override
  void dispose() {
    if (oldSystemUiOverlayStyle != null)
      DeviceUtils.setSystemBarStyle(oldSystemUiOverlayStyle);
    super.dispose();
  }

  @override
  Widget getTopFloatWidget() {
    return Padding(
      padding: EdgeInsets.only(top: BaseFuntion.topbarheight),
      child: getAppBar(),
    );
  }

  double header_top = 0;

  @override
  Widget buildWidget(BuildContext context) {
    if (header_top == 0) header_top = getTopBarHeight() + getAppBarHeight();
    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              width: double.infinity,
              height: header_top + 100,
              decoration: BoxDecoration(
                gradient: gradient_header,
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: AspectRatio(
                      aspectRatio: 2,
                      child: Image(
                        image: AssetImage("assets/img/bg_account_header.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Positioned(
                    top: header_top + 5,
                    left: 30,
                    child: InkWell(
                      onTap: () {
                        clickFixName();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            widget.walletaccount.account,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
                            child: Icon(
                              Icons.border_color,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: header_top + 40,
                    left: 30,
                    right: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          child: Text(
                            "Address:" + widget.walletaccount.hd_eth_address,
                            maxLines: 3,
//                        overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ResColor.white_80,
                              fontSize: 14,
                            ),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: getScreenWidth() - 30 - 60,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                          height: 30,
                          width: 30,
                          child: IconButton(
                            icon: Icon(
                              Icons.content_copy,
                              color: Color(0xff666666),
                              size: 15,
                            ),
                            onPressed: () {
                              clickCopy(widget.walletaccount);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
//              physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: menudata.map((menu) {
                    return Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            onClickMenu(menu);
                          },
                          child: Container(
                            height: 60,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(left: 5),
                                  width: 40,
                                  height: double.infinity,
                                  child: Icon(
                                    menu.icon,
                                    size: 16,
                                    color: color_icon,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    menu.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: color_icon,
                                  size: 16,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  clickDel();
                },
                child: Container(
                  height: 60,
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 5),
                        width: 40,
                        height: double.infinity,
                        child: Icon(
                          OMIcons.delete,
                          size: 16,
                          color: color_icon,
                        ),
                      ),
                      Text(
                        ResString.get(context, RSID.adv_2), //"删除钱包",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  clickCopy(WalletAccount wa) {
    dlog("clickCopy");
    DeviceUtils.copyText(wa.hd_eth_address);
//    ToastUtils.showToast("已复制到剪切板");
    ToastUtils.showToast(ResString.get(context, RSID.copied));
  }

  clickFixName() {
    BottomDialog.showTextInputDialog(
      context,
      ResString.get(context, RSID.adv_3), //"修改钱包名称",
      widget.walletaccount.account,
      ResString.get(context, RSID.iwv_7), //"请输入钱包名称",
      20,
      (text) {
        setState(() {
          widget.walletaccount.account = text;
        });
        AccountMgr().save();
      },
    );
  }

  clickDel() {
    BottomDialog.showPassWordInputDialog(
      context,
      widget.walletaccount.password,
      (password) {
        //点击确定回调

        showLoadDialog(
          ResString.get(context, RSID.adv_4), //"正在删除钱包...",
          touchOutClose: false,
          backClose: false,
          onShow: () {
            AccountMgr().delAccount(widget.walletaccount).then((_) {
              closeLoadDialog();
            });
          },
          onClose: () {
            //on dismiss
            finish();
          },
        );
      },
    );
  }

  onClickMenu(AccountMenu menu) {
    switch (menu.type) {
      case MenuType.FIXPASSWORD:
        {
          BottomDialog.showPassWordInputDialog(
            context,
            widget.walletaccount.password,
            (password) {
              //点击确定回调
              // 修改密码
              ViewGT.showFixPasswordView(context, widget.walletaccount);
            },
          );
        }
        break;
      case MenuType.PRIVATEKEY:
        {
          // 导出私钥
          BottomDialog.showPassWordInputDialog(
            context,
            widget.walletaccount.password,
            (password) {
              //点击确定回调
              ViewGT.showExportEpikPrivateKeyView(
                  context, widget.walletaccount);
            },
          );
        }
        break;
    }
  }
}

enum MenuType {
  ///修改密码
  FIXPASSWORD,

  ///查看私钥
  PRIVATEKEY,
}

class AccountMenu {
  IconData icon;
  String title;
  MenuType type;

  AccountMenu(this.icon, this.title, this.type);
}
