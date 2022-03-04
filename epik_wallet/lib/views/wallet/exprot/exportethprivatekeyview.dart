import 'dart:async';
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:convert/convert.dart';
import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
import 'package:epikplugin/Bip44Path.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:web3dart/credentials.dart';

class ExportEthPrivateKeyView extends BaseWidget {
  WalletAccount walletaccount;

  ExportEthPrivateKeyView(this.walletaccount);

  BaseWidgetState<BaseWidget> getState() {
    return _ExportEthPrivateKeyViewState();
  }
}

class _ExportEthPrivateKeyViewState extends BaseWidgetState<ExportEthPrivateKeyView> {
  String PrivateKey = "";

  @override
  void initStateConfig() {
    super.initStateConfig();
    setTopBarVisible(false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(ResString.get(context, RSID.eepkv_6));
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

  SystemUiOverlayStyle oldSystemUiOverlayStyle;

  @override
  void onCreate() {
    super.onCreate();

    oldSystemUiOverlayStyle = DeviceUtils.system_bar_current;
    DeviceUtils.setSystemBarStyle(DeviceUtils.system_bar_dark);

    refresh();
  }

  @override
  void dispose() {
    if (oldSystemUiOverlayStyle != null) DeviceUtils.setSystemBarStyle(oldSystemUiOverlayStyle);
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(30, 30, 30, 30),
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          decoration: BoxDecoration(
            color: ResColor.b_3,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Text(
            PrivateKey,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        LoadingButton(
          margin: EdgeInsets.fromLTRB(30, 40, 30, 20),
          gradient_bg: ResColor.lg_1,
          color_bg: Colors.transparent,
          disabledColor: Colors.transparent,
          height: 40,
          text: ResString.get(context, RSID.eepkv_3),
          //"复制私钥",
          textstyle: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          bg_borderradius: BorderRadius.circular(4),
          onclick: (lbtn) {
            DeviceUtils.copyText(PrivateKey);
//              showToast("已复制私钥");
            showToast(ResString.get(context, RSID.eepkv_2));
          },
        ),
//         Container(
//           width: double.infinity,
//           height: 44,
//           margin: EdgeInsets.fromLTRB(30, 50, 30, 20),
//           child: FlatButton(
//             highlightColor: Colors.white24,
//             splashColor: Colors.white24,
//             onPressed: () {
//               DeviceUtils.copyText(PrivateKey);
// //              showToast("已复制私钥");
//               showToast(ResString.get(context, RSID.eepkv_2));
//             },
//             child: Text(
//               ResString.get(context, RSID.eepkv_3), //"复制私钥",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//               ),
//             ),
//             color: Color(0xff393E45),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(Radius.circular(22)),
//             ),
//           ),
//         )
      ],
    );
  }

  refresh() {
    setLoadingWidgetVisible(true);

    // widget.walletaccount.hdwallet
    //     .export(widget.walletaccount.hd_eth_address)
    //     .then((value) {
    //   PrivateKey = value??"";
    //   closeStateLayout();
    //   Future.delayed(Duration(milliseconds: 500)).then((value) => showTips());
    // });

    Future.delayed(Duration(milliseconds: 500)).then((value) async {
      // String seed = bip39.mnemonicToSeedHex(widget.walletaccount.mnemonic);
      // Chain chain = Chain.seed(seed);
      // String path_eth = Bip44Path.getPath("ETH"); // "m/44'/60'/0'/0/0";
      // ExtendedPrivateKey key = chain.forPath(path_eth);
      // PrivateKey = key.privateKeyHex() ?? "";

      EthPrivateKey pk = widget.walletaccount.credentials;
      Uint8List pkbytes = pk.privateKey;
      if(pkbytes.length==33 && pkbytes[0]==0)
        pkbytes=pkbytes.sublist(1);
      PrivateKey = hex.encode(pkbytes);

      closeStateLayout();
      Future.delayed(Duration(milliseconds: 500)).then((value) => showTips());
    });
  }

  showTips() {
    //todo
    // MessageDialog.showMsgDialog(
    //   context,
    //   title:ResString.get(context, RSID.eepkv_4),
    //   msg:ResString.get(context, RSID.eepkv_5),
    //   btnLeft: ResString.get(context, RSID.isee),
    //   onClickBtnLeft: (dialog) => dialog.dismiss(),
    // );
  }
}
