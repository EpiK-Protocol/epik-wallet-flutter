class UniswapInfo
{
  String USDT="";
  String EPK="";
  String Share ="";
  /// 毫秒
  int LastBlockTime = 0;

  /// 价格 usdt/epk
  double price_USDT_EPK = 0;
  /// 价格 epk/usdt
  double price_EPK_USDT = 0;

  UniswapInfo();

  UniswapInfo.fromJson(Map<String,dynamic> json)
  {
    try{
      USDT =json["USDT"]??"0";
      EPK =json["EPK"]??"0";
      Share =json["Share"]??"0";
      LastBlockTime =(json["LastBlockTime"]??0)*1000;

      double _usdt = double.parse(USDT)??0;
      double _epk = double.parse(EPK)??0;
      if(_usdt!=0 && _epk!=0)
      {
        price_USDT_EPK = _usdt/_epk;
        price_EPK_USDT = _epk/_usdt;
      }

    }catch(e){
      print(e);
    }
  }
}