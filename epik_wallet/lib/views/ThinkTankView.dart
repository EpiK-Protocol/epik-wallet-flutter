import 'dart:ui';

import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/base/common_function.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/api/api_mainnet.dart';
import 'package:epikwallet/model/Expert.dart';
import 'package:epikwallet/model/ExpertBaseInfo.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

enum ThinkTankStateType {
  ALL,

  ///新申请的
  REGISTERED,

  ///审核通过
  NOMINATED,

  ///正常可用状态
  NORMAL,

  ///黑名单
  BLACK,
}

extension ThinkTankStateTypeEx on ThinkTankStateType {
  String getName() {
    switch (this) {
      case ThinkTankStateType.ALL:
        return "全部";
      case ThinkTankStateType.REGISTERED:
        return ExpertStatus.registered.getString();
      case ThinkTankStateType.NOMINATED:
        return ExpertStatus.nominated.getString();
      case ThinkTankStateType.NORMAL:
        return ExpertStatus.normal.getString();
      case ThinkTankStateType.BLACK:
        return ExpertStatus.blocked.getString();
    }
  }
}

///智库
class ThinkTankView extends BaseInnerWidget {
  ThinkTankView(Key key) : super(key: key) {}

  @override
  BaseInnerWidgetState<BaseInnerWidget> getState() {
    return ThinkTankViewState();
  }

  @override
  int setIndex() {
    return 3;
  }
}

class ThinkTankViewState extends BaseInnerWidgetState<ThinkTankView> {
  ExpertInfomation expertInfomation;

  ThinkTankStateType pageIndex = ThinkTankStateType.ALL;

  List<Expert> data_experts = [];

  List<Expert> data_experts_show = [];

  GlobalKey<ListPageState> key_scroll = GlobalKey();

  ListPageDefState _ListPageDefState = ListPageDefState(null, img: "");

  int page = 0;
  int pageSize = 20;
  bool isLoading = false;
  bool hasMore = false;

  @override
  void initStateConfig() {
    super.initStateConfig();
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);

    refresh();
  }

  bool isFirst = true;

  refresh() async {
    if (isFirst) {
      isFirst = false;
    }

    setLoadingWidgetVisible(true);
    isLoading = true;

    page = 0;
    HttpJsonRes hjr_info = await ApiMainNet.expertBaseInfomation();
    if (hjr_info.code == 0) {
      expertInfomation =
          ExpertInfomation.fromJson(hjr_info.jsonMap["expertInfomation"]);

      HttpJsonRes hjr = await ApiMainNet.experts(page, pageSize);
      dataCallback(hjr);
    } else {
      setErrorWidgetVisible(true);
      isLoading = false;
    }
  }

  dataCallback(HttpJsonRes hjr) {
    List<Expert> data = null;
    if (hjr?.code == 0) {
      data = JsonArray.parseList(JsonArray.obj2List(hjr.jsonMap["list"]),
          (json) => Expert.fromJson(json));
      data = data ?? [];
    }

    if (data != null) {
      // 请求成功
      if (page == 0) {
        data_experts.clear();
      }
      data_experts.addAll(data);

      dataFilter(pageIndex);

      // if (data.length >= pageSize) {
      //   hasMore = true;
      //   page += 1;
      // } else {
      //   hasMore = false;
      // }
      hasMore = false;

      if (page == 0 && data.length == 0) {
        setEmptyWidgetVisible(true);
        isLoading = false;
        return;
      }
    } else {
      showToast(ResString.get(context, RSID.request_failed)); //"请求失败);
      if (page == 0) {
        setErrorWidgetVisible(true);
        isLoading = false;
        return;
      }
    }
    closeStateLayout();
    isLoading = false;
    return;
  }

  @override
  Widget buildWidget(BuildContext context) {
    Widget widget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader(),
        Expanded(
          child: buildList(),
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.fromLTRB(0, BaseFuntion.topbarheight, 0, 0),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          colors: [
            Color(0xfff7e6f0),
            Colors.white,
          ],
          center: Alignment.center,
          radius: 1,
          tileMode: TileMode.clamp,
        ),
      ),
      child: widget,
    );
  }

  Widget buildHeader() {
    Container card = Container(
      margin: EdgeInsets.only(top: 0),
      padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
      width: double.infinity,
      child: Card(
        color: ResColor.main,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        clipBehavior: Clip.antiAlias,
        //card内容按边框剪切
        elevation: 10,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                RSID.mainview_5.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(height: 10),
              Row(
                children: [
                  Text(
                    "总投票数:",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${expertInfomation?.TotalVote_f ?? 0} EPK",
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              Container(height: 5),
              Row(
                children: [
                  Text(
                    "平均投票:",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${expertInfomation?.AvgVote_f ?? 0} EPK",
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              Container(height: 5),
              // Row(
              //   children: [
              //     Text(
              //       "专家奖励:",
              //       style: const TextStyle(
              //         color: Colors.white,
              //         fontSize: 16,
              //       ),
              //     ),
              //     Expanded(child: Text(
              //       "${expertInfomation?.TotalExpertReward ?? 0} EPK",
              //       textAlign: TextAlign.right,
              //       style: const TextStyle(
              //         color: Colors.white,
              //         fontSize: 16,
              //       ),
              //     ),),
              //   ],
              // ),
              // Container(height: 5),
              Row(
                children: [
                  Text(
                    "投票收益:",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${expertInfomation?.TotalVoteReward_f ?? 0} EPK",
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              Container(height: 5),
              Row(
                children: [
                  Text(
                    "年化收益:",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      StringUtils.formatNumAmount(
                              (expertInfomation?.AnnualizedRate_d ?? 0),
                              point: 2,
                              supply0: true) +
                          "%",
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    List<Widget> children = [
      // getAppBar(),
      card,
      getBanner(),
      getTabs(),
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget getBanner() {
    return Container(
      margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
      height: 50,
      width: double.infinity,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: ResColor.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        elevation: 10,
        shadowColor: ResColor.black_20,
        child: InkWell(
          onTap: () {
            // todo 申请领域专家
            ViewGT.showApplyExpertView(context);
          },
          child: Stack(
            children: [
              Align(
                alignment: FractionalOffset(0.5, 0.5),
                child: Text(
                  "申请成为领域专家",
                  style: TextStyle(
                    fontSize: 16,
                    color: ResColor.black,
                  ),
                ),
              ),
              Align(
                alignment: FractionalOffset(0.95, 0.5),
                child: Icon(
                  Icons.arrow_forward_ios_outlined,
                  size: 12,
                  color: ResColor.black_50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTabs() {
    List<Widget> items = [];

    ThinkTankStateType.values.forEach((type) {
      Widget v = Expanded(
        child: GestureDetector(
          onTap: () {
            onClickTab(type);
          },
          child: Text(
            type.getName(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: pageIndex == type ? Colors.black : Colors.black45,
              fontSize: 14,
            ),
          ),
        ),
      );
      items.add(v);
    });

    return Container(
      width: double.infinity,
      height: BaseFuntion.appbarheight_def,
      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: Container(
        height: 40,
        width: double.infinity,
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          elevation: 5,
          shadowColor: Colors.black38,
          child: Row(
            children: items,
          ),
        ),
      ),
    );
  }

  ///导航栏appBar中间部分 ，不满足可以自行重写
  Widget getAppBarCenter({Color color}) {
    return Text(
      RSID.mainview_5.text,
      style: TextStyle(
        fontSize: appBarCenterTextSize,
        color: color ?? appBarContentColor,
//        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget buildList() {
    Widget widget = new ListPage(
      data_experts_show ?? [],
      headerList: [_ListPageDefState],
      headerCreator: (context, position) {
        return stateHeaderWidgetBuild(context, position);
      },
      itemWidgetCreator: (context, position) {
        return InkWell(
          onTap: () => onItemClick(position),
          child: itemWidgetBuild(context, position),
        );
      },
      pullRefreshCallback: _pullRefreshCallback,
      needLoadMore: needLoadMore,
      onLoadMore: onLoadMore,
      key: key_scroll,
    );
    return widget;
  }

  onItemClick(int position) {
    Expert item = data_experts_show[position];
    ViewGT.showExpertInfoView(context, item).then((value) {
      // dlog("showExpertInfoView result =${value}");
      setState(() {});
    });
  }

  Widget itemWidgetBuild(BuildContext context, int position) {
    Expert item = data_experts[position];

    return Container(
      margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
      width: double.infinity,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: ResColor.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        elevation: 10,
        shadowColor: ResColor.black_20,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ID: ${item.id}",
              ),
              Text(
                "领域: xxx",
              ),
              Text(
                "票数: ${StringUtils.formatNumAmount(item.vote)}${item.getRequiredVoteStr()} EPK",
              ),
              Text(
                "收益: ${StringUtils.formatNumAmount(item.income)} EPK",
              ),
              Text(
                "状态: ${item?.status_e?.getString()}",
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onClickErrorWidget() {
    refresh();
  }

  void onClickEmptyWidget() {
    refresh();
  }

  Future<void> _pullRefreshCallback() async {
    if (isLoading) {
      return;
    }
    page = 0;
    isLoading = true;

    //  刷新
    // HttpJsonRes hjr = await ApiMainNet.experts(page, pageSize);
    // dataCallback(hjr);

    HttpJsonRes hjr_info = await ApiMainNet.expertBaseInfomation();
    if (hjr_info.code == 0) {
      expertInfomation =
          ExpertInfomation.fromJson(hjr_info.jsonMap["expertInfomation"]);

      HttpJsonRes hjr = await ApiMainNet.experts(page, pageSize);
      dataCallback(hjr);
    } else {
      setErrorWidgetVisible(true);
      isLoading = false;
    }
  }

  /**是否需要加载更多*/
  bool needLoadMore() {
    bool ret = hasMore && !isLoading;
    dlog("needLoadMore = " + ret.toString());
    return ret;
  }

  /**加载分页*/
  Future<bool> onLoadMore() async {
    if (isLoading) return true;
    dlog("onLoadMore  ");
    isLoading = true;

    //  加载分页
    HttpJsonRes hjr = await ApiMainNet.experts(page, pageSize);
    dataCallback(hjr);
    return hasMore;
  }

  void onClickTab(ThinkTankStateType type) {
    //todo
    if (pageIndex == type) return;
    pageIndex = type;
    setState(() {
      dataFilter(pageIndex);
    });

    key_scroll?.currentState?.scrollController?.animateTo(0,
        duration: Duration(milliseconds: 200), curve: Curves.easeIn);

    // // 切换数据类型
    // refresh();
  }

  dataFilter(ThinkTankStateType type) {
    List<Expert> data = [];
    if (data_experts != null) {
      data_experts.forEach((item) {
        switch (type) {
          case ThinkTankStateType.REGISTERED:
            {
              if (item.status_e == ExpertStatus.registered) data.add(item);
            }
            break;
          case ThinkTankStateType.NOMINATED:
            {
              if (item.status_e == ExpertStatus.nominated) data.add(item);
            }
            break;
          case ThinkTankStateType.NORMAL:
            {
              if (item.status_e == ExpertStatus.normal) data.add(item);
            }
            break;
          case ThinkTankStateType.BLACK:
            {
              if (item.status_e == ExpertStatus.blocked ||
                  item.status_e == ExpertStatus.disqualified) data.add(item);
            }
            break;
          case ThinkTankStateType.ALL:
          default:
            data.add(item);
        }
      });
    }
    data_experts_show = data;
    if (data == null || data.length == 0) {
      _ListPageDefState.type = ListPageDefStateType.EMPTY;
    } else {
      _ListPageDefState.type = null;
    }
  }

  Widget stateHeaderWidgetBuild(BuildContext context, int position) {
    try {
      return ListPageDefStateWidgetHeader.getWidgetHeader(_ListPageDefState);
    } catch (e) {
      print(e);
    }
    return Container();
  }
}
