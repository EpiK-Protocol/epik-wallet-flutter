import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/AIBotLatestMgr.dart';
import 'package:epikwallet/logic/LocalAddressMgr.dart';
import 'package:epikwallet/logic/LocalWebsiteMgr.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/Upgrade.dart';
import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/views/mainview.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SplashView extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> getState() {
    return _SplashViewState();
  }
}

class _SplashViewState extends BaseWidgetState<SplashView> with TickerProviderStateMixin {
  Timer timer;

  AnimationController controller;

  bool localImage = true;
  String netImageUrl;

  @override
  void initState() {
    isTopBarShow = false; //状态栏是否显示
    isAppBarShow = false; //导航栏是否显示
    super.initState();

    //1
//    if(StringUtils.isNotEmpty(serviceConfigMgr?.config?.splash_image))
//    {
//      netImageUrl = serviceConfigMgr.config.splash_image;
//      localImage = false;
//    }

    //2
    // if (ServiceInfo.serverConfig == null || ServiceInfo.homeMenuMap == null) {
    //   loadConfig();
    // } else {
    //   timer = Timer(Duration(seconds: 2), () {
    //     timer = null;
    //     startNextView();
    //   });
    //   ServiceInfo.requestConfig();
    // }

    //3
    time_3 = DateUtil.getNowDateMs();
    loadConfig2();

    // 隐藏底部按钮栏
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
  }

  @override
  void dispose() {
    if (controller != null) controller.dispose();
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    if (controller == null) {
      controller = new AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
      controller.forward();
    }

    return Container(
      color: ResColor.main,
      child: GestureDetector(
        onTap: () {
          clickToLogin();
        },
        child: AnimatedBuilder(
          animation: controller,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: localImage ? getLocalImage() : getNetImage(),
              ),
            ],
          ),
          builder: (context, child) {
            return Opacity(
              opacity: controller.value,
              child: child,
            );
          },
        ),
      ),
    );
  }

  Widget getLocalImage() {
    return Image(
      image: AssetImage("assets/img/bg_splash.png"),
      fit: BoxFit.fitHeight,
    );
  }

  Widget getNetImage() {
    return CachedNetworkImage(
      imageUrl: netImageUrl,
      fit: BoxFit.cover,
      errorWidget: (context, url, error) {
        return getLocalImage();
      },
      placeholder: (context, url) {
//                    return Container(
//                      width: double.infinity,
//                      height: double.infinity,
//                      color: Colors.black12,
//                    );
        return Stack(
          alignment: FractionalOffset(0.5, 0.5),
          children: <Widget>[
            SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(ResColor.black_10)),
            )
          ],
        );
      },
    );
  }

  clickToLogin() {
    if (ServiceInfo.serverConfig == null || ServiceInfo.homeMenuMap == null) return;

    if (timer != null && timer.isActive) {
      timer.cancel();
      startNextView();
    }
  }

  startNextView() {
    ViewGT.showView(context, MainView(), model: ViewPushModel.PushReplacement);
  }

  // loadConfig() async {
  //   int time_1 = DateUtil.getNowDateMs();
  //   await ServiceInfo.requestConfig();
  //   int time_2 = DateUtil.getNowDateMs();
  //   int t = time_2 - time_1;
  //   // ServiceInfo.serverConfig=null;
  //   // ServiceInfo.homeMenuMap=null;
  //   if (ServiceInfo.serverConfig == null || ServiceInfo.homeMenuMap == null) {
  //     if (loadingDialogIsShow != true) showLoadDialog("");
  //     Future.delayed(Duration(milliseconds: 100)).then((value) {
  //       loadConfig();
  //     });
  //   } else {
  //     closeLoadDialog();
  //     if (t <= 2000) await Future.delayed(Duration(milliseconds: 2000 - t));
  //     startNextView();
  //   }
  // }

  int time_3 = 0;

  loadConfig2() async {
    await ServiceInfo.requestConfig();

    // ServiceInfo.serverConfig=null;//todo test
    if (ServiceInfo.serverConfig == null || ServiceInfo.homeMenuMap == null) {
      closeLoadDialog();
      await Future.delayed(Duration(milliseconds: 200));
      MessageDialog.showMsgDialog(
        context,
        title: RSID.request_failed_checknetwork.text,
        titleAlign: TextAlign.center,
        backClose: false,
        touchOutClose: false,
        btnLeft: RSID.retry.text,
        onClickBtnLeft: (dialog) {
          //点击重试
          dialog.dismiss();
          if (loadingDialogIsShow != true) showLoadDialog("");
          Future.delayed(Duration(milliseconds: 100)).then((value) {
            loadConfig2();
          });
        },
      );
    } else
    {
      await AccountMgr().load(); // 加载钱包账户
      await localaddressmgr.load();
      await localwebsitemgr.load();
      await aibotlatestmgr.load();

      bool needRequired = await checkUpgrade();
      if (needRequired == true) {
        //强制升级 不能进入
        return;
      }

      int time_2 = DateUtil.getNowDateMs();
      int t = time_2 - time_3;
      closeLoadDialog();
      try{
        if (t <= 2000) {
          await Future.delayed(Duration(milliseconds: 2000 - t));
        } else {
          await Future.delayed(Duration(milliseconds: 200));
        }
      }catch(e,s){
        print(e);
        print(s);
      }
      startNextView();
    }
  }

  Future<bool> checkUpgrade() async {
    // 检测升级
    try {
      if (ServiceInfo.upgrade != null) {
        dlog("checkUpgrade");
        Upgrade upgrade = ServiceInfo.upgrade;
        await upgrade.checkVersion();
        //判断强制升级
        if (upgrade.needRequired) {
          showUpgradeDialog(upgrade);
          return true;
        }
      } else {
        dlog("checkUpgrade ServiceInfo.upgrade = null");
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  showUpgradeDialog(Upgrade upgrade) {
    MessageDialog.showMsgDialog(
      context,
      title: ResString.get(context, RSID.upgrade_tip),
      //"版本升级提示",
      msg: upgrade.description,
      msgAlign: TextAlign.center,
      btnLeft: upgrade.needRequired ? null : ResString.get(context, RSID.upgrade_cancel),
      // "取消",
      btnRight: ResString.get(context, RSID.upgrade_confirm),
      //"升级",
      touchOutClose: !upgrade.needRequired,
      backClose: !upgrade.needRequired,
      onClickBtnLeft: (dialog) {
        dialog.dismiss();
      },
      onClickBtnRight: (dialog) {
        if (!upgrade.needRequired) {
          dialog.dismiss();
        }
        if (Platform.isAndroid) {
          // 外部下载
          canLaunchUrlString(upgrade.upgrade_url).then((value) {
            if (value) {
              launchUrlString(upgrade.upgrade_url,mode: LaunchMode.externalApplication).then((value) {
                // print("upgrade launch = $value  url = ${upgrade.upgrade_url}");
              });
            }
          });
        } else if (Platform.isIOS) {
          canLaunchUrlString(upgrade.upgrade_url).then((value) {
            if (value) {
              launchUrlString(upgrade.upgrade_url,mode: LaunchMode.externalApplication).then((value) {
                // print("upgrade launch = $value  url = ${upgrade.upgrade_url}");
              });
            }
          });
          // todo  去苹果商店
//        String url = "http://itunes.apple.com/cn/lookup?id=项目包名";
//        canLaunch(url).then((value) {
//          if (value) {
//            launch(url);
//          }
//        });
        }
      },
    );
  }
}
