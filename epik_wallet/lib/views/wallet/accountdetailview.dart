import 'dart:convert';
import 'dart:ui';

import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_wallet.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/auth/RemoteAuth.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/utils/toast/toast.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/text/TextEllipsisMiddle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  Color color_icon = Colors.white; //Color(0xff41454a);

  @override
  void initState() {
    super.initState();
  }

  // LinearGradient gradient_header = LinearGradient(
  //   colors: [Color(0xff2C3036), Color(0xff1A1C1F)],
  //   begin: Alignment.centerLeft,
  //   end: Alignment.centerRight,
  // );
  LinearGradient gradient_header = ResColor.lg_1;

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
          MenuType.PRIVATEKEY_EPIK),
      AccountMenu(Icons.security, ResString.get(context, RSID.eepkv_6),
          MenuType.PRIVATEKEY_ETH),
      AccountMenu(Icons.qr_code_scanner_outlined,
          ResString.get(context, RSID.eepkv_7), MenuType.REMOTE_AUTH),
    ];
  }

  @override
  void onCreate() {
    super.onCreate();
  }

  @override
  void dispose() {
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
              height: header_top + 128 + 20,
              decoration: BoxDecoration(
                gradient: gradient_header,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Stack(
                children: <Widget>[
                  // Positioned(
                  //   left: 0,
                  //   top: 0,
                  //   bottom: 0,
                  //   child: AspectRatio(
                  //     aspectRatio: 2,
                  //     child: Image(
                  //       image: AssetImage("assets/img/bg_account_header.png"),
                  //       fit: BoxFit.fill,
                  //     ),
                  //   ),
                  // ),
                  Column(
                    children: [
                      Container(
                        height: getTopBarHeight(),
                      ),
                      Container(
                        height: getAppBarHeight(),
                      ),
                      InkWell(
                        onTap: () {
                          clickFixName();
                        },
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 30,
                            ),
                            Expanded(
                              child: Text(
                                widget.walletaccount.account,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(width: 10),
                            Icon(
                              Icons.border_color,
                              size: 14,
                              color: Colors.white,
                            ),
                            Container(
                              width: 20,
                            ),
                          ],
                        ),
                      ),
                      Container(height: 10),
                      InkWell(
                        onTap: () {
                          if(StringUtils.isNotEmpty(widget?.walletaccount?.mining_id))
                          {
                            clickCopyID(widget.walletaccount);
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(width: 30,height: 35,),
                            Text(
                              "ID: ",
                              // maxLines: 3,
                              // overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: ResColor.white,
                                fontSize: 12,
                              ),
                            ),
                            Expanded(
                              child: TextEm(
                                widget?.walletaccount?.mining_id ?? "",
                                maxLines: 1,
                                // overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: ResColor.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Container(width: 10),
                            Icon(
                              Icons.content_copy,
                              color: ResColor.white,
                              size: 14,
                            ),
                            Container(width: 20),
                          ],
                        ),
                      ),
                      // Container(height: 20),
                      InkWell(
                        onTap: () {
                          clickCopyEther(widget.walletaccount);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(width: 30,
                              height: 35,
                            ),
                            Text(
                              "ETH: ",
                              // maxLines: 3,
                              // overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: ResColor.white,
                                fontSize: 12,
                              ),
                            ),
                            Expanded(
                              child: TextEm(
                                // "ETH:\n" + widget.walletaccount.hd_eth_address,
                                widget.walletaccount.hd_eth_address,
                                maxLines: 1,
                                // overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: ResColor.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Container(width: 10),
                            Icon(
                              Icons.content_copy,
                              color: ResColor.white,
                              size: 14,
                            ),
                            Container(width: 20),
                          ],
                        ),
                      ),
                      // Container(height: 20),
                      InkWell(
                        onTap: () {
                          clickCopyEpik(widget.walletaccount);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(width: 30,height: 35,),
                            Text(
                              "EpiK: ",
                              // maxLines: 3,
                              // overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: ResColor.white,
                                fontSize: 12,
                              ),
                            ),
                            Expanded(
                              child: TextEm(
                                // "EpiK:\n" + widget.walletaccount.epik_EPK_address,
                                widget.walletaccount.epik_EPK_address,
                                maxLines: 1,
                                // overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: ResColor.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Container(width: 10),
                            Icon(
                              Icons.content_copy,
                              color: ResColor.white,
                              size: 14,
                            ),
                            Container(width: 20),
                          ],
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),
            Container(height: 20),
            Expanded(
              child: SingleChildScrollView(
//              physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: menudata.map((menu) {
                    int position = menudata.indexOf(menu);
                    bool isend = position >= menudata.length - 1;
                    return Container(
                      // margin: EdgeInsets.only(top: 10),
                      child: Material(
                        color: ResColor.b_2, //Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            onClickMenu(menu);
                          },
                          child: Container(
                            height: 60,
                            child: Stack(
                              children: [
                                Row(
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
                                          fontSize: 17,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: double.infinity,
                                      padding:
                                          EdgeInsets.fromLTRB(15, 0, 25, 0),
                                      child: Image.asset(
                                        "assets/img/ic_arrow_right_1.png",
                                        width: 7,
                                        height: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                if (!isend)
                                  Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Divider(
                                        height: 1 / ScreenUtil.pixelRatio,
                                        thickness: 1 / ScreenUtil.pixelRatio,
                                        indent: 20,
                                        color: ResColor.white_20,
                                      )),
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
            // Material(
            //   color: Colors.transparent,
            //   child: InkWell(
            //     onTap: () {
            //       clickDel();
            //     },
            //     child: Container(
            //       height: 60,
            //       child: Row(
            //         children: <Widget>[
            //           Container(
            //             margin: EdgeInsets.only(left: 5),
            //             width: 40,
            //             height: double.infinity,
            //             child: Icon(
            //               OMIcons.delete,
            //               size: 16,
            //               color: color_icon,
            //             ),
            //           ),
            //           Text(
            //             ResString.get(context, RSID.adv_2), //"删除钱包",
            //             style: TextStyle(
            //               fontSize: 15,
            //               color: Colors.black,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),

            SafeArea(
              child: LoadingButton(
                margin: EdgeInsets.fromLTRB(30, 40, 30, 0),
                gradient_bg: ResColor.lg_1,
                color_bg: Colors.transparent,
                disabledColor: Colors.transparent,
                height: 40,
                text: RSID.adv_2.text,
                //"删除钱包",
                textstyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                bg_borderradius: BorderRadius.circular(4),
                onclick: (lbtn) {
                  clickDel();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  clickCopyEther(WalletAccount wa) {
    dlog("clickCopy");
    DeviceUtils.copyText(wa.hd_eth_address);
//    ToastUtils.showToast("已复制到剪切板");
    ToastUtils.showToast(ResString.get(context, RSID.copied));
  }

  clickCopyEpik(WalletAccount wa) {
    dlog("clickCopy");
    DeviceUtils.copyText(wa.epik_EPK_address);
//    ToastUtils.showToast("已复制到剪切板");
    ToastUtils.showToast(ResString.get(context, RSID.copied));
  }

  clickCopyID(WalletAccount wa) {
    dlog("clickCopy");
    DeviceUtils.copyText(wa.mining_id);
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
      case MenuType.PRIVATEKEY_EPIK:
        {
          // 导出epik私钥
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
      case MenuType.PRIVATEKEY_ETH:
        {
          // 导出eht私钥
          BottomDialog.showPassWordInputDialog(
            context,
            widget.walletaccount.password,
            (password) {
              //点击确定回调
              ViewGT.showExportEthPrivateKeyView(context, widget.walletaccount);
            },
          );
        }
        break;
      case MenuType.REMOTE_AUTH:
        {
          //远程授权 扫码
          ViewGT.showQrcodeScanView(context).then((value) {
            RemoteAuth ra = RemoteAuth.fromString(value);
            if (ra == null) {
              showToast(RSID.qsv_2.text);
              return;
            }

            if(RemoteAuth.code_version < ra.v )
            {
              showToast(RSID.qsv_3.text);
              return;
            }


            if(ra.isSign)
            {
              //单纯远程签名 回调授权
              BottomDialog.showPassWordInputDialog(
                  context, widget.walletaccount.password, (value) async {
                showLoadDialog("");
                ApiWallet.sendRemoteAuth(ra).then((hjr) {
                  closeLoadDialog();
                  if(hjr.code!=0)
                  {
                    showToast(hjr.msg);
                  }
                });
              });
            }else if(ra.isDeal)
            {
              // 交易签名  如扫码支付
              BottomDialog.showRemoteAuthMessageDialog(context,  widget.walletaccount, ra, (value)async {

                showLoadDialog("");

                String message = jsonEncode(ra.m);
                ResultObj<String> robj = await widget.walletaccount.epikWallet.signAndSendMessage(widget.walletaccount.epik_EPK_address, message);

                closeLoadDialog();

                if(robj?.isSuccess == true){
                  String cid = robj.data;
                  MessageDialog.showMsgDialog(
                    context,
                    title: RSID.dlg_bd_5.text,//"发送交易",
                    msg: "${RSID.minerview_18.text}\n$cid",//交易已提交
                    btnLeft: RSID.minerview_19.text,//"查看交易",
                    btnRight: RSID.isee.text,
                    onClickBtnLeft: (dialog) {
                      dialog.dismiss();
                      String url = ServiceInfo.epik_msg_web + cid;
                      ViewGT.showGeneralWebView(context, RSID.berlv_4.text, url);
                    },
                    onClickBtnRight: (dialog) {
                      dialog.dismiss();
                    },
                  );
                } else {
                  ToastUtils.showToastCenter(robj?.errorMsg ?? RSID.request_failed.text);
                }
              });
            }
          });
        }
        break;
    }
  }
}

enum MenuType {
  ///修改密码
  FIXPASSWORD,

  ///epik查看私钥
  PRIVATEKEY_EPIK,

  /// eth私钥
  PRIVATEKEY_ETH,

  ///远程授权
  REMOTE_AUTH,
}

class AccountMenu {
  IconData icon;
  String title;
  MenuType type;

  AccountMenu(this.icon, this.title, this.type);
}
