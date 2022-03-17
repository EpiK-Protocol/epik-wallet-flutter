import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/views/wallet/create/createwalletview.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';

class ImportWalletView extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> getState() {
    return _ImportWalletViewState();
  }
}

class _ImportWalletViewState extends BaseWidgetState<ImportWalletView> with TickerProviderStateMixin {
  List<String> tabItems;
  TabController _tabController;
  int _selectedIndex = 0;

  String keyword_1 = "";
  String keyword_2 = "";
  TextEditingController _controllerKeyword_1, _controllerKeyword_2;

  String accountName = "";
  TextEditingController _controllerAccount;

  String import_mnemonic = "";
  TextEditingController _controllerImportMnemonic;

  String import_pk_epik = "";
  String import_pk_eth = "";
  TextEditingController _controllerImportPkEpik;
  TextEditingController _controllerImportPkEth;

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
    if (tabItems == null)
      tabItems = [
        RSID.iwv_3.text,
        RSID.iwv_21.text,
      ];

    if (_tabController == null) {
      _tabController = new TabController(initialIndex: _selectedIndex, length: tabItems.length, vsync: this);
      _tabController.addListener(() {
        // tabbar 监听
        setState(() {
          _selectedIndex = _tabController.index;
        });
      });
    }

    if (_controllerKeyword_1 == null)
      _controllerKeyword_1 = new TextEditingController.fromValue(TextEditingValue(
        text: keyword_1,
        selection: new TextSelection.fromPosition(
          TextPosition(affinity: TextAffinity.downstream, offset: keyword_1.length),
        ),
      ));

    if (_controllerKeyword_2 == null)
      _controllerKeyword_2 = new TextEditingController.fromValue(TextEditingValue(
        text: keyword_2,
        selection: new TextSelection.fromPosition(
          TextPosition(affinity: TextAffinity.downstream, offset: keyword_2.length),
        ),
      ));

    if (_controllerAccount == null)
      _controllerAccount = new TextEditingController.fromValue(TextEditingValue(
        text: accountName,
        selection: new TextSelection.fromPosition(
          TextPosition(affinity: TextAffinity.downstream, offset: accountName.length),
        ),
      ));

    if (_controllerImportMnemonic == null) _controllerImportMnemonic = new TextEditingController(text: import_mnemonic);
    if (_controllerImportPkEpik == null) _controllerImportPkEpik = new TextEditingController(text: import_pk_epik);
    if (_controllerImportPkEth == null) _controllerImportPkEth = new TextEditingController(text: import_pk_eth);

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
                ResString.get(context, RSID.iwv_1), // "导入EpiK Portal钱包",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 20),
              child: Text(
                ResString.get(context, RSID.iwv_2),
                //"请备份好您的密码！EpiK Portal不存储用户密码，无法提供找回或重置的服务。",
                style: TextStyle(
                  color: Colors.white, //Colors.redAccent,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 42,
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              margin: EdgeInsets.only(bottom: 0),
              child: TabBar(
                onTap: (int index) {
                  dlog('Selected......$index');
                },
                tabs: tabItems.map((text) {
                  return Text(text);
                }).toList(),
                controller: _tabController,
                isScrollable: true,
                labelPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                labelColor: Colors.white,
                labelStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
                unselectedLabelColor: ResColor.white_60,
                unselectedLabelStyle: TextStyle(
                  fontSize: 14,
                  color: ResColor.white_60,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: ResColor.lg_1,
                ),
                indicatorPadding: EdgeInsets.fromLTRB(8, 32, 8, 6),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 4,
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(30, 0, 30, 5),
            //   child: Text(
            //     ResString.get(context, RSID.iwv_3), // "导入EpiK Portal钱包",
            //     style: TextStyle(
            //       color: ResColor.white,
            //       fontSize: 12,
            //     ),
            //   ),
            // ),
//             Container(
//               width: double.infinity,
//               height: 90,
//               margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
//               child: TextField(
//                 controller: _controllerImport,
//                 keyboardType: TextInputType.text,
//                 //获取焦点时,启用的键盘类型
//                 maxLines: 999,
//                 // 输入框最大的显示行数
// //              maxLength: 20, //允许输入的字符长度/ 右下角有数量提示
//                 maxLengthEnforced: true,
//                 //是否允许输入的字符长度超过限定的字符长度
//                 obscureText: false,
//                 //是否是密码
//                 inputFormatters: [WhitelistingTextInputFormatter(RegExpUtil.re_noChs)],
//
//                 // 这里限制长度 不会有数量提示
//                 decoration: InputDecoration(
//                   // 以下属性可用来去除TextField的边框
//                   border: InputBorder.none,
//                   errorBorder: InputBorder.none,
//                   focusedErrorBorder: InputBorder.none,
//                   disabledBorder: InputBorder.none,
//                   enabledBorder: const UnderlineInputBorder(
//                     borderRadius: BorderRadius.zero,
//                     borderSide: BorderSide(
//                       color: ResColor.white_20,
//                       width: 1,
//                     ),
//                   ),
//                   focusedBorder: const UnderlineInputBorder(
//                     borderRadius: BorderRadius.zero,
//                     borderSide: BorderSide(
//                       color: ResColor.white,
//                       width: 1,
//                     ),
//                   ),
//                   contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
//                   hintText:
//                       _selectedIndex == 0 ? ResString.get(context, RSID.iwv_4) : ResString.get(context, RSID.iwv_5),
//                   //"请输入助记词(12个英文单词)按空格隔开" : "请输入私钥",
//                   hintStyle: TextStyle(color: ResColor.white_50, fontSize: 17),
//                 ),
//                 cursorWidth: 2.0,
//                 //光标宽度
//                 cursorRadius: Radius.circular(2),
//                 //光标圆角弧度
//                 cursorColor: Colors.white,
//                 //光标颜色
//                 style: TextStyle(fontSize: 17, color: Colors.white),
//                 onChanged: (value) {
//                   importString = value.trim();
//                 },
//                 onSubmitted: (value) {
//                   importString = value.trim();
//                 }, // 是否隐藏输入的内容
//               ),
//             ),
            ...getMainInput(),
            getInputWidget(
              accountName,
              RSID.iwv_6.text,
              ResString.get(context, RSID.iwv_7), //"请输入钱包名称",
              _controllerAccount,
              (text) {
                dlog(text); // 当输入内容变更时,如何处理
                setState(() {
//              text = RegExpUtil.re_noChs.stringMatch(text) ?? "";
                  dlog(text);
                  accountName = text.trim();
                });
              },
              () {
                setState(() {
                  accountName = "";
                  _controllerAccount = null;
                });
              },
              isPassword: false,
            ),
            getInputWidget(
              keyword_1,
              RSID.iwv_8.text,
              ResString.get(context, RSID.iwv_10), //iwv_19"请输入钱包密码",
              _controllerKeyword_1,
              (text) {
                dlog(text); // 当输入内容变更时,如何处理
                setState(() {
                  text = RegExpUtil.re_noChs.stringMatch(text) ?? "";
                  dlog(text);
                  keyword_1 = text;
                });
              },
              () {
                setState(() {
                  keyword_1 = "";
                  _controllerKeyword_1 = null;
                });
              },
            ),

            getInputWidget(
              keyword_2,
              RSID.iwv_11.text, //
              ResString.get(context, RSID.iwv_10), //iwv_11"请确认钱包密码",
              _controllerKeyword_2,
              (text) {
                dlog(text); // 当输入内容变更时,如何处理
                setState(() {
                  text = RegExpUtil.re_noChs.stringMatch(text) ?? "";
                  keyword_2 = text;
                });
              },
              () {
                setState(() {
                  keyword_2 = "";
                  _controllerKeyword_2 = null;
                });
              },
            ),
            LoadingButton(
              margin: EdgeInsets.fromLTRB(30, 40, 30, 0),
              gradient_bg: ResColor.lg_1,
              color_bg: Colors.transparent,
              disabledColor: Colors.transparent,
              height: 40,
              text: RSID.iwv_12.text,
              textstyle: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              bg_borderradius: BorderRadius.circular(4),
              onclick: (lbtn) {
                if (_selectedIndex == 0) {
                  clickNextMnemonic();
                } else {
                  clickNextPrivatekey();
                }
              },
            ),
            InkWell(
              onTap: () {
                clickToCreate();
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 40, 0, 10),
                padding: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: Text(
                  ResString.get(context, RSID.iwv_13), //"没有钱包？去创建",
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

  List<Widget> getMainInput() {
    List<Widget> ret = [];
    if (_selectedIndex == 0) {
      ret.add(getInputWidget(
        import_mnemonic,
        null,
        RSID.iwv_4.text, //"请输入助记词",
        _controllerImportMnemonic,
        (text) {
          dlog(text); // 当输入内容变更时,如何处理
          setState(() {
            dlog(text);
            import_mnemonic = text.trim();
          });
        },
        () {
          setState(() {
            import_mnemonic = "";
            _controllerImportMnemonic = null;
          });
        },
        isPassword: false,
        maxLines: 999,
        minLines: 3,
        maxlength: 999,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExpUtil.re_noChs)],
      ));
    } else {
      ret.add(getInputWidget(
        import_pk_epik,
        RSID.iwv_24.text, //"EpiK私钥",
        RSID.iwv_22.text,
        _controllerImportPkEpik,
        (text) {
          dlog(text); // 当输入内容变更时,如何处理
          setState(() {
            dlog(text);
            import_pk_epik = text.trim();
          });
        },
        () {
          setState(() {
            import_pk_epik = "";
            _controllerImportPkEpik = null;
          });
        },
        isPassword: false,
        maxLines: 999,
        minLines: 3,
        maxlength: 999,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExpUtil.re_hex_no_0x)],
      ));

      ret.add(getInputWidget(
        import_pk_eth,
        RSID.iwv_25.text, //"以太坊私钥",
        RSID.iwv_23.text,
        _controllerImportPkEth,
        (text) {
          dlog(text); // 当输入内容变更时,如何处理
          setState(() {
            dlog(text);
            import_pk_eth = text.trim();
          });
        },
        () {
          setState(() {
            import_pk_eth = "";
            _controllerImportPkEth = null;
          });
        },
        isPassword: false,
        maxLines: 999,
        minLines: 3,
        maxlength: 999,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExpUtil.re_hex_no_0x)],
      ));
    }
    return ret;
  }

  Widget getInputWidget(
    String keyword,
    String label,
    String hind,
    TextEditingController controller,
    ValueChanged<String> onChanged,
    VoidCallback onClean, {
    bool isPassword = true,
    int maxLines = 1,
    int minLines = 1,
    int maxlength = 20,
    List<TextInputFormatter> inputFormatters,
  }) {
    Widget textview = TextField(
      controller: controller,
      keyboardType: maxLines == 1 ? TextInputType.text : TextInputType.multiline,
      //获取焦点时,启用的键盘类型
      maxLines: maxLines,
      minLines: minLines,
      // 输入框最大的显示行数
//              maxLength: 20, //允许输入的字符长度/ 右下角有数量提示
      maxLengthEnforced: true,
      //是否允许输入的字符长度超过限定的字符长度
      obscureText: isPassword,
      //是否是密码
      inputFormatters: [LengthLimitingTextInputFormatter(maxlength), if (inputFormatters != null) ...inputFormatters],
      //WhitelistingTextInputFormatter(RegExpUtil.re_azAZ09)
      // 这里限制长度 不会有数量提示
      decoration: InputDecoration(
        // 以下属性可用来去除TextField的边框
        // border: InputBorder.none,
        // errorBorder: InputBorder.none,
        // focusedErrorBorder: InputBorder.none,
        border: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        enabledBorder: const UnderlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: ResColor.white_20,
            width: 1,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: ResColor.white,
            width: 1,
          ),
        ),
        // contentPadding: EdgeInsets.fromLTRB(0, 10, 40, 20),
        contentPadding: maxLines > 1 ? EdgeInsets.fromLTRB(0, 10, 0, 10) : EdgeInsets.fromLTRB(0, 10, 40, 20),

//                      contentPadding: EdgeInsets.symmetric(vertical: 8.5),
        hintText: hind,
        hintStyle: TextStyle(color: ResColor.white_50, fontSize: 14),
        labelText: label,
        labelStyle: TextStyle(color: ResColor.white, fontSize: 17),
      ),
      cursorWidth: 2.0,
      //光标宽度
      cursorRadius: Radius.circular(2),
      //光标圆角弧度
      cursorColor: Colors.white,
      //光标颜色
      style: TextStyle(fontSize: 17, color: Colors.white),
      onChanged: onChanged,
      onSubmitted: (value) {
        // 当用户确定已经完成编辑时触发
      }, // 是否隐藏输入的内容
    );

    return Container(
      width: double.infinity,
      height: maxLines > 1 ? null : 77,
      margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: maxLines == 1
          ? Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: textview,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: (StringUtils.isEmpty(keyword))
                      ? Container()
                      : SizedBox(
                          width: 40,
                          height: 62,
                          child: IconButton(
                            onPressed: () {
                              onClean();
                            },
                            padding: EdgeInsets.all(0),
                            icon: Icon(Icons.clear_rounded),
                            color: Colors.white,
                            iconSize: 14,
                          ),
                        ),
                ),
              ],
            )
          : textview,
    );
  }

  bool checkPassword() {
    if (StringUtils.isEmpty(accountName)) {
//      showToast("请输入钱包名称");
      showToast(ResString.get(context, RSID.iwv_7));
      return false;
    }

    if (StringUtils.isEmpty(keyword_1)) {
//      showToast("请输入密码");
      showToast(ResString.get(context, RSID.iwv_9));
      return false;
    }

    if (StringUtils.isEmpty(keyword_2)) {
//      showToast("请输入确认密码");
      showToast(ResString.get(context, RSID.iwv_14));
      return false;
    }

    if (keyword_1 != keyword_2) {
//      showToast("两次输入的密码必须一致");
      showToast(ResString.get(context, RSID.iwv_15));
      return false;
    }

    if (keyword_1.length < 8) {
//      showToast("密码至少需要8位");
      showToast(ResString.get(context, RSID.iwv_16));
      return false;
    }

    return true;
  }

  bool checkImportMnemonic() {
    if (StringUtils.isEmpty(import_mnemonic)) {
//      showToast(_selectedIndex == 0 ? "请输入助记词" : "请输入私钥");
      showToast(_selectedIndex == 0 ? ResString.get(context, RSID.iwv_17) : ResString.get(context, RSID.iwv_5));
      return false;
    }

    if (_selectedIndex == 0) {
      // 助记词
      List<String> words = import_mnemonic.split(RegExp(r'\s+'));
      // print(words);
      // print(words.length);
      if (words == null || words.length != 12) {
//        showToast("请输入助记词(12个英文单词)按空格隔开");
        showToast(ResString.get(context, RSID.iwv_4));
        return false;
      }
    } else {
      if (import_mnemonic.length != 64) {
//        showToast("私钥格式不正确");
        showToast(ResString.get(context, RSID.iwv_18));
        return false;
      }
    }
    return true;
  }

  clickNextMnemonic() {
    if (!checkImportMnemonic()) {
      return;
    }

    if (!checkPassword()) {
      return;
    }

    closeInput();

    showLoadDialog("", touchOutClose: false, backClose: false, onShow: () async {
      import_mnemonic = import_mnemonic.replaceAll(RegExp(r"\s+"), " ");
      bool mnemonicok = bip39.validateMnemonic(import_mnemonic);

      if (mnemonicok != true) {
        showToast(ResString.get(context, RSID.iwv_19));
        closeLoadDialog();
        return;
      }

      WalletAccount waccount = WalletAccount();
      waccount.account = accountName;
      waccount.password = keyword_1;
      waccount.mnemonic = import_mnemonic;
      AccountMgr().addAccount(waccount);
      AccountMgr().setCurrentAccount(waccount).then((ok) {
        if (ok) {
          closeLoadDialog();
          Future.delayed(Duration(milliseconds: 300)).then((value) => finish());
        } else {
          AccountMgr().delAccount(waccount);
          closeLoadDialog();
//            showToast("导入失败钱包失败");
          showToast(ResString.get(context, RSID.iwv_20));
        }
      });
    });
  }

  bool checkPrivatekey() {
    bool hasepik = StringUtils.isNotEmpty(import_pk_epik);
    bool haseth = StringUtils.isNotEmpty(import_pk_eth);
    if (hasepik!=true && haseth!=true) {
      showToast(RSID.iwv_26.text); //至少需要输入一种私钥
      return false;
    }

    bool ret_epik = null;
    bool ret_eth = null;
    if (hasepik) {
      // epik私钥
      Uint8List epik_u8l = EpikWalletUtils.hexStringToBytes(import_pk_epik);
      if (epik_u8l == null || epik_u8l.length == 0) {
        showToast(RSID.iwv_27.text);//"EpiK私钥不正确");
        ret_epik =false;
        return ret_epik;
      } else {
        ret_epik=true;
      }
    } else if (haseth) {
      //eth私钥
      Uint8List eth_u8l = EpikWalletUtils.hexStringToBytes(import_pk_eth);
      if (eth_u8l == null || eth_u8l.length == 0) {
        showToast(RSID.iwv_28.text);//"Eth私钥不正确");
        ret_eth =false;
        return ret_eth;
      } else {
        ret_eth=true;
      }
    }
    return true;
  }

  clickNextPrivatekey() {
    if (!checkPrivatekey()) {
      return;
    }

    if (!checkPassword()) {
      return;
    }

    closeInput();

    showLoadDialog("", touchOutClose: false, backClose: false, onShow: () async {

      bool hasepik = StringUtils.isNotEmpty(import_pk_epik);
      bool haseth = StringUtils.isNotEmpty(import_pk_eth);

      WalletAccount waccount = WalletAccount();
      waccount.account = accountName;
      waccount.password = keyword_1;
      // waccount.mnemonic = import_mnemonic;
      if(hasepik)
        waccount.pk_epk = import_pk_epik;
      if(haseth)
        waccount.pk_eth = import_pk_eth;

      AccountMgr().addAccount(waccount);
      AccountMgr().setCurrentAccount(waccount).then((ok) {
        if (ok) {
          closeLoadDialog();
          Future.delayed(Duration(milliseconds: 300)).then((value) => finish());
        } else {
          AccountMgr().delAccount(waccount);
          closeLoadDialog();
//            showToast("导入失败钱包失败");
          showToast(ResString.get(context, RSID.iwv_20));
        }
      });
    });
  }

  clickToCreate() {
    closeInput();

    ViewGT.showView(context, CreateWalletView(), model: ViewPushModel.PushReplacement);
  }
}
