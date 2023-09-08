import 'dart:convert';
import 'dart:ui';

import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_mainnet.dart';
import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/CurrencyAsset.dart';
import 'package:epikwallet/model/Expert.dart';
import 'package:epikwallet/model/VoterInfo.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/ClickUtil.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/sp_utils/sp_utils.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/views/viewgoto.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';

///领域专家详情
class ExpertInfoView extends BaseWidget {
  Expert expert;
  VoterInfo voterinfo;

  ExpertInfoView(this.expert, this.voterinfo);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return ExpertInfoViewState();
  }
}

class ExpertInfoViewState extends BaseWidgetState<ExpertInfoView> {
  TextEditingController _tec_vote;
  TextEditingController _tec_rescind;
  TextEditingController _tec_withdraw;

  String text_vote = "";
  double amount_vote = 0;
  String text_rescind = "";
  double amount_rescind = 0;
  String text_withdraw = "";
  double amount_withdraw = 0;

  @override
  void initState() {
    viewSystemUiOverlayStyle = DeviceUtils.system_bar_main.copyWith(systemNavigationBarColor: ResColor.b_4);
    super.initState();
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);

    resizeToAvoidBottomPadding = true;
    refresh();

    AccountMgr().currentAccount.epikWallet.voterInfo(AccountMgr().currentAccount.epik_EPK_address).then((value) {
      dlog("voterInfo");
      dlog(value.data);
    });
    //   {
    //     "UnlockingVotes":"0",
    //   "UnlockedVotes":"0",
    //   "WithdrawableRewards":"9161620797299401600",
    //   "Candidates":{
    //   "f01000":"42785500000000000000"
    //   }
    // }
  }

  bool get isSelfQualified
  {
    // print(isSelf);
    // print(widget.expert.status_e);
    return isSelf  && widget.expert.status_e==ExpertStatus.normal;//&& expertinfo.status_t==ExpertInfoStatus.nomal
  }

  ///导航栏appBar中间部分 ，不满足可以自行重写
  Widget getAppBarRight({Color color}) {
    if (isSelfQualified)
      return InkWell(
        onTap: () {
          showDomainBackendDialog();
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          width: 24.0 + 20 + 20,
          height: getAppBarHeight(),
          child: Icon(
            Icons.more_horiz,
            color: color ?? appBarContentColor,
            size: 20,
          ),
        ),
      );

    return Container();
  }

  //dialog 提示领域专家后台
  showDomainBackendDialog() {
    MessageDialog.showMsgDialog(
      context,
      title: RSID.expertview_2.text,
      msg: RSID.expertinfoview_17.text+"\n"+ServiceInfo.EPIKG_DOMAIN_BACKEND_URL,
      btnLeft: RSID.copy.text,
      btnRight: RSID.confirm.text,
      onClickBtnLeft: (dialog) {
        DeviceUtils.copyText(ServiceInfo.EPIKG_DOMAIN_BACKEND_URL);
        showToast(RSID.copied.text);
      },
      onClickBtnRight: (dialog) {
        dialog.dismiss();
      },
    );
  }

  ExpertInfo expertinfo;
  bool isSelf = false;

  refresh() async {
    setLoadingWidgetVisible(true);

    ResultObj<String> robj =
        await AccountMgr()?.currentAccount?.epikWallet?.voterInfo(AccountMgr()?.currentAccount?.epik_EPK_address);
    if (robj.isSuccess) {
      dlog("voterInfo");
      dlog(robj.data);
      widget?.voterinfo?.parseJson(jsonDecode(robj.data));
    }

    ResultObj<String> resultObj = await AccountMgr().currentAccount.epikWallet.expertInfo(widget.expert.id);
    dlog("expertInfo");
    dlog(resultObj?.data);
    // {"Owner":"f0101","Type":0,"ApplicationHash":"","Proposer":"f0101","ApplyNewOwner":"f0101","ApplyNewOwnerEpoch":-1,"LostEpoch":-1,"Status":2,"StatusDesc":"normal(votes not enough)","ImplicatedTimes":0,"DataCount":368,"CurrentVotes":"59542785500000000000000","RequiredVotes":"100000000000000000000000","TotalReward":"4406399999999999999987"}
    if (resultObj.isSuccess && resultObj.data != null) {
      Map<String, dynamic> json = jsonDecode(resultObj.data);
      widget.expert.parseJsonFromExpertInfo(json);
    }

    HttpJsonRes hjr = await ApiMainNet.expertProfile(hash: widget.expert.application_hash);
    if (hjr.code == 0) {
      expertinfo = ExpertInfo.fromJson(hjr.jsonMap["profile"]);
      if (expertinfo.owner == AccountMgr().currentAccount.epik_EPK_address) {
        isSelf = true;
      } else {
        isSelf = false;
      }

      // isSelf = true;// TODO test
      // dlog("owner isSelf=${isSelf}");
      // dlog(expertinfo.owner);
      // dlog(AccountMgr().currentAccount.epik_EPK_address);
      closeStateLayout();

      if(isSelfQualified && SpUtils.getBool("domain_expert_backend_tip",defValue: true))
      {
        SpUtils.putBool("domain_expert_backend_tip", false);
        showDomainBackendDialog();
      }

    } else if (hjr.code < 0) {
      isSelf = false;
      setErrorWidgetVisible(true);
    } else {
      isSelf = false;
      closeStateLayout();
    }
  }

  @override
  void onClickErrorWidget() {
    super.onClickErrorWidget();
    refresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(RSID.expertinfoview_0.text); //"领域专家详情");
  }

  @override
  Widget buildWidget(BuildContext context) {
    if (_tec_vote == null)
      _tec_vote = new TextEditingController.fromValue(TextEditingValue(
        text: text_vote,
        selection: new TextSelection.fromPosition(
          TextPosition(affinity: TextAffinity.downstream, offset: text_vote.length),
        ),
      ));

    if (_tec_rescind == null)
      _tec_rescind = new TextEditingController.fromValue(TextEditingValue(
        text: text_rescind,
        selection: new TextSelection.fromPosition(
          TextPosition(affinity: TextAffinity.downstream, offset: text_rescind.length),
        ),
      ));

    if (_tec_withdraw == null)
      _tec_withdraw = new TextEditingController.fromValue(TextEditingValue(
        text: text_withdraw,
        selection: new TextSelection.fromPosition(
          TextPosition(affinity: TextAffinity.downstream, offset: text_withdraw.length),
        ),
      ));

    List<Widget> items = [];

    items.add(
      Container(
        width: double.infinity,
        height: 51,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: EdgeInsets.all(9.75),
                    decoration: BoxDecoration(
                      color: Color(0xff333333),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Image.asset(
                      "assets/img/ic_main_menu_expert_s.png",
                      width: 40.5,
                      height: 40.5,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: -20.05,
              top: -0.05,
              height: 30,
              child: Container(
                padding: EdgeInsets.fromLTRB(14, 0, 14, 0),
                decoration: BoxDecoration(
                  gradient: ResColor.lg_3,
                  borderRadius: BorderRadius.only(topRight: Radius.circular((20)), bottomLeft: Radius.circular((20))),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "ID:${widget.expert.id}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isSelf)
              Positioned(
                left: -20.05,
                top: -0.05,
                height: 30,
                child: Container(
                  padding: EdgeInsets.fromLTRB(14, 0, 14, 0),
                  decoration: BoxDecoration(
                    gradient: ResColor.lg_2,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular((20)), bottomRight: Radius.circular((20))),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        RSID.expertinfoview_16.text, //"Self",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (expertinfo != null) {
      items.addAll([
        // 姓名 领域
        // Container(
        //   width: double.infinity,
        //   child: Text(
        //     expertinfo.name ?? "--",
        //     textAlign: TextAlign.center,
        //     style: TextStyle(
        //       color: ResColor.white,
        //       fontSize: 17,
        //     ),
        //   ),
        // ),
        Text(
          RSID.applyexpertview_16.text + ": " + expertinfo.name ?? "--",
          // textAlign: TextAlign.center,
          style: TextStyle(
            color: ResColor.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),

        if (StringUtils.isNotEmpty(expertinfo?.twitter))
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    RSID.applyexpertview_27.text + ": " + expertinfo.twitter ?? "--",
                    // textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ResColor.white_80,
                      fontSize: 14,
                    ),
                  ),
                ),
                LoadingButton(
                  height: 20,
                  width: 40,
                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
                  // gradient_bg: ResColor.lg_1,
                  color_bg: Colors.transparent,
                  disabledColor: Colors.transparent,
                  side: BorderSide(width: 1, color: ResColor.o_1),
                  bg_borderradius: BorderRadius.circular(4),
                  text: RSID.copy.text,
                  //"复制",//"Copy",
                  textstyle: const TextStyle(
                    color: ResColor.o_1,
                    fontSize: 12,
                  ),
                  onclick: (lbtn) {
                    if (StringUtils.isNotEmpty(expertinfo.twitter)) {
                      DeviceUtils.copyText(expertinfo.twitter);
                      showToast(RSID.copied.text);
                    }
                  },
                ),
              ],
            ),
          ),

        if (StringUtils.isNotEmpty(expertinfo?.linkedin))
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    RSID.applyexpertview_28.text + ": " + expertinfo.linkedin ?? "--",
                    // textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ResColor.white_80,
                      fontSize: 14,
                    ),
                  ),
                ),
                LoadingButton(
                  height: 20,
                  width: 40,
                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
                  // gradient_bg: ResColor.lg_1,
                  color_bg: Colors.transparent,
                  disabledColor: Colors.transparent,
                  side: BorderSide(width: 1, color: ResColor.o_1),
                  bg_borderradius: BorderRadius.circular(4),
                  text: RSID.copy.text,
                  //"复制",//"Copy",
                  textstyle: const TextStyle(
                    color: ResColor.o_1,
                    fontSize: 12,
                  ),
                  onclick: (lbtn) {
                    if (StringUtils.isNotEmpty(expertinfo.linkedin)) {
                      DeviceUtils.copyText(expertinfo.linkedin);
                      showToast(RSID.copied.text);
                    }
                  },
                ),
              ],
            ),
          ),

        Container(height: 20),

        // 姓名 领域
        Wrap(
          direction: Axis.horizontal,
          //排列方向，默认水平方向排列
          alignment: WrapAlignment.center,
          //子控件在主轴上的对齐方式
          spacing: 0.0,
          //主轴上子控件中间的间距
          runAlignment: WrapAlignment.center,
          //子控件在交叉轴上的对齐方式
          runSpacing: 0,
          //交叉轴上子控件之间的间距
          crossAxisAlignment: WrapCrossAlignment.center,
          //交叉轴上子控件的对齐方式
          verticalDirection: VerticalDirection.down,
          //垂直方向上子控件的其实位置
          children: [
            Text(
              RSID.expertview_7.text + ": ", //"领域: ",
              style: TextStyle(
                color: ResColor.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              expertinfo.domain ?? "--",
              style: TextStyle(
                color: ResColor.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        Container(height: 20),

        // 个人简介
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 14,
              color: ResColor.o_1,
              margin: EdgeInsets.only(right: 6, top: 3),
            ),
            Expanded(
              child: Text(
                RSID.applyexpertview_42.text, //"为什么我能做好这个领域？",
                style: TextStyle(
                  color: ResColor.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),

        Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: 10, bottom: 20),
          child: Text(
            expertinfo?.why ?? "--",
            //"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\nxxxxxxxxxxxxxxxxx\nxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\nxxxxxxxxxxxxxxxxx\n",
            style: TextStyle(
              color: ResColor.white_80,
              fontSize: 14,
            ),
          ),
        ),

        // 开源协议
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 14,
              color: ResColor.o_1,
              margin: EdgeInsets.only(right: 6, top: 3),
            ),
            Expanded(
              child: Text(
                RSID.applyexpertview_43.text, //"我会如何推动AI应用来使这个领域中的数据收益",
                style: TextStyle(
                  color: ResColor.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: 10, bottom: 20),
          child: Text(
            expertinfo?.how ?? "--",
            //"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\nxxxxxxxxxxxxxxxxx\nxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\nxxxxxxxxxxxxxxxxx\n",
            style: TextStyle(
              color: ResColor.white_80,
              fontSize: 14,
            ),
          ),
        ),

        Container(height: 20),
      ]);
    }

    items.addAll([
      // Text(
      //   "ID: ${widget.expert.id}",
      //   style: TextStyle(
      //     color: ResColor.black,
      //     fontSize: 16,
      //   ),
      // ),
      // Container(height: 20),
      Text(
        // "状态: ${widget.expert?.statusDesc}"
        "${RSID.expertinfoview_3.text}: ${widget.expert?.statusDesc}",
        style: TextStyle(
          color: ResColor.white,
          fontSize: 14,
        ),
      ),
      Container(height: 20),
      Wrap(
        direction: Axis.horizontal,
        //排列方向，默认水平方向排列
        alignment: WrapAlignment.start,
        //子控件在主轴上的对齐方式
        spacing: 0.0,
        //主轴上子控件中间的间距
        runAlignment: WrapAlignment.start,
        //子控件在交叉轴上的对齐方式
        runSpacing: 10,
        //交叉轴上子控件之间的间距
        crossAxisAlignment: WrapCrossAlignment.end,
        //交叉轴上子控件的对齐方式
        verticalDirection: VerticalDirection.down,
        //垂直方向上子控件的其实位置
        children: [
          Text(
            RSID.expertinfoview_4.text + ": ", //"投票: ",
            style: TextStyle(
              color: ResColor.white,
              fontSize: 14,
            ),
          ),
          Text(
            "${StringUtils.formatNumAmount(widget.expert.vote)}${widget.expert.getRequiredVoteStr()} AIEPK",
            style: TextStyle(
              color: ResColor.o_1,
              fontSize: 14,
            ),
          ),
        ],
      ),
      Container(height: 20),
      Text(
        //收益
        "${RSID.expertinfoview_5.text}: ${StringUtils.formatNumAmount(widget.expert.income)} AIEPK",
        style: TextStyle(
          color: ResColor.white,
          fontSize: 14,
        ),
      ),
      Container(height: 20),
    ]);

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // header card
          Container(
            width: double.infinity,
            height: getAppBarHeight() + getTopBarHeight() + 128,
            padding: EdgeInsets.only(top: getTopBarHeight()),
            decoration: BoxDecoration(
              gradient: ResColor.lg_1,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                getAppBar(),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: getAppBarHeight() + getTopBarHeight(),
            bottom: 0,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.fromLTRB(30, 40, 30, 40),
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                      decoration: BoxDecoration(
                        color: ResColor.b_3,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: items,
                      ),
                    ),
                  ),
                ),
                getBottomBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getBottomBar() {
    List<Widget> views = [];

    views.add(Container(
      height: 50,
      child: Row(
        children: [
          Text(
            "${RSID.expertinfoview_6.text} AIEPK", //已投
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          Container(width: 7),
          Expanded(
            child: Text(
              StringUtils.formatNumAmount(widget?.voterinfo?.getCandidateById(widget.expert.id) ?? "0", point: 8),
              // "0.0000 TODO",
              style: TextStyle(
                fontSize: 24,
                color: ResColor.o_1,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ));

    views.add(Container(
      width: double.infinity,
      height: 0.5,
      decoration: BoxDecoration(
        gradient: ResColor.lg_4,
      ),
    ));

    views.addAll(getInputs());

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(30, 0, 30, 30 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: ResColor.b_4,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: views,
      ),
    );
  }

  Widget getInputWidget({
    TextEditingController tec,
    String btnText,
    ValueChanged<String> onChanged,
    VoidCallback btnOnClick,
    VoidCallback maxOnClick,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 33,
                child: Row(
                  children: [
                    // textfield
                    Expanded(
                        child: Container(
                      height: 33,
                      child: TextField(
                        controller: tec,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        maxLines: 1,
                        obscureText: false,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExpUtil.re_float)],
                        // 这里限制长度 不会有数量提示
                        decoration: InputDecoration(
                          // 以下属性可用来去除TextField的边框
                          border: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.fromLTRB(0, -15, 0, 0),
                          hintText: RSID.expertinfoview_7.text,
                          //"请输入数额",
                          hintStyle: TextStyle(color: Colors.white, fontSize: 17),
                        ),
                        cursorWidth: 2.0,
                        //光标宽度
                        cursorRadius: Radius.circular(2),
                        //光标圆角弧度
                        cursorColor: Colors.white,
                        //光标颜色
                        style: TextStyle(fontSize: 17, color: Colors.white),
                        onChanged: onChanged,
                      ),
                    )),
                    // max
                    if (maxOnClick != null)
                      InkWell(
                        onTap: () {
                          // 全部
                          if (ClickUtil.isFastDoubleClick()) return;
                          maxOnClick();
                        },
                        child: Text(
                          " Max ",
                          style: TextStyle(
                            color: ResColor.white,
                            fontSize: 17,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Divider(
                height: 0.5,
                thickness: 0.5,
                color: ResColor.white_20,
              ),
            ],
          ),
        ),
        LoadingButton(
          margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
          height: 40,
          width: 100,
          gradient_bg: ResColor.lg_1,
          color_bg: Colors.transparent,
          disabledColor: Colors.transparent,
          progress_size: 20,
          padding: EdgeInsets.all(0),
          bg_borderradius: BorderRadius.circular(4),
          text: btnText,
          textstyle: const TextStyle(
            color: ResColor.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          loading: false,
          onclick: (lbtn) {
            btnOnClick();
          },
        ),
      ],
    );
  }

  List<Widget> getInputs() {
    List<Widget> inputs = [
      Container(height: 15),
      getInputWidget(
        btnText: RSID.expertinfoview_8.text,
        //"追加投票",
        tec: _tec_vote,
        onChanged: (text) {
          text_vote = _tec_vote.text.trim();
          amount_vote = StringUtils.parseDouble(text_vote, 0);
        },
        btnOnClick: () {
          onClickVoteSend();
        },
        maxOnClick: () {
          String balance = "0";

          CurrencyAsset ca = AccountMgr()?.currentAccount?.getCurrencyAssetByCs(CurrencySymbol.AIEPK);
          if (ca != null) balance = ca.balance;
          _tec_vote = null;
          text_vote = balance;
          amount_vote = StringUtils.parseDouble(text_vote, 0);
          setState(() {});
        },
      ),
      Container(height: 15),
      getInputWidget(
        btnText: RSID.expertinfoview_9.text,
        //"撤回投票",
        tec: _tec_rescind,
        onChanged: (text) {
          text_rescind = _tec_rescind.text.trim();
          amount_rescind = StringUtils.parseDouble(text_rescind, 0);
        },
        btnOnClick: () {
          onClickVoteRescind();
        },
        maxOnClick: () {
          _tec_rescind = null;
          text_rescind = widget?.voterinfo?.getCandidateById(widget.expert.id) ?? "0";
          amount_rescind = StringUtils.parseDouble(text_rescind, 0);
          setState(() {});
        },
      ),
      // Container(height: 15),
      // getInputWidget(
      //     btnText: RSID.expertinfoview_10.text,// "提取EPK",
      //     tec: _tec_withdraw,
      //     onChanged: (text) {
      //       text_withdraw = _tec_withdraw.text.trim();
      //       amount_withdraw = StringUtils.parseDouble(text_withdraw, 0);
      //     },
      //     btnOnClick: () {
      //       onClickVoteWithdraw();
      //     }),
    ];

    return inputs;
  }

  void onClickVoteSend() {
    // 投票

    if (amount_vote <= 0) {
      showToast(RSID.expertinfoview_11.text); //"请输入数量");
      return;
    }

    closeInput();

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
                await AccountMgr().currentAccount.epikWallet.voteSend(widget.expert.id, text_vote);
            closeLoadDialog();
            if (resultObj.isSuccess) {
              // String hash = resultObj.data;
              // dlog(hash);
              // showToast( RSID.expertinfoview_12.text);//"已投票");
              String cid = resultObj.data;
              MessageDialog.showMsgDialog(
                context,
                title: RSID.expertinfoview_8.text,
                //"撤回投票",
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
              showToast(resultObj?.errorMsg ?? RSID.request_failed.text);
            }
          },
        );
      },
    );
  }

  void onClickVoteRescind() {
    //撤回投票 然后可以提取

    if (amount_rescind <= 0) {
      showToast(RSID.expertinfoview_11.text); //"请输入数量");
      return;
    }

    closeInput();

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
                await AccountMgr().currentAccount.epikWallet.voteRescind(widget.expert.id, text_rescind);
            closeLoadDialog();
            if (resultObj.isSuccess) {
              String hash = resultObj.data;
              // dlog(hash);
              // showToast(RSID.expertinfoview_13.text);//"已撤回");
              String cid = resultObj.data;
              MessageDialog.showMsgDialog(
                context,
                title: RSID.expertinfoview_9.text,
                //"撤回投票",
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
              showToast(resultObj?.errorMsg ?? RSID.request_failed.text);
            }
          },
        );
      },
    );
  }

// void onClickVoteWithdraw() {
//   //提取EPK
//
//   // if (amount_withdraw <= 0) {
//   //   showToast("请输入数量");
//   //   return;
//   // }
//
//   closeInput();
//
//   BottomDialog.showPassWordInputDialog(
//     context,
//     AccountMgr().currentAccount.password,
//     (password) {
//       //点击确定回调 , 已验证密码, 并且已关闭dialog
//       showLoadDialog(
//         "",
//         touchOutClose: false,
//         backClose: false,
//         onShow: () async {
//           ResultObj<String> resultObj = await AccountMgr()
//               .currentAccount
//               .epikWallet
//               .voteWithdraw(AccountMgr().currentAccount.epik_EPK_address);
//           closeLoadDialog();
//           if (resultObj.isSuccess) {
//             String hash = resultObj.data;
//             dlog(hash);
//             showToast(RSID.expertinfoview_14.text);//"已提取");
//           } else {
//             showToast(resultObj?.errorMsg ?? RSID.request_failed.text);
//           }
//         },
//       );
//     },
//   );
// }
}
