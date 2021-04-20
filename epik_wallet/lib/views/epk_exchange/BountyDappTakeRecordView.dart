import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/api/api_dapp.dart';
import 'package:epikwallet/logic/api/api_wallet.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/Dapp.dart';
import 'package:epikwallet/model/DappEpkSwapRecord.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/data/date_util.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';

///DAPP epk 领取记录
class BountyDappTakeRecordView extends BaseWidget {
  Dapp dapp;

  BountyDappTakeRecordView(this.dapp);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return BountyDappTakeRecordViewState();
  }
}

class BountyDappTakeRecordViewState
    extends BaseWidgetState<BountyDappTakeRecordView> {
  List<DappEpkSwapRecord> data = [];

  SystemUiOverlayStyle oldSystemUiOverlayStyle;

  @override
  void initStateConfig() {
    super.initStateConfig();

    oldSystemUiOverlayStyle = DeviceUtils.system_bar_current;
    DeviceUtils.setSystemBarStyle(DeviceUtils.system_bar_dark);

    refresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle("领取记录");
  }

  @override
  void dispose() {
    if (oldSystemUiOverlayStyle != null)
      DeviceUtils.setSystemBarStyle(oldSystemUiOverlayStyle);
    super.dispose();
  }

  bool isFirst = true;

  refresh() async {
    if (isFirst) {
      isFirst = false;
    }

    setLoadingWidgetVisible(true);

    List<DappEpkSwapRecord> temp = [];

    isLoading = true;
    HttpJsonRes hjr = await ApiDapp.getFlowList(
        widget.dapp.api_host, widget.dapp.getDappToken());
    isLoading = false;

    if (hjr?.code == 0) {
      temp = JsonArray.parseList<DappEpkSwapRecord>(
          JsonArray.obj2List(hjr.jsonMap["list"]),
          (json) => DappEpkSwapRecord.fromJson(json));
    } else {
      setErrorWidgetVisible(true);

      return;
    }

    if (temp != null && temp.length > 0) {
      data = temp;
      closeStateLayout();
    } else {
      setEmptyWidgetVisible(true);
    }
  }

  bool isLoading = false;

  Future<void> _pullRefreshCallback() async {
    if (isLoading) {
      return;
    }
    isLoading = true;

    List<DappEpkSwapRecord> temp = [];

    HttpJsonRes hjr = await ApiWallet.Erc2EpkSwapRecords();
    if (hjr?.code == 0) {
      temp = JsonArray.parseList<DappEpkSwapRecord>(
          JsonArray.obj2List(hjr.jsonMap["list"]),
          (json) => DappEpkSwapRecord.fromJson(json));
    } else {
      setErrorWidgetVisible(true);
      return;
    }

    if (temp != null && temp.length > 0) {
      data = temp;
      closeStateLayout();
    } else {
      setEmptyWidgetVisible(true);
    }
    isLoading = false;
  }

  @override
  void onClickEmptyWidget() {
    refresh();
  }

  @override
  void onClickErrorWidget() {
    refresh();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return ListPage(
      data,
      itemWidgetCreator: (context, position) {
        return InkWell(
          onTap: () => onItemClick(position),
          child: itemWidgetBuild(context, position),
        );
      },
      pullRefreshCallback: _pullRefreshCallback,
    );
  }

  itemWidgetBuild(BuildContext context, int position) {
    DappEpkSwapRecord record = data[position];

    List<Widget> items = [
      Row(
        children: [
          Text(
            record.created_at_dt == null
                ? ""
                : DateUtil.formatDate(record.created_at_dt,
                    format: DataFormats.y_mo_d_h_m),
            style: TextStyle(
              fontSize: 16,
              color: Color(0xff333333),
            ),
          ),
          Expanded(
            child: Text(
              "${record.amount} EPK",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xff333333),
              ),
            ),
          ),
        ],
      ),

      Container(height: 5),

      Row(
        children: [
          Expanded(
            child: Text(
              record.status,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xff333333),
              ),
            ),
          ),
          Container(width: 5),
          if (StringUtils.isNotEmpty(record.hash))
            InkWell(
              onTap: () {
                lookEpkCid(record.hash);
              },
              child: Text(
                "EPK发放交易",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                ),
              ),
            ),
        ],
      ),
      //
      // Container(height: 5),
      //
      // Row(
      //   children: [
      //     Expanded(
      //       child:Text(
      //        "ERC20-EPK销毁交易",
      //         textAlign: TextAlign.center,
      //         style: TextStyle(
      //           fontSize: 12,
      //           color: Colors.blue,
      //         ),
      //       ),
      //     ),
      //     Expanded(
      //       child:Text(
      //         "EPK发放交易",
      //         textAlign: TextAlign.center,
      //         style: TextStyle(
      //           fontSize: 12,
      //           color: Colors.blue,
      //         ),
      //       ),
      //     ),
      //   ],
      // ),

      Container(height: 14),

      Divider(
        color: const Color(0xffeeeeee),
        height: 1,
        thickness: 1,
      ),
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ),
    );
  }

  onItemClick(int position) {}

  lookEthTxhash(String txhash) {
//    https://cn.etherscan.com/address/0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    String url = ServiceInfo.ether_tx_web + txhash;
    ViewGT.showGeneralWebView(
      context,
      RSID.usolv_3.text, //"详情",
      url,
    );
  }

  lookEpkCid(String cid) {
    String url = ServiceInfo.epik_msg_web + cid; // 需要epk浏览器地址
    ViewGT.showGeneralWebView(
      context,
      RSID.usolv_3.text, //"详情",
      url,
    );
  }
}
