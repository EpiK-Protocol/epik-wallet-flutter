import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';

class UniswapPoolRemoveView extends BaseWidget {
  WalletAccount walletAccount;
  UniswapInfo uniswapinfo;

  UniswapPoolRemoveView(this.walletAccount, this.uniswapinfo);

  BaseWidgetState<BaseWidget> getState() {
    return UniswapPoolRemoveViewState();
  }
}

class UniswapPoolRemoveViewState
    extends BaseWidgetState<UniswapPoolRemoveView> {
  
  Widget buildWidget(BuildContext context) {
    return Container();
  }

}
