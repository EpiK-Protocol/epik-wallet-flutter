// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:convert/convert.dart';
// import 'package:crypto/crypto.dart';
// import 'package:epikwallet/base/_base_widget.dart';
// import 'package:epikwallet/base/common_function.dart';
// import 'package:epikwallet/dialog/message_dialog.dart';
// import 'package:epikwallet/localstring/localstringdelegate.dart';
// import 'package:epikwallet/localstring/resstringid.dart';
// import 'package:epikwallet/logic/account_mgr.dart';
// import 'package:epikwallet/logic/api/api_testnet.dart';
// import 'package:epikwallet/logic/api/serviceinfo.dart';
// import 'package:epikwallet/utils/RegExpUtil.dart';
// import 'package:epikwallet/utils/device/deviceutils.dart';
// import 'package:epikwallet/utils/eventbus/event_manager.dart';
// import 'package:epikwallet/utils/eventbus/event_tag.dart';
// import 'package:epikwallet/utils/http/httputils.dart';
// import 'package:epikwallet/utils/res_color.dart';
// import 'package:epikwallet/utils/string_utils.dart';
// import 'package:epikwallet/widget/custom_checkbox.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:url_launcher/url_launcher.dart' as url_launcher;
//
// /// 绑定社交账号  todo
// class BindSocialAccountView extends BaseWidget {
//   @override
//   BaseWidgetState<BaseWidget> getState() {
//     return _BindSocialAccountViewState();
//   }
// }
//
// class _BindSocialAccountViewState extends BaseWidgetState<BindSocialAccountView>
//     with TickerProviderStateMixin {
//   TextEditingController _controllerWechat;
//   String wechat = "";
//   TextEditingController _controllerTelegram;
//   String telegram = "";
//   bool agreement = false;
//
//   List<String> tabItems;
//   TabController _tabController;
//   int _selectedIndex = 0;
//
//   @override
//   void initStateConfig() {
//     isTopBarShow = true; //状态栏是否显示
//     isAppBarShow = true; //导航栏是否显示
//     setAppBarTitle("");
//     resizeToAvoidBottomPadding = true;
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // setAppBarTitle(ResString.get(context, RSID.msv_1));
//     setAppBarTitle("绑定社交账号");
//     tabItems = [
//       ResString.get(context, RSID.msv_13),
//       ResString.get(context, RSID.msv_14),
//     ];
//   }
//
//   @override
//   void dispose() {
//     if (_tabController != null) _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget buildWidget(BuildContext context) {
//     if (_tabController == null) {
//       _tabController = new TabController(
//           initialIndex: _selectedIndex, length: tabItems.length, vsync: this);
//       _tabController.addListener(() {
//         // tabbar 监听
//         setState(() {
//           _selectedIndex = _tabController.index;
//         });
//       });
//     }
//
//     if (_controllerWechat == null)
//       _controllerWechat = new TextEditingController.fromValue(TextEditingValue(
//         text: wechat,
//         selection: new TextSelection.fromPosition(
//           TextPosition(
//               affinity: TextAffinity.downstream, offset: wechat.length),
//         ),
//       ));
//
//     if (_controllerTelegram == null)
//       _controllerTelegram =
//           new TextEditingController.fromValue(TextEditingValue(
//         text: telegram,
//         selection: new TextSelection.fromPosition(
//           TextPosition(
//               affinity: TextAffinity.downstream, offset: telegram.length),
//         ),
//       ));
//
//     return SingleChildScrollView(
//       physics: AlwaysScrollableScrollPhysics(),
//       child: Container(
//         constraints: BoxConstraints(
//           minHeight: getScreenHeight() -
//               BaseFuntion.topbarheight -
//               BaseFuntion.appbarheight_def,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
// //            Padding(
// //              padding: EdgeInsets.fromLTRB(15, 6, 15, 10),
// //              child: Text(
// //                ResString.get(context, RSID.msv_1), //"预挖报名",
// //                style: TextStyle(
// //                  color: Colors.black,
// //                  fontSize: 20,
// //                ),
// //              ),
// //            ),
//             Container(
//               height: 30,
//               width: double.infinity,
//               alignment: Alignment.center,
//               margin: EdgeInsets.fromLTRB(15, 6, 15, 10),
//               child: TabBar(
//                 onTap: (int index) {
// //                  dlog('Selected......$index');
//                 },
//                 //设置未选中时的字体颜色，tabs里面的字体样式优先级最高
//                 unselectedLabelColor: Color(0xff999999),
//                 //设置选中时的字体颜色，tabs里面的字体样式优先级最高
//                 labelColor: Color(0xff393E45),
//                 //选中下划线的颜色
//                 indicatorColor: Color(0xff393E45),
//                 //选中下划线的长度，label时跟文字内容长度一样，tab时跟一个Tab的长度一样
//                 indicatorSize: TabBarIndicatorSize.label,
//                 //选中下划线的高度，值越大高度越高，默认为2。0
//                 indicatorWeight: 2.0,
//                 controller: _tabController,
//                 labelPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
//                 tabs: tabItems.map((text) {
//                   return Text(text);
//                 }).toList(),
//                 isScrollable: true,
//               ),
//             ),
//             _selectedIndex == 0
//                 ? InkWell(
//                     // 微信绑定
//                     onTap: () {
//                       DeviceUtils.copyText(ServiceInfo.server_wechat);
// //                showToast("已复制客服微信号\n请在微信添加好友",length:Toast.LENGTH_LONG);
//                       showToast(ResString.get(context, RSID.msv_2),
//                           length: Toast.LENGTH_LONG);
//                       try {
//                         url_launcher.launch("weixin://");
//                       } catch (e) {
//                         print(e);
//                       }
//                     },
//                     child: Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
//                       child: Text.rich(
//                         TextSpan(
//                           style: TextStyle(
//                             color: ResColor.black_50,
//                             fontSize: 13,
//                           ),
//                           children: <TextSpan>[
//                             TextSpan(
//                               text:"- 请使用绑定的微信号添加客服微信",
//                             ),
//                             TextSpan(
//                               text: "${ServiceInfo.server_wechat}",
//                               style: TextStyle(
//                                 color: Colors.blue,
//                                 fontSize: 13,
//                                 decoration: TextDecoration.underline,
//                               ),
//                             ),
//                             TextSpan(
//                               text:"为好友",
//                             ),
//                             TextSpan(
//                               text:"\n- 请将绑定后显示的ID发送给客户微信",
//                             ),
//                             TextSpan(
//                               text: "${ServiceInfo.server_wechat}",
//                               style: TextStyle(
//                                 color: Colors.blue,
//                                 fontSize: 13,
//                                 decoration: TextDecoration.underline,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   )
//                 : InkWell(
//                     // Telegram 电报绑定
//                     onTap: () {
// //                      DeviceUtils.copyText(ServiceInfo.server_wechat);
// //                      showToast(ResString.get(context, RSID.msv_2),
// //                          length: Toast.LENGTH_LONG);
//                       try {
//                         url_launcher.launch(ServiceInfo.server_telegram);
//                       } catch (e) {
//                         print(e);
//                       }
//                     },
//                     child: Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
//                       child: Text.rich(
//                         TextSpan(
//                           style: TextStyle(
//                             color: ResColor.black_50,
//                             fontSize: 13,
//                           ),
//                           children: <TextSpan>[
//                             TextSpan(
//                                 text:"- 报名前请先使用要绑定的电报号加入",
//                             ),
//                             TextSpan(
//                               text: ResString.get(context, RSID.msv_16),
//                               style: TextStyle(
//                                 color: Colors.blue,
//                                 fontSize: 13,
//                                 decoration: TextDecoration.underline,
//                               ),
//                             ),
//                             TextSpan(
//                               text:"\n- 请将绑定后显示的ID发送给电报群中的管理员。",
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//             Padding(
//               padding: EdgeInsets.fromLTRB(15, 25, 15, 15),
//               child: Text(
//                 _selectedIndex == 0
//                     ? ResString.get(context, RSID.msv_6)
//                     : ResString.get(context, RSID.msv_18), // "绑定微信号",
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 15,
//                 ),
//               ),
//             ),
//             getInputWidget(
//               _selectedIndex == 0 ? wechat : telegram,
//               _selectedIndex == 0
//                   ? ResString.get(context, RSID.msv_7)
//                   : ResString.get(context, RSID.msv_19), //"请输入微信号",
//               _selectedIndex == 0 ? _controllerWechat : _controllerTelegram,
//               (text) {
//                 setState(() {
//                   if (_selectedIndex == 0) {
//                     wechat = _controllerWechat.text ?? "";
//                     dlog(wechat);
//                   } else {
//                     telegram = _controllerTelegram.text ?? "";
//                     dlog(telegram);
//                   }
//                 });
//               },
//               () {
//                 setState(() {
//                   if (_selectedIndex == 0) {
//                     wechat = "";
//                     _controllerWechat = null;
//                   } else {
//                     telegram = "";
//                     _controllerTelegram = null;
//                   }
//                 });
//               },
//               isPassword: false,
//               icon: _selectedIndex == 0
//                   ? ImageIcon(
//                       AssetImage("assets/img/ic_wechat.png"),
//                       size: 20,
//                       color: Colors.white,
//                     )
//                   : Image(
//                       image: AssetImage("assets/img/ic_telgram.png"),
//                       width: 20,
//                       height: 20,
//                     ),
//               inputFormatters: [
//                 WhitelistingTextInputFormatter(RegExpUtil.re_noChs)
//               ],
//             ),
//             Container(
//               margin: EdgeInsets.fromLTRB(15, 50, 15, 0),
//               height: 44,
//               child: Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Container(
//                       height: 44,
//                       child: FlatButton(
//                         highlightColor: Colors.white24,
//                         splashColor: Colors.white24,
//                         onPressed: () {
//                           clickNext();
//                         },
//                         child: Text(
//                           "绑定",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 15,
//                           ),
//                         ),
//                         color: Color(0xff1A1C1F),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(22)),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget getInputWidget(
//     String keyword,
//     String hind,
//     TextEditingController controller,
//     ValueChanged<String> onChanged,
//     VoidCallback onClean, {
//     bool isPassword = true,
//     Widget icon,
//     List<TextInputFormatter> inputFormatters,
//   }) {
//     if (inputFormatters == null) inputFormatters = [];
//     inputFormatters.add(LengthLimitingTextInputFormatter(20));
//
//     return Container(
//       width: double.infinity,
//       height: 44,
//       margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
//       decoration: BoxDecoration(
//         color: Color(0xff393E45),
//         borderRadius: BorderRadius.circular(22),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: <Widget>[
//           Container(width: 5),
//           Container(
//             width: 44,
//             height: 44,
//             padding: EdgeInsets.all(11),
//             child: isPassword
//                 ? Icon(
//                     Icons.lock_outline,
//                     size: 20,
//                     color: Colors.white,
//                   )
//                 : icon,
//           ),
//           Expanded(
//             flex: 1,
//             child: TextField(
//               controller: controller,
//               keyboardType: TextInputType.emailAddress,
//               //获取焦点时,启用的键盘类型
//               maxLines: 1,
//               // 输入框最大的显示行数
// //              maxLength: 20, //允许输入的字符长度/ 右下角有数量提示
//               maxLengthEnforced: true,
//               //是否允许输入的字符长度超过限定的字符长度
//               obscureText: isPassword,
//               //是否是密码
//               inputFormatters: inputFormatters,
//               //WhitelistingTextInputFormatter(RegExpUtil.re_azAZ09)
//               // 这里限制长度 不会有数量提示
//               decoration: InputDecoration(
//                 // 以下属性可用来去除TextField的边框
//                 border: InputBorder.none,
//                 errorBorder: InputBorder.none,
//                 focusedErrorBorder: InputBorder.none,
//                 disabledBorder: InputBorder.none,
//                 enabledBorder: InputBorder.none,
//                 focusedBorder: InputBorder.none,
//                 contentPadding: EdgeInsets.fromLTRB(0, -3, 0, 0),
// //                      contentPadding: EdgeInsets.symmetric(vertical: 8.5),
//                 hintText: hind,
//                 hintStyle: TextStyle(color: ResColor.white_80, fontSize: 16),
//               ),
//               cursorWidth: 2.0,
//               //光标宽度
//               cursorRadius: Radius.circular(2),
//               //光标圆角弧度
//               cursorColor: Colors.white,
//               //光标颜色
//               style: TextStyle(fontSize: 16, color: Colors.white),
//               onChanged: onChanged,
//               onSubmitted: (value) {
//                 // 当用户确定已经完成编辑时触发
//               }, // 是否隐藏输入的内容
//             ),
//           ),
//           (StringUtils.isEmpty(keyword))
//               ? Container()
//               : SizedBox(
//                   width: 30,
//                   height: 40,
//                   child: IconButton(
//                     onPressed: () {
//                       onClean();
//                     },
//                     padding: EdgeInsets.all(0),
//                     icon: Icon(Icons.clear),
//                     color: Colors.white,
//                     iconSize: 14,
//                   ),
//                 ),
//           Container(width: 5),
//         ],
//       ),
//     );
//   }
//
//   clickNext() {
//     closeInput();
//
//     if (_selectedIndex == 0) {
//       if (StringUtils.isEmpty(wechat)) {
//         showToast(ResString.get(context, RSID.msv_7)); //"请输入微信号");
//         return;
//       }
//     } else {
//       if (StringUtils.isEmpty(telegram)) {
//         showToast(ResString.get(context, RSID.msv_19)); //"请输入微信号");
//         return;
//       }
//     }
//
//
//     showLoadDialog("", touchOutClose: false, backClose: false,
//         onShow: () async {
//       try {
//         String useraccount,
//             epik_address,
//             erc20_address,
//             epik_signature,
//             erc20_signature,
//             platform;
//
//         //weixin telegram
//         useraccount = _selectedIndex == 0 ? wechat.trim() : telegram.trim();
//         platform = _selectedIndex == 0 ? "weixin" : "telegram";
//
//         //epik_address
//         epik_address = AccountMgr().currentAccount.epik_EPK_address;
//
//         //erc20_address
//         erc20_address = AccountMgr().currentAccount.hd_eth_address;
//
//         //epik_signature
//         Digest digest = sha256.convert(utf8.encode(useraccount));
//         Uint8List epik_signature_byte = await AccountMgr()
//             .currentAccount
//             .epikWallet
//             .sign(epik_address, Uint8List.fromList(digest.bytes));
//         epik_signature = hex.encode(epik_signature_byte);
//
//         //erc20_signature
//         Uint8List erc20_signature_byte = await AccountMgr()
//             .currentAccount
//             .hdwallet
//             .signHash(erc20_address, Uint8List.fromList(digest.bytes));
// //          .signText(erc20_address, weixin);
//         erc20_signature = hex.encode(erc20_signature_byte);
//
//         HttpJsonRes httpjsonres = await ApiTestNet.signup(
//             useraccount,
//             epik_address,
//             erc20_address,
//             epik_signature,
//             erc20_signature,
//             platform);
//
//         closeLoadDialog();
//
//         if (httpjsonres.code == 0 && httpjsonres.jsonMap != null) {
//           String id = httpjsonres.jsonMap["id"] ?? "";
//           // eventMgr.send(EventTag.REFRESH_MININGVIEW);
//           eventMgr.send(EventTag.BIND_SOCIAL_ACCCOUNT);
//           DeviceUtils.copyText(id);
//           MessageDialog.showMsgDialog(
//             context,
//             title: RSID.tip.text,
//             // msg: ResString.get(
//             //     context, (_selectedIndex == 0 ? RSID.msv_11 : RSID.msv_20),
//             //     replace: [id]),
//             //"已报名，请将UUID:$id发送给微信客服，然后等待审核。UUID已经复制到剪切板。",
//             msg:"已提交绑定，请将ID:$id发送给微信客服。UUID已经复制到剪切板。",
//             btnRight: ResString.get(context, RSID.isee),
//             // "知道了",
//             onClickBtnRight: (YYDialog dialog) {
//               dialog.dismiss();
//             },
//             onDismiss: (dialog) {
//               Future.delayed(Duration(milliseconds: 500))
//                   .then((value) => finish());
//             },
//           );
//         } else {
//           showToast(httpjsonres.msg ??"绑定失败"); //"报名失败");
//         }
//       } catch (e) {
//         print(e);
//         showToast("${ResString.get(context, RSID.msv_12)}ERROR");
//         closeLoadDialog();
//       }
//     });
//   }
// }
