import 'dart:ui';

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/PopMenuDialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/LocaleConfig.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/LocalAddressMgr.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/ClickUtil.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/address/EditAddressView.dart';
import 'package:epikwallet/views/currency/currencybatchwithdrawview.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/custom_checkbox.dart';
import 'package:epikwallet/widget/rect_getter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:jazzicon/jazzicon.dart';
import 'package:web3dart/web3dart.dart';

class AddressListView extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> getState() {
    return AddressListViewState();
  }
}

class AddressListViewState extends BaseWidgetState<AddressListView> with TickerProviderStateMixin {
  List<CurrencySymbol> tabTypes = CurrencySymbol.values;
  CurrencySymbol pageIndex = CurrencySymbol.EPK;

  TabController tabcontroller;

  List<LocalAddressObj> seletedData = [];

  @override
  void initStateConfig() {
    super.initStateConfig();
    setTopBarVisible(false);

    if(ServiceInfo.hideBSC)
    {
      tabTypes= tabTypes.sublist(0,4);
      // tabTypes.remove(CurrencySymbol.BNB);
      // tabTypes.remove(CurrencySymbol.EPKbsc);
      // tabTypes.remove(CurrencySymbol.USDTbsc);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(RSID.address_list.text);
  }

  void clickAppBarBack() {
    if (inBatch) {
      setState(() {
        inBatch = false;
      });
      return;
    }

    finish();
  }

  @override
  Widget getAppBar() {
    return Container(
      width: double.infinity,
      height: getTopBarHeight() + getAppBarHeight(),
      padding: EdgeInsets.fromLTRB(0, getTopBarHeight(), 0, 0),
      decoration: BoxDecoration(
        gradient: ResColor.lg_1,
      ),
      child: super.getAppBar(),
    );
  }

  GlobalKey key_btn_menu = RectGetter.createGlobalKey();

  Widget getAppBarRight({Color color}) {
    Widget ret = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          child: Container(
            key: key_btn_menu,
            width: 40,
            height: 50,
            child: Icon(
              inBatch ? Icons.close : Icons.menu,
              size: 20,
              color: color ?? appBarContentColor,
            ),
          ),
          onTap: onClickMenu,
        ),
      ],
    );
    return ret;
  }

  @override
  Widget buildWidget(BuildContext context) {
    // if ((localaddressmgr?.datamap?.keys?.length ?? 0) <= 0) {
    //   return Container();
    // }

    // List<String> keys = List.from(localaddressmgr.datamap.keys);
    // List<LocalAddressObj> data = [];
    // localaddressmgr.datamap.forEach((key, value) {
    //   data.addAll(value);
    // });
    // data.sort((left, right) => left.name?.compareTo(right.name));

    Widget view = Column(
      children: [
        getTabs(),
        if ((localaddressmgr?.datamap?.keys?.length ?? 0) >= 0)
          Expanded(
            child: TabBarView(
              physics: inBatch ? NeverScrollableScrollPhysics() : null,
              controller: tabcontroller,
              children: <Widget>[
                ...tabTypes.map((cs) {
                  List<LocalAddressObj> data = localaddressmgr?.datamap[cs.codename] ?? [];
                  data = List.from(data);
                  return getListView(data);
                }).toList(),
              ],
            ),
          ),
        AnimatedSizeAndFade(
          vsync: this,
          child: inBatch ? getBatchBar() : Container(),
        )
      ],
    );

    return WillPopScope(
      onWillPop: () async {
        if (inBatch) {
          setState(() {
            inBatch = false;
          });
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: view,
    );
  }

  Widget getTabs() {
    Widget ret = null;
    if (inBatch && pageIndex != null) {
      String net = pageIndex.netNamePatch;
      if (StringUtils.isNotEmpty(net)) {
        net = "($net)";
      }
      ret = Container(
        key: ValueKey(1),
        width: double.infinity,
        height: 52,
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              pageIndex.symbol + net,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                // height: 1,
              ),
            ),
          ],
        ),
      );
    }

    int index = tabTypes.indexOf(pageIndex);

    if (tabcontroller == null) tabcontroller = TabController(initialIndex: index, length: tabTypes.length, vsync: this);

    if (ret == null)
      ret = Container(
        key: ValueKey(2),
        width: double.infinity,
        height: 52,
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Row(
          children: [
            Expanded(
              child: TabBar(
                //ExpertStateType.values.map
                tabs: tabTypes.map((item) {
                  String net = item.netNamePatch;
                  if (StringUtils.isNotEmpty(net)) {
                    net = "($net)";
                  }
                  return Container(
                    alignment: Alignment.bottomCenter,
                    child: Text(item.symbol + net),
                  );
                }).toList(),
                controller: tabcontroller,
                isScrollable: true,
                labelPadding: EdgeInsets.fromLTRB(10, 0, 10, 10),
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
                indicatorPadding: EdgeInsets.fromLTRB(8, 42, 8, 6),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 4,
                onTap: (position) {
                  CurrencySymbol value = tabTypes[position];
                  onClickTab(value);
                },
              ),
            ),
          ],
        ),
      );

    return AnimatedSizeAndFade(
      vsync: this,
      child: ret,
    );
  }

  onClickTab(CurrencySymbol type) {
    if (pageIndex == type) return;
    pageIndex = type;
    // setState(() {
    // dataFilter(pageIndex);
    // });
    // key_scroll?.currentState?.scrollController
    //     ?.animateTo(0, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  Widget getListView(List<LocalAddressObj> data) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: data.length,
      itemBuilder: (context, index) {
        LocalAddressObj lao = data[index];
        bool isCurrent = AccountMgr().currentAccount.hd_eth_address.toLowerCase() == lao.address.toLowerCase() ||
            AccountMgr().currentAccount.epik_EPK_address.toLowerCase() == lao.address.toLowerCase();

        Widget item = Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(50),
                      gradient: lao.useJazzicon ? null:lao.gradientCover,
                    ),
                    child: Stack(
                      children: [
                        if(lao.useJazzicon)
                          Jazzicon.getIconWidget(lao.jazziconData),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      lao.name,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      height: 20,
                      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: ResColor.o_1, width: 1, style: BorderStyle.solid)),
                      child: Text(
                        "Self",
                        style: TextStyle(fontSize: 12, color: ResColor.o_1, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              Container(
                height: 5,
              ),
              Text(
                lao.address,
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              Container(
                height: 10,
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: ResColor.white_60,
              ),
            ],
          ),
        );

        Widget batchview = Container();
        if (inBatch) {
          batchview = CustomCheckBox(
            value: isSeletedLao(lao),
            color_check: ResColor.o_1,
            color_border: ResColor.o_1,
            borderRadius: 100,
            width: 20,
            height: 20,
            margin: EdgeInsets.fromLTRB(15, 10, 0, 10),
            onChanged: (value) {
              onSeletedAddressItem(lao, value);
            },
          );
        }

        return InkWell(
          child: Row(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSizeAndFade(
                child: batchview,
              ),
              Expanded(child: item),
            ],
          ),
          onTap: () {
            if (ClickUtil.isFastDoubleClick()) return;
            onClickAddressItem(lao);
          },
          onLongPress: () {
            onLongClickAddressItem(lao);
          },
        );
      },
    );
  }

  Widget getBatchBar() {

    CurrencySymbol cs = pageIndex;
    bool localsupport = AccountMgr().currentAccount.isSupportCurrency(cs);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ResColor.b_4,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: true,
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  selectAll(true);
                  setState(() {});
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                  child: Text(
                    RSID.minermenu_7.text, //"全选",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  selectAll(false);
                  setState(() {});
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
                  child: Text(
                    RSID.minermenu_8.text, //"取消",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Container(width: 10),
              Expanded(
                child: LoadingButton(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  padding: EdgeInsets.only(bottom: 1),
                  height: 40,
                  gradient_bg: localsupport ? ResColor.lg_2 : ResColor.lg_7,
                  color_bg: Colors.transparent,
                  disabledColor: Colors.transparent,
                  bg_borderradius: BorderRadius.circular(4),
                  text: RSID.withdraw.text,
                  //转账
                  textstyle: TextStyle(
                    color: Colors.white,
                    fontSize: LocaleConfig.currentIsZh() ? 17 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                  onclick: (lbtn) {
                    if (hasSelected && localsupport) {
                      // 批量转账
                      onClickBatchWithdraw();
                    }
                  },
                ),
              ),
              Container(width: 10),
              Expanded(
                child: LoadingButton(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  padding: EdgeInsets.only(bottom: 1),
                  height: 40,
                  gradient_bg: ResColor.lg_3,
                  color_bg: Colors.transparent,
                  disabledColor: Colors.transparent,
                  bg_borderradius: BorderRadius.circular(4),
                  text: RSID.alv_delete.text,
                  //删除
                  textstyle: TextStyle(
                    color: Colors.white,
                    fontSize: LocaleConfig.currentIsZh() ? 17 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                  onclick: (lbtn) {
                    if (hasSelected) {
                      //  批量删除
                      onClickBatchDelete();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onClickAddressItem(LocalAddressObj lao) {
    dlog("onClickAddressItem ${lao.address}");

    if (inBatch) {
      bool isSeleted = isSeletedLao(lao);
      onSeletedAddressItem(lao, !isSeleted);
      setState(() {});
      return;
    }

    ViewGT.showView(
        context,
        EditAddressView(
          lao: lao,
        )).then((value) {
      if (value != null && value is LocalAddressObj) {
        // print(value.address);
        localaddressmgr.delete(lao);
        localaddressmgr.add(value);
        localaddressmgr.save();
        setState(() {});
      }
    });
  }

  onLongClickAddressItem(LocalAddressObj lao) {
    dlog("onLongClickAddressItem ${lao.address}");

    if (inBatch) {
      return;
    }

    MessageDialog.showMsgDialog(
      context,
      title: RSID.alv_delete.text,
      msg: '${lao.name}\n${lao.address}\n${RSID.alv_delete_ask.text}',
      msgAlign: TextAlign.center,
      btnLeft: RSID.cancel.text,
      btnRight: RSID.confirm.text,
      onClickBtnLeft: (dialog) {
        dialog.dismiss();
      },
      onClickBtnRight: (dialog) {
        dialog.dismiss();
        localaddressmgr.delete(lao);
        localaddressmgr.save();
        setState(() {});
      },
    );
  }

  onSeletedAddressItem(LocalAddressObj lao, bool isSeleted) {
    if (isSeleted) {
      if (seletedData?.contains(lao) == false) {
        seletedData.add(lao);
      }
    } else {
      seletedData?.remove(lao);
    }

    // print("${seletedData?.length ?? 0}");
  }

  bool isSeletedLao(LocalAddressObj lao) {
    bool isSeleted = seletedData?.contains(lao) == true;
    return isSeleted;
  }

  selectAll(bool isSelected) {
    if (isSelected) {
      List<LocalAddressObj> pagedata = localaddressmgr?.datamap[pageIndex.codename];
      seletedData = List.from(pagedata);
    } else {
      seletedData = [];
    }
  }

  bool get hasSelected {
    return seletedData != null && seletedData.length > 0;
  }

  static bool checkEthAddress(String address) {
    EthereumAddress ea = null;
    try {
      ea = EthereumAddress.fromHex(address);
    } catch (e) {}
    return ea != null;
  }

  static bool checkEpikAddress(String address) {
    return RegExpUtil.re_epik_address.hasMatch(address);
  }

  void onClickMenu() {
    if (inBatch) {
      setState(() {
        inBatch = false;
      });
      return;
    }

    Rect rect = RectGetter.getRectFromKey(key_btn_menu);
    PopMenuDialog.show<AddressMenu>(
      context: context,
      rect: rect,
      datas: AddressMenu.values,
      itemBuilder: (item, dialog) {
        Widget right = null;
        // switch (item) {
        //   case AddressMenu.addnew:
        //     break;
        // }

        return InkWell(
          onTap: () {
            dialog?.dismiss();
            onClickMenuItem(item);
          },
          child: Container(
            // width: double.infinity,
            padding: EdgeInsets.fromLTRB(15, 10, 20, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.getName(),
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                if (right != null) right,
              ],
            ),
          ),
        );
      },
    );
  }

  bool _inBatch = false;

  bool get inBatch => _inBatch;

  set inBatch(v) {
    _inBatch = v;
    if (v == true) seletedData = [];

    setState(() {});
    if (_inBatch) {
      viewSystemUiOverlayStyle = DeviceUtils.system_bar_main.copyWith(systemNavigationBarColor: ResColor.b_4);
      DeviceUtils.setSystemBarStyle(viewSystemUiOverlayStyle);
    } else {
      viewSystemUiOverlayStyle = DeviceUtils.system_bar_light;
      DeviceUtils.setSystemBarStyle(viewSystemUiOverlayStyle);
    }
  }

  onClickMenuItem(AddressMenu menu) {
    switch (menu) {
      case AddressMenu.addnew:
        {
          ViewGT.showView(context, EditAddressView()).then((value) {
            if (value != null && value is LocalAddressObj) {
              // print(value.address);
              localaddressmgr.add(value);
              localaddressmgr.save();
              setState(() {});
            }
          });
        }
        break;
      case AddressMenu.batch:
        {
          setState(() {
            inBatch = !inBatch;
          });
        }
        break;
    }
  }

  onClickBatchDelete() {
    localaddressmgr.deleteAll(seletedData);
    localaddressmgr.save();
    inBatch = false;
    setState(() {});
  }

  onClickBatchWithdraw() {
    if (seletedData.length == 1) {
      bool isCurrent =
          AccountMgr().currentAccount.hd_eth_address.toLowerCase() == seletedData.first.address.toLowerCase() ||
              AccountMgr().currentAccount.epik_EPK_address.toLowerCase() == seletedData.first.address.toLowerCase();
      if(isCurrent)
      {
        showToast(RSID.alv_withdraw_to_self.text);
        return;
      }
    }

    ViewGT.showView(
        context,
        CurrencyBatchWithdrawView(AccountMgr().currentAccount,
            AccountMgr().currentAccount.getCurrencyAssetByCs(seletedData.first.symbol), seletedData));
  }
}

enum AddressMenu {
  addnew,
  batch,
}

extension AddressMenuEx on AddressMenu {
  String getName() {
    switch (this) {
      case AddressMenu.addnew:
        return RSID.alv_addnew.text;
      case AddressMenu.batch:
        return RSID.alv_batch.text;
      default:
        return "";
    }
  }
}
