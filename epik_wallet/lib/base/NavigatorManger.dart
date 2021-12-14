
import '_base_widget.dart';

class NavigatorManger {
  List<String> _activityStack = new List<String>();

  NavigatorManger._internal();

  static NavigatorManger _singleton = new NavigatorManger._internal();

  //工厂模式
  factory NavigatorManger() => _singleton;
  void addWidget(BaseWidgetState widgetName) {
    _activityStack.add(widgetName.getWidgetName());
  }

  void removeWidget(BaseWidgetState widgetName) {
    _activityStack.remove(widgetName.getWidgetName());
  }

  bool isTopPage(BaseWidgetState widgetName) {
    if (_activityStack == null) {
      return false;
    }
    try {
      return widgetName.getWidgetName() ==
          _activityStack[_activityStack.length - 1];
    } catch (exception) {
      return false;
    }
  }

  bool isSecondTop(BaseWidgetState widgetName) {
    if (_activityStack == null) {
      return false;
    }
    try {
      return widgetName.getWidgetName() ==
          _activityStack[_activityStack.length - 2];
    } catch (exception) {
      return false;
    }
  }
}
