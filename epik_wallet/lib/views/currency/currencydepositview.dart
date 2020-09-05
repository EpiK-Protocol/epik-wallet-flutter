import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

// 充币
class CurrencyDepositView extends BaseWidget {
  WalletAccount walletaccount;
  CurrencySymbol currencysymbol;

  CurrencyDepositView(this.walletaccount, this.currencysymbol);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _CurrencyDepositViewState();
  }
}

class _CurrencyDepositViewState extends BaseWidgetState<CurrencyDepositView> {
  String address = "";
  String url_qrcode;

  @override
  void initStateConfig() {
    setAppBarTitle("收款");

    switch (widget.currencysymbol) {
      case CurrencySymbol.tEPK:
        {
          address = widget.walletaccount.epik_tEPK_address;
          break;
        }
      default:
        {
          address = widget.walletaccount.hd_eth_address;
        }
    }
    url_qrcode = "http://qr.topscan.com/api.php?text=" + address;
  }

  SystemUiOverlayStyle oldSystemUiOverlayStyle;

  @override
  void onCreate() {
    super.onCreate();

    oldSystemUiOverlayStyle = DeviceUtils.system_bar_current;
    DeviceUtils.setSystemBarStyle(DeviceUtils.system_bar_dark);
  }

  @override
  void dispose() {
    if (oldSystemUiOverlayStyle != null)
      DeviceUtils.setSystemBarStyle(oldSystemUiOverlayStyle);
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    List<Widget> views = [];

    views.add(Padding(
      padding: EdgeInsets.fromLTRB(40, 6, 15, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
//          Text(
//            "充币",
//            style: TextStyle(
//              color: Colors.black,
//              fontSize: 30,
//            ),
//          ),
        ],
      ),
    ));

    List<Widget> subviews = [];
    Widget subgroup = Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: subviews,
      ),
    );

    subviews.add(Container(
      padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
      child: Text(widget.currencysymbol.symbol,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          )),
    ));

    subviews.add(Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(70, 30, 70, 20),
      child: AspectRatio(
        aspectRatio: 1,
        child: CachedNetworkImage(
          imageUrl: url_qrcode,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[300],
            );
          },
          placeholder: (context, url) {
            return Stack(
              alignment: FractionalOffset(0.5, 0.5),
              children: <Widget>[
                SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(ResColor.black_10)),
                )
              ],
            );
          },
        ),
      ),
    ));

    subviews.add(Container(
      width: 150,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: FlatButton(
        highlightColor: Colors.white24,
        splashColor: Colors.white24,
        onPressed: () {
          onClickSave();
        },
        child: Text(
          "保存二维码到相册",
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
    ));

    subviews.add(Container(
      padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
      child: Text(
        "钱包地址",
        style: TextStyle(
          color: Colors.black54,
          fontSize: 14,
        ),
      ),
    ));

    subviews.add(Container(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Text(
        address,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
      ),
    ));

    subviews.add(Container(
      width: 150,
      padding: EdgeInsets.fromLTRB(0, 15, 0, 30),
      child: FlatButton(
        highlightColor: Colors.white24,
        splashColor: Colors.white24,
        onPressed: () {
          DeviceUtils.copyText(address);
          showToast("已复制钱包地址");
        },
        child: Text(
          "复制钱包地址",
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
    ));

    views.add(subgroup);

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(0),
      child: Container(
        constraints: BoxConstraints(
          minHeight: getScreenHeight() -
              BaseFuntion.topbarheight -
              BaseFuntion.appbarheight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: views,
        ),
      ),
    );
  }

  bool saving = false;

  onClickSave() async {
    if (saving) return;

    try {
      FileInfo fileinfo = DefaultCacheManager().getFileFromMemory(url_qrcode);
      if (fileinfo == null || fileinfo.file == null) {
        showToast("请稍等...二维码正在加载");
        return;
      }

      saving = true;

      Permission permission =
          Platform.isIOS ? Permission.photos : Permission.storage;
      PermissionStatus pstatus = await permission.request();
      if (!pstatus.isGranted) {
        openAppSettings();
        saving = false;
        return;
      }

      // 读文件
//      print(fileinfo.file);
      Uint8List data = await fileinfo.file.readAsBytes();
//      print("qrcode image Uint8List size=" + data.length.toString());

      // 保存
      String result = await ImageGallerySaver.saveImage(data); //这个是核心的保存图片的插件
      print(result); //保存图片的路径
      if (StringUtils.isNotEmpty(result))
        showToast("二维码已保存到相册");
      else
        showToast("保存失败");
      return;
    } catch (e) {
      print("onClickSave error");
      print(e);
    }
    saving = false;
  }
}
