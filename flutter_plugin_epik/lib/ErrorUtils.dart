class ErrorUtils {
// PlatformException(-1, go.Universe$proxyerror: Out of Balance, , null)
// 匹配 Out of Balance
  static RegExp re_error = RegExp(r'(?<=error:).+(?=, , null)');

  static String parseErrorMsg(e) {
    String ret = e?.toString() ?? "";
    try {
      ret = re_error.stringMatch(ret);
      if(ret==null)
      {
        ret= e?.toString()??"";
      }
    } catch (e, s) {
      print(e);
    }
    return ret;
  }
}
