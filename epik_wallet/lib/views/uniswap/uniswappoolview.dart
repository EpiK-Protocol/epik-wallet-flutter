import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class UniswapPoolView extends BaseInnerWidget {

  // 可能是空
  WalletAccount walletAccount;

  UniswapPoolView(this.walletAccount);

  @override
  BaseInnerWidgetState<BaseInnerWidget> getState() {
    return UniswapPoolViewState();
  }

  @override
  int setIndex() {
    return 0;
  }

}

class UniswapPoolViewState
    extends BaseInnerWidgetState<UniswapPoolView> {

  @override
  void initStateConfig() {
    super.initStateConfig();
    bodyBackgroundColor = Colors.transparent;
  }

  @override
  Widget buildWidget(BuildContext context) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(0),
      child: Container(
        constraints: BoxConstraints(
          minHeight: getScreenHeight() -
              BaseFuntion.topbarheight -
              BaseFuntion.appbarheight,
        ),
        child:Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 300,
              margin: EdgeInsets.fromLTRB(30, 30, 30, 30),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                elevation: 5,
                shadowColor: Colors.black26,
              ),
            ),
          ],
        ),
      ),
    );
  }

}