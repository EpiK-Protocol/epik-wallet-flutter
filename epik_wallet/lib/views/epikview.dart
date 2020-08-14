import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';


class EpikView extends BaseInnerWidget
{
  EpikView(Key key) : super(key: key) {}

  @override
  BaseInnerWidgetState<BaseInnerWidget> getState() {
    return _EpikViewState();
  }

  @override
  int setIndex() {
    return 1;
  }

}

class _EpikViewState extends BaseInnerWidgetState<EpikView>
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