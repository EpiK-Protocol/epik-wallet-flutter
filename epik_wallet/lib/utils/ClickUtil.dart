class ClickUtil{

   static int lastClickTime=0;

   static bool isFastDoubleClick()
  {
    int time = DateTime.now().millisecondsSinceEpoch;
    int timeD = time - lastClickTime;
    // print("cccmax time=$time  lastClickTime=$lastClickTime  timeD=$timeD");
    if (0 <= timeD && timeD < 300)
    {
      return true;
    }
    lastClickTime = time;
    return false;
  }

   static bool isFastDoubleClickT(int t)
  {
    if (t <= 0)
      t = 100;
    int time =  DateTime.now().millisecondsSinceEpoch;
    int timeD = time - lastClickTime;
    if (0 <= timeD && timeD < t)
    {
      return true;
    }
    lastClickTime = time;
    return false;
  }

  static void reset()
  {
    lastClickTime = 0;
  }
}