class Amounts {
  String AmountIn = "";
  String AmountOut = "";

  double AmountIn_d = 0;
  double AmountOut_d = 0;

  String tokenA,tokenB;

  Amounts();

  Amounts.fromJson(Map<String, dynamic> json) {
    try {
      AmountIn = json["AmountIn"] ?? "0";
      AmountOut = json["AmountOut"] ?? "0";
      AmountIn_d = double.parse(AmountIn);
      AmountOut_d = double.parse(AmountOut);
    } catch (e) {
      print(e);
    }
  }
}
