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
    // setAppBarTitle("领域专家申请");
  }

  @override
  void initStateConfig() {
    super.initStateConfig();
    setAppBarTitle("申请领域专家");
    resizeToAvoidBottomPadding = true;

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
       switch(expertInfo_old?.status_t){

         case ExpertInfoStatus.pre_regist:
           break;
         case ExpertInfoStatus.regist:
         //等待审核
           MessageDialog.showMsgDialog(context,
             title: RSID.tip.text,
             msg: "您的申请已提交，请等待审核结果。",
             backClose: false,
             touchOutClose: false,
             btnRight: RSID.isee.text,
             onClickBtnRight:(dialog) {
               dialog.dismiss();
               finish();
             },
            btnLeft: "再次申请",
             onClickBtnLeft:(dialog) {
               setFormData(null);
               setState(() {
               });
               dialog.dismiss();
             },
           );
           break;
         case ExpertInfoStatus.nomal:
         //审核已通过
           MessageDialog.showMsgDialog(context,
             title: RSID.tip.text,
             msg: "您的申请已通过",
             backClose: false,
             touchOutClose: false,
             btnRight: RSID.isee.text,
             onClickBtnRight:(dialog) {
               dialog.dismiss();
               finish();
             },
             btnLeft: "再次申请",
             onClickBtnLeft:(dialog) {
               setFormData(null);
               setState(() {
               });
               dialog.dismiss();
             },
           );
           break;
         case ExpertInfoStatus.reject:
         //申请被拒绝
           setState(() {
           });
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
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            Icon(
              Icons.help_outline,
              color: Colors.black,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: EdgeInsets.fromLTRB(15, 6, 15, 0),
        //   child: Row(
        //     crossAxisAlignment: CrossAxisAlignment.end,
        //     children: [
        //       Expanded(
        //         child: Text(
        //           "申请领域专家",
        //           style: TextStyle(
        //             color: Colors.black,
        //             fontSize: 20,
        //           ),
        //         ),
        //       ),
        //       Material(
        //         color: Colors.transparent,
        //         child: InkResponse(
        //           onTap: () {
        //             //  申请须知网页
        //           },
        //           child: Container(
        //             padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        //             child: Row(
        //               mainAxisSize: MainAxisSize.min,
        //               children: <Widget>[
        //                 Text(
        //                   "申请须知",
        //                   style: TextStyle(
        //                     fontSize: 15,
        //                     color: Colors.black,
        //                   ),
        //                 ),
        //                 Icon(
        //                   Icons.help_outline,
        //                   color: Colors.black,
        //                   size: 15,
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        if (expertInfo_old?.status_t==ExpertInfoStatus.reject) getStateTips(),
        Expanded(
          child: getFormView(),
        ),

        LoadingButton(
          margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
          height: 44,
          color_bg: ResColor.main,
          disabledColor: ResColor.main,
          progress_color: Colors.white,
          progress_size: 20,
          padding: EdgeInsets.all(0),
          text: "提交申请(花费100EPK)",
          textstyle: const TextStyle(
            color: ResColor.white,
            fontSize: 15,
          ),
          loading: btnloading,
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
  }

  Widget getStateTips() {
    return Container(
      margin: EdgeInsets.fromLTRB(15, 0, 15, 15),
      width: double.infinity,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: ResColor.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        elevation: 10,
        shadowColor: ResColor.black_30,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Text(
            "很遗憾，您的申请未通过。\n原因: ${expertInfo_old?.reason ?? ""}\n您可以更新申请表重新提交审核",
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
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
        "minLines": 3,
        "maxLines": -1,
        "maxLength": null,
      },
      {
        "key": "agreement",
        "type": "text_input",
        "des": "知识图谱数据默认遵循无任何限制的开源协议，如对开源协议有任何特殊要求，请填写如下（选填）",
        "lable": "开源协议(公开)",
        "minLines": 3,
        "maxLines": -1,
        "maxLength": null,
      },
    ];

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Container(
        // constraints: BoxConstraints(
        //   minHeight: getScreenHeight() -
        //       BaseFuntion.topbarheight -
        //       BaseFuntion.appbarheight_def,
        // ),
        padding: EdgeInsets.all(15),
        child: JsonFormWidget(
          formData: formData,
          schemaData: schemaData,
          onFormDataChange: (formData, key) {},
        ),
      ),
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
