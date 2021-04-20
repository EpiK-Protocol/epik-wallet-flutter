import 'package:epikwallet/model/prices.dart';

enum CurrencySymbol {
  EPK,
  EPKerc20,
  ETH,
  USDT,
}

extension aaaa on CurrencySymbol {
  String get iconUrl {
    switch (this) {
      case CurrencySymbol.EPK:
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

  String get symbol {
    String aa = toString().replaceAll("CurrencySymbol.", "");
    if (aa == "EPKerc20") aa = "ERC20-EPK";
    return aa;
  }

  String get symbolToNetWork {
    String aa = toString().replaceAll("CurrencySymbol.", "");
    if (aa == "EPKerc20") aa = "EPK";
    return aa;
  }

  CurrencySymbol get networkType {
    if (this != CurrencySymbol.EPK) return CurrencySymbol.ETH;
    return null;
  }

  Prices getPriceUSD(List<Prices> priceslist) {
    Prices find(List<Prices> list, String symbol) {
      for (Prices prices in list) {
        if (prices.id == symbol) {
          return prices;
        }
      }
      return null;
    }

    if (priceslist != null) {
      switch (this) {
        case CurrencySymbol.EPK:
          return Prices(price: "0", dPrice: 0);
        case CurrencySymbol.EPKerc20:
          return find(priceslist, "ERC20_EPK") ?? Prices(price: "0", dPrice: 0);
        case CurrencySymbol.ETH:
          return find(priceslist, "ETH") ?? Prices(price: "0", dPrice: 0);
        case CurrencySymbol.USDT:
          return find(priceslist, "USDT") ??Prices(price: "1", dPrice: 1);
      }
    }

    return Prices(price: "0", dPrice: 0);
  }
}
