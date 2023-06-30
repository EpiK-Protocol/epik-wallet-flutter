import 'package:epikwallet/main.dart';
import 'package:flutter/cupertino.dart';

class AppRestartView extends StatefulWidget {
  final Widget child;

  AppRestartView({Key key, @required this.child}) : super(key: key);

  _AppRestartViewState createState() => _AppRestartViewState();

  static restart(BuildContext context) {
    print(["restart",context]);
    context.findAncestorStateOfType<_AppRestartViewState>().restartApp();
  }
}

class _AppRestartViewState extends State<AppRestartView> {
  Key _key = UniqueKey();

  void restartApp() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}
