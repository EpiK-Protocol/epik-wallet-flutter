import 'package:epikwallet/model/prices.dart';

enum CurrencySymbol {
  tEPK,
  EPKerc20,
  ETH,
  USDT,
}

extension aaaa on CurrencySymbol
{
  String get iconUrl {
    switch(this)
    {
      case CurrencySymbol.tEPK:
        return "assets/img/ic_epk.png";
      case CurrencySymbol.EPKerc20:
        return "assets/img/ic_epk.png";
      case CurrencySymbol.ETH:
        return "assets/img/ic_eth.png";
      case CurrencySymbol.USDT:
        return "assets/img/ic_usdt.png";
      default:
        return "";
    }
  }

  String get symbol
  {
    String aa = toString().replaceAll("CurrencySymbol.", "");
    if(aa=="EPKerc20")
      aa = "EPK-ERC20";
    return aa;
  }

  String get symbolToNetWork
  {
    String aa = toString().replaceAll("CurrencySymbol.", "");
    if(aa=="EPKerc20")
      aa = "EPK";
    return aa;
  }

  CurrencySymbol get networkType{
    if(this != CurrencySymbol.tEPK)
      return CurrencySymbol.ETH;
    return null;
  }

  Prices getPriceUSD(List<Prices> priceslist)
  {
    Prices find(List<Prices> list,String symbol)
    {
      for(Prices prices in list)
      {
        if(prices.id == symbol)
        {
          return prices;
        }
      }
      return null;
    }

    if(priceslist!=null)
    {
      switch(this)
      {
        case CurrencySymbol.tEPK:
          return Prices(price: "0",dPrice: 0);
        case CurrencySymbol.EPKerc20:
          return Prices(price: "0",dPrice: 0);
        case CurrencySymbol.ETH:
          return find(priceslist, "ETH") ?? Prices(price: "0",dPrice: 0);
        case CurrencySymbol.USDT:
          return Prices(price: "1",dPrice: 1);
      }
    }

    return Prices(price: "0",dPrice: 0);
  }
}
