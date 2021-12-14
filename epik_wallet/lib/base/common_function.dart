import 'dart:async';

import 'package:epikwallet/base/_base_widget.dart';
import 'package:epikwallet/dialog/loading_dialog.dart';
import 'package:epikwallet/localstring/localstringdelegate.dart';
import 'package:epikwallet/localstring/resstringid.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/res_color.dart';
import 'package:epikwallet/utils/toast/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
// import 'package:provider/provider.dart';

import 'buildConfig.dart';

abstract class BaseFuntion {
  State _stateBaseFunction;
  BuildContext _contextBaseFunction;

  bool isTopBarShow = true;
  bool isAppBarShow = true;

  bool isTopFloatWidgetShow = false;

  bool isErrorWidgetShow = false;

  static Color titlebarColor = Colors.transparent;//Colors.white;

  Color topBarColor = titlebarColor; // Colors.blue;
  Color appBarColor = titlebarColor; // Colors.blue; //3b92f7
  Color _appBarContentColor = Colors.white;
  Color navigationColor = ResColor.b_1;//Colors.white;//Colors.white

  Color bodyBackgroundColor =ResColor.b_1;// Colors.white;

  Color proressBackgroundColor = ResColor.b_1;
  Color errorBackgroundColor = ResColor.b_1;
  Color emptyBackgroundColor = ResColor.b_1;

  double _appBarCenterTextSize = 20;
  String _appBarTitle;

  String _appBarRightTitle;
  double _appBarRightTextSize = 15.0;

  String _errorContentMesage;

  String _errImgPath = null;//"assets/img/ic_content_neterror.png";

  bool _isLoadingWidgetShow = false;

  bool _isEmptyWidgetVisible = false;

  String _emptyWidgetContent;

  String _emptyImgPath = null;// "assets/img/ic_content_empty.png";
  bool _isBackIconShow = true;

  bool get isBackIconShow => _isBackIconShow;

  FontWeight _fontWidget = FontWeight.w400;

  double bottomVsrtical = 0;

  EdgeInsets statelayout_margin = EdgeInsets.fromLTRB(0, 0, 0, 0);

  Color get appBarContentColor=>_appBarContentColor;
  double get appBarCenterTextSize=>_appBarCenterTextSize;
  String get appBarTitle=>_appBarTitle;

  /// false keyboard
  bool resizeToAvoidBottomPadding = false;

  void initBaseCommon(State state) {
    _stateBaseFunction = state;
    _contextBaseFunction = state.context;
    _appBarTitle = BuildConfig.isDebug ? getWidgetName() : "";
    if (BuildConfig.isDebug) {
      _appBarRightTitle = ""; //
    }
  }

  Widget getBaseView(BuildContext context) {
    if (_errorContentMesage == null)
      _errorContentMesage = ResString.get(context, RSID.net_error);
    if (_emptyWidgetContent == null)
      _emptyWidgetContent = ResString.get(context, RSID.content_empty);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: bodyBackgroundColor, //
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              isTopBarShow ? _getBaseTopBar() : _getHolderLWidget(),
              isAppBarShow ? _getBaseAppBar() : _getHolderLWidget(),
              Expanded(
                flex: 1,
                child: Stack(
                  children: <Widget>[
                    _buildProviderWidget(context),
                    isErrorWidgetShow
                        ? _getBaseErrorWidget()
                        : _getHolderLWidget(),
                    _isEmptyWidgetVisible
                        ? _getBaseEmptyWidget()
                        : _getHolderLWidget(),
                    _isLoadingWidgetShow
                        ? _getBassLoadingWidget()
                        : _getHolderLWidget(),
                    isTopFloatWidgetShow
                        ? _getTopFloatWidget()
                        : _getHolderLWidget(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getHolderLWidget() {
    return Container(
      width: 0,
      height: 0,
    );
  }

  Widget _getBaseTopBar() {
    return getTopBar();
  }

  Widget _getBaseAppBar() {
    return getAppBar();
  }

  Widget getTopBar() {
    return Container(
      height: getTopBarHeight(),
      width: double.infinity,
      color: topBarColor,
    );
  }

  Widget getErrorWidget() {
    return Container(
      margin: statelayout_margin,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      color: errorBackgroundColor,//Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: InkWell(
        onTap: () {
          onClickErrorWidget();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if(_errImgPath!=null)
              Image(
                image: AssetImage(_errImgPath),
                width: 150,
                height: 150,
              ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Text(_errorContentMesage,
                  style: TextStyle(
                    fontWeight: _fontWidget,
                    fontSize: 14,
                    color: ResColor.white_60,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  ///点击错误页面后展示内容
  void onClickErrorWidget() {
    onResume(); //
  }

  ///点击无数据页面后展示内容
  void onClickEmptyWidget() {
    onResume(); //
  }

  Widget getLoadingWidget() {
    return Container(
      //错误页面中心可以自己调整
      margin: statelayout_margin,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      color: proressBackgroundColor,//Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child:
            // 圆形进度条
            new CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: new AlwaysStoppedAnimation<Color>(ResColor.progress),
//          backgroundColor: Colors.blue,
//          // value: 0.2,
        ),

//        Container(
//          alignment: Alignment.center,
//          color: Colors.white70,
//          width: 200,
//          height: 200,
//          child: Text("你懂么？~~~"),
//        )
//
      ),
    );
  }

  ///导航栏appBar中间部分 ，不满足可以自行重写
  Widget getAppBarCenter({Color color}) {
    return Text(
      _appBarTitle,
      style: TextStyle(
        fontSize: _appBarCenterTextSize,
        color: color ?? _appBarContentColor,
//        fontWeight: FontWeight.w600,
      ),
    );
  }

  ///导航栏appBar中间部分 ，不满足可以自行重写
  Widget getAppBarRight({Color color}) {
    return Text(
      _appBarRightTitle == null ? "" : _appBarRightTitle,
      style: TextStyle(
        fontSize: _appBarRightTextSize,
        color: color ?? _appBarContentColor,
      ),
    );
  }

  ///导航栏appBar左边部分 ，不满足可以自行重写
  Widget getAppBarLeft({Color color}) {
    return InkWell(
      onTap: clickAppBarBack,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 0 , 20, 0),
        width: 24.0+20+20,
        height: getAppBarHeight(),
        // child: Icon(
        //   OMIcons.arrowBackIos,
        //   color: color ?? _appBarContentColor,
        //   size: 20,
        // ),
        child: Center(
          child: Image.asset("assets/img/ic_back.png",width: 24,height: 24,
          color: color ?? _appBarContentColor,
          ),
        ),
      ),
    );
  }

  void clickAppBarBack() {
    finish();
  }

  void finish<T extends Object>([T result]) {
    if (_stateBaseFunction != null) {
      if (_stateBaseFunction is BaseWidgetState) {
        (_stateBaseFunction as BaseWidgetState).closeInput();
      }
    }
    if (Navigator.canPop(_contextBaseFunction)) {
      print("finish pop $_contextBaseFunction");
      Navigator.pop<T>(_contextBaseFunction, result);
    } else {
      //说明已经没法回退了 ， 可以关闭了
      print("finish $_contextBaseFunction");
      finishDartPageOrApp();
    }
  }

//
//
//  defaultRouteName → String 启动应用程序时嵌入器请求的路由或路径。
//  devicePixelRatio → double 每个逻辑像素的设备像素数。 例如，Nexus 6的设备像素比为3.5。
//  textScaleFactor → double 系统设置的文本比例。默认1.0
//  toString（） → String 返回此对象的字符串表示形式。
//  physicalSize → Size 返回一个包含屏幕宽高的对象，单位是dp
//
//

  ///返回中间可绘制区域，也就是 我们子类 buildWidget 可利用的空间高度
  double getMainWidgetHeight() {
    double screenHeight = getScreenHeight() - bottomVsrtical;

    if (isTopBarShow) {
      screenHeight = screenHeight - getTopBarHeight();
    }
    if (isAppBarShow) {
      screenHeight = screenHeight - getAppBarHeight();
    }

    return screenHeight;
  }

  ///返回屏幕高度
  double getScreenHeight() {
    return MediaQuery.of(_contextBaseFunction).size.height;
  }

  static double topbarheight = 0;

  ///返回状态栏高度
  double getTopBarHeight() {
    topbarheight = MediaQuery.of(_contextBaseFunction).padding.top;
    return topbarheight;
  }

  static final double appbarheight_def = 44;
  double appbarheight = 0;

  ///返回appbar高度，也就是导航栏高度
  double getAppBarHeight() {
    if (appbarheight == 0) appbarheight = appbarheight_def; //kToolbarHeight;
    return appbarheight;
  }

  setAppBarHeight(double h) {
    appbarheight = h;
  }

  ///返回屏幕宽度
  double getScreenWidth() {

    try {
      return MediaQuery.of(_contextBaseFunction).size.width;
    } catch (e, s) {
      print(s);
    }
    return 1;
  }

  Widget _getBaseErrorWidget() {
    return getErrorWidget();
  }

  Widget _getBassLoadingWidget() {
    return getLoadingWidget();
  }

  Widget _getBaseEmptyWidget() {
    return getEmptyWidget();
  }

  Widget _getTopFloatWidget() {
    return getTopFloatWidget();
  }

  Widget getTopFloatWidget() {
    return Container();
  }

  Widget getEmptyWidget() {
    return GestureDetector(
      onTap: () {
        onClickEmptyWidget();
      },
      child: Container(
        //错误页面中心可以自己调整
        margin: statelayout_margin,
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        color: emptyBackgroundColor,//Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if(_emptyImgPath!=null)
                Image(
                  image: AssetImage(_emptyImgPath),
                  fit: BoxFit.cover,
                  width: 150,
                  height: 150,
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Text(_emptyWidgetContent,
                      style: TextStyle(
                        fontWeight: _fontWidget,
                        fontSize: 14,
                        color: ResColor.white_60,
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///关闭最后一个 flutter 页面 ， 如果是原生跳过来的则回到原生，否则关闭app
  void finishDartPageOrApp() {
    SystemNavigator.pop();
  }

  ///导航栏 appBar 可以重写
  Widget getAppBar() {
    return Container(
      height: getAppBarHeight(),
      width: double.infinity,
      color: appBarColor,
      child: Stack(
        alignment: FractionalOffset(0, 0.5),
        children: <Widget>[
          Align(
            alignment: FractionalOffset(0.5, 0.5),
            child: getAppBarCenter(),
          ),
          Align(
            //左边返回导航 的位置，可以根据需求变更
            alignment: FractionalOffset(0, 0.5),
            child: Offstage(
              offstage: !_isBackIconShow,
              child: getAppBarLeft(),
            ),
          ),
          Align(
            alignment: FractionalOffset(0.98, 0.5),
            child: getAppBarRight(),
          ),
        ],
      ),
    );
  }

  ///设置状态栏隐藏或者显示
  void setTopBarVisible(bool isVisible) {
    // ignore: invalid_use_of_protected_member
    if (_stateBaseFunction != null && _stateBaseFunction.mounted) {
      _stateBaseFunction.setState(() {
        isTopBarShow = isVisible;
      });
    }
  }

  ///默认这个状态栏下，设置颜色
  void setTopBarBackColor(Color color) {
    // ignore: invalid_use_of_protected_member
    if (_stateBaseFunction != null && _stateBaseFunction.mounted) {
      _stateBaseFunction.setState(() {
        topBarColor = color == null ? topBarColor : color;
      });
    }
  }

  ///设置导航栏的字体以及图标颜色
  void setAppBarContentColor(Color contentColor) {
    if (contentColor != null) {
      if (_stateBaseFunction != null && _stateBaseFunction.mounted) {
        // ignore: invalid_use_of_protected_member
        _stateBaseFunction.setState(() {
          _appBarContentColor = contentColor;
        });
      }
    }
  }

  ///设置导航栏隐藏或者显示
  void setAppBarVisible(bool isVisible) {
    // ignore: invalid_use_of_protected_member
    if (_stateBaseFunction != null && _stateBaseFunction.mounted) {
      _stateBaseFunction.setState(() {
        isAppBarShow = isVisible;
      });
    }
  }

  ///默认这个导航栏下，设置颜色
  void setAppBarBackColor(Color color) {
    // ignore: invalid_use_of_protected_member
    if (_stateBaseFunction != null && _stateBaseFunction.mounted) {
      _stateBaseFunction.setState(() {
        appBarColor = color == null ? appBarColor : color;
      });
    }
  }

  void setAppBarTitle(String title) {
    _appBarTitle = title;
    if (title != null) {
      if (_stateBaseFunction != null && _stateBaseFunction.mounted) {
        // ignore: invalid_use_of_protected_member
        _stateBaseFunction.setState(() {});
      }
    }
  }

  void setAppBarRightTitle(String title) {
    if (title != null) {
      if (_stateBaseFunction != null && _stateBaseFunction.mounted) {
        // ignore: invalid_use_of_protected_member
        _stateBaseFunction.setState(() {
          _appBarRightTitle = title;
        });
      }
    }
  }

  ///设置错误提示信息
  void setErrorContent(String content) {
    if (content != null) {
      if (_stateBaseFunction != null && _stateBaseFunction.mounted) {
        // ignore: invalid_use_of_protected_member
        _stateBaseFunction.setState(() {
          _errorContentMesage = content;
        });
      }
    }
  }

  ///设置错误页面显示或者隐藏
  void setErrorWidgetVisible(bool isVisible) {
    // ignore: invalid_use_of_protected_member
    if (_stateBaseFunction != null && _stateBaseFunction.mounted) {
      _stateBaseFunction.setState(() {
        if (isVisible) {
          //如果可见 说明 空页面要关闭啦
          _isEmptyWidgetVisible = false;
        }
        // 不管如何loading页面要关闭啦，
        _isLoadingWidgetShow = false;
        isErrorWidgetShow = isVisible;
      });
    }
  }

  ///设置空页面显示或者隐藏
  void setEmptyWidgetVisible(bool isVisible) {
    // ignore: invalid_use_of_protected_member
    if (_stateBaseFunction != null && _stateBaseFunction.mounted) {
      _stateBaseFunction.setState(() {
        if (isVisible) {
          //如果可见 说明 错误页面要关闭啦
          isErrorWidgetShow = false;
        }

        // 不管如何loading页面要关闭啦，
        _isLoadingWidgetShow = false;
        _isEmptyWidgetVisible = isVisible;
      });
    }
  }

  void setLoadingWidgetVisible(bool isVisible) {
    // ignore: invalid_use_of_protected_member
    if (_stateBaseFunction != null && _stateBaseFunction.mounted) {
      _stateBaseFunction.setState(() {
        _isLoadingWidgetShow = isVisible;
        if (isVisible) {
          _isEmptyWidgetVisible = false;
          isErrorWidgetShow = false;
        }
      });
    }
  }

  void closeStateLayout() {
    if (_stateBaseFunction != null && _stateBaseFunction.mounted) {
      _stateBaseFunction.setState(() {
        _isLoadingWidgetShow = false;
        _isEmptyWidgetVisible = false;
        isErrorWidgetShow = false;
      });
    }
  }

  ///设置空页面内容
  void setEmptyWidgetContent(String content) {
    if (content != null) {
      if (_stateBaseFunction != null && _stateBaseFunction.mounted) {
        // ignore: invalid_use_of_protected_member
        _stateBaseFunction.setState(() {
          _emptyWidgetContent = content;
        });
      }
    }
  }

  ///设置错误页面图片
  void setErrorImage(String imagePath) {
    if (imagePath != null) {
      if (_stateBaseFunction != null && _stateBaseFunction.mounted) {
        // ignore: invalid_use_of_protected_member
        _stateBaseFunction.setState(() {
          _errImgPath = imagePath;
        });
      }
    }
  }

  ///设置空页面图片
  void setEmptyImage(String imagePath) {
    if (imagePath != null) {
      if (_stateBaseFunction != null && _stateBaseFunction.mounted) {
        // ignore: invalid_use_of_protected_member
        _stateBaseFunction.setState(() {
          _emptyImgPath = imagePath;
        });
      }
    }
  }

  void setBackIconHinde({bool isHinde = true}) {
    // ignore: invalid_use_of_protected_member
    if (_stateBaseFunction != null && _stateBaseFunction.mounted) {
      _stateBaseFunction.setState(() {
        _isBackIconShow = !isHinde;
      });
    }
  }

  ///初始化一些变量 相当于 onCreate ， 放一下 初始化数据操作
  void onCreate() {}

  ///相当于onResume, 只要页面来到栈顶， 都会调用此方法，网络请求可以放在这个方法
  void onResume() {}

  ///页面被覆盖,暂停
  void onPause() {}

  ///返回UI控件 相当于setContentView()
  Widget buildWidget(BuildContext context);

  ///app切回到后台
  void onBackground() {
    dlog("回到后台");
  }

  ///app切回到前台
  void onForeground() {
    dlog("回到前台");
  }

  bool isDestory = false;

  ///页面注销方法
  void onDestory() {
    dlog("destory");
    _stateBaseFunction = null;
    _contextBaseFunction = null;
    isDestory = true;
  }

  void dlog(String content) {
    Dlog.p(getWidgetName(), content);
  }

  String _widgetname;
  String getWidgetName() {
    if(_widgetname==null)
    {
      String className = _contextBaseFunction?.widget?.toString();
//    print("classname : $className");
      if (className == null) {
        return "NoViewName";
      }
      List<String> array = className.split("-");
      if (array != null && array.length > 0) {
        className = array[0];
      }
      _widgetname= className;
    }
    return _widgetname;
  }

  ///弹吐司
  void showToast(String content,
      {Toast length = Toast.LENGTH_SHORT,
      ToastGravity gravity = ToastGravity.CENTER,
      Color backColor = Colors.black54,
      Color textColor = Colors.white}) {
    ToastUtils.showToast(content,
        length: length,
        gravity: gravity,
        backColor: backColor,
        textColor: textColor);
  }

  ///返回 状态管理组件
  _buildProviderWidget(BuildContext context) {
    // return MultiProvider(
    //     providers: getProvider() == null ? [] : getProvider(),
    //     child: buildWidget(context));
    return buildWidget(context);
  }

  String getClassName() {
    if (_contextBaseFunction == null) {
      return null;
    }
    String className = _contextBaseFunction.toString();
    if (className == null) {
      return null;
    }
    className = className.substring(0, className.indexOf("("));
    return className;
  }

  //可以复写
  // List<SingleChildCloneableWidget> getProvider() {
  //   return null;
  // }

  /// 选择图片  拍照 或者 相册
  static showImagePicker(BuildContext context, callback(PickedFile file)) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(height: 1),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    ImagePicker()
                        .getImage(source: ImageSource.camera)
                        .then((file) {
                      callback(file);
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                          child:
                              Container(height: 45, color: Colors.transparent)),
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                        child: Text(
                            ResString.get(context, RSID.takephoto), //"拍照",
                            style: TextStyle(
                                fontSize: 18, color: Color(0xff666666))),
                      ),
                      Expanded(
                          child:
                              Container(height: 45, color: Colors.transparent)),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: ResColor.black_10,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    ImagePicker()
                        .getImage(source: ImageSource.gallery)
                        .then((file) {
                      callback(file);
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                          child:
                              Container(height: 45, color: Colors.transparent)),
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                        child: Text(
                            ResString.get(context, RSID.gallery), //"相册",
                            style: TextStyle(
                                fontSize: 18, color: Color(0xff666666))),
                      ),
                      Expanded(
                          child:
                              Container(height: 45, color: Colors.transparent)),
                    ],
                  ),
                ),
                Container(height: 1),
              ],
            ),
          );
        });
  }

  bool loadingDialogIsShow = false;

  showLoadDialog(
    String msg, {
    bool touchOutClose = true,
    bool backClose = true,
    VoidCallback onShow,
    VoidCallback onClose,
    int timedShutdown_ms,
  }) {
    loadingDialogIsShow = true;

    LoadingDialog.showLoadDialog(_contextBaseFunction, msg,
            touchOutClose: touchOutClose, backClose: backClose, onShow: onShow)
        .then((value) {
      loadingDialogIsShow = false;
      if (onClose != null) {
        onClose();
      }
    });

    // 定时自动关闭
    if (timedShutdown_ms != null) {
      Timer(Duration(milliseconds: timedShutdown_ms), () {
        if (loadingDialogIsShow) {
          closeLoadDialog();
        }
      });
    }
  }

  closeLoadDialog() {
    print("cloasLoadDialog loadingDialogIsShow=$loadingDialogIsShow");
    if (loadingDialogIsShow) {
      LoadingDialog.cloasLoadDialog(_contextBaseFunction);
    }
  }
}
