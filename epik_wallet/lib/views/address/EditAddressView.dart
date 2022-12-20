import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/LocalAddressMgr.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/utils/toast/toast.dart';
import 'package:epikwallet/views/address/AddressListView.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/custom_checkbox.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditAddressView extends BaseWidget {
  LocalAddressObj lao;

  EditAddressView({this.lao});

  @override
  BaseWidgetState<BaseWidget> getState() {
    return EditAddressViewState();
  }
}

class EditAddressViewState extends BaseWidgetState<EditAddressView> {
  String name = "";
  TextEditingController _controllerName;
  FocusNode focus_name = FocusNode();

  String address = "";
  TextEditingController _controllerToAddress;
  FocusNode focus_address = FocusNode();

  CurrencySymbol seletedCs = null;

  @override
  void initStateConfig() {
    super.initStateConfig();
    isTopBarShow = false; //状态栏是否显示
    isAppBarShow = false; //导航栏是否显示
    isTopFloatWidgetShow = true;

    resizeToAvoidBottomPadding = true;

    if (widget.lao != null) {
      address = widget.lao.address ?? "";
      name = widget.lao.name ?? "";
      seletedCs = widget.lao.symbol;
    }
  }

  @override
  Widget getTopFloatWidget() {
    return Padding(
      padding: EdgeInsets.only(top: getTopBarHeight()),
      child: getAppBar(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.lao == null) {
      setAppBarTitle(RSID.alv_addnew.text);
    } else {
      setAppBarTitle(RSID.alv_edit.text);
    }
  }

  @override
  void onCreate() {
    super.onCreate();
    eventMgr.add(EventTag.SCAN_QRCODE_RESULT, eventcallback_qrcode);
  }

  @override
  void dispose() {
    eventMgr.remove(EventTag.SCAN_QRCODE_RESULT, eventcallback_qrcode);
    super.dispose();
  }

  eventcallback_qrcode(arg) {
    String text = StringUtils.parseString(arg, null);
    if (text != null) {
      setState(() {
        // todo
        if (AddressListViewState.checkEpikAddress(text) || AddressListViewState.checkEthAddress(text)) {
          address = text;
          _controllerToAddress = null;
          setState(() {});
        } else {
          showToast(RSID.alv_input_address.text);
        }
      });
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    List<Widget> views = [];

    if (_controllerName == null) _controllerName = new TextEditingController(text: name);

    views.add(
      Container(
        width: double.infinity,
        // height: 77,
        constraints: BoxConstraints(
          minHeight: 67,
        ),
        margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: TextField(
                      focusNode: focus_name,
                      controller: _controllerName,
                      keyboardType: TextInputType.text,
                      //获取焦点时,启用的键盘类型
                      maxLines: null,
                      // 输入框最大的显示行数
//              maxLength: 20, //允许输入的字符长度/ 右下角有数量提示
//                       maxLengthEnforced: true,
                      //是否允许输入的字符长度超过限定的字符长度
                      obscureText: false,
                      //是否是密码
                      // 这里限制长度 不会有数量提示
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                        labelText: RSID.alv_name.text,
                        labelStyle: TextStyle(color: ResColor.white, fontSize: 17),
                      ),
                      cursorWidth: 2.0,
                      //光标宽度
                      cursorRadius: Radius.circular(2),
                      //光标圆角弧度
                      cursorColor: Colors.white,
                      //光标颜色
                      style: TextStyle(fontSize: 17, color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          name = _controllerName.text.trim();
                        });
                      },
                      onSubmitted: (value) {
                        setState(() {
                          name = _controllerName.text.trim();
                        });
                        FocusScope.of(context).requestFocus(focus_address);
                      }, // 是否隐藏输入的内容
                    ),
                  ),
                ],
              ),
            ),
            (StringUtils.isEmpty(name))
                ? Container()
                : SizedBox(
                    width: 40,
                    height: 67,
                    child: IconButton(
                      onPressed: () {
                        name = "";
                        _controllerName = null;
                        setState(() {});
                      },
                      padding: EdgeInsets.all(0),
                      icon: Icon(Icons.clear_rounded),
                      color: Colors.white,
                      iconSize: 14,
                    ),
                  ),
          ],
        ),
      ),
    );
    views.add(Container(
      height: 1,
      width: double.infinity,
      color: ResColor.white_20,
      margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
    ));

    if (_controllerToAddress == null) _controllerToAddress = new TextEditingController(text: address);

    views.add(
      Container(
        width: double.infinity,
        // height: 77,
        constraints: BoxConstraints(
          minHeight: 67,
        ),
        margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: TextField(
                      focusNode: focus_address,
                      controller: _controllerToAddress,
                      keyboardType: TextInputType.text,
                      //获取焦点时,启用的键盘类型
                      maxLines: null,
                      //1,
                      // 输入框最大的显示行数
//              maxLength: 20, //允许输入的字符长度/ 右下角有数量提示
//                       maxLengthEnforced: true,
                      //是否允许输入的字符长度超过限定的字符长度
                      obscureText: false,
                      //是否是密码
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExpUtil.re_noChs)],
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
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        // enabledBorder: const UnderlineInputBorder(
                        //   borderRadius: BorderRadius.zero,
                        //   borderSide: BorderSide(
                        //     color: ResColor.white_20,
                        //     width: 1,
                        //   ),
                        // ),
                        // focusedBorder: const UnderlineInputBorder(
                        //   borderRadius: BorderRadius.zero,
                        //   borderSide: BorderSide(
                        //     color: ResColor.white,
                        //     width: 1,
                        //   ),
                        // ),
                        contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 20),

//                      contentPadding: EdgeInsets.symmetric(vertical: 8.5),
//                         hintText: RSID.cwv_2.text,
//                         //"接收地址"
//                         hintStyle:
//                             TextStyle(color: ResColor.white_50, fontSize: 14),
                        labelText: RSID.alv_address.text,
                        labelStyle: TextStyle(color: ResColor.white, fontSize: 17),
                      ),
                      cursorWidth: 2.0,
                      //光标宽度
                      cursorRadius: Radius.circular(2),
                      //光标圆角弧度
                      cursorColor: Colors.white,
                      //光标颜色
                      style: TextStyle(fontSize: 17, color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          address = _controllerToAddress.text.trim();
                        });
                      },
                      onSubmitted: (value) {
                        setState(() {
                          address = _controllerToAddress.text.trim();
                        });
                      }, // 是否隐藏输入的内容
                    ),
                  ),
                ],
              ),
            ),
            (StringUtils.isEmpty(address))
                ? Container()
                : SizedBox(
                    width: 40,
                    height: 67,
                    child: IconButton(
                      onPressed: () {
                        address = "";
                        _controllerToAddress = null;
                        setState(() {});
                      },
                      padding: EdgeInsets.all(0),
                      icon: Icon(Icons.clear_rounded),
                      color: Colors.white,
                      iconSize: 14,
                    ),
                  ),
            InkWell(
              onTap: () {
                onClickScan();
              },
              child: Container(
                width: 40,
                height: 62,
                padding: EdgeInsets.all(9),
                child: Image.asset("assets/img/ic_scan_2.png"),
              ),
            ),
          ],
        ),
      ),
    );
    views.add(Container(
      height: 1,
      width: double.infinity,
      color: ResColor.white_20,
      margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
    ));

    List<CurrencySymbol> cslist = CurrencySymbol.values;
    Widget footer = StatefulBuilder(
      builder: (context, setState) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            spacing: 20,
            runSpacing: 10,
            children: cslist.map((cs) {
              String net = cs.netNamePatch ?? "";
              if (StringUtils.isNotEmpty(net)) {
                net = "($net)";
              }
              Widget row = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomCheckBox(
                    value: seletedCs == cs,
                    color_check: ResColor.o_1,
                    color_border: ResColor.o_1,
                    borderRadius: 100,
                    onChanged: (value) {
                      if (seletedCs == cs)
                        seletedCs = null;
                      else
                        seletedCs = cs;
                      setState(() {});
                    },
                  ),
                  Container(width: 5),
                  Text(
                    cs.symbol + net,
                    style: TextStyle(fontSize: 14, color: ResColor.white),
                  ),
                ],
              );
              return InkWell(
                child: row,
                onTap: () {
                  if (seletedCs == cs)
                    seletedCs = null;
                  else
                    seletedCs = cs;
                  setState(() {});
                },
              );
            }).toList(),
          ),
        );
      },
    );

    views.add(footer);

    views.add(
      LoadingButton(
        margin: EdgeInsets.fromLTRB(30, 40, 30, 20),
        gradient_bg: ResColor.lg_1,
        color_bg: Colors.transparent,
        disabledColor: Colors.transparent,
        height: 40,
        text: RSID.confirm.text,
        //"确定",
        textstyle: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        bg_borderradius: BorderRadius.circular(4),
        onclick: (lbtn) {
          onClickOk();
        },
      ),
    );

    Widget subgroup = Container(
      margin: EdgeInsets.fromLTRB(30, 40, 30, 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ResColor.b_3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: views,
      ),
    );

    Widget sv = SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(0),
      child: Container(
        constraints: BoxConstraints(
          minHeight: getScreenHeight() - BaseFuntion.topbarheight - BaseFuntion.appbarheight_def,
        ),
        child: Column(
          children: [subgroup],
        ),
      ),
    );

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: getAppBarHeight() + getTopBarHeight() + 128,
            decoration: BoxDecoration(
              gradient: ResColor.lg_1,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          Positioned(left: 0, right: 0, bottom: 0, top: getAppBarHeight() + getTopBarHeight(), child: sv),
        ],
      ),
    );
  }

  onClickScan() {
    ViewGT.showQrcodeScanView(context);
  }

  onClickOk() {
    if (seletedCs == null) {
      ToastUtils.showToast(RSID.alv_select_currency.text); //"请选择币种");
      return;
    }
    dlog("add new address");
    dlog(name);
    dlog(address);
    dlog(seletedCs.symbol);

    if(StringUtils.isEmpty(name))
    {
      ToastUtils.showToast(RSID.alv_input_name.text); //"请选择币种");
      return;
    }

    bool checkaddress = false;
    if (seletedCs.networkType == CurrencySymbol.ETH || seletedCs.networkType == CurrencySymbol.BNB) {
      checkaddress = AddressListViewState.checkEthAddress(address);
      dlog("checkEthAddress $checkaddress");
    } else if (seletedCs.networkType == CurrencySymbol.EPK) {
      checkaddress = AddressListViewState.checkEpikAddress(address);
      dlog("checkEpikAddress $checkaddress");
    }
    if (checkaddress != true) {
      ToastUtils.showToast(RSID.alv_input_address.text); //"请输入正确的钱包地址");
      return;
    }

    LocalAddressObj lao = LocalAddressObj()
      ..name = name
      ..address = address
      ..symbol = seletedCs;

    // localaddressmgr.add(lao);
    // localaddressmgr.save();
    // callback(lao);

    finish(lao);
  }
}
