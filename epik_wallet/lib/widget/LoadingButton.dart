import 'package:epikwallet/utils/ClickUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoadingButton extends StatefulWidget {
  double width, height;
  EdgeInsets margin, padding;
  Function(LoadingButton lbtn) onclick;
  Color color_bg;
  Color disabledColor;
  Color highlightColor;
  Color splashColor;
  BorderSide side;
  String text;
  TextStyle textstyle;
  double progress_size;
  Color progress_color;
  BorderRadius bg_borderradius;
  bool loading;

  ///防止双击连点
  bool preventDoubleClick;

  LoadingButton({
    Key key,
    this.text = "",
    this.textstyle = const TextStyle(
      fontSize: 16,
      color: Colors.white,
      fontWeight: FontWeight.w400,
      height: 1.2,
    ),
    this.width = double.infinity,
    this.height,
    this.margin = const EdgeInsets.fromLTRB(0, 0, 0, 0),
    this.padding = const EdgeInsets.fromLTRB(0, 0, 0, 0),
    this.onclick,
    this.color_bg = Colors.lightBlue,
    this.progress_size = 30,
    this.progress_color = Colors.white,
    this.bg_borderradius,
    this.loading = false,
    this.side = BorderSide.none,
    this.disabledColor = null,
    this.highlightColor= Colors.white24,
    this.splashColor=Colors.white24,
    this.preventDoubleClick = true,
  })
      : super(key: key)
  {
    if (bg_borderradius == null) {
      bg_borderradius = BorderRadius.circular(20.0);
    }
  }

  @override
  State<StatefulWidget> createState() {
    return LoadingButtonState();
  }

  setLoading(bool isloading)
  {
    this.loading=isloading;
    if(key!=null && key is GlobalKey)
    {
      (key as GlobalKey).currentState?.setState(() {
      });
    }
  }
}

class LoadingButtonState extends State<LoadingButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      // padding: widget.padding,
      child: FlatButton(
        // padding: EdgeInsets.all(0),
        padding: widget.padding,
        onPressed: (widget.loading == false && widget.onclick != null)
            ? () {
                if (widget.preventDoubleClick == true &&
                    ClickUtil.isFastDoubleClick()) {
                  // print("cccmax 防止双击连点");
                  return;
                }
                widget.onclick(widget);
              }
            : null,
        color: widget.color_bg,
        disabledColor: widget.disabledColor,
        highlightColor: widget.highlightColor,
        splashColor:widget.splashColor,
        shape: RoundedRectangleBorder(
            borderRadius: widget.bg_borderradius, side: widget.side),
        child: widget.loading == true
            ? Container(
                width: widget.progress_size,
                height: widget.progress_size,
                padding: EdgeInsets.all(2),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(widget.progress_color),
                ),
              )
            : Container(
                // height: 30,
                alignment: Alignment.center,
                child: Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  style: widget.textstyle,
                ),
              ),
      ),
    );
  }
}
