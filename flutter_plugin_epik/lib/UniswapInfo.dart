class UniswapInfo {
  String USDT = "";
  String EPK = "";
  String Share = "";
  String UNI = "";

  /// 毫秒
  int LastBlockTime = 0;

  double usdt_d = 0;
  double epk_d = 0;
  double share_d = 0;
  double uni_d = 0;

  /// 价格 usdt/epk
  double price_USDT_EPK = 0;

  /// 价格 epk/usdt
  double price_EPK_USDT = 0;

  UniswapInfo();

  UniswapInfo.fromJson(Map<String, dynamic> json) {
    try {
      USDT = json["USDT"] ?? "0";
      EPK = json["EPK"] ?? "0";
      Share = json["Share"] ?? "0";
      UNI = json["UNI"] ?? "0";
      LastBlockTime = (json["LastBlockTime"] ?? 0) * 1000;

      usdt_d = double.parse(USDT) ?? 0;
      epk_d = double.parse(EPK) ?? 0;
      share_d = double.parse(Share) ?? 0;
      uni_d = double.parse(UNI) ?? 0;

      if (usdt_d != 0 && epk_d != 0) {
        price_USDT_EPK = usdt_d / epk_d;
        price_EPK_USDT = epk_d / usdt_d;
      }
    } catch (e) {
      print(e);
    }
  }
}
