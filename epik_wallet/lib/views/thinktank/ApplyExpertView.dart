import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/dialog/message_dialog.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_mainnet.dart';
import 'package:epikwallet/model/Expert.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/jsonform/JsonFormWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

//申请领域专家
class ApplyExpertView extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> getState() {
    return ApplyExpertViewState();
  }
}

class ApplyExpertViewState extends BaseWidgetState<ApplyExpertView> {
  ExpertInfo expertInfo_old;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle("申请领域专家");
  }

  @override
  void initStateConfig() {
    super.initStateConfig();
    navigationColor = ResColor.b_2;
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);
// resizeToAvoidBottomPadding=true;
    refresh();
  }

  refresh() async {
    setLoadingWidgetVisible(true);

    HttpJsonRes hjr = await ApiMainNet.expertProfile(
        owner: AccountMgr().currentAccount.epik_EPK_address);
    if (hjr.code == 0) {
      expertInfo_old = ExpertInfo.fromJson(hjr.jsonMap["profile"]);
      setFormData(expertInfo_old);
      closeStateLayout();

      Future.delayed(Duration(milliseconds: 100)).then((value) {
        // expertInfo_old?.status_t=ExpertInfoStatus.reject; //todo test
        switch (expertInfo_old?.status_t) {
          case ExpertInfoStatus.pre_regist:
            break;
          case ExpertInfoStatus.regist:
            //等待审核
            MessageDialog.showMsgDialog(
              context,
              title: RSID.tip.text,
              msg: "您的申请已提交，请等待审核结果。",
              backClose: false,
              touchOutClose: false,
              btnRight: RSID.isee.text,
              onClickBtnRight: (dialog) {
                dialog.dismiss();
                finish();
              },
              btnLeft: "再次申请",
              onClickBtnLeft: (dialog) {
                setFormData(null);
                setState(() {});
                dialog.dismiss();
              },
            );
            break;
          case ExpertInfoStatus.nomal:
            //审核已通过
            MessageDialog.showMsgDialog(
              context,
              title: RSID.tip.text,
              msg: "您的申请已通过",
              backClose: false,
              touchOutClose: false,
              btnRight: RSID.isee.text,
              onClickBtnRight: (dialog) {
                dialog.dismiss();
                finish();
              },
              btnLeft: "再次申请",
              onClickBtnLeft: (dialog) {
                setFormData(null);
                setState(() {});
                dialog.dismiss();
              },
            );
            break;
          case ExpertInfoStatus.reject:
            //申请被拒绝
            setState(() {});
            break;
        }
      });
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
  Widget getAppBarRight({Color color}) {
    return InkWell(
      onTap: () {
        // todo 申请须知网页
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "申请须知",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            Icon(
              Icons.help_outline,
              color: Colors.white,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    Widget list = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (expertInfo_old?.status_t == ExpertInfoStatus.reject) getStateTips(),
        getFormView(),
        Container(height: 10),
        Row(
          children: [
            Text(
              "费用",
              style: TextStyle(
                fontSize: 11,
                color: ResColor.white_60,
              ),
            ),
            Expanded(
              child: Text(
                "100 EPK",
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 17,
                  color: ResColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        LoadingButton(
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          gradient_bg: ResColor.lg_1,
          color_bg: Colors.transparent,
          disabledColor: Colors.transparent,
          height: 40,
          text: "提交申请",
          textstyle: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          bg_borderradius: BorderRadius.circular(4),
          onclick: (lbtn) {
            //  提交请求
            closeInput();

            if (StringUtils.isEmpty(formData["name"])) {
              showToast("请输入姓名");
              return;
            }
            if (StringUtils.isEmpty(formData["phone"])) {
              showToast("请输入手机号");
              return;
            }
            if (StringUtils.isEmpty(formData["email"])) {
              showToast("请输入邮箱");
              return;
            }
            if (StringUtils.isEmpty(formData["domain"])) {
              showToast("请输入领域");
              return;
            }
            if (StringUtils.isEmpty(formData["des"])) {
              showToast("请输入个人介绍");
              return;
            }

            BottomDialog.showPassWordInputDialog(
              context,
              AccountMgr().currentAccount.password,
              (password) {
                //点击确定回调
                onClickPost();
              },
            );
          },
        ),
      ],
    );

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
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(30, 40, 30, 40),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ResColor.b_3,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: list,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getStateTips() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 11, 20, 11),
      width: double.infinity,
      decoration: BoxDecoration(
        color: ResColor.warning_bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "很遗憾，您的申请未通过。\n原因: ${expertInfo_old?.reason ?? ""}\n您可以更新申请表重新提交审核",
        style: TextStyle(
          color: ResColor.warning_text,
          fontSize: 14,
        ),
      ),
    );
  }

  Map<String, dynamic> formData = {
    "name": "",
    "phone": "",
    "email": "",
    "domain": "",
    "des": "",
    "agreement": "",
  };

  setFormData(ExpertInfo info) {
    formData = {
      "name": info?.name ?? "",
      "phone": info?.mobile ?? "",
      "email": info?.email ?? "",
      "domain": info?.domain ?? "",
      "des": info?.introduction ?? "",
      "agreement": info?.license ?? "",
    };
  }

  Widget getFormView() {
    List schemaData = [
      {
        "key": "name",
        "type": "text_input",
        "t_label": "姓名(公开)",
        "maxLines": 1,
        "maxLength": null,
      },
      {
        "key": "phone",
        "type": "text_input",
        "t_label": "手机号(非公开)",
        "maxLines": 1,
        "maxLength": null,
      },
      {
        "key": "email",
        "type": "text_input",
        "t_label": "邮箱(非公开)",
        "maxLines": 1,
        "maxLength": null,
      },
      {
        "key": "domain",
        "type": "text_input",
        "t_label": "想申请的领域(公开)",
        "maxLines": 1,
        "maxLength": null,
      },
      {
        "key": "des",
        "type": "text_input",
        "des": "请从教育背景，工作经历，影响力等方面介绍自己",
        "t_label": "个人介绍(公开)",
        "minLines": 1,
        "maxLines": -1,
        "maxLength": null,
      },
      {
        "key": "agreement",
        "type": "text_input",
        "des": "知识图谱数据默认遵循无任何限制的开源协议，如对开源协议有任何特殊要求，请填写如下（选填）",
        "t_label": "开源协议(公开)",
        "minLines": 1,
        "maxLines": -1,
        "maxLength": null,
      },
    ];

    return JsonFormWidget(
      formData: formData,
      schemaData: schemaData,
      onFormDataChange: (formData, key) {},
    );
  }

  bool btnloading = false;

  void onClickPost() async {
    // "name": "",
    // "phone": "",
    // "email": "",
    // "domain": "",
    // "des": "",
    // "agreement": "",

    if (btnloading == true) return;

    btnloading = true;
    setState(() {});

    HttpJsonRes hjr = await ApiMainNet.registerExpert(
      name: formData["name"],
      mobile: formData["phone"],
      email: formData["email"],
      domain: formData["domain"],
      introduction: formData["des"],
      license: formData["agreement"],
      owner: AccountMgr().currentAccount.epik_EPK_address,
    );

    String hash;
    if (hjr.code == 0) {
      hash = hjr.jsonMap["hash"];
    } else {
      showToast(hjr?.msg ?? RSID.request_failed.text);
    }
    btnloading = false;
    setState(() {});

    if (StringUtils.isNotEmpty(hash)) {
      showLoadDialog(
        "交易确认中",
        backClose: false,
        touchOutClose: false,
        onShow: () async {
          ResultObj<String> resultObj =
              await AccountMgr().currentAccount.epikWallet.createExpert(hash);
          closeLoadDialog();
          if (resultObj?.code == 0) {
            String expert_id = resultObj.data; //专家ID
            dlog(expert_id); //

            MessageDialog.showMsgDialog(
              context,
              title: RSID.tip.text,
              msg: "领域专家申请已提交，请等待审核。",
              btnRight: RSID.confirm.text,
              onClickBtnRight: (dialog) {
                dialog.dismiss();
                Future.delayed(Duration(milliseconds: 200)).then((value) {
                  finish();
                });
              },
            );
          } else {
            showToast(resultObj?.errorMsg ?? RSID.request_failed.text);
          }
        },
      );
    }
  }
}
