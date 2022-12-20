import 'package:decimal/decimal.dart';
import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/bottom_dialog.dart';
import 'package:epikwallet/localstring/LocaleConfig.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/logic/account_mgr.dart';
import 'package:epikwallet/logic/api/api_pool.dart';
import 'package:epikwallet/model/nodepool/PoolObj.dart';
import 'package:epikwallet/utils/device/deviceutils.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/string_utils.dart';
import 'package:epikwallet/widget/LoadingButton.dart';
import 'package:epikwallet/widget/jsonform/base/jf_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class NodePoolCreateView extends BaseWidget {

  PoolObj pool;

  NodePoolCreateView({this.pool});

  @override
  BaseWidgetState<BaseWidget> getState() {
    return NodePoolCreateViewState();
  }
}

class NodePoolCreateViewState extends BaseWidgetState<NodePoolCreateView> with TickerProviderStateMixin {
  @override
  void initStateConfig() {
    super.initStateConfig();
    viewSystemUiOverlayStyle = DeviceUtils.system_bar_main.copyWith(systemNavigationBarColor: ResColor.b_4);
    setAppBarVisible(false);
    setTopBarVisible(false);
    resizeToAvoidBottomPadding = true;

    if(widget.pool!=null)
    {
      FeeAddress = widget.pool.FeeAddress; //收益地址
      Name = widget.pool.Name; //名称
      Description = widget.pool.Description; //描述
      Enable = widget.pool.Enable; //是否开放
      Decimal dd = Decimal.parse(widget.pool.Fee);
      Fee_d = dd.toDouble();
      Fee = (dd*Decimal.fromInt(100)).toInt(); //抽成比例 0<x<1    int 0<x<100
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setAppBarTitle(widget.pool!=null? RSID.nodepool_edit.text: RSID.nodepool_create.text);
  }

  @override
  Widget buildWidget(BuildContext context) {
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
            top: getAppBarHeight() + getTopBarHeight(),
            bottom: 0,
            child: SingleChildScrollView(
              child: getEdteItems(),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: bottomBar(),
          ),
        ],
      ),
    );
  }

  Widget bottomBar() {
    Widget view = Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(30, 10, 30, 10 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: ResColor.b_4,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: LoadingButton(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              padding: EdgeInsets.only(bottom: 1),
              height: 40,
              gradient_bg: ResColor.lg_1,
              color_bg: Colors.transparent,
              disabledColor: Colors.transparent,
              bg_borderradius: BorderRadius.circular(4),
              text:widget.pool==null ? RSID.confirm.text : RSID.nodepool_confirm_edit.text,
              textstyle: TextStyle(
                color: Colors.white,
                fontSize: LocaleConfig.currentIsZh() ? 17 : 14,
                fontWeight: FontWeight.bold,
              ),
              onclick: (lbtn) {
                onClickCreate();
              },
            ),
          ),
        ],
      ),
    );
    return view;
  }

  String FeeAddress = ""; //收益地址
  String Name = ""; //名称
  String Description = ""; //描述
  int Fee = 30; //抽成比例 0<x<1    int 0<x<100
  double Fee_d = 0.3;
  bool Enable = true; //是否开放

  Widget getEdteItems() {
    List<Widget> items = [];

    items.add(Text(
      RSID.npcv_1.text,//"名称",
      style: TextStyle(
        fontSize: 18,
        color: Colors.white,
      ),
    ));
    items.add(
      JfText(
        data: Name,
        autofocus: false,
        maxLines: 1,
        hint: RSID.npcv_2.text,//"请输入名称",
        maxLength: 40,
        fontsize: 16,
        onChanged: (text, classtype) {
          Name = text.toString().trim();
        },
      ),
    );

    items.add(Text(
      RSID.npcv_3.text,//"描述",
      style: TextStyle(
        fontSize: 18,
        color: Colors.white,
      ),
    ));
    items.add(
      JfText(
        data: Description,
        autofocus: false,
        maxLines: -1,
        minLines: 1,
        hint: RSID.npcv_4.text,//"请输入描述",
        maxLength: 500,
        fontsize: 16,
        onChanged: (text, classtype) {
          Description = text.toString().trim();
        },
      ),
    );

    items.add(Text(
      RSID.npcv_5.text,//"EPK收益地址",
      style: TextStyle(
        fontSize: 18,
        color: Colors.white,
      ),
    ));
    items.add(
      JfText(
        data: FeeAddress,
        autofocus: false,
        maxLines: -1,
        minLines: 1,
        hint: RSID.npcv_6.text,//"请输入收益地址",
        regexp: r"^f[a-zA-Z0-9]*$",
        maxLength: 500,
        fontsize: 16,
        onChanged: (text, classtype) {
          FeeAddress = text.toString().trim();
        },
      ),
    );

    items.add(Text(
      RSID.npcv_7.text,//"抽成比例",
      style: TextStyle(
        fontSize: 18,
        color: Colors.white,
      ),
    ));
    items.add(Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: JfText(
            enable: false,
            textAlign: TextAlign.center,
            data: "$Fee%",
            autofocus: false,
            maxLines: 1,
            minLines: 1,
            maxLength: 20,
            regexp: r'\d+\.?\d*',
            fontsize: 16,
            onChanged: (text, classtype) {
              // Fee = double.parse(text.toString().trim());
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
            width: double.infinity,
            child: Slider(
              value: Fee.toDouble(),
              // 当前滑块定位到的值
              label: '${StringUtils.formatNumAmount(Fee, point: 2, supply0: false)}%',
              onChanged: (val) {
                // 滑动监听
                setState(() {
                  Fee = StringUtils.parseDouble(val.toStringAsFixed(0), 1).toInt();
                  Decimal d = Decimal.fromInt(Fee) / Decimal.fromInt(100);
                  Fee_d = d.toDouble();
                });
              },
              onChangeStart: (val) {},
              onChangeEnd: (val) {},
              min: 0,
              max: 99,
              divisions: 100,
              activeColor: ResColor.o_1,
              inactiveColor: ResColor.white,
            ),
          ),
        ),
      ],
    ));

    items.add(Text(
      RSID.npcv_8.text,//"是否启用",
      style: TextStyle(
        fontSize: 18,
        color: Colors.white,
      ),
    ));

    items.add(Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: JfText(
            enable: false,
            textAlign: TextAlign.center,
            data: Enable ? RSID.npcv_9.text : RSID.npcv_10.text ,//"启用" : "暂停",
            autofocus: false,
            maxLines: 1,
            minLines: 1,
            maxLength: 20,
            fontsize: 16,
            onChanged: (text, classtype) {
              // Fee = double.parse(text.toString().trim());
            },
          ),
        ),
        Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 0, 10, 20),
              alignment: Alignment.centerRight,
              child: Switch(
                value: Enable,
                onChanged: (value) {
                  Enable = value;
                  setState(() {});
                },
                activeTrackColor: ResColor.o_1,
                activeColor: ResColor.white,
                inactiveTrackColor: Colors.grey,
              ),
            )),
      ],
    ));

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 200),
      margin: EdgeInsets.fromLTRB(30, 45, 30, 100),
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
  }

  bool checkParams() {
    if (StringUtils.isEmpty(Name)) {
      showToast(RSID.npcv_2.text);//"请输入名称");
      return false;
    }
    if (StringUtils.isEmpty(Description)) {
      showToast(RSID.npcv_4.text);//"请输入描述");
      return false;
    }
    if (StringUtils.isEmpty(FeeAddress)) {
      showToast(RSID.npcv_6.text);//"请输入地址");
      return false;
    }
    if (Fee != null && 0 <= Fee && Fee < 1) {
      showToast(RSID.npcv_11.text);//"请设置抽成比例");
      return false;
    }
    return true;
  }

  onClickCreate() {
    if (checkParams() != true) return;

    BottomDialog.simpleAuth(context, AccountMgr().currentAccount.password, (value) async {
      showLoadDialog("", backClose: false, touchOutClose: false);

      HttpJsonRes hjr = await ApiPool.pool_CreateOrUpdate(
        Name: Name.trim(),
        Description: Description.trim(),
        FeeAddress: FeeAddress.trim(),
        Enable: Enable,
        Fee: Fee_d,
      );


      closeLoadDialog();

      if (hjr.code == 0) {

        if(widget.pool==null)
        {
          showToast(RSID.npcv_12.text);//创建成功
        }else{
          showToast(RSID.npcv_13.text);//"已保存");

          widget.pool.Name= Name.trim();
          widget.pool.Description= Description.trim();
          widget.pool.FeeAddress= FeeAddress.trim();
          widget.pool.Enable= Enable;
          widget.pool.Fee= Fee_d.toString();
        }

        finish(true);
      } else {
        showToast(hjr.msg);
      }
    });
  }
}
