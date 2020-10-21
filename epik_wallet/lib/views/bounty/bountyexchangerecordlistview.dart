import 'dart:convert';

import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/logic/api/api_bounty.dart';
import 'package:epikwallet/logic/loader/DL_TepkLoginToken.dart';
import 'package:epikwallet/model/BountyUserSwap.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class BountyExchangeRecordListview extends BaseInnerWidget {
  int index = 0;

  BountyExchangeRecordListview(this.index);

  @override
  BaseInnerWidgetState<BaseInnerWidget> getState() {
    return BountyExchangeRecordListviewState();
  }

  @override
  int setIndex() {
    return 0;
  }
}

class BountyExchangeRecordListviewState
    extends BaseInnerWidgetState<BountyExchangeRecordListview> {
  List<BountyUserSwapRecord> datalist = [];

  bool moreLoading = false;
  bool needNoMoreTipe = false;

  @override
  void initStateConfig() {
    super.initStateConfig();
    setAppBarVisible(false);
    setTopBarVisible(false);
  }

  void onCreate() {
    super.onCreate();
    refresh();
  }

  int pageSize = 20;
  int page = 0;
  bool isLoading = false;
  bool hasMore = false;

  int lastBuildItemMax = 0;

  refresh() {
    isLoading = true;

    setLoadingWidgetVisible(true);

    hasMore = false;
    page = 0;
    ApiBounty.getUserSwaplist(
            DL_TepkLoginToken.getEntity().getToken(), page, pageSize)
        .then((httpjsonres) {
      datacallback(httpjsonres);
    });
  }

  datacallback(HttpJsonRes hjr) {
    List<BountyUserSwapRecord> data;

    if (hjr != null && hjr.code == 0) {
      // 解析数据列表
      data = JsonArray.parseList<BountyUserSwapRecord>(
          hjr?.jsonMap["list"] ?? [],
          (json) => BountyUserSwapRecord.fromJson(json));

//       test
      int size = datalist.length + data.length;
      for (int i = size; i < size + 20; i++) {
        data.add((BountyUserSwapRecord.fromJson(jsonDecode(
            '{"id":1,"created_at":"2020-10-10T00:00:00Z","updated_at":"0001-01-01T00:00:00Z","miner_id":"241b7750-e601-54ad-9145-33837529dbbb","amount":100,"erc20_epk":120,"fee":0,"status":"pending","tx_hash":"$i"}'))));
      }
    }

    if (data != null) {
      // 请求成功
      if (page == 0) {
        lastBuildItemMax = 0;
        datalist.clear();
      }
      datalist.addAll(data);

      if (data.length >= pageSize) {
        hasMore = true;
        page += 1;
      } else {
        hasMore = false;
      }

      if (datalist.length == 0) {
        setEmptyWidgetVisible(true);
        return;
      }
    } else {
//      showToast("请求失败");
      if (page == 0) {
        setErrorWidgetVisible(true);
        return;
      }
    }
    closeStateLayout();
    isLoading = false;
    return;
  }

  @override
  void onClickErrorWidget() {
    super.onClickErrorWidget();
    refresh();
  }

  @override
  void onClickEmptyWidget() {
    super.onClickEmptyWidget();
    refresh();
  }

  @override
  Widget buildWidget(BuildContext context) {
//    return ListPage(
//        datalist,
//      itemWidgetCreator: (context, position) {
//        return InkWell(
//          onTap: () => onItemClick(position),
//          child: itemWidgetBuild(context, position),
//        );
//      },
//      pullRefreshCallback: _pullRefreshCallback,
//      needLoadMore: needLoadMore,
//      onLoadMore: onLoadMore,
//    );

    Widget customscrollview = CustomScrollView(
      key: PageStorageKey<String>("bountyrecord_exchange${this.widget.index}"),
      slivers: <Widget>[
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, index) {
//              return itemWidgetBuild(context, index);
              return buildItemWidget(context, index);
            },
            childCount: datalist.length + 1,
          ),
        )
      ],
    );
//    return customscrollview;

    return RefreshIndicator(
      displacement: 50,
      color: ResColor.progress,
      onRefresh: _pullRefreshCallback,
      child: customscrollview,
//      key: key_refresh,
    );
  }

  Widget buildItemWidget(BuildContext context, int index) {
    if (index == datalist.length) {
      if (lastBuildItemMax != index) {
        lastBuildItemMax = index;

        if (needLoadMore()) {
          moreLoading = true;
          onLoadMore().then((hasmore) {
            hasMore = hasmore;
            moreLoading = false;
            if (mounted) setState(() {});
          });
        } else {
          hasMore = false;
          moreLoading = false;
        }
      }
      return buildLoadMoreWidget(context, index);
    } else {
      return InkWell(
        onTap: () => onItemClick(index),
        child: itemWidgetBuild(context, index),
      );
    }
  }

  Widget itemWidgetBuild(BuildContext context, int position) {
    var item = datalist[position];
    return Container(
      width: double.infinity,
//      height: 135,
      padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(
                "- " +
                    StringUtils.formatNumAmount(item.amount, point: 8) +
                    " 积分",
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xff333333),
                ),
              )),
              Text(
                item.getStatusStr(),
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xff333333),
                ),
              ),
            ],
          ),
          Container(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  "+ " +
                      StringUtils.formatNumAmount(item.erc20_epk, point: 8) +
                      " ERC2-EPK",
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xff333333),
                  ),
                ),
              ),
              Text(
                "手续费: ${StringUtils.formatNumAmount(item.fee, point: 8)} ERC2-EPK",
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xff333333),
                ),
              ),
            ],
          ),
          Container(height: 10),
          Text(
            "时间:${item.created_at_local}",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xff333333),
            ),
          ),

          if (StringUtils.isNotEmpty(item?.tx_hash))
            Container(
              padding: EdgeInsets.only(top: 5),
              child:   Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "txhash:${item.tx_hash}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xff333333),
                      ),
                    ),
                  ),
                  Container(
                    width: 12,
                    margin: EdgeInsets.fromLTRB(5, 3, 0, 0),
                    child: Icon(
                      Icons.redo,
                      color: Colors.blue,
                      size: 12,
                    ),
                  )
                ],
              ),
            ),
          Container(
            margin: EdgeInsets.only(top: 14),
            height: 1,
            color: Color(0xffeeeeee),
          ),
        ],
      ),
//      child: Stack(
//        children: <Widget>[
//          // 底部分割线
//          Positioned(
//            left: 0,
//            right: 0,
//            bottom: 0,
//            height: 1,
//            child: Container(
//              color: Color(0xffeeeeee),
//            ),
//          ),
//          Positioned(
//            left: 0,
//            top: 0,
//            child: Text(
//              "- " + StringUtils.formatNumAmount(item.amount, point: 8) + " 积分",
//              style: TextStyle(
//                fontSize: 15,
//                color: Color(0xff333333),
//              ),
//            ),
//          ),
//          Positioned(
//            right: 10,
//            top: 0,
//            child: Text(
//              item.getStatusStr(),
//              style: TextStyle(
//                fontSize: 15,
//                color: Color(0xff333333),
//              ),
//            ),
//          ),
//          Positioned(
//            left: 0,
//            top: 37,
//            child: Text(
//              "+ " +
//                  StringUtils.formatNumAmount(item.erc20_epk, point: 8) +
//                  " ERC2-EPK",
//              style: TextStyle(
//                fontSize: 15,
//                color: Color(0xff333333),
//              ),
//            ),
//          ),
//          Positioned(
//            right: 10,
//            top: 37,
//            child: Text(
//              "手续费: ${StringUtils.formatNumAmount(item.fee, point: 8)} ERC2-EPK",
//              style: TextStyle(
//                fontSize: 15,
//                color: Color(0xff333333),
//              ),
//            ),
//          ),
//          Positioned(
//            left: 0,
//            top: 70,
//            child: Text(
//              "时间:${item.created_at_local}",
//              style: TextStyle(
//                fontSize: 12,
//                color: Color(0xff333333),
//              ),
//            ),
//          ),
//          Positioned(
//            left: 0,
//            right: 10,
//            top: 90,
//            child: Row(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: <Widget>[
//                Expanded(
//                  child: Text(
//                    "txhash:${item.tx_hash}",
//                    maxLines: 1,
//                    overflow: TextOverflow.ellipsis,
//                    style: TextStyle(
//                      fontSize: 12,
//                      color: Color(0xff333333),
//                    ),
//                  ),
//                ),
//                Container(
//                  width: 12,
//                  margin: EdgeInsets.fromLTRB(5, 3, 0, 0),
//                  child: Icon(
//                    Icons.redo,
//                    color: Colors.blue,
//                    size: 12,
//                  ),
//                )
//              ],
//            ),
//          ),
//        ],
//      ),
    );
  }

  Widget buildLoadMoreWidget(BuildContext context, int position) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(5.0),
      child: ((moreLoading || hasMore) && isLoading)
          ? new CircularProgressIndicator(
              strokeWidth: 2,
            )
          : Container(
              child: needNoMoreTipe
                  ? Text(
                      "没有更多了",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)),
                    )
                  : null,
            ),
    );
  }

  onItemClick(int position) {
    String hash = datalist[position].tx_hash;
    DeviceUtils.copyText(hash);
//    https://cn.etherscan.com/address/0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    String url = "https://cn.etherscan.com/tx/$hash";
    ViewGT.showGeneralWebView(context, "详情", url);
  }

  Future<void> _pullRefreshCallback() async {
    if (isLoading) {
      return;
    }
    hasMore = false;
    page = 0;
    isLoading = true;
    HttpJsonRes httpjsonres = await ApiBounty.getUserSwaplist(
        DL_TepkLoginToken.getEntity().getToken(), page, pageSize);

    datacallback(httpjsonres);
  }

  /**是否需要加载更多*/
  bool needLoadMore() {
    bool ret = hasMore && !isLoading;
    return ret;
  }

  /**加载分页*/
  Future<bool> onLoadMore() async {
    if (isLoading) return true;
    dlog("onLoadMore  ");
    isLoading = true;

    var data = await ApiBounty.getUserSwaplist(
        DL_TepkLoginToken.getEntity().getToken(), page, pageSize);
    datacallback(data);
    return hasMore;
  }
}
