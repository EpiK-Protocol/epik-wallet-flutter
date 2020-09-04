enum CurrencySymbol {
  tEPK,
  EPK,
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
      case CurrencySymbol.EPK:
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
    if(aa=="EPK")
      aa = "ERC20-EPK";
    return aa;
  }

  CurrencySymbol get networkType{
    if(this != CurrencySymbol.tEPK)
      return CurrencySymbol.ETH;
    return null;
  }
}
