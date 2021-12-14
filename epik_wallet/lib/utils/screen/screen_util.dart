
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WHScreenUtil extends ScreenUtil {

  static bool isVertical = true;

  static initUtil(BuildContext context)
  {
    ScreenUtil.instance = ScreenUtil(width: 375, height: 667)..init(context);
    isVertical = ScreenUtil.screenWidth < ScreenUtil.screenHeight;
  }

  ///返回设备宽度 px
  static getScreenWidthPx() {
    return ScreenUtil.screenWidth;
  }

  static getScreenWidth() {
    return ScreenUtil.screenWidthDp;
  }
//屏幕尺寸类，

  /**
   * 获取屏幕宽与设计稿宽度等比的DP
   */
  static getWdp(double size)
  {
    return ScreenUtil.getInstance().setWidth(size);
  }

  /**
   * 获取屏幕高与设计稿高度等比的DP
   */
  static getHdp(double size)
  {
    return ScreenUtil.getInstance().setHeight(size);
  }

  /**
   * 取屏幕最短边与设计稿等比的DP
   */
  static getAutoDp(double size)
  {
    if(isVertical)
      return getWdp(size);
    else
      return getHdp(size);
  }

  static double dp2px(double size)
  {
    return ScreenUtil.pixelRatio*size;
  }

  static double onePx()
  {
    return 1/ScreenUtil.pixelRatio;
  }
}
