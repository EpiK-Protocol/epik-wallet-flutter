import 'package:bip39/bip39.dart' as bip39;
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/model/CreateAccountModel.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/views/wallet/create/createwalletview.dart';
import 'package:epikwallet/views/wallet/create/verifymnemonicview.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/material.dart';

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
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: getScreenHeight() - BaseFuntion.topbarheight - BaseFuntion.appbarheight_def,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(height: 20),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 20),
              child: Text(
                ResString.get(context, RSID.cmv_1), //"备份助记词",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
              child: Text(
                ResString.get(context, RSID.cmv_2), // "请备份好您的助记词，不要截图、拍照，不要泄漏给他人！\nEpiK Portal不存储用户数据，无法提供找回或重置的服务。",
                style: TextStyle(
                  color: Colors.white, //Colors.redAccent,
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 40, 30, 15),
              child: Row(
                children: <Widget>[
                  Text(
                    ResString.get(context, RSID.cmv_3), // "您的助记词",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
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
                      icon: Icon(Icons.refresh, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            getMnemonicGridWidget(),
            Container(
              margin: EdgeInsets.fromLTRB(30, 40, 30, 0),
              height: 44,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: LoadingButton(
                      gradient_bg: ResColor.lg_1,
                      color_bg: Colors.transparent,
                      disabledColor: Colors.transparent,
                      height: 40,
                      text: ResString.get(context, RSID.cmv_4),
                      // "我已备份",
                      textstyle: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      bg_borderradius: BorderRadius.circular(4),
                      onclick: (lbtn) {
                        clickNextSetp();
                      },
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
      gridItemHightRatio = (getScreenWidth() - 30 * 2 - 10 * 3) / 4.0 / 40.0; //    每个item的宽 / 高 = 比例
    }

    List<Widget> items = [];

    if (mnemonic_list != null) {
      mnemonic_list.forEach((text) {
        items.add(
          // FlatButton(
          //   highlightColor: Colors.white24,
          //   splashColor: Colors.white24,
          //   onPressed: () {},
          //   padding: EdgeInsets.zero,
          //   child: Text(
          //     text,
          //     style: TextStyle(
          //       color: ResColor.b_1,
          //       fontSize: 14,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          //   color: Colors.white,
          //   //Color(0xff1A1C1F),
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.all(Radius.circular(4)),
          //   ),
          // ),
          TextButton(
            onPressed: () {},
            child: Text(
              text,
              style: TextStyle(
                color: ResColor.b_1,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ButtonStyle(
              //padding
              padding: MaterialStateProperty.all(EdgeInsets.zero),
              //阴影
              elevation: MaterialStateProperty.all(0),
              //背景色
              backgroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
                // case MaterialState.hovered: //悬停：
                // case MaterialState.focused://焦点
                // case MaterialState.pressed://按住
                // case MaterialState.dragged://拖拽
                // case MaterialState.selected://选中
                // case MaterialState.disabled://禁用
                // case MaterialState.error://错误
                if (states.contains(MaterialState.disabled)) {
                  //禁用时
                  return Colors.white;
                } else if (states.contains(MaterialState.pressed)) {
                  //按住时
                  return Colors.white;
                }
                //默认
                return Colors.white;
              }),
              //前景色 控制btn里的文本和icon颜色
              // foregroundColor:MaterialStateProperty.all(Colors.white),
              //设置水波纹颜色
              overlayColor: MaterialStateProperty.all(Colors.white24),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  // side: widget.side, //描边
                ),
              ),
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
        padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
        //一行的Widget数量
        crossAxisCount: 4,
        //子Widget宽高比例
        childAspectRatio: gridItemHightRatio,
        children: items,
      ),
    );
  }

  createMnemonic() {
    // HD.newMnemonic().then((mnemonic) {
    //   dlog("newMnemonic $mnemonic");
    //   mnemonic_string = mnemonic;
    //   mnemonic_list = mnemonic.split(" ");
    //   if (mounted) setState(() {});
    // });

    String mnemonic = bip39.generateMnemonic();
    dlog("newMnemonic $mnemonic");
    mnemonic_string = mnemonic;
    mnemonic_list = mnemonic.split(" ");
    if (mounted) setState(() {});
  }

  clickLastSetp() {
    ViewGT.showView(context, CreateWalletView(), model: ViewPushModel.PushReplacement);
  }

  clickNextSetp() {
    widget._CreateAccountModel.mnemonic_string = mnemonic_string;
    widget._CreateAccountModel.mnemonic_list = mnemonic_list;
    ViewGT.showView(context, VerifyMnemonicView(widget._CreateAccountModel), model: ViewPushModel.PushReplacement);
  }
}
