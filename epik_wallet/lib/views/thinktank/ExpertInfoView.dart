import 'dart:convert';

import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_mainnet.dart';
import 'package:epikwallet/model/CurrencyAsset.dart';
import 'package:epikwallet/model/Expert.dart';
import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/ClickUtil.dart';
import 'package:epikwallet/utils/RegExpUtil.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';

///领域专家详情
class ExpertInfoView extends BaseWidget {
  Expert expert;

  ExpertInfoView(this.expert);

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
    super.initState();
    resizeToAvoidBottomPadding = true;

    refresh();

    AccountMgr().currentAccount.epikWallet.voterInfo(AccountMgr().currentAccount.epik_EPK_address).then((value) {
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

  ExpertInfo expertinfo;

  refresh() async {
    setLoadingWidgetVisible(true);

    ResultObj<String> resultObj = await AccountMgr().currentAccount.epikWallet.expertInfo(widget.expert.id);
    dlog(resultObj?.data);
    // {"Owner":"f0101","Type":0,"ApplicationHash":"","Proposer":"f0101","ApplyNewOwner":"f0101","ApplyNewOwnerEpoch":-1,"LostEpoch":-1,"Status":2,"StatusDesc":"normal(votes not enough)","ImplicatedTimes":0,"DataCount":368,"CurrentVotes":"59542785500000000000000","RequiredVotes":"100000000000000000000000","TotalReward":"4406399999999999999987"}
    if(resultObj.isSuccess && resultObj.data!=null)
    {
      Map<String,dynamic> json = jsonDecode(resultObj.data);
      widget.expert.parseJsonFromExpertInfo(json);
    }


    HttpJsonRes hjr =
        await ApiMainNet.expertProfile(hash : widget.expert.application_hash);
    if (hjr.code == 0) {
      expertinfo = ExpertInfo.fromJson(hjr.jsonMap["profile"]);
      closeStateLayout();
    } else if (hjr.code < 0) {
      setErrorWidgetVisible(true);
    } else {
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
    setAppBarTitle("领域专家");
  }


  @override
  Widget buildWidget(BuildContext context) {
    if (_tec_vote == null)
      _tec_vote = new TextEditingController.fromValue(TextEditingValue(
        text: text_vote,
        selection: new TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream, offset: text_vote.length),
        ),
      ));

    if (_tec_rescind == null)
      _tec_rescind = new TextEditingController.fromValue(TextEditingValue(
        text: text_rescind,
        selection: new TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream, offset: text_rescind.length),
        ),
      ));

    if (_tec_withdraw == null)
      _tec_withdraw = new TextEditingController.fromValue(TextEditingValue(
        text: text_withdraw,
        selection: new TextSelection.fromPosition(
          TextPosition(
              affinity: TextAffinity.downstream, offset: text_withdraw.length),
        ),
      ));

    List<Widget> items = [];

    if (expertinfo != null) {
      items.addAll([
        // 姓名 领域
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
              "姓名: ",
              style: TextStyle(
                color: ResColor.black,
                fontSize: 16,
              ),
            ),
            Text(
              expertinfo.name ?? "",
              style: TextStyle(
                color: ResColor.black,
                fontSize: 16,
              ),
            ),
          ],
        ),

        Container(height: 20),

        // 姓名 领域
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
              "领域: ",
              style: TextStyle(
                color: ResColor.black,
                fontSize: 16,
              ),
            ),
            Text(
              expertinfo.domain ?? "",
              style: TextStyle(
                color: ResColor.black,
                fontSize: 16,
              ),
            ),
          ],
        ),

        Container(height: 20),

        // 个人简介
        Text(
          "个人简介",
          style: TextStyle(
            color: ResColor.black,
            fontSize: 16,
          ),
        ),
        Text(
          expertinfo.introduction,
          //"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\nxxxxxxxxxxxxxxxxx\nxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\nxxxxxxxxxxxxxxxxx\n",
          style: TextStyle(
            color: ResColor.black,
            fontSize: 14,
          ),
        ),

        Container(height: 20),

        // 开源协议
        Text(
          "开源协议",
          style: TextStyle(
            color: ResColor.black,
            fontSize: 16,
          ),
        ),
        Text(
          expertinfo.license,
          //"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\nxxxxxxxxxxxxxxxxx\nxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\nxxxxxxxxxxxxxxxxx\n",
          style: TextStyle(
            color: ResColor.black,
            fontSize: 14,
          ),
        ),

        Container(height: 20),
      ]);
    }

    items.addAll([
      Text(
        "ID: ${widget.expert.id}",
        style: TextStyle(
          color: ResColor.black,
          fontSize: 16,
        ),
      ),
      Container(height: 20),
      Text(
        "收益: ${StringUtils.formatNumAmount(widget.expert.income)} EPK",
        style: TextStyle(
          color: ResColor.black,
          fontSize: 16,
        ),
      ),
      Container(height: 20),
      Text(
        "状态: ${widget.expert?.status_e?.getString()}",
        style: TextStyle(
          color: ResColor.black,
          fontSize: 16,
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
            "投票: ",
            style: TextStyle(
              color: ResColor.black,
              fontSize: 16,
            ),
          ),
          Text(
            "${StringUtils.formatNumAmount(widget.expert.vote)}${widget.expert.getRequiredVoteStr()} EPK",
            style: TextStyle(
              color: ResColor.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
      Container(height: 20),
      getInputWidget(
        btnText: "追加投票",
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

          CurrencyAsset ca = AccountMgr()
              ?.currentAccount
              ?.getCurrencyAssetByCs(CurrencySymbol.EPK);
          if (ca != null) balance = ca.balance;
          _tec_vote = null;
          text_vote = balance;
          amount_vote = StringUtils.parseDouble(text_vote, 0);
          setState(() {});
        },
      ),
      Container(height: 15),
      getInputWidget(
          btnText: "撤回投票",
          tec: _tec_rescind,
          onChanged: (text) {
            text_rescind = _tec_rescind.text.trim();
            amount_rescind = StringUtils.parseDouble(text_rescind, 0);
          },
          btnOnClick: () {
            onClickVoteRescind();
          }),
      Container(height: 15),
      getInputWidget(
          btnText: "提取EPK",
          tec: _tec_withdraw,
          onChanged: (text) {
            text_withdraw = _tec_withdraw.text.trim();
            amount_withdraw = StringUtils.parseDouble(text_withdraw, 0);
          },
          btnOnClick: () {
            onClickVoteWithdraw();
          }),
    ]);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
      child: Container(
        constraints: BoxConstraints(
          minHeight: getScreenHeight() -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items,
        ),
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
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        maxLines: 1,
                        obscureText: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExpUtil.re_float)
                        ],
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
                          // hintText: ResString.get(context, RSID.bexv_5),
                          //"请输入兑换数量",
                          hintStyle:
                              TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                        cursorWidth: 2.0,
                        //光标宽度
                        cursorRadius: Radius.circular(2),
                        //光标圆角弧度
                        cursorColor: Colors.blue,
                        //光标颜色
                        style: TextStyle(fontSize: 16, color: Colors.black),
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
                            color: ResColor.black_80,
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Divider(
                height: 0.5,
                thickness: 0.5,
                color: ResColor.main,
              ),
            ],
          ),
        ),
        LoadingButton(
          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
          height: 34,
          width: 100,
          color_bg: ResColor.main,
          disabledColor: Colors.white24,
          progress_color: Colors.white,
          progress_size: 20,
          padding: EdgeInsets.all(0),
          text: btnText,
          textstyle: const TextStyle(
            color: ResColor.white,
            fontSize: 15,
          ),
          loading: false,
          onclick: (lbtn) {
            btnOnClick();
          },
        ),
      ],
    );
  }

  void onClickVoteSend() {
    // 投票

    if (amount_vote <= 0) {
      showToast("请输入数量");
      return;
    }

    closeInput();

    BottomDialog.showPassWordInputDialog(
      context,
      AccountMgr().currentAccount.password,
      (password) {
        //点击确定回调 , 已验证密码, 并且已关闭dialog
        showLoadDialog(
          "",
          touchOutClose: false,
          backClose: false,
          onShow: () async {
            ResultObj<String> resultObj =  await AccountMgr().currentAccount.epikWallet.voteSend(widget.expert.id, text_vote);
            closeLoadDialog();
            if(resultObj.isSuccess)
            {
              String hash =resultObj.data;
              dlog(hash);
              showToast("已投票");
            }else{
              showToast(resultObj?.errorMsg?? RSID.request_failed.text);
            }

          },
        );
      },
    );
  }

  void onClickVoteRescind() {
    //撤回投票 然后可以提取

    if (amount_rescind <= 0) {
      showToast("请输入数量");
      return;
    }

    closeInput();

    BottomDialog.showPassWordInputDialog(
      context,
      AccountMgr().currentAccount.password,
          (password) {
        //点击确定回调 , 已验证密码, 并且已关闭dialog
        showLoadDialog(
          "",
          touchOutClose: false,
          backClose: false,
          onShow: () async {
            ResultObj<String> resultObj =  await AccountMgr().currentAccount.epikWallet.voteRescind(widget.expert.id, text_rescind);
            closeLoadDialog();
            if(resultObj.isSuccess)
            {
              String hash =resultObj.data;
              dlog(hash);
              showToast("已撤回");
            }else{
              showToast(resultObj?.errorMsg?? RSID.request_failed.text);
            }

          },
        );
      },
    );
  }

  void onClickVoteWithdraw() {
    //提取EPK

    // if (amount_withdraw <= 0) {
    //   showToast("请输入数量");
    //   return;
    // }

    closeInput();

    BottomDialog.showPassWordInputDialog(
      context,
      AccountMgr().currentAccount.password,
          (password) {
        //点击确定回调 , 已验证密码, 并且已关闭dialog
        showLoadDialog(
          "",
          touchOutClose: false,
          backClose: false,
          onShow: () async {
            ResultObj<String> resultObj =  await AccountMgr().currentAccount.epikWallet.voteWithdraw(AccountMgr().currentAccount.epik_EPK_address);
            closeLoadDialog();
            if(resultObj.isSuccess)
            {
              String hash =resultObj.data;
              dlog(hash);
              showToast("已提取");
            }else{
              showToast(resultObj?.errorMsg?? RSID.request_failed.text);
            }

          },
        );
      },
    );
  }
}
