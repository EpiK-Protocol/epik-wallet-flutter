import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:flutter/material.dart';

typedef HeaderWidgetBuild = Widget Function(BuildContext context, int position);

typedef ItemWidgetBuild = Widget Function(BuildContext context, int position);

/**下拉回调方法,方法需要有async和await关键字，没有await，刷新图标立马消失，没有async，刷新图标不会消失*/
typedef PullRefreshCallback = Future<void> Function();

typedef NeedLoadMore = bool Function();

typedef LoadMoreCallback = Future<bool> Function();

typedef ScrollCallback = void Function(ScrollController ctrl);

typedef BgContainer = Widget Function(Widget view);

class ListPage extends StatefulWidget {
  List headerList;
  List listData;
  ItemWidgetBuild itemWidgetCreator;
  HeaderWidgetBuild headerCreator;
  PullRefreshCallback pullRefreshCallback;
  NeedLoadMore needLoadMore;
  LoadMoreCallback onLoadMore;
  ScrollCallback scrollCallback;
  BgContainer bgContainer;

  int basePageSize = 20;

  bool needNoMoreTipe = true;

  ListPage(
    List this.listData, {
    Key key,
    List this.headerList,
    ItemWidgetBuild this.itemWidgetCreator,
    HeaderWidgetBuild this.headerCreator,
    PullRefreshCallback this.pullRefreshCallback,
    NeedLoadMore this.needLoadMore,
    LoadMoreCallback this.onLoadMore,
    ScrollCallback this.scrollCallback,
    int this.basePageSize = 20,
    this.needNoMoreTipe,
        this.bgContainer,
  }) : super(key: key);

  @override
  ListPageState createState() {
    return new ListPageState();
  }
}

class ListPageState extends State<ListPage> {
  ScrollController scrollController = new ScrollController();

  GlobalKey<RefreshIndicatorState> key_refresh;

  bool moreLoading = false;
  bool hasmore = false;

  @override
  void initState() {
    super.initState();

    hasmore = widget.needLoadMore != null; // 如果有更多事件回调 就默认开启更多
    if (hasmore &&
        widget.listData != null &&
        widget.listData.length < widget.basePageSize) {
      // 防止第一页加载数据 不足 还出现loadingmore
      hasmore = false;
    }

    key_refresh = GlobalKey();

    scrollController.addListener(() {
      if (widget.scrollCallback != null) {
        try {
          widget.scrollCallback(scrollController);
        } catch (e) {
          Dlog.p("ListPage",e);
        }
      }
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (widget.onLoadMore != null && widget.needLoadMore != null) {
          if (widget.needLoadMore()) {
            setState(() {
              moreLoading = true;
            });
            widget.onLoadMore().then((hasmore) {
              setState(() {
                this.hasmore = hasmore;
                moreLoading = false;
              });
            });
          } else {
            setState(() {
              hasmore = false;
              moreLoading = false;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    Dlog.p("ListPage","cccmax1  hasmore=$hasmore  size=${widget.listData.length}");
//    if(!hasmore && widget.needLoadMore != null && widget.listData.length>=widget.basePageSize)
//    {
//      hasmore = true;
//    }
//    Dlog.p("ListPage","cccmax2  hasmore=$hasmore  size=${widget.listData.length}");

    ListView listview = ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(0),
      itemBuilder: (BuildContext context, int position) {
        return buildItemWidget(context, position);
      },
      itemCount: _getListCount() + 1,
      //+ (moreLoading ? 1 : 0),
      controller: scrollController,
    );

    if (widget.pullRefreshCallback != null) {
      return RefreshIndicator(
        color: ResColor.progress,
        onRefresh: widget.pullRefreshCallback,
        child: widget.bgContainer==null? listview: widget.bgContainer(listview),
        key: key_refresh,
      );
    } else {
      return Container(child: listview);
    }
  }

  int _getListCount() {
    int itemCount = widget.listData.length;
    return getHeaderCount() + itemCount;
  }

  int getHeaderCount() {
    int headerCount = widget.headerList != null ? widget.headerList.length : 0;
    return headerCount;
  }

  Widget _headerItemWidget(BuildContext context, int index) {
    if (widget.headerCreator != null) {
      return widget.headerCreator(context, index);
    } else {
      return new GestureDetector(
        child: new Padding(
            padding: new EdgeInsets.all(10.0),
            child: new Text("Header Row $index")),
        onTap: () {
          Dlog.p("ListPage",'header click $index --------------------');
        },
      );
    }
  }

  Widget buildItemWidget(BuildContext context, int index) {
    if (index < getHeaderCount()) {
      return _headerItemWidget(context, index);
    } else {
      if (index == _getListCount()) {
        return buildLoadMoreWidget(context, index);
      } else {
        int pos = index - getHeaderCount();
        return _itemBuildWidget(context, pos);
      }
    }
  }

  Widget _itemBuildWidget(BuildContext context, int index) {
    if (widget.itemWidgetCreator != null) {
      return widget.itemWidgetCreator(context, index);
    } else {
      return new GestureDetector(
        child: new Padding(
            padding: new EdgeInsets.all(10.0), child: new Text("Row $index")),
        onTap: () {
          Dlog.p("ListPage",'click $index --------------------');
        },
      );
    }
  }

  Widget buildLoadMoreWidget(BuildContext context, int position) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(5.0),
      child: (moreLoading || hasmore)
          ? new CircularProgressIndicator(
              strokeWidth: 2,
            )
          : Container(
              child: widget.needNoMoreTipe
                  ? Text(
                      "没有更多了",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)),
                    )
                  : null,
            ),
    );
  }

  doRefresh() {
    if (key_refresh != null && key_refresh.currentState != null)
      key_refresh.currentState.show();
    if (widget.pullRefreshCallback != null) widget.pullRefreshCallback();
  }
}
