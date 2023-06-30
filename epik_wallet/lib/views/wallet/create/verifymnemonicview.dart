import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/buildConfig.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/model/CreateAccountModel.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/views/wallet/create/createwalletview.dart';
import 'package:epikwallet/views/wallet/create/verifycreatepasswordview.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/text/diff_scale_text.dart';
import 'package:flutter/material.dart';

class SelectedText {
  String text = "";
  bool isSelected = false;

  SelectedText(this.text, this.isSelected);
}

class VerifyMnemonicView extends BaseWidget {
  CreateAccountModel _CreateAccountModel;

  VerifyMnemonicView(this._CreateAccountModel);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _VerifyMnemonicViewState();
  }
}

class _VerifyMnemonicViewState extends BaseWidgetState<VerifyMnemonicView> {
  String mnemonic_string = "";
  List<SelectedText> mnemonic_list = [];
  List<SelectedText> mnemonic_list_source = [];

  Color bgColor = Colors.white;
  Color bgColor_disabled = const Color(0xff262626);

  @override
  void initState() {
    super.initState();
  }

  @override
  void initStateConfig() {
    isTopBarShow = true; //状态栏是否显示
    isAppBarShow = true; //导航栏是否显示
    setAppBarTitle("");

    widget._CreateAccountModel.mnemonic_list.forEach((text) {
      mnemonic_list_source.add(SelectedText(text, false));
    });
    mnemonic_list_source.shuffle(); // 随机
  }

  @override
  void onCreate() {
    super.onCreate();
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
                ResString.get(context, RSID.vmv_1), //"验证助记词",
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
                ResString.get(context, RSID.vmv_2),
                // "为了安全起见，按照顺序填写助记词以确认该助记词是否有效。",
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
                    ResString.get(context, RSID.vmv_3), // "填写助记词",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            getMnemonicGridWidget_1(),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 40, 30, 15),
              child: Row(
                children: <Widget>[
                  Text(
                    ResString.get(context, RSID.vmv_4), //  "按助记词顺序点击下面词组：",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            getMnemonicGridWidget_2(),
            LoadingButton(
              margin: EdgeInsets.fromLTRB(30, 40, 30, 0),
              gradient_bg: ResColor.lg_1,
              color_bg: Colors.transparent,
              disabledColor: Colors.transparent,
              height: 40,
              text: ResString.get(context, RSID.vmv_1),
              //"验证助记词",
              textstyle: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              bg_borderradius: BorderRadius.circular(4),
              onclick: (lbtn) {
                clickNextSetp();
              },
              onLongClick: BuildConfig.isDebug
                  ? (lbtn) {
                      setState(() {
                        mnemonic_list_source.forEach((element) {
                          element.isSelected = true;
                        });
                        mnemonic_list = [];
                        widget._CreateAccountModel.mnemonic_list.forEach((element) {
                          mnemonic_list.add(SelectedText(element, true));
                        });
                      });
                    }
                  : null,
            ),
            InkWell(
              onTap: () {
                clickRecreate();
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 40, 0, 10),
                padding: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: Text(
                  ResString.get(context, RSID.vmv_5), //  "忘记助记词，重新创建",
                  style: TextStyle(
                    fontSize: 14,
                    color: ResColor.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double gridItemHightRatio = 0;

  Widget getMnemonicGridWidget_1() {
    if (gridItemHightRatio == 0) {
      gridItemHightRatio = (getScreenWidth() - 30 * 2 - 10 * 3) / 4.0 / 40.0; //    每个item的宽 / 高 = 比例
    }

    int size = mnemonic_list_source.length;

    List<Widget> items = [];

    if (mnemonic_list != null) {
      for (int i = 0; i < size; i++) {
        SelectedText text = null;
        if (i < mnemonic_list.length) text = mnemonic_list[i];

        items.add(
          // FlatButton(
          //   highlightColor: Colors.white24,
          //   splashColor: Colors.white24,
          //   onPressed: text == null
          //       ? null
          //       : () {
          //           clickGroup1Cancel(text, i);
          //         },
          //   padding: EdgeInsets.zero,
          //   child: DiffScaleText(
          //     text: text == null ? (i + 1).toString() : text.text,
          //     textStyle: TextStyle(
          //       color: text == null ?Colors.white: ResColor.b_1,
          //       fontSize: 14,
          //       fontFamily: fontFamily_def,
          //       fontWeight:FontWeight.bold,
          //     ),
          //   ),
          //   disabledColor: bgColor_disabled,
          //   color: bgColor,
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.all(Radius.circular(4)),
          //   ),
          // ),
          TextButton(
            onPressed: text == null
                ? null
                : () {
                    clickGroup1Cancel(text, i);
                  },
            child: DiffScaleText(
              text: text == null ? (i + 1).toString() : text.text,
              textStyle: TextStyle(
                color: text == null ? Colors.white : ResColor.b_1,
                fontSize: 14,
                fontFamily: fontFamily_def,
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
                  return bgColor_disabled;
                }
                // else if (states.contains(MaterialState.pressed)) {
                //   //按住时
                //   return Colors.white;
                // }
                //默认
                return bgColor;
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
      }
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

  Widget getMnemonicGridWidget_2() {
    if (gridItemHightRatio == 0) {
      gridItemHightRatio = (getScreenWidth() - 30 * 2 - 10 * 3) / 4.0 / 40.0; //    每个item的宽 / 高 = 比例
    }

    List<Widget> items = [];

    if (mnemonic_list_source != null) {
      for (int i = 0; i < mnemonic_list_source.length; i++) {
        SelectedText text = mnemonic_list_source[i];

        items.add(
          // FlatButton(
          //   highlightColor: Colors.white24,
          //   splashColor: Colors.white24,
          //   onPressed: () {
          //     clickGroup2(text, i);
          //   },
          //   padding: EdgeInsets.zero,
          //   child: Text(
          //     text.text,
          //     style: TextStyle(
          //       color: text.isSelected?Colors.white:ResColor.b_1,
          //       fontSize: 14,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          //   color: text.isSelected ? bgColor_disabled : bgColor,
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.all(Radius.circular(4)),
          //   ),
          // ),
          TextButton(
            onPressed: () {
              clickGroup2(text, i);
            },
            child: Text(
              text.text,
              style: TextStyle(
                color: text.isSelected ? Colors.white : ResColor.b_1,
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
                // if (states.contains(MaterialState.disabled)) {
                //   //禁用时
                //   return Colors.white;
                // } else if (states.contains(MaterialState.pressed)) {
                //   //按住时
                //   return Colors.white;
                // }
                //默认
                return text.isSelected ? bgColor_disabled : bgColor;
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
      }
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

  clickGroup1Cancel(SelectedText text, int index) {
    mnemonic_list.remove(text);
    text.isSelected = false;
    setState(() {});
  }

  clickGroup2(SelectedText text, int index) {
    if (text.isSelected) {
      // 取消
      mnemonic_list.remove(text);
    } else {
      // 添加
      mnemonic_list.add(text);
    }
    text.isSelected = !text.isSelected;
    setState(() {});
  }

  makeMnemonicString() {
    mnemonic_string = "";
    mnemonic_list.forEach((element) {
      mnemonic_string += element.text + " ";
    });
    mnemonic_string = mnemonic_string.trim();
  }

  bool checkParams() {
    if (mnemonic_list == null || mnemonic_list.length < mnemonic_list_source.length) {
//      showToast("请按助记词顺序点击词组填满数字区域");
      showToast(ResString.get(context, RSID.vmv_6));
      return false;
    }

    makeMnemonicString();
    dlog(widget._CreateAccountModel.mnemonic_string);
    dlog("mnemonic_string= $mnemonic_string");
    if (mnemonic_string != widget._CreateAccountModel.mnemonic_string) {
//      showToast("填入的助记词顺序不正确");
      showToast(ResString.get(context, RSID.vmv_7));
      return false;
    }

    return true;
  }

  clickNextSetp() {
    if (!checkParams()) return;

    ViewGT.showView(context, VerifyCreatePasswordView(widget._CreateAccountModel),
        model: ViewPushModel.PushReplacement);
  }

  clickRecreate() {
    ViewGT.showView(context, CreateWalletView(), model: ViewPushModel.PushReplacement);
  }
}
