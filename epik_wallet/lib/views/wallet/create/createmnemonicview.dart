import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/logic/WalletUtils.dart';
import 'package:epikwallet/model/CreateAccountModel.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/views/wallet/create/createwalletview.dart';
import 'package:epikwallet/views/wallet/create/verifymnemonicview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class CreateMnemonicView extends BaseWidget {
  CreateAccountModel _CreateAccountModel;

  CreateMnemonicView(this._CreateAccountModel);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _CreateMnemonicViewState();
  }
}

class _CreateMnemonicViewState extends BaseWidgetState<CreateMnemonicView> {
  String mnemonic_string;
  List<String> mnemonic_list;

  @override
  void initState() {
    super.initState();
//    WalletUtils.createSeedFormMnemonic(
//            "equip will roof matter pink blind book anxiety banner elbow sun young")
//        .then((seed) async {
//
//       HDWallet hdWallet = await WalletUtils.createHdWallet(seed, Bip32Path.filecoin);
//       String base58 = hdWallet.base58Priv;
//        dlog("base58="+base58);
//       HDWallet hdWallet2 = HDWallet.fromBase58(base58);
//        dlog("hdWallet2.address = ${hdWallet2.address}");
//        dlog("hdWallet2.pubKey = ${hdWallet2.pubKey}");
//        dlog("hdWallet2.privkey = ${hdWallet2.privKey}");
//        dlog("hdWallet2.wif = ${hdWallet2.wif}");
//        dlog("hdWallet2.networktype = ${hdWallet2.network.toString()}");
//
//    });
  }

  @override
  void initStateConfig() {
    isTopBarShow = true; //状态栏是否显示
    isAppBarShow = true; //导航栏是否显示
    setAppBarTitle("");
  }

  @override
  void onCreate() {
    super.onCreate();
    createMnemonic();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child:ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: getScreenHeight()-BaseFuntion.topbarheight-BaseFuntion.appbarheight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(15, 6, 15, 10),
              child: Text(
                "备份助记词",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
              child: Text(
                "请备份好您的助记词，不要截图、拍照，不要泄漏给他人！\nEPIK不存储用户数据，无法提供找回或重置的服务。",
                style: TextStyle(
                  color: ResColor.black_50,
                  fontSize: 13,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 5, 15, 0),
              child: Row(
                children: <Widget>[
                  Text(
                    "您的助记词",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  SizedBox(
                    width: 35,
                    height: 35,
                    child: IconButton(
                      onPressed: () {
                        createMnemonic();
                      },
                      icon: Icon(Icons.refresh, size: 20, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
            getMnemonicGridWidget(),
            Container(
              margin: EdgeInsets.fromLTRB(15, 50, 15, 0),
              height: 44,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      height: 44,
                      child: FlatButton(
                        highlightColor: Colors.white24,
                        splashColor: Colors.white24,
                        onPressed: () {
                          clickLastSetp();
                        },
                        child: Text(
                          "上一步",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        color: Color(0xff393E45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(22)),
                        ),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(left: 10)),
                  Expanded(
                    child: Container(
                      height: 44,
                      child: FlatButton(
                        highlightColor: Colors.white24,
                        splashColor: Colors.white24,
                        onPressed: () {
                          clickNextSetp();
                        },
                        child: Text(
                          "我已备份",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        color: Color(0xff1A1C1F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(22)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double gridItemHightRatio = 0;

  Widget getMnemonicGridWidget() {
    if (gridItemHightRatio == 0) {
      gridItemHightRatio = (getScreenWidth() - 15 * 2 - 10 * 3) /
          4.0 /
          35.0; //    每个item的宽 / 高 = 比例
    }

    List<Widget> items = [];

    if (mnemonic_list != null) {
      mnemonic_list.forEach((text) {
        items.add(
          FlatButton(
            highlightColor: Colors.white24,
            splashColor: Colors.white24,
            onPressed: () {},
            padding: EdgeInsets.zero,
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            color: Color(0xff1A1C1F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        );
      });
    }

    return Container(
      width: double.infinity,
      child: GridView.count(
        shrinkWrap: true,
        //嵌套 无限内容
        physics: NeverScrollableScrollPhysics(),
        //嵌套 无滚动
        //水平子Widget之间间距
        crossAxisSpacing: 10,
        //垂直子Widget之间间距
        mainAxisSpacing: 10,
        //GridView内边距
        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
        //一行的Widget数量
        crossAxisCount: 4,
        //子Widget宽高比例
        childAspectRatio: gridItemHightRatio,
        children: items,
      ),
    );
  }

  createMnemonic() {
    WalletUtils.createMnemonic().then((mnemonic) {
      mnemonic_string = mnemonic;
      mnemonic_list = mnemonic.split(" ");
      if (mounted) setState(() {});
    });
  }

  clickLastSetp() {
    ViewGT.showView(context, CreateWalletView(),
        model: ViewPushModel.PushReplacement);
  }

  clickNextSetp()
  {

    widget._CreateAccountModel.mnemonic_string = mnemonic_string;
    widget._CreateAccountModel.mnemonic_list = mnemonic_list;
    ViewGT.showView(context, VerifyMnemonicView(widget._CreateAccountModel),
        model: ViewPushModel.PushReplacement);
  }

}
