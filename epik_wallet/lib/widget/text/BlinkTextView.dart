import 'package:epikwallet/utils/res_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

//渐变色动画闪烁的文字
class BlinkTextView extends StatefulWidget {
  Color backgroundColor;

  String text;

  double fontSize = 50;

  String fontFamily;

  double shader_w, shader_h;

  int animation_duration_ms = 1500;

  Alignment begin, end;

  List<Color> colors;
  List<double> stops;

  BlinkTextView(
    this.text, {
    Key key,
    this.fontSize = 50,
    this.fontFamily = "DIN_Condensed_Bold",
    this.animation_duration_ms = 1500,
    this.shader_w,
    this.shader_h,
    this.colors = const [ResColor.white_10, ResColor.white_40, ResColor.white_10],
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BlinkTextViewState();
  }
}

class BlinkTextViewState extends State<BlinkTextView> with TickerProviderStateMixin<BlinkTextView> {
  AnimationController _controller;
  Animation _animation;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      _controller = AnimationController(duration: Duration(milliseconds: widget.animation_duration_ms), vsync: this);
      _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
      _controller.repeat();
    }

    if (widget.shader_w == null || widget.shader_w == 0) widget.shader_w = MediaQuery.of(context).size.width;
    if (widget.shader_h == null || widget.shader_h == 0) widget.shader_h = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        double value = _animation.value;
        Gradient gradient = LinearGradient(
          begin: widget.begin, //Alignment.topLeft,
          end: widget.end, //Alignment.bottomRight,
          colors: widget.colors,
          stops: [value - 0.2, value, value + 0.2],
        );
        Shader shader = gradient.createShader(Rect.fromLTWH(0, 0, widget.shader_w, widget.shader_h));
        return Text(
          widget.text ?? "",
          style: TextStyle(
            fontSize: widget.fontSize,
            fontFamily: widget.fontFamily,
            foreground: Paint()..shader = shader,
          ),
        );
      },
    );
  }
}
