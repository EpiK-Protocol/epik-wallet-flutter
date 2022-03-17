class RegExpUtil {
  static RegExp re_float = RegExp(r'\d+\.?\d*');
  static RegExp re_int = RegExp(r'\d+');
  /// 大小写字母和数字
  static RegExp re_azAZ09 = RegExp(r'(\d|[a-z]|[A-Z])+');
  static RegExp re_http = RegExp(r'http.*');
  /// 非中文 但匹配中文标点
  static RegExp re_noChs = RegExp(r'[^\u4e00-\u9fa5]+');
  /// 基础ascii码从0到127 不可见的控制字符
  static RegExp re_ascii_00_7f = RegExp(r'[\u0000-\u007f]+');
  /// 基础ascii码从0到127以外的字符  排除所有不可见控制字符
  static RegExp re_ascii_00_7f_not = RegExp(r'[^\u0000-\u007f]+');

  //字符串末尾的0
  static RegExp re_end_zero = RegExp(r"(?<=.+)(0+)$");
  //字符串开头的0
  static RegExp re_start_zero = RegExp(r"^(0+)(?<=.+)");

  //epik地址规范
  static RegExp re_epik_address = RegExp(r"^f[a-zA-Z0-9]+$");


  //十六进制内容不包含0x
  static RegExp re_hex_no_0x = RegExp("[0-9a-fA-F]+");
  

}
