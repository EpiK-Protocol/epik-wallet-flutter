class RegExpUtil {
  static RegExp re_float = RegExp(r'\d+\.?\d*');
  static RegExp re_int = RegExp(r'\d+');
  static RegExp re_azAZ09 = RegExp(r'(\d|[a-z]|[A-Z])+');
  static RegExp re_http = RegExp(r'http.*');
  static RegExp re_noChs = RegExp(r'[^\u4e00-\u9fa5]+');



}
