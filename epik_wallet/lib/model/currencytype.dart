import 'package:epikwallet/logic/api/serviceinfo.dart';
import 'package:epikwallet/model/prices.dart';
import 'package:epikwallet/utils/string_utils.dart';

enum CurrencySymbol {
  AIEPK,
  EPKerc20,
  ETH,
  USDT,
  EPKbsc,
  BNB,
  USDTbsc,
}

extension CurrencySymbolEx on CurrencySymbol {
  String get iconUrl {
    switch (this) {
      case CurrencySymbol.AIEPK:
        return "assets/img/ic_epk_2.png";
      case CurrencySymbol.EPKerc20:
        return "assets/img/ic_epk_2.png";
      case CurrencySymbol.ETH:
        return "assets/img/ic_eth_2.png";
      case CurrencySymbol.USDT:
        return "assets/img/ic_usdt_2.png";
      case CurrencySymbol.EPKbsc:
        return "assets/img/ic_epk_2.png";
      case CurrencySymbol.BNB:
        return "assets/img/ic_bnb.png";
      case CurrencySymbol.USDTbsc:
        return "assets/img/ic_usdt_2.png";
      default:
        return "";
    }
  }

  String get codename {
    String aa = toString().replaceAll("CurrencySymbol.", "");
    return aa;
  }

  static CurrencySymbol fromCodeName(String codename)
  {
    for(CurrencySymbol cs in CurrencySymbol.values)
    {
      if(codename == cs.codename)
        return cs;
    }
  }

  String get symbol {
    String aa = toString().replaceAll("CurrencySymbol.", "");
    switch (aa) {
      case "EPKerc20":
        aa = "AIEPK(ERC20)";//"ERC20-EPK";
        break;
      case "EPKbsc":
        aa = "BSC-EPK";
        break;
      case "USDTbsc":
        aa= "USDT";
        break;
    }
    return aa;
  }

  String get symbolToNetWork {
    String aa = toString().replaceAll("CurrencySymbol.", "");
    // if (aa == "EPKerc20") aa = "EPK";
    switch (aa) {
      case "EPKerc20":
        aa = "AIEPK(ERC20)";//"ERC20-EPK";
        break;
      case "EPKbsc":
        aa = "BSC-EPK";
        break;
      case "USDTbsc":
        aa= "USDT";
        break;
    }
    return aa;
  }

  bool get isToken{
    switch (this) {
      case CurrencySymbol.EPKerc20:
      case CurrencySymbol.USDT:
      case CurrencySymbol.EPKbsc:
      case CurrencySymbol.USDTbsc:
        return true;
    }
    return false;
  }

  CurrencySymbol get networkType {
    // if (this == CurrencySymbol.EPK) return CurrencySymbol.EPK;
    switch (this) {
      case CurrencySymbol.AIEPK:
        return CurrencySymbol.AIEPK;
      case CurrencySymbol.EPKerc20:
      case CurrencySymbol.ETH:
      case CurrencySymbol.USDT:
        return CurrencySymbol.ETH;
      case CurrencySymbol.EPKbsc:
      case CurrencySymbol.BNB:
      case CurrencySymbol.USDTbsc:
        return CurrencySymbol.BNB;
    }
  }

  //获取代币的合约地址
   String get tokenContractaddress{
    switch(this)
    {
      case CurrencySymbol.EPKerc20:
        return ServiceInfo.TOKEN_ADDRESS_ETH_EPK;
      case CurrencySymbol.USDT:
        return ServiceInfo.TOKEN_ADDRESS_ETH_USDT;
      case CurrencySymbol.EPKbsc:
        return ServiceInfo.TOKEN_ADDRESS_BSC_EPK;
      case CurrencySymbol.USDTbsc:
        return ServiceInfo.TOKEN_ADDRESS_BSC_USDT;
    }
    return null;
  }

  String get networkTypeName {
    // if (this == CurrencySymbol.EPK) return CurrencySymbol.EPK;
    switch (this) {
      case CurrencySymbol.AIEPK:
        return "EpiK";
      case CurrencySymbol.EPKerc20:
      case CurrencySymbol.ETH:
      case CurrencySymbol.USDT:
        return "Ethereum";
      case CurrencySymbol.EPKbsc:
      case CurrencySymbol.BNB:
      case CurrencySymbol.USDTbsc:
        return "BSC"; //Binance Smart Chain
    }
  }

  // String get netAddressType
  // {
  //   switch (this) {
  //     case CurrencySymbol.EPK:
  //       return "EpiK";
  //     case CurrencySymbol.EPKerc20:
  //     case CurrencySymbol.ETH:
  //     case CurrencySymbol.USDT:
  //     case CurrencySymbol.EPKbsc:
  //     case CurrencySymbol.BNB:
  //       return "Ethereum";
  //
  //   }
  // }

  static CurrencySymbol getNetworkTypeByName(String networkname){
    if(networkname == "ETH")
    {
      return CurrencySymbol.ETH;
    }
    for(CurrencySymbol cs in CurrencySymbol.values)
    {
      if(cs.networkType.networkTypeName == networkname)
      {
        return cs.networkType;
      }
    }
    return null;
  }


  String get networkTypeNorm {
    // if (this == CurrencySymbol.EPK) return CurrencySymbol.EPK;
    switch (this) {
      case CurrencySymbol.AIEPK:
        return "EpiK";
      case CurrencySymbol.EPKerc20:
      case CurrencySymbol.ETH:
      case CurrencySymbol.USDT:
        return "ERC20";
      case CurrencySymbol.EPKbsc:
      case CurrencySymbol.BNB:
      case CurrencySymbol.USDTbsc:
        return "BEP20(BSC)"; //Binance Smart Chain
    }
  }

  String get netNamePatch
  {
    switch (this) {
      case CurrencySymbol.USDT:
        return networkTypeName;
      case CurrencySymbol.USDTbsc:
        return networkTypeName; //Binance Smart Chain
      case CurrencySymbol.AIEPK:
      case CurrencySymbol.EPKerc20:
      case CurrencySymbol.ETH:
      case CurrencySymbol.EPKbsc:
      case CurrencySymbol.BNB:
      default:
        return "";
    }
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
        case CurrencySymbol.AIEPK:
          return find(priceslist, "EPK") ?? Prices(price: "0", dPrice: 0);
        case CurrencySymbol.EPKerc20:
        case CurrencySymbol.EPKbsc: //return find(priceslist, "BSC-EPK") ?? Prices(price: "0", dPrice: 1);
          return find(priceslist, "ERC20_EPK") ?? Prices(price: "0", dPrice: 0);
        case CurrencySymbol.ETH:
          return find(priceslist, "ETH") ?? Prices(price: "0", dPrice: 0);
        case CurrencySymbol.USDT:
          return find(priceslist, "USDT") ?? Prices(price: "1", dPrice: 1);
        case CurrencySymbol.BNB:
          return find(priceslist, "BNB") ?? Prices(price: "0", dPrice: 1);
        case CurrencySymbol.USDTbsc:
          return find(priceslist, "USDT") ?? Prices(price: "1", dPrice: 1);
      }
    }

    return Prices(price: "0", dPrice: 0);
  }
}
