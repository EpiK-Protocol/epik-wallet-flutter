import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:qrcode/qrcode.dart';
import 'package:epikwallet/localstring/resstringid.dart';

/// 二维码扫描
class QrcodeScanView extends BaseWidget {

  QrcodeScanView();

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _QrcodeScanViewState();
  }
}

class _QrcodeScanViewState extends BaseWidgetState<QrcodeScanView>
    with TickerProviderStateMixin {
  QRCaptureController _captureController = QRCaptureController();

  Animation<Alignment> _animation;
  AnimationController _animationController;

  bool working = false;

  @override
  void initState() {
    isTopBarShow = false; //状态栏是否显示
    isAppBarShow = false; //导航栏是否显示
    super.initState();
//    setAppBarTitle("扫一扫");

    _captureController.onCapture((data) {
      if (working) return;

      if (StringUtils.isNotEmpty(data)) {
        working = true;
        print('onCapture----$data');

        _captureController.pause(); // 暂停画面

        // 震动
        Vibrate.canVibrate.then((ok) {
          Vibrate.feedback(FeedbackType.success);
        });
        eventMgr.send(EventTag.SCAN_QRCODE_RESULT,data);
        finish(data); //结束当前页面
      }
    });

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1500));
    _animation =
        AlignmentTween(begin: Alignment.topCenter, end: Alignment.bottomCenter)
            .animate(_animationController)
              ..addListener(() {
                setState(() {});
              })
              ..addStatusListener((status) {
                if (status == AnimationStatus.completed) {
                  _animationController.reverse();
                } else if (status == AnimationStatus.dismissed) {
                  _animationController.forward();
                }
              });
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(ResString.get(context, RSID.qsv_1));
  }

  @override
  void onCreate() {
    super.onCreate();
  }

  @override
  void dispose() {
    _captureController.pause();
    _captureController = null;
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Container(
      color: Color(0xff000000),
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            bottom: 0,
            child: getContent(),
          ),
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            height: getTopBarHeight() + getAppBarHeight(),
            child: getTitleBar(),
          ),
        ],
      ),
    );
  }

  Widget getTitleBar() {
    return Container(
      height: getTopBarHeight() + getAppBarHeight(),
      padding: EdgeInsets.fromLTRB(10, getTopBarHeight(), 0, 0),
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: clickAppBarBack,
        child: Icon(
          OMIcons.arrowBackIos,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget getContent() {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: QRCaptureView(controller: _captureController),
        ),

        Positioned(
          left: 50,
          right: 50,
          top: getScreenHeight()/4,
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              alignment: _animation.value,
              children: <Widget>[
                Image.asset('assets/img/ic_qrcode_scan.png')
              ],
            ),
          ),
        ),

      ],
    );
  }
}
