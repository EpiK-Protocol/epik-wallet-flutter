import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';

class ThinkTankView extends BaseInnerWidget
{
  ThinkTankView(Key key) : super(key: key) {}

  @override
  BaseInnerWidgetState<BaseInnerWidget> getState() {
    return ThinkTankViewState();
  }

  @override
  int setIndex() {
    return 3;
  }

}

class ThinkTankViewState extends BaseInnerWidgetState<ThinkTankView>{
  @override
  Widget buildWidget(BuildContext context) {
    return Container();
  }

}