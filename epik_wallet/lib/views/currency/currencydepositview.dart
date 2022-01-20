import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui show ImageByteFormat, Image;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
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

  GlobalKey key_card = GlobalKey();

  @override
  void initStateConfig() {
//    setAppBarTitle("收款");

    isTopBarShow = false; //状态栏是否显示
    isAppBarShow = false; //导航栏是否显示
    isTopFloatWidgetShow = true;

    switch (widget.currencysymbol) {
      case CurrencySymbol.EPK:
        {
          address = widget.walletaccount.epik_EPK_address;
          break;
        }
      default:
        {
          address = widget.walletaccount.hd_eth_address;
        }
    }
//    url_qrcode = "http://qr.topscan.com/api.php?text=" + address;
    url_qrcode = "https://wenhairu.com/static/api/qr/?size=300&text=" + address;
  }

  @override
  Widget getTopFloatWidget() {
    return Padding(
      padding: EdgeInsets.only(top: getTopBarHeight()),
      child: getAppBar(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle("${RSID.deposit.text} ${widget.currencysymbol.symbol}");
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
  Widget buildWidget(BuildContext context) {
    List<Widget> views = [];

    List<Widget> subviews = [];
    Widget subgroup = RepaintBoundary(
      key: key_card,
      child: Container(
        margin: EdgeInsets.fromLTRB(30, 40, 30, 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: ResColor.b_3,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: subviews,
        ),
      ),
    );

    //钱包地址
    subviews.add(Container(
      padding: EdgeInsets.fromLTRB(0, 21, 0, 19),
      child: Text(
        "${RSID.cdv_2.text} ${widget.currencysymbol.networkTypeNorm}",//ResString.get(context, RSID.cdv_2), //"钱包地址",
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
        ),
      ),
    ));

    double iconsize=(getScreenWidth() - 100 - 140) * 0.2;
    double iconsize_net=iconsize*0.4;

    //二维码
    subviews.add(Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(70, 0, 70, 0),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
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
                            strokeWidth: 2, valueColor: AlwaysStoppedAnimation(ResColor.black_10)),
                      )
                    ],
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: iconsize,
                height: iconsize,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      right: 0,
                      bottom: 0,
                      child: Image.asset(
                        widget.currencysymbol.iconUrl,
                      ),
                    ),
                    Positioned(
                      right:0,
                      bottom: 0,
                      width: iconsize_net,
                      height: iconsize_net,
                      child: Image.asset(
                        widget.currencysymbol.networkType.iconUrl,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));

    subviews.add(Container(
      padding: EdgeInsets.fromLTRB(30, 21, 30, 19),
      child: Text(
        address,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
        ),
      ),
    ));

    subviews.add(
      LoadingButton(
        margin: EdgeInsets.fromLTRB(30, 0, 30, 20),
        // gradient_bg: ResColor.lg_1,
        color_bg: Color(0xff424242),
        disabledColor: Color(0xff424242),
        height: 40,
        text: ResString.get(context, RSID.cdv_1),
        //"保存二维码到相册",
        textstyle: TextStyle(
          color: Colors.white,
          fontSize: 17,
        ),
        bg_borderradius: BorderRadius.circular(4),
        onclick: (lbtn) {
          onClickSave();
        },
      ),
    );

    subviews.add(
      LoadingButton(
        margin: EdgeInsets.fromLTRB(30, 0, 30, 20),
        // gradient_bg: ResColor.lg_1,
        color_bg: Color(0xff424242),
        disabledColor: Color(0xff424242),
        height: 40,
        text: ResString.get(context, RSID.cdv_4),
        // "复制钱包地址",
        textstyle: TextStyle(
          color: Colors.white,
          fontSize: 17,
        ),
        bg_borderradius: BorderRadius.circular(4),
        onclick: (lbtn) {
          DeviceUtils.copyText(address);
          showToast(ResString.get(context, RSID.cdv_3)); //"已复制钱包地址");
        },
      ),
    );

    CurrencySymbol nettype_cs = widget.currencysymbol.networkType;
    String nettype_str = "";
    if (nettype_cs == CurrencySymbol.ETH) {
      // nettype_str="(ERC20)";
    }

    subviews.add(Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(30, 0, 30, 20),
      padding: EdgeInsets.fromLTRB(20, 11, 20, 11),
      decoration: BoxDecoration(
        color: ResColor.warning_bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        // "请勿转入非 ${widget.currencysymbol.symbol}${nettype_str} 资产到以上地址，否则转入资产将永久损失且无法找回。",
        RSID.cdv_8.replace(["${widget.currencysymbol.symbol}${nettype_str}"]),
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 14,
          color: ResColor.warning_text,
        ),
      ),
    ));

    views.add(subgroup);

    Widget sv = SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(0),
      child: Container(
        constraints: BoxConstraints(
          minHeight: getScreenHeight() - BaseFuntion.topbarheight - BaseFuntion.appbarheight_def,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: views,
        ),
      ),
    );

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: getAppBarHeight() + getTopBarHeight() + 128,
            decoration: BoxDecoration(
              gradient: ResColor.lg_1,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          Positioned(left: 0, right: 0, bottom: 0, top: getAppBarHeight() + getTopBarHeight(), child: sv),
        ],
      ),
    );
  }

  bool saving = false;

  onClickSave() async {
    if (saving) return;

    bool isWidgetImage = true;

    try {
      FileInfo fileinfo = await DefaultCacheManager().getFileFromMemory(url_qrcode);
      dlog(fileinfo.file.path);
      if (fileinfo == null || fileinfo.file == null) {
        showToast(ResString.get(context, RSID.cdv_5)); //"请稍等...二维码正在加载");
        return;
      }

      Uint8List data = null;
      if (isWidgetImage) {
        //从widget上截图  正式打包才能用  debug无效

        // 1. 获取 RenderRepaintBoundary
        RenderRepaintBoundary boundary = key_card.currentContext.findRenderObject();
        // 2. 生成 Image
        ui.Image image = await boundary.toImage(pixelRatio: 3);
        // 3. 生成 Uint8List
        ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        data = byteData.buffer.asUint8List();
      } else {
        // 读 二维码 文件
        data = await fileinfo.file.readAsBytes();
      }

      dlog("qrcode image Uint8List size=" + data.length.toString());

      saving = true;

      Permission permission = Platform.isIOS ? Permission.photos : Permission.storage;
      PermissionStatus pstatus = await permission.request();
      if (!pstatus.isGranted) {
        openAppSettings();
        saving = false;
        return;
      }

      // Directory d1 = await getApplicationSupportDirectory(); //应用支持目录 /data/user/0/com.teda.teda_oa/files
      // Directory d2 = await getTemporaryDirectory();//AppDate  /data/user/0/com.teda.teda_oa/cache
      // Directory d3 = await getApplicationDocumentsDirectory();// /data/user/0/com.teda.teda_oa/app_flutter
      // List<Directory> d4 = await getExternalStorageDirectories();//sd卡 /storage/emulated/0/Android/data/com.teda.teda_oa/files
      // List<Directory> d5 = await getExternalCacheDirectories();//外部存储  /storage/emulated/0/Android/data/com.teda.teda_oa/cache
      String result = "";
      if (DeviceUtils.isAndroid) {
        List<Directory> d4 = await getExternalStorageDirectories(); //sd卡
        if (d4 != null && d4.length > 0) {
          Directory dir = d4[0];
          if (!dir.existsSync()) dir.createSync();
          File file = File(dir.path + "/qrcode/${DateUtil.getNowDateMs()}.png");
          if (!file.parent.existsSync()) file.parent.createSync();
          file.createSync();
          file.writeAsBytesSync(data);
          result = file.path;
          await ImageGallerySaver.saveFile(result);
          print(file.path);
        }
      } else {
        // 保存
        result = await ImageGallerySaver.saveImage(data); //这个是核心的保存图片的插件
        print(result); //保存图片的路径
      }

      if (StringUtils.isNotEmpty(result))
        showToast(ResString.get(context, RSID.cdv_6)); //"二维码已保存到相册");
      else
        showToast(ResString.get(context, RSID.cdv_7)); //"保存失败");
      saving = false;
      return;
    } catch (e, s) {
      print("onClickSave error");
      print(e);
      print(s);
    }
    saving = false;
  }
}
