import 'package:flutter/cupertino.dart';

class DashLineWidget extends StatelessWidget {

  final Axis axis; // 虚线的方向
  final double width; // 整个虚线的宽度
  final double height; // 整个虚线的高度
  final double dashWidth; // 每根虚线的宽度
  final double dashHeight; // 每根虚线的高度
  final double spaceWidth; // 间隔宽度
  final Color color; // 虚线的颜色
  final EdgeInsetsGeometry margin;

  DashLineWidget({
    Key key,
    this.axis = Axis.horizontal,
    this.width,
    this.height,
    this.dashWidth = 10,
    this.dashHeight = 1,
    this.spaceWidth = 5,
    this.color = const Color(0xffeeeeee),
    this.margin,
  }) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.width,
      height: this.height,
      margin: this.margin,
      child: LayoutBuilder(
        builder: (BuildContext context,BoxConstraints constraints) {
          final boxWidth = constraints.constrainWidth();
          final dashCount = (boxWidth / (dashWidth+spaceWidth)).floor();

          return Flex(
            direction: this.axis,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (int index){
              return SizedBox(
                width: this.dashWidth,
                height: this.dashHeight,
                child: DecoratedBox(decoration: BoxDecoration(color: this.color)),
              );
            }),
          );
        },
      ),
    );
  }
}