import 'dart:ui';

import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/api/api_mainnet.dart';
import 'package:epikwallet/model/Expert.dart';
import 'package:epikwallet/model/ExpertBaseInfo.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';



///矿工
class MinnerView extends BaseInnerWidget {
  MinnerView(Key key) : super(key: key) {}

  @override
  BaseInnerWidgetState<BaseInnerWidget> getState() {
    return MinnerViewState();
  }

  @override
  int setIndex() {
    return 3;
  }
}

class MinnerViewState extends BaseInnerWidgetState<MinnerView> {

  @override
  void initStateConfig() {
    super.initStateConfig();
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);

    refresh();
  }

  bool isFirst = true;

  refresh() async {
    if (isFirst) {
      isFirst = false;
    }

  }


  @override
  Widget buildWidget(BuildContext context) {

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.fromLTRB(0, BaseFuntion.topbarheight, 0, 0),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          colors: [
            Color(0xfff7e6f0),
            Colors.white,
          ],
          center: Alignment.center,
          radius: 1,
          tileMode: TileMode.clamp,
        ),
      ),
      alignment: Alignment.center,
      child: Text("矿工 TODO"),
    );
  }

  void onClickErrorWidget() {
    refresh();
  }

  void onClickEmptyWidget() {
    refresh();
  }

}
