import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/loading_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/LocaleConfig.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_mainnet.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/CoinbaseInfo2.dart';
import 'package:epikwallet/utils/ClickUtil.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/utils/toast/toast.dart';
import 'package:epikwallet/views/miner/AddOtherMinerPledgeView.dart';
import 'package:epikwallet/views/miner/MinerBatchTransferView.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:epikwallet/widget/rect_getter.dart';
import 'package:epikwallet/widget/text/TextEllipsisMiddle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import '../../utils/string_utils.dart';

///miner列表 有删选、批量操作
class MinerListView extends BaseWidget {
  CoinbaseInfo2 coinbase;

  MinerListView(this.coinbase);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return MinerListViewState();
  }
}

class MinerListViewState extends BaseWidgetState<MinerListView> {
  MinerFilterType _MinerFilterType = MinerFilterType.ALL;
  MinerSortType _MinerSortType = MinerSortType.ID_UP;

  List<CbMinerObj> data = [];

  List<CbMinerObj> data_filter = [];

  Map<String, List<CbMinerObj>> map_ownerfilter = {};
  String _owner_current;

  List<CbMinerObj> data_seleted = [];

  GlobalKey<ListPageState> key_listpage = GlobalKey();

  @override
  void initStateConfig() {
    super.initStateConfig();
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);

    refresh();
  }

  List<int> debuginputlist = [];

  String debugkey = "0,1,1,0,1,1,1";
  int debugkeyLength = 7;

  static bool debugBtn = false;

  void debuginput(int key) {
    if (debuginputlist.length >= debugkeyLength) {
      debuginputlist.removeAt(0);
    }
    debuginputlist.add(key);
    dlog(debuginputlist.toString());
    if (debuginputlist.length == debugkeyLength && debuginputlist.join(",") == debugkey) {
      debugBtn = !debugBtn;
      dlog("debug=$debugBtn");
      setState(() {});
      Vibrate.canVibrate.then((ok) {
        Vibrate.feedback(FeedbackType.medium);
      });
    }
  }

  @override
  Widget getAppBarCenter({Color color}) {
    Widget title = Text(
      appBarTitle,
      style: TextStyle(
        fontSize: appBarCenterTextSize,
        color: color ?? appBarContentColor,
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            debuginput(0);
          },
          child: Container(
            height: double.infinity,
            width: 60,
            color: Colors.transparent,
          ),
        ),
        title,
        InkWell(
          onTap: () {
            debuginput(1);
          },
          child: Container(
            height: double.infinity,
            width: 60,
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }

  @override
  Widget getAppBarRight({Color color}) {
    return InkWell(
      onTap: () {
        if (!isLoading) ViewGT.showView(context, AddOtherMinerPledgeView(), model: ViewPushModel.PushReplacement);
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        width: 24.0 + 20 + 20,
        height: getAppBarHeight(),
        child: Icon(
          Icons.add_rounded,
          color: color ?? Colors.white,
          size: 24,
        ),
        // child: Center(
        //   child: Image.asset("assets/img/ic_back.png",width: 24,height: 24,
        //     color: color ?? _appBarContentColor,
        //   ),
        // ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(RSID.mainview_6.text);
  }

  bool isFirst = true;

  bool isLoading = false;

  double maxPower = 0;

  refresh({bool frompull}) async {
    if (isFirst) {
      isFirst = false;
    }

    isLoading = true;
    proressBackgroundColor = Colors.transparent;
    if (frompull != true) setLoadingWidgetVisible(true);

    HttpJsonRes hjr = await ApiMainNet.getMinersAutoSection(widget?.coinbase?.miner?.MinerIDs);
    if (hjr?.code == 0) {
      // "maxPower":"17825792"
      maxPower = StringUtils.parseDouble(hjr.jsonMap["maxPower"], null);

      data = JsonArray.parseList(JsonArray.obj2List(hjr.jsonMap["list"]), (json) => CbMinerObj.fromJson(json));
      if (data == null || data?.length == 0) {
        emptyBackgroundColor = Colors.transparent;
        statelayout_margin = EdgeInsets.only(top: getAppBarHeight() + 100);
        setEmptyWidgetVisible(true);
      } else {
        await filterOwner();
        await filterData();
        if (data_filter?.isNotEmpty == true) {
          closeStateLayout();
        } else {
          emptyBackgroundColor = Colors.transparent;
          statelayout_margin = EdgeInsets.only(top: getAppBarHeight() + 100);
          setEmptyWidgetVisible(true);
        }
      }
    } else {
      errorBackgroundColor = Colors.transparent;
      statelayout_margin = EdgeInsets.only(top: getAppBarHeight() + getTopBarHeight());
      setErrorContent(hjr.msg ?? RSID.net_error.text);
      setErrorWidgetVisible(true);
    }
    isLoading = false;
  }

  ///数据筛选过滤
  Future filterData() async {
    List<CbMinerObj> ret = [];

    switch (_MinerFilterType) {
      case MinerFilterType.ALL:
        {
          ret = List.from(data);
        }
        break;
      case MinerFilterType.COINBASE_MY:
        {
          List<CbMinerObj> temp = [];
          data.forEach((obj) {
            if (obj != null && obj.Coinbase == widget.coinbase.ID) {
              temp.add(obj);
            }
          });
          ret = temp;
        }
        break;
      case MinerFilterType.COINBASE_OTHER:
        {
          List<CbMinerObj> temp = [];
          data.forEach((obj) {
            if (obj != null && obj.Coinbase == widget.coinbase.ID) {
            } else {
              temp.add(obj);
            }
          });
          ret = temp;
        }
        break;
      case MinerFilterType.PLEDGED:
        {
          List<CbMinerObj> temp = [];
          data.forEach((obj) {
            // if (obj != null && obj.MiningPledgors.containsKey(widget.coinbase.ID))
            if (obj != null && obj.MiningPledge_d >= 1000) {
              temp.add(obj);
            }
          });
          ret = temp;
        }
        break;
      case MinerFilterType.PLEDGED_NOT:
        {
          List<CbMinerObj> temp = [];
          data.forEach((obj) {
            // if (obj != null && !obj.MiningPledgors.containsKey(widget.coinbase.ID))
            if (obj != null && obj.MiningPledge_d < 1000) {
              temp.add(obj);
            }
          });
          ret = temp;
        }
        break;
      case MinerFilterType.ACTIVATING:
        {
          List<CbMinerObj> temp = [];
          data.forEach((obj) {
            if (obj != null && obj.QualityAdjPower_i > 0) {
              temp.add(obj);
            }
          });
          ret = temp;
        }
        break;
      case MinerFilterType.POWER_0:
        {
          List<CbMinerObj> temp = [];
          data.forEach((obj) {
            if (obj != null && obj.QualityAdjPower_i <= 0) {
              temp.add(obj);
            }
          });
          ret = temp;
        }
        break;
      case MinerFilterType.POWER_LOW:
        {
          List<CbMinerObj> temp = [];
          data.forEach((obj) {
            if (obj != null &&
                maxPower != null &&
                maxPower > 0 &&
                obj.QualityAdjPower_i > 0 &&
                obj.QualityAdjPower_i < maxPower) {
              temp.add(obj);
            }
          });
          ret = temp;
        }
        break;
      case MinerFilterType.OWNER:
        {
          List<CbMinerObj> temp = [];

          if (_owner_current != null && map_ownerfilter != null) {
            temp = map_ownerfilter[_owner_current] ?? [];
          }

          ret = temp;
        }
        break;
    }

    //排序
    switch (_MinerSortType) {
      case MinerSortType.ID_UP:
        ret?.sort((left, right) {
          // f0242498  f0242498 去掉f 剩下转数字比较大小 升序排列
          int l = StringUtils.parseInt(left.ID.toString().substring(1), 0);
          int r = StringUtils.parseInt(right.ID.toString().substring(1), 0);
          return l?.compareTo(r);
        });
        break;
      case MinerSortType.ID_DOWN:
        ret?.sort((left, right) {
          // f0242498  f0242498 去掉f 剩下转数字比较大小 升序排列
          int l = StringUtils.parseInt(left.ID.toString().substring(1), 0);
          int r = StringUtils.parseInt(right.ID.toString().substring(1), 0);
          return r?.compareTo(l);
        });
        break;
      case MinerSortType.POWER_UP:
        ret?.sort((left, right) => left?.QualityAdjPower_i?.compareTo(right?.QualityAdjPower_i));
        break;
      case MinerSortType.POWER_DOWN:
        ret?.sort((left, right) => right?.QualityAdjPower_i?.compareTo(left?.QualityAdjPower_i));
        break;
      case MinerSortType.REWARD_UP:
        ret?.sort((left, right) => left?.TotalMined_d?.compareTo(right?.TotalMined_d));
        break;
      case MinerSortType.REWARD_DOWN:
        ret?.sort((left, right) => right?.TotalMined_d?.compareTo(left?.TotalMined_d));
        break;
    }

    data_filter = ret;
  }

  Future filterOwner() async {
    if (data == null) return;
    Map<String, List<CbMinerObj>> map = {};
    for (CbMinerObj obj in data) {
      List<CbMinerObj> list = [];
      if (map.containsKey(obj.Owner)) {
        list = map[obj.Owner] ?? [];
      } else {
        map[obj.Owner] = list;
      }
      list.add(obj);
    }
    map_ownerfilter = map;
    // _owner_current = map?.keys?.first ?? null;
  }

  @override
  Widget buildWidget(BuildContext context) {
    Widget view = ListPage(
      data_filter ?? [],
      key: key_listpage,
      itemWidgetCreator: (context, position) {
        return buildItem(position);
      },
      pullRefreshCallback: inbatch ? null : _pullRefreshCallback,
    );

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Container(
            height: getAppBarHeight() + getTopBarHeight() + 128,
            padding: EdgeInsets.fromLTRB(0, getTopBarHeight(), 0, 128),
            decoration: BoxDecoration(
              gradient: ResColor.lg_1,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: getAppBar(),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: getAppBarHeight() + getTopBarHeight() + 45,
            child: ((data?.length ?? 0) <= 0 && isLoading) ? Container() : getTopBtnbar(),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: getAppBarHeight() + getTopBarHeight() + 45 + 30 + 5,
            bottom: 0,
            child: Column(
              children: [
                Expanded(child: view),
                if (inbatch) getBatchBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  GlobalKey key_btn1 = RectGetter.createGlobalKey();
  GlobalKey key_btnsort = RectGetter.createGlobalKey();
  bool inbatch = false;
  bool showfilter = false;
  bool showsort = false;

  Widget getTopBtnbar() {
    List<Widget> items = [];

    if (!inbatch) {
      String btn1_name = _MinerFilterType.getName();
      if (_MinerFilterType == MinerFilterType.OWNER && map_ownerfilter != null) {
        btn1_name = "$btn1_name-$_owner_current";
      }

      Widget btn1 = InkWell(
        onTap: () {
          Rect rect = RectGetter.getRectFromKey(key_btn1);
          // 点击筛选
          showfilter = !showfilter;
          isTopFloatWidgetShow = showfilter;
          setState(() {});
        },
        child: RectGetter(
          key: key_btn1,
          child: Container(
            height: showfilter ? 40 : 30,
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(10, 0, 8, showfilter ? 10 : 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(
                    // maxWidth: getScreenWidth()-270,
                    maxWidth: 115,
                  ),
                  child: Text(
                    btn1_name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 12,
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: ResColor.b_4,
              borderRadius: showfilter
                  ? BorderRadius.vertical(top: Radius.circular(15.0), bottom: Radius.zero)
                  : BorderRadius.all(Radius.circular(15.0)),
            ),
          ),
        ),
      );
      items.add(btn1);
    }

    if (!inbatch) {
      Widget btnsort = InkWell(
        onTap: () {
          Rect rect = RectGetter.getRectFromKey(key_btnsort);
          // 点击排序
          showsort = !showsort;
          isTopFloatWidgetShow = showsort;
          setState(() {});
        },
        child: RectGetter(
          key: key_btnsort,
          child: Container(
            height: showsort ? 40 : 30,
            alignment: Alignment.center,
            margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
            padding: EdgeInsets.fromLTRB(10, 0, 8, showsort ? 10 : 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _MinerSortType.getName(),
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Icon(
                  _MinerSortType.getIcon(),
                  color: Colors.white,
                  size: 10,
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: ResColor.b_4,
              borderRadius: showsort
                  ? BorderRadius.vertical(top: Radius.circular(15.0), bottom: Radius.zero)
                  : BorderRadius.all(Radius.circular(15.0)),
            ),
          ),
        ),
      );
      items.add(btnsort);
    }

    if (data_filter != null && data_filter.length > 0) {
      Widget btn2 = InkWell(
        onTap: () {
          if (ClickUtil.isFastDoubleClick()) return;
          inbatch = !inbatch;
          setState(() {});
          if (inbatch) {
            viewSystemUiOverlayStyle = DeviceUtils.system_bar_main.copyWith(systemNavigationBarColor: ResColor.b_4);
            DeviceUtils.setSystemBarStyle(viewSystemUiOverlayStyle);
          } else {
            viewSystemUiOverlayStyle = DeviceUtils.system_bar_light;
            DeviceUtils.setSystemBarStyle(viewSystemUiOverlayStyle);
          }
        },
        child: Container(
          height: 30,
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(inbatch ? 0 : 5, 0, 0, 0),
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                inbatch ? RSID.mlv_2.text : RSID.mlv_1.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            color: ResColor.b_4,
            borderRadius: BorderRadius.all(Radius.circular(22.0)),
          ),
        ),
      );
      items.add(btn2);
    }

    if (inbatch) {
      Widget btnCopyId = InkWell(
        onTap: () {
          //复制选中的nodeid
          if(data_seleted?.isNotEmpty==true)
          {
            List<String> minerids = [];
            data_seleted?.forEach((obj) {
              minerids.add(obj?.ID);
            });
            String ids =minerids.join(",");
            DeviceUtils.copyText(ids);
            showToast(RSID.copied.text);
          }
        },
        child: Container(
          height: 30,
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                RSID.mlv_32.text, //"复制NodeID",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            color: hasSelected ? ResColor.b_4 : ResColor.black_50,
            borderRadius: BorderRadius.all(Radius.circular(22.0)),
          ),
        ),
      );
      items.add(btnCopyId);
    }

    // items.add(
    //   Expanded(
    //     child: Container(),
    //   ),
    // );

    String count = "";
    if ((data_filter?.length != null && data_filter?.length > 0)) {
      if (inbatch) {
        count = "${data_seleted.length} / ${data_filter.length}";
      } else {
        count = "Count ${data_filter.length}";
      }
    }
    // if (StringUtils.isNotEmpty(count))
    //   items.add(
    //     Container(
    //       height: 30,
    //       alignment: Alignment.center,
    //       // padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
    //       child: Row(
    //         mainAxisSize: MainAxisSize.min,
    //         children: <Widget>[
    //           // Icon(
    //           //   Icons.bar_chart,
    //           //   size: 14,
    //           //   color: Colors.white,
    //           // ),
    //           Text(
    //             count,
    //             style: TextStyle(
    //               color: Colors.white,
    //               fontSize: 14,
    //             ),
    //           ),
    //         ],
    //       ),
    //       // decoration: BoxDecoration(
    //       //   color: ResColor.b_5,
    //       //   borderRadius: BorderRadius.all(Radius.circular(22.0)),
    //       // ),
    //     ),
    //   );

    return Container(
      padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        // children: items,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: items,
              ),
            ),
          ),
          if (StringUtils.isNotEmpty(count))
            Container(
              height: 30,
              alignment: Alignment.center,
              // padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Icon(
                  //   Icons.bar_chart,
                  //   size: 14,
                  //   color: Colors.white,
                  // ),
                  Text(
                    count,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              // decoration: BoxDecoration(
              //   color: ResColor.b_5,
              //   borderRadius: BorderRadius.all(Radius.circular(22.0)),
              // ),
            ),
        ],
      ),
    );
  }

  @override
  Widget getTopFloatWidget() {
    if (showfilter) {
      return getFilterList();
    } else if (showsort) {
      return getSortList();
    }

    return Container();
  }

  Widget getFilterList() {
    List<Widget> items = [];

    ///构造菜单按钮
    Widget makeMenuItem(MinerFilterType type, String name_extend, bool isCurrent, bool isEnd) {
      Widget item = Container(
        padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
        color: ResColor.b_4, //ResColor.b_3,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 56,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name_extend == null ? type.getName() : "${type.getName()}-$name_extend",
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      padding: EdgeInsets.all(5),
                      height: 25,
                      width: 25,
                      child: Image.asset(
                        "assets/img/ic_checkmark.png",
                      ),
                    ),
                ],
              ),
            ),
            if (!isEnd)
              Container(
                width: double.infinity,
                height: 1,
                color: ResColor.white_20,
              ),
          ],
        ),
      );

      return InkWell(
        onTap: () {
          if (ClickUtil.isFastDoubleClick()) return;
          if (isCurrent) return;

          _MinerFilterType = type;
          _owner_current = name_extend;
          showfilter = false;
          isTopFloatWidgetShow = false;
          setState(() {});
          Future.delayed(Duration(milliseconds: 0)).then((value) {
            filterData().then((value) {
              data_seleted?.clear();
              if (data_filter?.isEmpty == true) {
                emptyBackgroundColor = Colors.transparent;
                statelayout_margin = EdgeInsets.only(top: getAppBarHeight() + 100);
                setEmptyWidgetVisible(true);
              } else {
                key_listpage?.currentState?.scrollController?.jumpTo(1);
                closeStateLayout();
              }
            });
          });
        },
        child: item,
      );
    }

    MinerFilterType.values.forEach((type) {
      if (type == MinerFilterType.OWNER) {
        if (map_ownerfilter != null && map_ownerfilter.length > 0) {
          map_ownerfilter.forEach((key_owner, value_minerlist) {
            bool isEnd = key_owner == map_ownerfilter.keys.last;
            String nameEx = "$key_owner";
            bool isCurrent = _owner_current == key_owner;
            items.add(makeMenuItem(type, nameEx, isCurrent, isEnd));
          });
        }
      } else {
        bool isEnd = type == MinerFilterType.values.last;
        bool isCurrent = _MinerFilterType == type;
        items.add(makeMenuItem(type, null, isCurrent, isEnd));
      }
    });

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: InkWell(
              onTap: () {
                if (ClickUtil.isFastDoubleClick()) return;
                showfilter = false;
                isTopFloatWidgetShow = false;
                setState(() {});
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: getAppBarHeight() + getTopBarHeight() + 45 + 30 + 2,
            bottom: 0,
            child: InkWell(
              onTap: () {
                if (ClickUtil.isFastDoubleClick()) return;
                showfilter = false;
                isTopFloatWidgetShow = false;
                setState(() {});
              },
              child: Container(
                color: ResColor.black_60,
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(), //不能滑出边界
                  child: Column(
                    children: items,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getSortList() {
    List<Widget> items = [];

    ///构造菜单按钮
    Widget makeMenuItem(MinerSortType type, String name_extend, bool isCurrent, bool isEnd) {
      Widget item = Container(
        padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
        color: ResColor.b_4, //ResColor.b_3,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 56,
              child: Row(
                children: [
                  Text(
                    type.getName2(),
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    type.getIcon(),
                    size: 17,
                    color: Colors.white,
                  ),
                  Expanded(child: Container()),
                  if (isCurrent)
                    Container(
                      padding: EdgeInsets.all(5),
                      height: 25,
                      width: 25,
                      child: Image.asset(
                        "assets/img/ic_checkmark.png",
                      ),
                    ),
                ],
              ),
            ),
            if (!isEnd)
              Container(
                width: double.infinity,
                height: 1,
                color: ResColor.white_20,
              ),
          ],
        ),
      );

      return InkWell(
        onTap: () {
          if (ClickUtil.isFastDoubleClick()) return;
          if (isCurrent) return;

          _MinerSortType = type;
          showsort = false;
          isTopFloatWidgetShow = false;
          setState(() {});
          Future.delayed(Duration(milliseconds: 0)).then((value) {
            filterData().then((value) {
              data_seleted?.clear();
              if (data_filter?.isEmpty == true) {
                emptyBackgroundColor = Colors.transparent;
                statelayout_margin = EdgeInsets.only(top: getAppBarHeight() + 100);
                setEmptyWidgetVisible(true);
              } else {
                key_listpage?.currentState?.scrollController?.jumpTo(1);
                closeStateLayout();
              }
            });
          });
        },
        child: item,
      );
    }

    MinerSortType.values.forEach((type) {
      bool isEnd = type == MinerSortType.values.last;
      bool isCurrent = _MinerSortType == type;
      items.add(makeMenuItem(type, null, isCurrent, isEnd));
    });

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: InkWell(
              onTap: () {
                if (ClickUtil.isFastDoubleClick()) return;
                showsort = false;
                isTopFloatWidgetShow = false;
                setState(() {});
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: getAppBarHeight() + getTopBarHeight() + 45 + 30 + 2,
            bottom: 0,
            child: InkWell(
              onTap: () {
                if (ClickUtil.isFastDoubleClick()) return;
                showsort = false;
                isTopFloatWidgetShow = false;
                setState(() {});
              },
              child: Container(
                color: ResColor.black_60,
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(), //不能滑出边界
                  child: Column(
                    children: items,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getBatchBar() {
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
                  gradient_bg: ResColor.lg_2,
                  color_bg: Colors.transparent,
                  disabledColor: Colors.transparent,
                  bg_borderradius: BorderRadius.circular(4),
                  // text: debugBtn ? RSID.mlv_31.text : RSID.mlv_9.text, //全部质押
                  text: RSID.mlv_31.text,
                  //质押
                  textstyle: TextStyle(
                    color: Colors.white,
                    fontSize: LocaleConfig.currentIsZh() ? 17 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                  onclick: (lbtn) {
                    if (hasSelected) {
                      onClickBatchAdd();
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
                  text: RSID.mlv_21.text,
                  //"转移",Transfer
                  //全部质押
                  textstyle: TextStyle(
                    color: Colors.white,
                    fontSize: LocaleConfig.currentIsZh() ? 17 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                  onclick: (lbtn) {
                    if (hasSelected) {
                      onClickBatchTransfer();
                    }
                  },
                ),
              ),
              if (debugBtn) Container(width: 10),
              if (debugBtn)
                Expanded(
                  child: LoadingButton(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    padding: EdgeInsets.only(bottom: 1),
                    height: 40,
                    gradient_bg: ResColor.lg_5,
                    color_bg: Colors.transparent,
                    disabledColor: Colors.transparent,
                    bg_borderradius: BorderRadius.circular(4),
                    text: RSID.mlv_25.text,
                    //赎回 apply withdraw
                    textstyle: TextStyle(
                      color: Colors.white,
                      fontSize: LocaleConfig.currentIsZh() ? 17 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                    onclick: (lbtn) {
                      onClickBatchApplyWithdraw();
                    },
                  ),
                ),
              if (debugBtn) Container(width: 10),
              if (debugBtn)
                Expanded(
                  child: LoadingButton(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    padding: EdgeInsets.only(bottom: 1),
                    height: 40,
                    gradient_bg: ResColor.lg_5,
                    color_bg: Colors.transparent,
                    disabledColor: Colors.transparent,
                    bg_borderradius: BorderRadius.circular(4),
                    text: RSID.minerview2_4.text,
                    //"提现",
                    textstyle: TextStyle(
                      color: Colors.white,
                      fontSize: LocaleConfig.currentIsZh() ? 17 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                    onclick: (lbtn) {
                      onClickBatchWithdraw();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getColumnKeyValue(
    String key,
    String value, {
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    double centerpading = 4,
    bool textem = false,
    bool clickCopy = false,
  }) {
    Widget w = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(key, style: TextStyle(fontSize: 14, color: ResColor.white_60)),
        Container(
          height: centerpading,
        ),
        textem
            ? TextEm(value, style: TextStyle(fontSize: 14, color: ResColor.white))
            : Text(value, style: TextStyle(fontSize: 14, color: ResColor.white)),
      ],
    );
    return InkWell(
      onTap: clickCopy
          ? () {
              if (ClickUtil.isFastDoubleClick()) return;
              if (StringUtils.isNotEmpty(value)) {
                DeviceUtils.copyText(value);
                showToast(RSID.copied.text);
              }
            }
          : null,
      child: w,
    );
  }

  Widget buildItem(int position) {
    CbMinerObj obj = data_filter[position];

    if (obj.myLockedObj == null) {
      obj.myLockedObj = obj.getMyMiningLocked(coinbase: widget?.coinbase?.ID ?? "");
      if (obj.myLockedObj == null) obj.myLockedObj = CbMinerBaseLockedObj();
    }

    ///基础质押解锁剩余高度
    int leftover_unlockepoch = obj?.myLockedObj?.leftover_unlockepoch(widget?.coinbase?.epoch ?? 0) ?? 0;

    ///解锁锁定的epk
    double lockedepk = obj?.myLockedObj?.Amount_d ?? 0;

    List<Widget> items = [];

    // NodeID      owner        coinbase
    // xxxx         xxxx        xxxx
    items.add(
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: getColumnKeyValue("NodeID", obj?.ID ?? "--",
                crossAxisAlignment: CrossAxisAlignment.start, clickCopy: !inbatch),
          ),
          Expanded(
            child: getColumnKeyValue("Owner", obj?.Owner ?? "--", crossAxisAlignment: CrossAxisAlignment.center),
          ),
          Expanded(
            child: getColumnKeyValue("Coinbase", obj?.Coinbase ?? "--", crossAxisAlignment: CrossAxisAlignment.end),
          ),
        ],
      ),
    );

    // 流量质押： xxx EPK
    // 增加  赎回  转移
    //
    // 锁定中          剩余高度
    // xxxx EPK      xxx
    // 已解锁：xxxEPK                提现

    items.add(
      Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
        padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: const Color(0xff424242),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  RSID.mlv_5.text + ": ",
                  style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${StringUtils.formatNumAmount(obj?.MiningPledge ?? 0)} EPK",
                  style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Container(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  RSID.mlv_6.text + ": ",
                  style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Text(
                    "${StringUtils.formatNumAmount(obj?.getMyPledge(coinbase: widget?.coinbase?.ID ?? "") ?? 0)} EPK",
                    style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Container(height: 10),
            Row(
              children: [
                Expanded(
                  child: LoadingButton(
                    height: 30,
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    padding: EdgeInsets.only(bottom: 1),
                    gradient_bg: ResColor.lg_2,
                    color_bg: Colors.transparent,
                    disabledColor: Colors.transparent,
                    bg_borderradius: BorderRadius.circular(4),
                    text: RSID.olv_3.text,
                    //添加
                    textstyle: TextStyle(
                      color: Colors.white,
                      fontSize: LocaleConfig.currentIsZh() ? 17 : 14,
                    ),
                    onclick: !inbatch
                        ? (lbtn) {
                            //需要质押的金额 = 1000-已有的质押
                            double amount = 1000 - obj.MiningPledge_d;
                            amount = max(amount, 0);
                            String amount_str = StringUtils.formatNumAmount(amount, point: 8).replaceAll(",", "");
                            BottomDialog.showTextInputDialog(
                              context,
                              "${obj.ID} ${RSID.olv_3.text} ",
                              amount_str,
                              "",
                              999,
                              (amount) {
                                onClickBaseAdd(obj, amount);
                              },
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExpUtil.re_float)],
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                            );
                          }
                        : null,
                  ),
                ),
                Container(width: 10),
                Expanded(
                  child: LoadingButton(
                    height: 30,
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    padding: EdgeInsets.only(bottom: 1),
                    gradient_bg: ResColor.lg_5,
                    color_bg: Colors.transparent,
                    disabledColor: Colors.transparent,
                    bg_borderradius: BorderRadius.circular(4),
                    text: RSID.olv_4.text,
                    //赎回
                    textstyle: TextStyle(
                      color: Colors.white,
                      fontSize: LocaleConfig.currentIsZh() ? 17 : 14,
                    ),
                    onclick: !inbatch
                        ? (lbtn) {
                            if (obj?.getMyPledgeD(coinbase: widget?.coinbase?.ID ?? "") > 0) {
                              //申请赎回
                              onClickBaseApplyWithdraw(obj);
                            }
                          }
                        : null,
                  ),
                ),
                Container(width: 10),
                Expanded(
                  child: LoadingButton(
                    height: 30,
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    padding: EdgeInsets.only(bottom: 1),
                    gradient_bg: ResColor.lg_3,
                    color_bg: Colors.transparent,
                    disabledColor: Colors.transparent,
                    bg_borderradius: BorderRadius.circular(4),
                    text: RSID.mlv_21.text,
                    //"转移",Transfer
                    //赎回
                    textstyle: TextStyle(
                      color: Colors.white,
                      fontSize: LocaleConfig.currentIsZh() ? 17 : 14,
                    ),
                    onclick: !inbatch
                        ? (lbtn) {
                            //有质押 或者 有锁定 可以转移
                            if (obj?.getMyPledgeD(coinbase: widget?.coinbase?.ID ?? "") > 0 || lockedepk > 0) {
                              //输入目标NodeID
                              // BottomDialog.showTextInputDialog(
                              //   context,
                              //   "${obj.ID} ${RSID.mlv_22.text}",
                              //   "",
                              //   RSID.mlv_23.text,
                              //   99,
                              //   (value) {
                              //     // 输入密码后发送转移请求
                              //     if (StringUtils.isNotEmpty(value)) {
                              //       onClickBaseTransfer(obj, value);
                              //     }
                              //   },
                              // );

                              String amount = "";
                              if (obj?.getMyPledgeD(coinbase: widget?.coinbase?.ID ?? "") > 0) {
                                amount = obj?.getMyPledge(coinbase: widget?.coinbase?.ID ?? "");
                              } else if (lockedepk > 0) {
                                amount = obj?.myLockedObj?.Amount ?? "";
                              }

                              BottomDialog.showTextInputDialogMultiple(
                                context: context,
                                title: "${obj.ID} ${RSID.mlv_22.text}",
                                objlist: [
                                  TextInputConfigObj()
                                    ..oldText = ""
                                    ..hint = RSID.mlv_23.text //请输入目标NodeID
                                    ..maxLength = 99,
                                  TextInputConfigObj()
                                    ..oldText = amount
                                    ..hint = RSID.mlv_27.text //请输入数量
                                    ..maxLength = 99
                                    ..inputFormatters = [FilteringTextInputFormatter.allow(RegExpUtil.re_float)]
                                    ..keyboardType = TextInputType.numberWithOptions(decimal: true),
                                ],
                                callback: (datas) {
                                  onClickBaseTransfer(obj, datas[0], datas[1]);
                                },
                              );
                            }
                          }
                        : null,
                  ),
                ),
              ],
            ),
            Container(height: 15),
            Row(
              children: [
                Expanded(
                  child: getColumnKeyValue(
                      RSID.minerview2_2.text, //锁定中
                      "${StringUtils.formatNumAmount(leftover_unlockepoch > 0 ? lockedepk : 0, point: 2, supply0: false)} EPK"),
                ),
                Expanded(
                  child: getColumnKeyValue(
                      RSID.minerview_29.text, //"剩余高度",
                      "${StringUtils.formatNumAmount(leftover_unlockepoch, point: 2, supply0: false)}"),
                ),
              ],
            ),
            Container(height: 8),
            Row(
              children: [
                Text(
                  RSID.minerview2_3.text + ": ", //"已解锁"
                  style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Text(
                    "${StringUtils.formatNumAmount(leftover_unlockepoch <= 0 ? lockedepk : 0, point: 2, supply0: false)} EPK",
                    style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                LoadingButton(
                  height: 20,
                  width: LocaleConfig.currentIsZh() ? 40 : 60,
                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
                  color_bg: Colors.transparent,
                  disabledColor: Colors.transparent,
                  side: BorderSide(
                      width: 1, color: (leftover_unlockepoch <= 0 && lockedepk > 0) ? ResColor.o_1 : ResColor.white_60),
                  bg_borderradius: BorderRadius.circular(4),
                  text: RSID.minerview2_4.text,
                  // "提现", Withdraw
                  textstyle: TextStyle(
                    color: (leftover_unlockepoch <= 0 && lockedepk > 0) ? ResColor.o_1 : ResColor.white_60,
                    fontSize: 12,
                  ),
                  onclick: !inbatch
                      ? (lbtn) {
                          if (leftover_unlockepoch <= 0 && lockedepk > 0)
                            onClickBaseWithdraw(obj, obj?.myLockedObj?.Amount);
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    items.add(Container(height: 20));

    // 有效算力      节点收益
    // xxxx         xxxx
    items.add(
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: getColumnKeyValue(RSID.mlv_7.text, obj?.getQualityAdjPowerRs() ?? "--"),
          ),
          Expanded(
            child: getColumnKeyValue(RSID.mlv_8.text, "${StringUtils.formatNumAmount(obj?.TotalMined)} EPK"),
          ),
        ],
      ),
    );

    Widget card = Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
      padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ResColor.b_2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    );

    bool isBatchSeleted = hasMinerSelect(obj);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onTap: inbatch
                ? () {
                    if (ClickUtil.isFastDoubleClick()) return;
                    // obj.isBatchSeleted = !obj.isBatchSeleted;
                    setMinerSelect(obj, !isBatchSeleted);
                    setState(() {});
                  }
                : null,
            child: card,
          ),
          //覆盖 是否已绑定的标签
          Positioned(
              top: 0,
              right: 25,
              child: Container(
                padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                decoration: BoxDecoration(
                  color: ResColor.blue_1,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  obj.Binded ? RSID.mlv_3.text : RSID.mlv_4.text,
                  style: const TextStyle(
                    color: ResColor.white,
                    fontSize: 12,
                  ),
                ),
              )),
          //覆盖 选择框
          if (inbatch)
            Positioned(
              left: 19,
              top: 165,
              child: InkWell(
                onTap: () {
                  if (ClickUtil.isFastDoubleClick()) return;
                  // obj.isBatchSeleted = !obj.isBatchSeleted;
                  setMinerSelect(obj, !isBatchSeleted);
                  setState(() {});
                },
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: isBatchSeleted
                      ? BoxDecoration(
                          //选中
                          gradient: ResColor.lg_1,
                          borderRadius: BorderRadius.circular(22),
                        )
                      : BoxDecoration(
                          //未选中
                          color: Color(0xff424242),
                          border: Border.all(color: ResColor.white, width: 1.5),
                          borderRadius: BorderRadius.circular(22),
                        ),
                  child: isBatchSeleted
                      ? Image.asset(
                          "assets/img/ic_checkmark.png",
                          width: 10,
                          height: 10,
                        )
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pullRefreshCallback() async {
    if (isLoading) {
      return;
    }
    await refresh(frompull: true);
    return;
  }

  setMinerSelect(CbMinerObj miner, bool isSelected) {
    if (isSelected && !data_seleted.contains(miner)) {
      data_seleted.add(miner);
    } else {
      data_seleted.remove(miner);
    }
  }

  bool hasMinerSelect(CbMinerObj miner) {
    return data_seleted?.contains(miner) ?? false;
  }

  selectAll(bool isSelected) {
    if (isSelected) {
      // data_seleted = data_filter;
      data_seleted = List.from(data_filter);
    } else {
      data_seleted = [];
    }
  }

  bool get hasSelected {
    return data_seleted != null && data_seleted.length > 0;
  }

  ///单个节点增加质押
  onClickBaseAdd(CbMinerObj miner, String amount) async {
    if (miner == null) return;

    double num = StringUtils.parseDouble(amount, 0);
    if (num <= 0) {
      ToastUtils.showToastCenter(RSID.uspav_4.text);
      return;
    }

    closeInput();

    BottomDialog.simpleAuth(
        context, AccountMgr().currentAccount.password, (value) async {
      LoadingDialog.showLoadDialog(context, "", touchOutClose: false, backClose: false);

      ResultObj<String> robj = await AccountMgr().currentAccount.epikWallet.minerPledgeAdd(miner.ID, amount.trim());

      LoadingDialog.cloasLoadDialog(context);

      if (robj?.isSuccess) {
        String cid = robj.data; //bafy2bzaceaa4fwwhrn5oqjsxe5vumlibispulwdzf4uskh4silxlfo4qh6cu6
        setState(() {});

        MessageDialog.showMsgDialog(
          context,
          title: RSID.minerview_10.text,
          //"矿工基础抵押",
          msg: "${RSID.minerview_18.text}\n$cid",
          //交易已提交
          btnLeft: RSID.minerview_19.text,
          //"查看交易",
          btnRight: RSID.isee.text,
          onClickBtnLeft: (dialog) {
            dialog.dismiss();
            String url = ServiceInfo.epik_msg_web + cid;
            ViewGT.showGeneralWebView(context, RSID.berlv_4.text, url);
          },
          onClickBtnRight: (dialog) {
            dialog.dismiss();
          },
        );
      } else {
        ToastUtils.showToastCenter(robj?.errorMsg ?? RSID.request_failed.text);
      }
    });
  }

  ///  单个miner申请赎回
  onClickBaseApplyWithdraw(CbMinerObj miner) async {
    //, String amount
    if (miner == null) return;

    // double num = StringUtils.parseDouble(amount, 0);
    // if (num <= 0) {
    //   ToastUtils.showToastCenter(RSID.uspav_4.text);
    //   return;
    // }

    closeInput();

    BottomDialog.simpleAuth(
        context, AccountMgr().currentAccount.password, (value) async {
      LoadingDialog.showLoadDialog(context, "", touchOutClose: false, backClose: false);

      ResultObj<String> robj =
          await AccountMgr().currentAccount.epikWallet.minerPledgeApplyWithdraw(miner.ID); //, amount.trim()

      LoadingDialog.cloasLoadDialog(context);

      if (robj?.isSuccess) {
        String cid = robj.data; //bafy2bzaceaa4fwwhrn5oqjsxe5vumlibispulwdzf4uskh4silxlfo4qh6cu6
        setState(() {});

        MessageDialog.showMsgDialog(
          context,
          title: RSID.minerview_10.text,
          //"矿工基础抵押",
          msg: "$RSID.mlv_20.text}\n$cid",
          //申请赎回抵押交易已提交
          btnLeft: RSID.minerview_19.text,
          //"查看交易",
          btnRight: RSID.isee.text,
          onClickBtnLeft: (dialog) {
            dialog.dismiss();
            String url = ServiceInfo.epik_msg_web + cid;
            ViewGT.showGeneralWebView(context, RSID.berlv_4.text, url);
          },
          onClickBtnRight: (dialog) {
            dialog.dismiss();
          },
        );
      } else {
        ToastUtils.showToastCenter(robj?.errorMsg ?? RSID.request_failed.text);
      }
    });
  }

  ///  单个miner赎回
  onClickBaseWithdraw(CbMinerObj miner, String amount) async {
    if (miner == null) return;

    double num = StringUtils.parseDouble(amount, 0);
    if (num <= 0) {
      ToastUtils.showToastCenter(RSID.uspav_4.text);
      return;
    }

    closeInput();

    BottomDialog.simpleAuth(
        context, AccountMgr().currentAccount.password, (value) async {
      LoadingDialog.showLoadDialog(context, "", touchOutClose: false, backClose: false);

      ResultObj<String> robj =
          await AccountMgr().currentAccount.epikWallet.minerPledgeWithdraw(miner.ID, amount.trim());

      LoadingDialog.cloasLoadDialog(context);

      if (robj?.isSuccess) {
        String cid = robj.data; //bafy2bzaceaa4fwwhrn5oqjsxe5vumlibispulwdzf4uskh4silxlfo4qh6cu6
        setState(() {});

        MessageDialog.showMsgDialog(
          context,
          title: RSID.minerview_10.text,
          //"矿工基础抵押",
          msg: "${RSID.minerview_26.text}\n$cid",
          //赎回抵押交易已提交
          btnLeft: RSID.minerview_19.text,
          //"查看交易",
          btnRight: RSID.isee.text,
          onClickBtnLeft: (dialog) {
            dialog.dismiss();
            String url = ServiceInfo.epik_msg_web + cid;
            ViewGT.showGeneralWebView(context, RSID.berlv_4.text, url);
          },
          onClickBtnRight: (dialog) {
            dialog.dismiss();
          },
        );
      } else {
        ToastUtils.showToastCenter(robj?.errorMsg ?? RSID.request_failed.text);
      }
    });
  }

  ///  单个miner转移质押  // 20211009 需要输入金额
  onClickBaseTransfer(CbMinerObj miner, String toMinerID, String amount) async {
    if (miner == null) return;

    double num = StringUtils.parseDouble(amount, 0);
    if (num <= 0) {
      ToastUtils.showToastCenter(RSID.uspav_4.text);
      return;
    }

    closeInput();

    BottomDialog.simpleAuth(
        context, AccountMgr().currentAccount.password, (value) async {
      LoadingDialog.showLoadDialog(context, "", touchOutClose: false, backClose: false);
      ResultObj<String> robj =
          await AccountMgr().currentAccount.epikWallet.minerPledgeTransfer(miner.ID, toMinerID, amount);

      // ResultObj<String> robj = ResultObj(data: "cccccc",code: 0,errorMsg: "OK");//test

      LoadingDialog.cloasLoadDialog(context);

      if (robj?.isSuccess) {
        String cid = robj.data; //bafy2bzaceaa4fwwhrn5oqjsxe5vumlibispulwdzf4uskh4silxlfo4qh6cu6
        setState(() {});

        MessageDialog.showMsgDialog(
          context,
          title: RSID.mlv_22.text,
          //"质押转移",
          msg: "${RSID.mlv_24.text}\n$cid",
          //质押转移交易已提交
          btnLeft: RSID.minerview_19.text,
          //"查看交易",
          btnRight: RSID.isee.text,
          onClickBtnLeft: (dialog) {
            dialog.dismiss();
            String url = ServiceInfo.epik_msg_web + cid;
            ViewGT.showGeneralWebView(context, RSID.berlv_4.text, url);
          },
          onClickBtnRight: (dialog) {
            dialog.dismiss();
          },
        );
      } else {
        ToastUtils.showToastCenter(robj?.errorMsg ?? RSID.request_failed.text);
      }
    });
  }

  //批量质押
  onClickBatchAdd() {
    BottomDialog.simpleAuth(
        context, AccountMgr().currentAccount.password, (value) async {
      showLoadDialog("", touchOutClose: false, backClose: false);

      List<String> minerids = [];
      data_seleted?.forEach((obj) {
        minerids.add(obj?.ID);
      });

      ResultObj<String> robj = await AccountMgr().currentAccount.epikWallet.minerPledgeOneClick(minerids);

      closeLoadDialog();

      if (robj?.isSuccess) {
        MessageDialog.showMsgDialog(
          context,
          title: RSID.minermenu_6.text, //一键抵押
          msg: "${RSID.minerview_18.text}", //交易已提交
          // btnLeft: RSID.minerview_19.text,//"查看交易",
          btnRight: RSID.isee.text,
          // onClickBtnLeft: (dialog) {
          //   dialog.dismiss();
          //   String url = ServiceInfo.epik_msg_web + cid;
          //   ViewGT.showGeneralWebView(context, RSID.berlv_4.text, url);
          // },
          onClickBtnRight: (dialog) {
            dialog.dismiss();
          },
        );
      } else {
        showToast(robj?.errorMsg ?? RSID.request_failed.text);
      }
    });
  }

  //批量申请赎回
  onClickBatchApplyWithdraw() {
    BottomDialog.simpleAuth(
        context, AccountMgr().currentAccount.password, (value) async {
      showLoadDialog("", touchOutClose: false, backClose: false);

      List<String> minerids = [];
      data_seleted?.forEach((obj) {
        minerids.add(obj?.ID);
      });

      ResultObj<String> robj = await AccountMgr().currentAccount.epikWallet.minerPledgeApplyWithdrawOneClick(minerids);

      closeLoadDialog();

      if (robj?.isSuccess) {
        MessageDialog.showMsgDialog(
          context,
          title: RSID.mlv_10.text, //批量赎回  Batch Apply Withdraw
          msg: "${RSID.minerview_18.text}", //交易已提交
          // btnLeft: RSID.minerview_19.text,//"查看交易",
          btnRight: RSID.isee.text,
          // onClickBtnLeft: (dialog) {
          //   dialog.dismiss();
          //   String url = ServiceInfo.epik_msg_web + cid;
          //   ViewGT.showGeneralWebView(context, RSID.berlv_4.text, url);
          // },
          onClickBtnRight: (dialog) {
            dialog.dismiss();
          },
        );
      } else {
        showToast(robj?.errorMsg ?? RSID.request_failed.text);
      }
    });
  }

  //批量赎回提现
  onClickBatchWithdraw() {
    BottomDialog.simpleAuth(
        context, AccountMgr().currentAccount.password, (value) async {
      showLoadDialog("", touchOutClose: false, backClose: false);

      List<String> minerids = [];
      data_seleted?.forEach((obj) {
        minerids.add(obj?.ID);
      });

      ResultObj<String> robj = await AccountMgr().currentAccount.epikWallet.minerPledgeWithdrawOneClick(minerids);

      closeLoadDialog();

      if (robj?.isSuccess) {
        MessageDialog.showMsgDialog(
          context,
          title: RSID.mlv_26.text, //"批量提现",
          msg: "${RSID.minerview_18.text}", //交易已提交
          // btnLeft: RSID.minerview_19.text,//"查看交易",
          btnRight: RSID.isee.text,
          // onClickBtnLeft: (dialog) {
          //   dialog.dismiss();
          //   String url = ServiceInfo.epik_msg_web + cid;
          //   ViewGT.showGeneralWebView(context, RSID.berlv_4.text, url);
          // },
          onClickBtnRight: (dialog) {
            dialog.dismiss();
          },
        );
      } else {
        showToast(robj?.errorMsg ?? RSID.request_failed.text);
      }
    });
  }

  //批量转移
  onClickBatchTransfer() {
    List<CbMinerObj> minerids = List.from(data_seleted);
    BottomDialog.showTextInputDialog(context, RSID.mlv_35.text, "", RSID.mlv_33.replace(["${minerids.length}"]), 9999, (value) {

      List<String> targetList=[];
      RegExp re = RegExp(r'f\d+');
      Iterable<RegExpMatch> remlist = re.allMatches(value);
      for(RegExpMatch rem in remlist)
      {
        targetList.add(rem.group(0));
      }
      // print(targetList);
      print("target NodeID size ="+targetList.length.toString());

      if(targetList.length!=minerids.length)
      {
        //数量不一致
        showToast(RSID.mlv_34.text);
        return;
      }

      //
      Future.delayed(Duration(milliseconds: 200)).then((value){
        ViewGT.showView(context, MinerBatchTransferView(widget?.coinbase?.ID ?? "",minerids, targetList));
      });

    },multipleLine: true);
  }
}

enum MinerFilterType {
  ALL, //全部
  COINBASE_MY, //coinbase,
  COINBASE_OTHER, //
  PLEDGED, //已质押,
  PLEDGED_NOT, //未质押
  ACTIVATING, //激活中,
  POWER_0, //0算力,
  POWER_LOW, // 低算力（非满算力）
  OWNER,
}

extension MinerFilterTypeEx on MinerFilterType {
  String getName() {
    switch (this) {
      case MinerFilterType.ALL:
        return RSID.mlv_12.text; //全部
      case MinerFilterType.COINBASE_MY:
        return RSID.mlv_13.text; //"CoinBase";
      case MinerFilterType.COINBASE_OTHER: //
        return RSID.mlv_18.text; //"其它 CoinBase",
      case MinerFilterType.PLEDGED:
        return RSID.mlv_14.text; //已质押的;
      case MinerFilterType.PLEDGED_NOT:
        return RSID.mlv_17.text; //未质押的
      case MinerFilterType.ACTIVATING:
        return RSID.mlv_15.text; //激活中;
      case MinerFilterType.POWER_0:
        return RSID.mlv_16.text; //0算力;
      case MinerFilterType.POWER_LOW:
        return RSID.mlv_19.text; //低算力
      case MinerFilterType.OWNER:
        return "Owner";
      default:
        return "";
    }
  }
}

enum MinerSortType {
  ID_UP, //id升序
  ID_DOWN, //id降序
  POWER_UP, //算力升序
  POWER_DOWN, //算力降序
  REWARD_UP, //收益升序
  REWARD_DOWN, //收益降序
}

extension MinerSortTypeEX on MinerSortType {
  String getName() {
    switch (this) {
      case MinerSortType.ID_UP:
      case MinerSortType.ID_DOWN:
        return RSID.mlv_30.text; //"ID";
      case MinerSortType.POWER_UP:
      case MinerSortType.POWER_DOWN:
        return RSID.mlv_28.text; //"Power";
      case MinerSortType.REWARD_UP:
      case MinerSortType.REWARD_DOWN:
        return RSID.mlv_29.text; //"Reward";
      default:
        return "";
    }
  }

  String getName2() {
    switch (this) {
      case MinerSortType.ID_UP:
        return RSID.mlv_30_1.text;
      case MinerSortType.ID_DOWN:
        return RSID.mlv_30_2.text;
      case MinerSortType.POWER_UP:
        return RSID.mlv_28_1.text;
      case MinerSortType.POWER_DOWN:
        return RSID.mlv_28_2.text;
      case MinerSortType.REWARD_UP:
        return RSID.mlv_29_1.text;
      case MinerSortType.REWARD_DOWN:
        return RSID.mlv_29_2.text;
      default:
        return "";
    }
  }

  IconData getIcon() {
    switch (this) {
      case MinerSortType.ID_UP:
      case MinerSortType.POWER_UP:
      case MinerSortType.REWARD_UP:
        return Icons.arrow_upward;
      case MinerSortType.ID_DOWN:
      case MinerSortType.POWER_DOWN:
      case MinerSortType.REWARD_DOWN:
        return Icons.arrow_downward;
      default:
        return null;
    }
  }
}
