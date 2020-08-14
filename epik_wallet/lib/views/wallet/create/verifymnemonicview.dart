import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/main.dart';
import 'package:epikwallet/model/CreateAccountModel.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/views/wallet/create/createwalletview.dart';
import 'package:epikwallet/views/wallet/create/verifycreatepasswordview.dart';
import 'package:epikwallet/widget/text/diff_scale_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

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

  Color bgColor = Color(0xff1A1C1F);
  Color bgColor_disabled = Colors.black54;

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
          minHeight: getScreenHeight() -
              BaseFuntion.topbarheight -
              BaseFuntion.appbarheight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(15, 6, 15, 10),
              child: Text(
                "验证助记词",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
              child: Text(
                "为了安全起见，按照顺序填写助记词以确认该助记词是否有效。",
                style: TextStyle(
                  color: ResColor.black_50,
                  fontSize: 13,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 10),
              child: Row(
                children: <Widget>[
                  Text(
                    "填写助记词",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            getMnemonicGridWidget_1(),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 10),
              child: Row(
                children: <Widget>[
                  Text(
                    "按助记词顺序点击下面词组：",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            getMnemonicGridWidget_2(),
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
                          clickNextSetp();
                        },
                        child: Text(
                          "验证助记词",
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
            InkWell(
              onTap: () {
                clickRecreate();
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                padding: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: Text(
                  "忘记助记词，重新创建",
                  style: TextStyle(
                    fontSize: 13,
                    color: ResColor.black_50,
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
      gridItemHightRatio = (getScreenWidth() - 15 * 2 - 10 * 3) /
          4.0 /
          35.0; //    每个item的宽 / 高 = 比例
    }

    int size = mnemonic_list_source.length;

    List<Widget> items = [];

    if (mnemonic_list != null) {
      for (int i = 0; i < size; i++) {
        SelectedText text = null;
        if (i < mnemonic_list.length) text = mnemonic_list[i];

        items.add(
          FlatButton(
            highlightColor: Colors.white24,
            splashColor: Colors.white24,
            onPressed: text == null
                ? null
                : () {
                    clickGroup1Cancel(text, i);
                  },
            padding: EdgeInsets.zero,
            child: DiffScaleText(
              text: text == null ? (i + 1).toString() : text.text,
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: fontFamily_def,
              ),
            ),
            disabledColor: bgColor_disabled,
            color: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
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
        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
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
      gridItemHightRatio = (getScreenWidth() - 15 * 2 - 10 * 3) /
          4.0 /
          35.0; //    每个item的宽 / 高 = 比例
    }

    List<Widget> items = [];

    if (mnemonic_list_source != null) {
      for (int i = 0; i < mnemonic_list_source.length; i++) {
        SelectedText text = mnemonic_list_source[i];

        items.add(
          FlatButton(
            highlightColor: Colors.white24,
            splashColor: Colors.white24,
            onPressed: () {
              clickGroup2(text, i);
            },
            padding: EdgeInsets.zero,
            child: Text(
              text.text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            color: text.isSelected ? bgColor_disabled : bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
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
        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
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
    if (mnemonic_list == null ||
        mnemonic_list.length < mnemonic_list_source.length) {
      showToast("请按助记词顺序点击词组填满数字区域");
      return false;
    }

    makeMnemonicString();
    dlog(widget._CreateAccountModel.mnemonic_string);
    dlog("mnemonic_string= $mnemonic_string");
    if (mnemonic_string != widget._CreateAccountModel.mnemonic_string) {
      showToast("填入的助记词顺序不正确");
      return false;
    }

    return true;
  }

  clickNextSetp() {
    if (!checkParams()) return;

    ViewGT.showView(
        context, VerifyCreatePasswordView(widget._CreateAccountModel),
        model: ViewPushModel.PushReplacement);
  }

  clickRecreate() {
    ViewGT.showView(context, CreateWalletView(),
        model: ViewPushModel.PushReplacement);
  }
}
