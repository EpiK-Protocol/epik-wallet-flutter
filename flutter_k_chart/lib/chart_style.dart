import 'package:flutter/material.dart';

class ChartColors {
  ChartColors._();

  //背景颜色
  static const Color bgColor = Color(0x00ffffff); //Color(0xff0D141E);//背景颜色
  static const Color kLineColor = Color(0xff4C86CD);
  static const Color gridColor = Color(0x33ffffff);//Color(0x22000000); //Color(0xff4c5c74);//网格颜色
  static const List<Color> kLineShadowColor = [
    Color(0x554C86CD),
    Color(0x00000000)
  ]; //k线阴影渐变
  static const Color ma5Color = Color(0xffC9B885);
  static const Color ma10Color = Color(0xff6CB0A6);
  static const Color ma30Color = Color(0xff9979C6);
  static const Color upColor = Color(
      0xff4ADE2C); //Color(0xffcfe9bb);//Color(0x60AED581);  //Color(0xff4DAA90);
  static const Color dnColor = Color(
      0xffF24F30); //Color(0xfffeccdd);//Color(0x60FF80AB); //Color(0xffC15466);
  static const Color volColor = Color(0xff4729AE);
  static const Color macdColor = Color(0xff4729AE);
  static const Color difColor = Color(0xffC9B885);
  static const Color deaColor = Color(0xff6CB0A6);

  static const Color kColor = Color(0xffC9B885);
  static const Color dColor = Color(0xff6CB0A6);
  static const Color jColor = Color(0xff9979C6);
  static const Color rsiColor = Color(0xffC9B885);

  //右边y轴刻度
  static const Color yAxisTextColor = Color(0x99ffffff);//Color(0x33000000); //Color(0xff60738E);
  //下方时间刻度
  static const Color xAxisTextColor =Color(0x99ffffff);// Color(0x33000000); //Color(0xff60738E);
  //最大最小值的颜色
  static const Color maxMinTextColor =Color(0x99ffffff);// Color(0x66000000); //Color(0xffffffff);

  //深度颜色
  static const Color depthBuyColor = Color(0xff60A893);
  static const Color depthSellColor = Color(0xffC15866);

  //选中后显示值边框颜色
  static const Color markerBorderColor = Color(0x20ffffff); //Color(0x206C7A86);
  //选中后显示值背景的填充颜色
  static const Color markerBgColor = Color(
      0xff3a3a3a); //Color(0xffb8cfea);//Color(0xff0D1722);
  static const Color markerTextColor = Color(0xffffffff);

  //实时线颜色等
  static const Color realTimeBgColor = Color(
      0xff3a3a3a); //Color(0xff4C86CD);//Color(0xff0D1722);// 圆框背景颜色
  static const Color realTimeBgColor_right = Color(
      0xff3a3a3a); //Color(0xffb8cfea);//Color(0xff4C86CD); // 最右边背景颜色
  static const Color rightRealTimeTextColor = Color(
      0xffb8cfea); //Color(0xff4C86CD); // 最右边时文字颜色
  static const Color realTimeTextBorderColor = Color(0xffffffff); // 圆框描边颜色
  static const Color realTimeTextColor = Color(0xffffffff); // 圆框内文字颜色

  //实时线
  static const Color realTimeLineColor = Color(
      0xffffffff); //Color(0xffb8cfea);//Color(0xff4C86CD); //
  static const Color realTimeLongLineColor = Color(
      0xffffffff); //Color(0xffb8cfea);//Color(0xff4C86CD);

  static const Color simpleLineUpColor = Color(0xff6CB0A6);
  static const Color simpleLineDnColor = Color(0xffC15466);

  static const Color vCrossColor = Color(0x33ffffff);//Color(0x10000000); 选中时item叠加的背景色从上到下
  static const Color hCrossColor = Color(0x20000000);
}

class ChartStyle {
  ChartStyle._();

  //点与点的距离
  static const double pointWidth = 11.0;

  //蜡烛宽度
  static const double candleWidth = 8.5;

  //蜡烛中间线的宽度
  static const double candleLineWidth = 1.5;

  //vol柱子宽度
  static const double volWidth = 8.5;

  //macd柱子宽度
  static const double macdWidth = 3.0;

  //垂直交叉线宽度
  static const double vCrossWidth = 8.5;

  //水平交叉线宽度
  static const double hCrossWidth = 0.5;

  //网格
  static const int gridRows = 3,
      gridColumns = 4;

  static const double topPadding = 10.0,
      bottomDateHigh = 20.0,
      childPadding = 25.0;

  static const double defaultTextSize = 10.0;
}
