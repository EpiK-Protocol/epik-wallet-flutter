import 'dart:convert';

import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/api/api_bounty.dart';
import 'package:epikwallet/logic/loader/DL_TepkLoginToken.dart';
import 'package:epikwallet/model/BountyUserReward.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as ensv;
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class BountyRewardRecordListview extends BaseInnerWidget {
  int index = 0;

  BountyRewardRecordListview(this.index);

  @override
  BaseInnerWidgetState<BaseInnerWidget> getState() {
    return BountyRewardRecordListviewState();
  }

  @override
  int setIndex() {
    return 0;
  }
}

class BountyRewardRecordListviewState
    extends BaseInnerWidgetState<BountyRewardRecordListview> {
  List<BountyUserRewardRecord> datalist = [];

  bool moreLoading = false;
  bool needNoMoreTipe = false;

  @override
  void initStateConfig() {
    super.initStateConfig();
    setAppBarVisible(false);
    setTopBarVisible(false);
  }

  @override
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
    ApiBounty.getUserTaskList(
            DL_TepkLoginToken.getEntity().getToken(), page, pageSize)
        .then((httpjsonres) {
      datacallback(httpjsonres);
    });
  }

  datacallback(HttpJsonRes hjr) {
    List<BountyUserRewardRecord> data;

    if (hjr != null && hjr.code == 0) {
      // 解析数据列表
      data = JsonArray.parseList<BountyUserRewardRecord>(
          hjr?.jsonMap["list"] ?? [],
          (json) => BountyUserRewardRecord.fromJson(json));

      // test
      // int size = datalist.length + data.length;
      // for (int i = size; i < size + 20; i++) {
      //   data.add((BountyUserRewardRecord.fromJson(jsonDecode(
      //       '{"id":1,"created_at":"2020-10-10T00:00:00Z","updated_at":"0001-01-01T00:00:00Z","bounty_id":1,"title":"案件水电费","miner_id":"241b7750-e601-54ad-9145-33837529dbbb","bonus":${i},"status":"done","description":"asdfa"}'))));
      // }
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
      key: PageStorageKey<String>("bountyrecord_reward${this.widget.index}"),
      slivers: <Widget>[
        SliverOverlapInjector(
          handle: ensv.NestedScrollView.sliverOverlapAbsorberHandleFor(context),
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
      displacement: 80,
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
      return itemWidgetBuild(context, index);
    }
  }

  Widget itemWidgetBuild(BuildContext context, int position) {
    var item = datalist[position];
    return Container(
      width: double.infinity,
//      height: 135,
      padding: EdgeInsets.fromLTRB(20, 17, 20, 0),
      color: ResColor.b_3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(
                item.title ?? "Title",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              )),
              Container(width: 10),
              Text(
                "+ " +
                    StringUtils.formatNumAmount(item.bonus, point: 8) +
                    ResString.get(context, RSID.berlv_1), //" 积分",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  ResString.get(context, RSID.berlv_3) + item.created_at_local,
                  //"时间:${item.created_at_local}",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white60,
                  ),
                ),
              ),
              Text(
                item.description ?? RSID.brrlv_1.text,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
          Container(
              margin: EdgeInsets.only(top: 16),
              height: 1,
              color: ResColor.white_20),
        ],
      ),
    );
    // return Container(
    //   width: double.infinity,
    //   height: 80,
    //   padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
    //   color: Colors.white,
    //   child: Stack(
    //     children: <Widget>[
    //       // 底部分割线
    //       Positioned(
    //         left: 0,
    //         right: 0,
    //         bottom: 0,
    //         height: 1,
    //         child: Container(
    //           color: Color(0xffeeeeee),
    //         ),
    //       ),
    //       Positioned(
    //         left: 0,
    //         top: 0,
    //         child: Text(
    //           item.title ?? "Title",
    //           style: TextStyle(
    //             fontSize: 15,
    //             color: Color(0xff333333),
    //           ),
    //         ),
    //       ),
    //       Positioned(
    //         right: 10,
    //         top: 0,
    //         child: Text(
    //           item.description ?? ResString.get(context, RSID.brrlv_1),
    //           //"完成任务",
    //           style: TextStyle(
    //             fontSize: 15,
    //             color: Color(0xff333333),
    //           ),
    //         ),
    //       ),
    //       Positioned(
    //         left: 0,
    //         bottom: 10,
    //         child: Text(
    //           "+ " +
    //               StringUtils.formatNumAmount(item.bonus, point: 8) +
    //               ResString.get(context, RSID.berlv_1), //" 积分",
    //           style: TextStyle(
    //             fontSize: 15,
    //             color: Color(0xff333333),
    //           ),
    //         ),
    //       ),
    //       Positioned(
    //         right: 10,
    //         bottom: 10,
    //         child: Text(
    //           item.created_at_local,
    //           style: TextStyle(
    //             fontSize: 12,
    //             color: Color(0xff333333),
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
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
                      ResString.get(context, RSID.no_more), //"没有更多了",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)),
                    )
                  : null,
            ),
    );
  }

  onItemClick(int position) {}

  Future<void> _pullRefreshCallback() async {
    if (isLoading) {
      return;
    }
    hasMore = false;
    page = 0;
    isLoading = true;
    HttpJsonRes httpjsonres = await ApiBounty.getUserTaskList(
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

    var data = await ApiBounty.getUserTaskList(
        DL_TepkLoginToken.getEntity().getToken(), page, pageSize);
    datacallback(data);
    return hasMore;
  }
}
