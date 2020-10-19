import 'dart:typed_data';

import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/views/wallet/create/createwalletview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class ImportWalletView extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> getState() {
    return _ImportWalletViewState();
  }
}

class _ImportWalletViewState extends BaseWidgetState<ImportWalletView>
    with TickerProviderStateMixin {
  List<String> tabItems = [
    "助记词" /*, "私钥"*/
  ];
  TabController _tabController;
  int _selectedIndex = 0;

  String keyword_1 = "";
  String keyword_2 = "";
  TextEditingController _controllerKeyword_1, _controllerKeyword_2;

  String accountName = "";
  TextEditingController _controllerAccount;

  String importString = "";
  TextEditingController _controllerImport;

  @override
  void initState() {
    super.initState();
  }

  @override
  void initStateConfig() {
    isTopBarShow = true; //状态栏是否显示
    isAppBarShow = true; //导航栏是否显示
    setAppBarTitle("");
    resizeToAvoidBottomPadding = true;
  }

  @override
  void onCreate() {
    super.onCreate();
  }

  @override
  void dispose() {
    if (_tabController != null) _tabController.dispose();
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    if (_tabController == null) {
      _tabController = new TabController(
          initialIndex: _selectedIndex, length: tabItems.length, vsync: this);
      _tabController.addListener(() {
        // tabbar 监听
        setState(() {
          _selectedIndex = _tabController.index;
        });
      });
    }

    if (_controllerKeyword_1 == null)
      _controllerKeyword_1 =
          new TextEditingController.fromValue(TextEditingValue(
        text: keyword_1,
        selection: new TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream, offset: keyword_1.length),
        ),
      ));

    if (_controllerKeyword_2 == null)
      _controllerKeyword_2 =
          new TextEditingController.fromValue(TextEditingValue(
        text: keyword_2,
        selection: new TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream, offset: keyword_2.length),
        ),
      ));

    if (_controllerAccount == null)
      _controllerAccount = new TextEditingController.fromValue(TextEditingValue(
        text: accountName,
        selection: new TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream, offset: accountName.length),
        ),
      ));

    if (_controllerImport == null)
      _controllerImport = new TextEditingController(text: importString);

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: getScreenHeight() -
              BaseFuntion.topbarheight -
              BaseFuntion.appbarheight_def,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(15, 6, 15, 10),
              child: Text(
                "导入EpiK Portal钱包",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
              child: Text(
                "请备份好您的密码！EpiK Portal不存储用户密码，无法提供找回或重置的服务。",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13,
                ),
              ),
            ),
            Container(
              height: 30,
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: TabBar(
                onTap: (int index) {
                  dlog('Selected......$index');
                },
                //设置未选中时的字体颜色，tabs里面的字体样式优先级最高
                unselectedLabelColor: Color(0xff999999),
                //设置选中时的字体颜色，tabs里面的字体样式优先级最高
                labelColor: Color(0xff393E45),
                //选中下划线的颜色
                indicatorColor: Color(0xff393E45),
                //选中下划线的长度，label时跟文字内容长度一样，tab时跟一个Tab的长度一样
                indicatorSize: TabBarIndicatorSize.label,
                //选中下划线的高度，值越大高度越高，默认为2。0
                indicatorWeight: 2.0,
                controller: _tabController,
                labelPadding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                tabs: tabItems.map((text) {
                  return Text(text);
                }).toList(),
                isScrollable: true,
              ),
            ),
            Container(
              width: double.infinity,
              height: 100,
              margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
              decoration: BoxDecoration(
                color: Color(0xff393E45),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _controllerImport,
                keyboardType: TextInputType.text,
                //获取焦点时,启用的键盘类型
                maxLines: 999,
                // 输入框最大的显示行数
//              maxLength: 20, //允许输入的字符长度/ 右下角有数量提示
                maxLengthEnforced: true,
                //是否允许输入的字符长度超过限定的字符长度
                obscureText: false,
                //是否是密码
                inputFormatters: [
                  WhitelistingTextInputFormatter(RegExpUtil.re_noChs)
                ],

                // 这里限制长度 不会有数量提示
                decoration: InputDecoration(
                  // 以下属性可用来去除TextField的边框
                  border: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                  hintText:
                      _selectedIndex == 0 ? "请输入助记词(12个英文单词)按空格隔开" : "请输入私钥",
                  hintStyle: TextStyle(color: ResColor.white_80, fontSize: 16),
                ),
                cursorWidth: 2.0,
                //光标宽度
                cursorRadius: Radius.circular(2),
                //光标圆角弧度
                cursorColor: Colors.white,
                //光标颜色
                style: TextStyle(fontSize: 16, color: Colors.white),
                onChanged: (value) {
                  importString = value.trim();
                },
                onSubmitted: (value) {
                  importString = value.trim();
                }, // 是否隐藏输入的内容
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: Text(
                "钱包名称",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ),
            getInputWidget(accountName, "请输入钱包名称", _controllerAccount, (text) {
              dlog(text); // 当输入内容变更时,如何处理
              setState(() {
//              text = RegExpUtil.re_noChs.stringMatch(text) ?? "";
                dlog(text);
                accountName = text.trim();
              });
            }, () {
              setState(() {
                accountName = "";
                _controllerAccount = null;
              });
            }, isPassword: false),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: Text(
                "钱包密码",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ),
            getInputWidget(keyword_1, "请输入钱包密码", _controllerKeyword_1, (text) {
              dlog(text); // 当输入内容变更时,如何处理
              setState(() {
                text = RegExpUtil.re_noChs.stringMatch(text) ?? "";
                dlog(text);
                keyword_1 = text;
              });
            }, () {
              setState(() {
                keyword_1 = "";
                _controllerKeyword_1 = null;
              });
            }),
            Container(
              padding: EdgeInsets.fromLTRB(15, 5, 15, 10),
              alignment: Alignment.centerRight,
              child: Text(
                "*建议大小写字母、符号、数字组合 8位以上",
                style: TextStyle(
                  color: ResColor.black_50,
                  fontSize: 10,
                ),
              ),
            ),
            getInputWidget(keyword_2, "请确认钱包密码", _controllerKeyword_2, (text) {
              dlog(text); // 当输入内容变更时,如何处理
              setState(() {
                text = RegExpUtil.re_noChs.stringMatch(text) ?? "";
                keyword_2 = text;
              });
            }, () {
              setState(() {
                keyword_2 = "";
                _controllerKeyword_2 = null;
              });
            }),
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
                          clickNext();
                        },
                        child: Text(
                          "开始导入",
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
                clickToCreate();
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 15, 0, 10),
                padding: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: Text(
                  "没有钱包？去创建",
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

  Widget getInputWidget(
    String keyword,
    String hind,
    TextEditingController controller,
    ValueChanged<String> onChanged,
    VoidCallback onClean, {
    bool isPassword = true,
  }) {
    return Container(
      width: double.infinity,
      height: 44,
      margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
      decoration: BoxDecoration(
        color: Color(0xff393E45),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(width: 5),
          Container(
            width: 44,
            height: 44,
            child: Icon(
              isPassword ? Icons.lock_outline : OMIcons.accountBalanceWallet,
              size: 20,
              color: Colors.white,
            ),
          ),
          Expanded(
            flex: 1,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.text,
              //获取焦点时,启用的键盘类型
              maxLines: 1,
              // 输入框最大的显示行数
//              maxLength: 20, //允许输入的字符长度/ 右下角有数量提示
              maxLengthEnforced: true,
              //是否允许输入的字符长度超过限定的字符长度
              obscureText: isPassword,
              //是否是密码
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
              ],
              //WhitelistingTextInputFormatter(RegExpUtil.re_azAZ09)
              // 这里限制长度 不会有数量提示
              decoration: InputDecoration(
                // 以下属性可用来去除TextField的边框
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(0, -3, 0, 0),
//                      contentPadding: EdgeInsets.symmetric(vertical: 8.5),
                hintText: hind,
                hintStyle: TextStyle(color: ResColor.white_80, fontSize: 16),
              ),
              cursorWidth: 2.0,
              //光标宽度
              cursorRadius: Radius.circular(2),
              //光标圆角弧度
              cursorColor: Colors.white,
              //光标颜色
              style: TextStyle(fontSize: 16, color: Colors.white),
              onChanged: onChanged,
              onSubmitted: (value) {
                // 当用户确定已经完成编辑时触发
              }, // 是否隐藏输入的内容
            ),
          ),
          (StringUtils.isEmpty(keyword))
              ? Container()
              : SizedBox(
                  width: 30,
                  height: 40,
                  child: IconButton(
                    onPressed: () {
                      onClean();
                    },
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.clear),
                    color: Colors.white,
                    iconSize: 14,
                  ),
                ),
          Container(width: 5),
        ],
      ),
    );
  }

  bool checkPassword() {
    if (StringUtils.isEmpty(accountName)) {
      showToast("请输入钱包名称");
      return false;
    }

    if (StringUtils.isEmpty(keyword_1)) {
      showToast("请输入密码");
      return false;
    }

    if (StringUtils.isEmpty(keyword_2)) {
      showToast("请输入确认密码");
      return false;
    }

    if (keyword_1 != keyword_2) {
      showToast("两次输入的密码必须一致");
      return false;
    }

    if (keyword_1.length < 8) {
      showToast("密码至少需要8位");
      return false;
    }

    return true;
  }

  bool checkImportString() {
    if (StringUtils.isEmpty(importString)) {
      showToast(_selectedIndex == 0 ? "请输入助记词" : "请输入私钥");
      return false;
    }

    if (_selectedIndex == 0) {
      // 助记词
      List<String> words = importString.split(" ");
      if (words == null || words.length != 12) {
        showToast("请输入助记词(12个英文单词)按空格隔开");
        return false;
      }
    } else {
      if (importString.length != 64) {
        showToast("私钥格式不正确");
        return false;
      }
    }
    return true;
  }

  clickNext() {
    if (!checkImportString()) {
      return;
    }

    if (!checkPassword()) {
      return;
    }

    closeInput();

    showLoadDialog("", touchOutClose: false, backClose: false, onShow: () {
//      Function callback = (HDWallet hdwallet) async{
//
//        LocalKeyStore lks = LocalKeyStore();
//        lks.account =accountName;
//        lks.password = keyword_1;
//        lks.mHDWallet = hdwallet;
//
//        AccountMgr().addAccount(lks);
//
//        closeLoadDialog();
//
//        finish();
//      };
//
//      if (_selectedIndex == 0){
//        // 助记词
//        WalletUtils.createFromMnemonic(
//            importString, Bip32Path.filecoin)
//            .then(callback);
//      }else{
//        // 私钥
//        WalletUtils.ImportFromPrivKey(importString).then(callback);
//      }

      HD.seedFromMnemonic(importString).then((Uint8List seed) {
        if (seed == null || seed.length == 0) {
          // 验证助记词失败
          showToast("导入失败，助记词不能正确解析");
          closeLoadDialog();
          return;
        }
        WalletAccount waccount = WalletAccount();
        waccount.account = accountName;
        waccount.password = keyword_1;
        waccount.mnemonic = importString;
        AccountMgr().addAccount(waccount);
        AccountMgr().setCurrentAccount(waccount).then((ok) {
          if (ok) {
            closeLoadDialog();
            Future.delayed(Duration(milliseconds: 300)).then((value) => finish());
          } else {
            closeLoadDialog();
            showToast("导入失败钱包失败");
          }
        });
      });
    });
  }

  clickToCreate() {
    closeInput();

    ViewGT.showView(context, CreateWalletView(),
        model: ViewPushModel.PushReplacement);
  }
}
