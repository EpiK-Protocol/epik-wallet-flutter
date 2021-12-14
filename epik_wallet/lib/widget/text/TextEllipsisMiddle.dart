
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui show TextHeightBehavior;

enum TextOverflowEm {clip,fade,ellipsisMiddle,ellipsisEnd,visible,}

// text 可以中间缩略
class TextEm extends Text {
  final String data;
  final TextStyle style;
  final StrutStyle strutStyle;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final Locale locale;
  final bool softWrap;
  final double textScaleFactor;
  final int maxLines;
  final String semanticsLabel;
  final TextWidthBasis textWidthBasis;
  final ui.TextHeightBehavior textHeightBehavior;
  final TextOverflowEm wxOverflow;

  final RenderParagraph __renderParagraph = RenderParagraph(
    TextSpan(
      text: "",
      style: TextStyle(
        fontSize: 14,
      ),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  );

  TextEm(
      this.data, {
        Key key,
        this.style,
        this.strutStyle,
        this.textAlign,
        this.textDirection,
        this.locale,
        this.softWrap,
        this.wxOverflow = TextOverflowEm.ellipsisMiddle,
        this.textScaleFactor,
        this.maxLines,
        this.semanticsLabel,
        this.textWidthBasis,
        this.textHeightBehavior,
      }):super(data);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, boxConstraint) {
      return Text(
        wxOverflow !=  TextOverflowEm.ellipsisMiddle ? data : _finalString(boxConstraint.maxWidth, data),
        style: style ?? TextStyle(color: style?.color ?? Colors.grey[900], fontSize: style?.fontSize ?? 14.0),
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: _getOverflow(wxOverflow),
        textScaleFactor: textScaleFactor,
        maxLines: 1,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
      );
    });
  }

  TextOverflow _getOverflow(TextOverflowEm overflow) {
    TextOverflow textOverflow;
    if (overflow == TextOverflowEm.ellipsisEnd || overflow == TextOverflowEm.ellipsisMiddle) {
      textOverflow = TextOverflow.ellipsis;
    } else if (overflow == TextOverflowEm.clip) {
      textOverflow = TextOverflow.clip;
    } else if (overflow == TextOverflowEm.visible) {
      textOverflow = TextOverflow.visible;
    } else if (overflow == TextOverflowEm.fade) {
      textOverflow = TextOverflow.fade;
    }
    return textOverflow;
  }

  RenderParagraph _renderParagraph(String text){
    __renderParagraph.text = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: style?.fontSize ?? 14.0,
      ),
    );
    return __renderParagraph;
  }

  String _finalString(double maxWidth, String text){

    int startIndex = 0;
    int endIndex = text.length;
    // 计算当前text的宽度
    double width = _renderParagraph(text).computeMinIntrinsicWidth(style?.fontSize ?? 14.0);
    // 当前text的宽度小于最大宽度，直接返回
    if(width < maxWidth) return text;
    // 计算...的宽度
    double ellipsisWidth = _renderParagraph("...").computeMinIntrinsicWidth(style?.fontSize ?? 14.0);
    double leftWidth =( maxWidth - ellipsisWidth ) * 0.5;
    int s = startIndex, e = endIndex;
    // 计算显示...的开始位置
    while(s < e){
      int m = ((s + e ) * 0.5 ).floor();
      double width  = _renderParagraph(text.substring(0,m)).computeMinIntrinsicWidth(style?.fontSize ?? 14.0);
      if(width > leftWidth){
        e = m;
      } else {
        s = m;
      }
      if(e - s <= 1){
        startIndex = s;
        break;
      }
    }

    s = startIndex;
    e = endIndex;
    // 计算显示...的结束位置
    while(s < e){
      int m = ((s + e ) * 0.5 ).ceil();
      double width = _renderParagraph(text.substring(m,endIndex)).computeMinIntrinsicWidth(style?.fontSize ?? 14.0);
      if(width > leftWidth){
        s = m;
      } else {
        e = m;
      }
      if(e - s <= 1){
        endIndex = e;
        break;
      }
    }
    double leftW  = _renderParagraph(text.substring(0,startIndex)).computeMinIntrinsicWidth(style?.fontSize ?? 14.0);
    double rightW = _renderParagraph(text.substring(endIndex,text.length)).computeMinIntrinsicWidth(style?.fontSize ?? 14.0);

    double margin = maxWidth - leftW - rightW -ellipsisWidth ;
    double startNext = _renderParagraph(text.substring(startIndex,startIndex + 1)).computeMinIntrinsicWidth(style?.fontSize ?? 14.0);
    double endBefore = _renderParagraph(text.substring(endIndex-1,endIndex)).computeMinIntrinsicWidth(style?.fontSize ?? 14.0);
    // 总体margin 可以再填下一个字符，将该字符填进去
    if(margin >= startNext && margin >= endBefore){
      if(startNext >= endBefore){
        startIndex = startIndex + 1;
      } else {
        endBefore = endBefore - 1;
      }
    } else if (margin >= startNext){
      startIndex = startIndex + 1;
    } else if (margin >= endBefore){
      endIndex = endIndex -1;
    }
    return text.replaceRange(startIndex, endIndex, "...");
  }
}