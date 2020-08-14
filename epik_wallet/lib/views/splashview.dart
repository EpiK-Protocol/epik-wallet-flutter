import 'package:epikwallet/base/_base_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';


class SplashView extends BaseWidget
{
  @override
  BaseWidgetState<BaseWidget> getState() {
    return _SplashViewState();
  }

}

class _SplashViewState extends BaseWidgetState<SplashView>
{
  @override
  void initState() {
    isTopBarShow = false; //状态栏是否显示
    isAppBarShow = false; //导航栏是否显示
    super.initState();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Container(
      color: Color(0xffffffff),
    );
  }

}