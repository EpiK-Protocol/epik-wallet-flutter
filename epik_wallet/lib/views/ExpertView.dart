import 'dart:convert';
import 'dart:ui';

import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/base_inner_widget.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/LocaleConfig.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_mainnet.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/Expert.dart';
import 'package:epikwallet/model/ExpertBaseInfo.dart';
import 'package:epikwallet/model/VoterInfo.dart';
import 'package:epikwallet/utils/JsonUtils.dart';
import 'package:epikwallet/utils/eventbus/event_manager.dart';
import 'package:epikwallet/utils/eventbus/event_tag.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/mainview.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

enum ExpertStateType {
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

extension ExpertStateTypeEx on ExpertStateType {
  String getName() {
    switch (this) {
      case ExpertStateType.ALL:
        return RSID.expertview_1.text; //"全部";
      case ExpertStateType.REGISTERED:
        return ExpertStatus.registered.getString();
      case ExpertStateType.NOMINATED:
        return ExpertStatus.nominated.getString();
      case ExpertStateType.NORMAL:
        return ExpertStatus.normal.getString();
      case ExpertStateType.BLACK:
        return ExpertStatus.blocked.getString();
    }
  }
}

///智库
class ExpertView extends BaseInnerWidget {
  ExpertView(Key key) : super(key: key) {}

  @override
  BaseInnerWidgetState<BaseInnerWidget> getState() {
    return ExpertViewState();
  }

  @override
  int setIndex() {
    return 3;
  }
}

class ExpertViewState extends BaseInnerWidgetState<ExpertView> with TickerProviderStateMixin {
  ExpertInfomation expertInfomation;

  ExpertStateType pageIndex = ExpertStateType.ALL;

  List<Expert> data_experts = [];

  List<Expert> data_experts_show = [];

  GlobalKey<ListPageState> key_scroll = GlobalKey();

  ListPageDefState _ListPageDefState = ListPageDefState(null, img: "");

  int page = 0;
  int pageSize = 20;
  bool isLoading = false;
  bool hasMore = false;

  List<ExpertStateType> tabTypes = [];

  @override
  void initStateConfig() {
    navigationColor = ResColor.b_2;
    super.initStateConfig();
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);

    tabTypes = [
      ExpertStateType.ALL,

      ///新申请的
      // ExpertStateType.REGISTERED,
      ///审核通过
      ExpertStateType.NOMINATED,

      ///正常可用状态
      ExpertStateType.NORMAL,

      ///黑名单
      ExpertStateType.BLACK,
    ];

    eventMgr.add(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventCallback_account);

    refresh();
  }

  eventCallback_account(obj) {
    voterinfo = VoterInfo();
    refresh();
  }

  @override
  void dispose() {
    eventMgr.remove(EventTag.LOCAL_CURRENT_ACCOUNT_CHANGE, eventCallback_account);
    super.dispose();
  }

  VoterInfo voterinfo;

  bool isFirst = true;
  bool needwalletfull=false;

  refresh() async {
    if (isFirst) {
      isFirst = false;
    }

    if (AccountMgr().currentAccount.hasEpikWallet != true) {
      needwalletfull = true;
      closeStateLayout();
      isLoading = false;
      return;
    }

    needwalletfull=false;

    setLoadingWidgetVisible(true);
    isLoading = true;

    page = 0;

    ResultObj<String> robj =
        await AccountMgr()?.currentAccount?.epikWallet?.voterInfo(AccountMgr()?.currentAccount?.epik_EPK_address);
    dlog("voterInfo");
    dlog(robj.data);
    if (voterinfo == null) voterinfo = VoterInfo();
    if (robj.isSuccess) {
      voterinfo.parseJson(jsonDecode(robj.data));
    }

    HttpJsonRes hjr_info = await ApiMainNet.expertBaseInfomation();
    if (hjr_info.code == 0) {
      expertInfomation = ExpertInfomation.fromJson(hjr_info.jsonMap["expertInfomation"]);

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
      data = JsonArray.parseList(JsonArray.obj2List(hjr.jsonMap["list"]), (json) => Expert.fromJson(json));
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

    if(needwalletfull)
    {
      Widget widget = Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              RSID.iwv_29.text, //"需要Epik钱包",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20,
              ),
            ),
          ],
        ),
      );
      return widget;
    }

    Widget widget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader(),
        Expanded(
          child: buildList(),
        ),
      ],
    );

    return widget;
  }

  Widget buildHeader() {
    print("voterinfo?.getUnlockingVotesF()=${voterinfo?.getUnlockingVotesF()}");
    print("voterinfo?.getUnlockedVotesF()=${voterinfo?.getUnlockedVotesF()}");
    Container card = Container(
      margin: EdgeInsets.only(top: 0),
      padding: EdgeInsets.fromLTRB(20, getTopBarHeight(), 20, 0),
      width: double.infinity,
      height: getTopBarHeight() + getAppBarHeight() + 128 + 5,
      decoration: BoxDecoration(
        gradient: ResColor.lg_1,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: getAppBarHeight(),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      RSID.expertview_2.text, //"领域专家",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if ((voterinfo?.withdrawablerewards_d ?? 0) > 0 || (voterinfo?.unlockedvotes_d ?? 0) > 0) {
                        onClickVoteWithdraw();
                      } else {
                        showToast(RSID.expertview_16.text);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            RSID.expertinfoview_10.text,
                            //"兑换",
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  (voterinfo?.withdrawablerewards_d ?? 0) > 0 || (voterinfo?.unlockedvotes_d ?? 0) > 0
                                      ? Colors.white
                                      : Colors.white60,
                              fontWeight:
                                  (voterinfo?.withdrawablerewards_d ?? 0) > 0 || (voterinfo?.unlockedvotes_d ?? 0) > 0
                                      ? FontWeight.bold
                                      : null,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                            child: Image.asset(
                              "assets/img/ic_arrow_right_1.png",
                              width: 7,
                              height: 11,
                              color:
                                  (voterinfo?.withdrawablerewards_d ?? 0) > 0 || (voterinfo?.unlockedvotes_d ?? 0) > 0
                                      ? Colors.white
                                      : Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Container(height: 20),
            Text(
              RSID.expertview_3.text, //"当前年化收益",
              style: const TextStyle(
                color: ResColor.white_80,
                fontSize: 14,
              ),
            ),
            Container(height: 2),
            Text(
              StringUtils.formatNumAmount((expertInfomation?.AnnualizedRate_d ?? 0), point: 2, supply0: true) + "%",
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: "DIN_Condensed_Bold",
                height: 1,
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${RSID.expertview_4.text}: ${expertInfomation?.TotalVote_f ?? 0} EPK", //已投
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: LocaleConfig.currentIsZh() ? 14 : 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${RSID.expertview_5.text}: ${expertInfomation?.TotalVoteReward_f ?? 0} EPK", //累计收益
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: LocaleConfig.currentIsZh() ? 14 : 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
              // constraints: BoxConstraints(
              //   minHeight:14.0+20,
              // ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${RSID.expertview_17.text}: ${voterinfo?.getAllvoterF() ?? 0} EPK",
                      //已投
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: LocaleConfig.currentIsZh() ? 14 : 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${RSID.expertview_14.text}: ${voterinfo?.getWithdrawableRewardsF() ?? 0} EPK",
                      //可提收益
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: LocaleConfig.currentIsZh() ? 14 : 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
              // constraints: BoxConstraints(
              //   minHeight:14.0+20,
              // ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${RSID.expertview_18.text}: ${voterinfo?.getUnlockingVotesF() ?? 0} EPK",
                      //已投
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: LocaleConfig.currentIsZh() ? 14 : 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${RSID.expertview_19.text}: ${voterinfo?.getUnlockedVotesF() ?? 0} EPK",
                      //可提收益
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: LocaleConfig.currentIsZh() ? 14 : 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    return LoadingButton(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      gradient_bg: ResColor.lg_1,
      color_bg: Colors.transparent,
      disabledColor: Colors.transparent,
      height: 40,
      text: RSID.expertview_6.text,
      //"申请成为领域专家",
      textstyle: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      bg_borderradius: BorderRadius.circular(4),
      onclick: (lbtn) {
        if (AccountMgr().currentAccount == null) {
          showToast(RSID.main_bv_7.text);
          eventMgr.send(EventTag.CHANGE_MAINVIEW_INDEX, main_subviewTypes.indexOf(MainSubViewType.WALLETVIEW));
          return;
        }
        ViewGT.showApplyExpertView(context);
      },
    );
  }

  TabController tabcontroller;

  Widget getTabs() {
    // int index = ExpertStateType.values.indexOf(pageIndex);
    int index = tabTypes.indexOf(pageIndex);

    if (tabcontroller == null)
      tabcontroller = TabController(
          initialIndex: index,
          // length: ExpertStateType.values.length,
          length: tabTypes.length,
          vsync: this);

    return Container(
      width: double.infinity,
      height: 52,
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              //ExpertStateType.values.map
              tabs: tabTypes.map((item) {
                return Container(
                  alignment: Alignment.bottomCenter,
                  child: Text(item.getName()),
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
                // ExpertStateType value = ExpertStateType.values[position];
                ExpertStateType value = tabTypes[position];
                onClickTab(value);
              },
            ),
          ),
        ],
      ),
    );

    // List<Widget> items = [];
    // ExpertStateType.values.forEach((type) {
    //   Widget v = Expanded(
    //     child: GestureDetector(
    //       onTap: () {
    //         onClickTab(type);
    //       },
    //       child: Text(
    //         type.getName(),
    //         textAlign: TextAlign.center,
    //         style: TextStyle(
    //           color: pageIndex == type ? Colors.black : Colors.black45,
    //           fontSize: 14,
    //         ),
    //       ),
    //     ),
    //   );
    //   items.add(v);
    // });
    //
    // return Container(
    //   width: double.infinity,
    //   height: BaseFuntion.appbarheight_def,
    //   padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
    //   child: Container(
    //     height: 40,
    //     width: double.infinity,
    //     child: Card(
    //       color: Colors.white,
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.all(Radius.circular(20.0)),
    //       ),
    //       elevation: 5,
    //       shadowColor: Colors.black38,
    //       child: Row(
    //         children: items,
    //       ),
    //     ),
    //   ),
    // );
    return Container();
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
    if (AccountMgr().currentAccount == null) {
      showToast(RSID.main_bv_7.text);
      eventMgr.send(EventTag.CHANGE_MAINVIEW_INDEX, main_subviewTypes.indexOf(MainSubViewType.WALLETVIEW));
      return;
    }

    Expert item = data_experts_show[position];
    ViewGT.showExpertInfoView(context, item, voterinfo).then((value) {
      // dlog("showExpertInfoView result =${value}");
      setState(() {});
    });
  }

  Widget itemWidgetBuild(BuildContext context, int position) {
    Expert item = data_experts_show[position]; //data_experts[position];

    return Container(
      margin: EdgeInsets.fromLTRB(0, 6, 0, 0),
      width: double.infinity,
      color: ResColor.b_3,
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Color(0xff333333),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    "assets/img/ic_main_menu_expert_s.png",
                    width: 14,
                    height: 14,
                  ),
                ),
                Container(width: 6),
                Expanded(
                  child: Text(
                    "${item.id}",
                    style: TextStyle(
                      fontSize: 12,
                      color: ResColor.white_80,
                    ),
                  ),
                ),
                Container(width: 6),
                Text(
                  "${StringUtils.formatNumAmount(item.vote)}${item.getRequiredVoteStr()} EPK",
                  style: TextStyle(
                    fontSize: 17,
                    color: ResColor.o_1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(height: 10),
            Row(
              children: [
                if (StringUtils.isNotEmpty(item?.domain))
                  Text(
                    "${RSID.expertview_7.text}: ${item.domain ?? ""}", //领域
                    style: TextStyle(
                      fontSize: 12,
                      color: ResColor.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Expanded(
                  child: Text(
                    "${RSID.expertview_8.text}: ${StringUtils.formatNumAmount(item.income)} EPK", //收益
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 12,
                      color: ResColor.white,
                    ),
                  ),
                ),
              ],
            ),

            // Text(
            //   "状态: ${item?.status_e?.getString()}",
            // ),
          ],
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

    ResultObj<String> robj =
        await AccountMgr()?.currentAccount?.epikWallet?.voterInfo(AccountMgr()?.currentAccount?.epik_EPK_address);
    dlog("voterInfo");
    dlog(robj.data);
    if (voterinfo == null) voterinfo = VoterInfo();
    if (robj.isSuccess) {
      voterinfo.parseJson(jsonDecode(robj.data));
    }

    HttpJsonRes hjr_info = await ApiMainNet.expertBaseInfomation();
    if (hjr_info.code == 0) {
      expertInfomation = ExpertInfomation.fromJson(hjr_info.jsonMap["expertInfomation"]);

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

  void onClickTab(ExpertStateType type) {
    //todo
    if (pageIndex == type) return;
    pageIndex = type;
    setState(() {
      dataFilter(pageIndex);
    });

    key_scroll?.currentState?.scrollController
        ?.animateTo(0, duration: Duration(milliseconds: 200), curve: Curves.easeIn);

    // // 切换数据类型
    // refresh();
  }

  dataFilter(ExpertStateType type) {
    List<Expert> data = [];
    if (data_experts != null) {
      data_experts.forEach((item) {
        switch (type) {
          case ExpertStateType.REGISTERED:
            {
              if (item.status_e == ExpertStatus.registered) data.add(item);
            }
            break;
          case ExpertStateType.NOMINATED:
            {
              if (item.status_e == ExpertStatus.nominated) data.add(item);
            }
            break;
          case ExpertStateType.NORMAL:
            {
              if (item.status_e == ExpertStatus.normal) data.add(item);
            }
            break;
          case ExpertStateType.BLACK:
            {
              if (item.status_e == ExpertStatus.blocked || item.status_e == ExpertStatus.disqualified) data.add(item);
            }
            break;
          case ExpertStateType.ALL:
          default:
            {
              // data.add(item);
              if (item.status_e != ExpertStatus.registered) data.add(item);
            }
            break;
        }
      });
    }
    data_experts_show = data;
    data_experts_show.forEach((element) {
      print(element.id);
    });
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

  void onClickVoteWithdraw() {
    //提取EPK

    // if (amount_withdraw <= 0) {
    //   showToast("请输入数量");
    //   return;
    // }

    closeInput();

    // BottomDialog.showTextInputDialog(context, RSID.expertview_15.text, "", "Max ${StringUtils.formatNumAmount(voterinfo?.WithdrawableRewards??"0",point: 10)}", 10, (value) {
    //
    //   double amount = StringUtils.parseDouble(value, 0);
    //   if(amount>0)
    //   {
    //     BottomDialog.showPassWordInputDialog(
    //       context,
    //       AccountMgr().currentAccount.password,
    //           (password) {
    //         //点击确定回调 , 已验证密码, 并且已关闭dialog
    //         showLoadDialog(
    //           "",
    //           touchOutClose: false,
    //           backClose: false,
    //           onShow: () async {
    //             ResultObj<String> resultObj = await AccountMgr()
    //                 .currentAccount
    //                 .epikWallet
    //                 .voteWithdraw(AccountMgr().currentAccount.epik_EPK_address);
    //             closeLoadDialog();
    //             if (resultObj.isSuccess) {
    //               String hash = resultObj.data;
    //               dlog(hash);
    //               showToast(RSID.expertinfoview_14.text);//"已提取");
    //             } else {
    //               showToast(resultObj?.errorMsg ?? RSID.request_failed.text);
    //             }
    //           },
    //         );
    //       },
    //     );
    //   }
    //
    // },autoBtnString: RSID.main_bv_4.text,autoBtnContent: voterinfo?.WithdrawableRewards??"0");

    BottomDialog.simpleAuth(
      context,
      AccountMgr().currentAccount.password,
      (password) {
        //点击确定回调 , 已验证密码, 并且已关闭dialog
        showLoadDialog(
          "",
          touchOutClose: false,
          backClose: false,
          onShow: () async {
            ResultObj<String> resultObj =
                await AccountMgr().currentAccount.epikWallet.voteWithdraw(AccountMgr().currentAccount.epik_EPK_address);
            closeLoadDialog();
            if (resultObj.isSuccess) {
              String hash = resultObj.data;
              dlog(hash);
              // showToast(RSID.expertinfoview_14.text);//"已提取");

              MessageDialog.showMsgDialog(
                context,
                title: RSID.expertinfoview_10.text,
                //"提取EPK收益",
                msg: "${RSID.minerview_18.text}\n$hash",
                //交易已提交
                btnLeft: RSID.minerview_19.text,
                //"查看交易",
                btnRight: RSID.isee.text,
                onClickBtnLeft: (dialog) {
                  dialog.dismiss();
                  String url = ServiceInfo.epik_msg_web + hash;
                  ViewGT.showGeneralWebView(context, RSID.berlv_4.text, url);
                },
                onClickBtnRight: (dialog) {
                  dialog.dismiss();
                },
              );
            } else {
              showToast(resultObj?.errorMsg ?? RSID.request_failed.text);
            }
          },
        );
      },
    );
  }
}
