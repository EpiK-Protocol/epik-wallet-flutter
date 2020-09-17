import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/logic/EpikWalletUtils.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/model/CreateAccountModel.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/views/wallet/create/createwalletview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';

class VerifyCreatePasswordView extends BaseWidget {
  CreateAccountModel _CreateAccountModel;

  VerifyCreatePasswordView(this._CreateAccountModel);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return _VerifyCreatePasswordViewState();
  }
}

class _VerifyCreatePasswordViewState
    extends BaseWidgetState<VerifyCreatePasswordView> {
  String keyword = "";
  TextEditingController _controllerKeyword;

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
  }

  @override
  Widget buildWidget(BuildContext context) {
    if (_controllerKeyword == null)
      _controllerKeyword = new TextEditingController.fromValue(TextEditingValue(
        text: keyword,
        selection: new TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream, offset: keyword.length),
        ),
      ));

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
                "验证钱包密码",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
              child: Text(
                "为了安全起见，请再次输入钱包密码。",
                style: TextStyle(
                  color: ResColor.black_50,
                  fontSize: 13,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 25, 15, 15),
              child: Text(
                "钱包密码",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ),
            getInputWidget(keyword, "请输入钱包密码", _controllerKeyword, (text) {
              dlog(text); // 当输入内容变更时,如何处理
              setState(() {
                text = RegExpUtil.re_noChs.stringMatch(text) ?? "";
                dlog(text);
                keyword = text;
              });
            }, () {
              setState(() {
                keyword = "";
                _controllerKeyword = null;
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
                          "下一步",
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
                ViewGT.showView(context, CreateWalletView(),
                    model: ViewPushModel.PushReplacement);
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 35, 0, 10),
                padding: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: Text(
                  "忘记密码？重新创建",
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
      VoidCallback onClean) {
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
              Icons.lock_outline,
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
              obscureText: true,
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
    if (StringUtils.isEmpty(keyword)) {
      showToast("请输入密码");
      return false;
    }

    if (keyword != widget._CreateAccountModel.password) {
      showToast("密码不正确");
      return false;
    }

    return true;
  }

  clickNext() {
    if (!checkPassword()) {
      return;
    }

    closeInput();

    if (loadingDialogIsShow) return;

    showLoadDialog("", touchOutClose: false, backClose: false, onShow: () {
      // 创建钱包
//      WalletUtils.createFromMnemonic(
//              widget._CreateAccountModel.mnemonic_string, Bip32Path.filecoin)
//          .then((HDWallet hdwallet) async {
//        LocalKeyStore lks = LocalKeyStore();
//        lks.account = widget._CreateAccountModel.accountname;
//        lks.password = widget._CreateAccountModel.password;
//        lks.mHDWallet = hdwallet;
//        // await AccountMgr().load();
//        AccountMgr().addAccount(lks);
//        closeLoadDialog();
//      });

      WalletAccount walletaccount = WalletAccount();
      walletaccount.account = widget._CreateAccountModel.accountname;
      walletaccount.password = widget._CreateAccountModel.password;
      walletaccount.mnemonic = widget._CreateAccountModel.mnemonic_string;

      AccountMgr().addAccount(walletaccount);
      AccountMgr().setCurrentAccount(walletaccount).then((ok) {
        if (ok) {
          print("test_1");
          closeLoadDialog();
          print("test_2");
          Future.delayed(Duration(milliseconds: 500)).then((value) => finish());
        } else {
          AccountMgr().delAccount(walletaccount).then((_){
            showToast("创建钱包失败");
            closeLoadDialog();
          });
        }
      });
    });
  }
}
