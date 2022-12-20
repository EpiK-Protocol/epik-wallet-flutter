import 'package:epikplugin/epikplugin.dart';
import 'package:epikwallet/base/_base_widget.dart';
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

//审核领域专家的申请
class VerifyApplyExpertInfoView extends BaseWidget {
  String selfid;
  ExpertInfo expertInfo;

  VerifyApplyExpertInfoView(this.selfid,this.expertInfo);

  @override
  BaseWidgetState<BaseWidget> getState() {
    return VerifyApplyExpertInfoViewState();
  }
}

class VerifyApplyExpertInfoViewState extends BaseWidgetState<VerifyApplyExpertInfoView> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(RSID.applyexpertview_1.text);
    setAppBarTitle(widget.expertInfo.ex_id);
  }

  @override
  void initStateConfig() {
    super.initStateConfig();
    navigationColor = ResColor.b_2;
    setTopBarVisible(false);
    setAppBarVisible(false);
    setAppBarBackColor(Colors.transparent);
    setTopBarBackColor(Colors.transparent);
    resizeToAvoidBottomPadding = true;
    refresh();
  }

  bool neednominate=false;

  refresh() async {
    setFormData(widget.expertInfo);
    String status = widget.expertInfo.status;
    String status_desc = widget.expertInfo.status_desc;

    if(status_desc.contains("registered"))
    {
      neednominate=true;//可以提名
    }else{
      neednominate=false;
    }
  }

  @override
  void onClickErrorWidget() {
    super.onClickErrorWidget();
    refresh();
  }

  @override
  Widget getAppBarRight({Color color}) {
    return Container();
  }

  @override
  Widget buildWidget(BuildContext context) {
    Widget list = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getFormView(),
        Container(height: 10),
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
            left:0,
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
          Positioned(
            left: 30,
            right: 30,
            bottom:20,
            child: neednominate?LoadingButton(
              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
              gradient_bg: ResColor.lg_1,
              color_bg: Colors.transparent,
              disabledColor: Colors.transparent,
              height: 40,
              text:RSID.expertview_27.text,//"Nominate",
              textstyle: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              bg_borderradius: BorderRadius.circular(4),
              onclick: (lbtn) {
                //  提名
                onClickPost();
              },
            ):LoadingButton(
              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
              gradient_bg: ResColor.lg_7,
              color_bg: Colors.transparent,
              disabledColor: Colors.transparent,
              height: 40,
              // text: widget.expertInfo.status_desc,
              text: RSID.expertview_28.text,//"Nominated",
              textstyle: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              bg_borderradius: BorderRadius.circular(4),
              onclick: (lbtn) {
                //啥也做不了
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> formData = {
    "email": "",
    "language": "",
    "name": "",
    "twitter": "",
    "linkedin": "",
    // "phone": "",
    "domain": "",
    "why": "",
    "how": "",
    // "des": "",
    // "agreement": "",
  };

  setFormData(ExpertInfo info) {
    formData = {
      "email": info?.email ?? "",
      "language": info?.language ?? "",

      "name": info?.name ?? "",
      "twitter": info?.twitter ?? "",
      "linkedin": info?.linkedin ?? "",
      // "phone": info?.mobile ?? "",
      "domain": info?.domain ?? "",
      "why": info?.why ?? "",
      "how": info?.how ?? "",
      // "des": info?.introduction ?? "",
      // "agreement": info?.license ?? "",
    };
  }

  Widget getFormView() {
    List schemaData = [
      {
        "key": "email",
        "type": "text_input",
        "t_label": RSID.applyexpertview_18.text, //"邮箱",
        "maxLines": 1,
        "maxLength": null,
        "enable": false,
      },
      {
        "key": "language",
        // "type": "text_input",
        // "t_label": RSID.applyexpertview_26.text, //语言
        // "maxLines": 1,
        // "maxLength": null,
        "type": "radio",
        "list": ["English", "中文"],
        "list_str": ["English", "中文"],
        "label": RSID.applyexpertview_26.text, //语言
        "label_size": 14,
        "label_boold": false,
        "enable": false,
      },
      {
        "key": "name",
        "type": "text_input",
        "t_label": "1. " + RSID.applyexpertview_16.text, //"姓名",
        "maxLines": 1,
        "maxLength": null,
        "label": RSID.applyexpertview_31.text, //基础信息
        // "des": RSID.applyexpertview_32.text, //告诉大家你是谁
        "enable": false,
      },
      {
        "key": "twitter",
        "type": "text_input",
        "t_label": "2. " + RSID.applyexpertview_27.text, //"推特",
        "maxLines": 1,
        "maxLength": null,
        "enable": false,
      },
      {
        "key": "linkedin",
        "type": "text_input",
        "t_label": "3. " + RSID.applyexpertview_28.text, //"领英",
        "maxLines": 1,
        "maxLength": null,
        "enable": false,
      },
      // {
      //   "key": "phone",
      //   "type": "text_input",
      //   "t_label": RSID.applyexpertview_17.text, //"手机号(非公开)",
      //   "maxLines": 1,
      //   "maxLength": null,
      // },
      {
        "key": "domain",
        "type": "text_input",
        "t_label": "4. " + RSID.applyexpertview_19.text, //"领域",
        "maxLines": 1,
        "maxLength": null,
        "label": RSID.applyexpertview_33.text, //专业介绍
        // "des": RSID.applyexpertview_34.text, //请选择一个领域，并结合您自己的经验告诉大家您是该领域专家最适合的人选。
        "enable": false,
      },
      {
        "key": "why",
        "type": "text_input",
        "t_label": "5. " + RSID.applyexpertview_29.text, //为什么你是这个领域的合适人选？
        "minLines": 3,
        "maxLines": -1,
        "maxLength": null,
        "enable": false,
      },
      {
        "key": "how",
        "type": "text_input",
        "t_label": "6. " + RSID.applyexpertview_30.text, //您将如何根据该领域收集的数据开发或推广应用程序？
        "minLines": 3,
        "maxLines": -1,
        "maxLength": null,
        "label": RSID.applyexpertview_35.text, //AI应用
        // "des": RSID.applyexpertview_36.text, //"请告诉大家，该领域中的数据将非常有用，您可以开发一个新的AI应用程序或找到一个现有的AI应用程序，以使该领域中的数据受益。
        "enable": false,
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

    if (btnloading == true) return;

    btnloading = true;
    setState(() {});

    showLoadDialog("",backClose: false,touchOutClose: false);


    ResultObj<String> resultObj = await AccountMgr()
        .currentAccount
        .epikWallet
        .expertNominate(widget.selfid, widget.expertInfo.ex_id.trim());
    // ResultObj<String> resultObj = ResultObj();

    closeLoadDialog();

    if (resultObj?.isSuccess) {
      widget.expertInfo.status_desc="nominated";
      neednominate=false;
      showToast(RSID.minerview_18.text);
    } else {
      showToast(resultObj?.errorMsg ?? RSID.request_failed.text);
    }

    btnloading = false;
    setState(() {});

  }
}
