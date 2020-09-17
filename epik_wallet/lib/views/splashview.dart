import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/mainview.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class SplashView extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> getState() {
    return _SplashViewState();
  }
}

class _SplashViewState extends BaseWidgetState<SplashView>
    with TickerProviderStateMixin {
  Timer timer;

  AnimationController controller;

  bool localImage=true;
  String netImageUrl;

  @override
  void initState() {
    isTopBarShow = false; //状态栏是否显示
    isAppBarShow = false; //导航栏是否显示
    super.initState();

//    if(StringUtils.isNotEmpty(serviceConfigMgr?.config?.splash_image))
//    {
//      netImageUrl = serviceConfigMgr.config.splash_image;
//      localImage = false;
//    }

    timer = Timer(Duration(seconds: 2), () {
      ViewGT.showView(context, MainView(),model: ViewPushModel.PushReplacement);
      timer = null;
    });
  }


  @override
  void dispose() {
    if (controller != null) controller.dispose();
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    if (controller == null) {
      controller = new AnimationController(
          duration: const Duration(milliseconds: 500), vsync: this);
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
                child: localImage? getLocalImage():getNetImage(),
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

  Widget getLocalImage()
  {
    return Image(
        image: AssetImage("assets/img/bg_splash.png"),
        fit: BoxFit.fitHeight,
    );
  }

  Widget getNetImage()
  {
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
              child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation(ResColor.black_10)),
            )
          ],
        );
      },
    );
  }

  clickToLogin() {
    if (timer != null && timer.isActive) {
      timer.cancel();
      ViewGT.showView(context, MainView(),model: ViewPushModel.PushReplacement);
    }
  }
}
