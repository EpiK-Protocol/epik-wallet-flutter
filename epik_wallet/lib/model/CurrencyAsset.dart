import 'package:epikwallet/model/currencytype.dart';
import 'package:epikwallet/utils/string_utils.dart';

class CurrencyAsset {
  String symbol = "";
  String name = "";
  String type = "";
  String icon_url = "";
  String balance = "0";
  CurrencySymbol cs;
  CurrencySymbol networkType;

  double price_usd = 0;
  String price_usd_str = "0";

  String asset_id = "";
  String chain_id = "";
  double price_btc = 0;
  double change_btc = 0;
  double change_usd = 0;
  String asset_key = "";
  double confirmations = 0;
  double capitalization = 0;

  CurrencyAsset({
    this.symbol = "",
    this.name = "",
    this.type = "",
    this.icon_url = "",
    this.balance = "",
    this.networkType,
    this.price_usd_str,
    this.price_usd,
    this.cs,
    this.change_usd,
  });

  double getBalanceDouble() {
    double b = StringUtils.parseDouble(balance?.replaceAll(",", ""), 0);
    return b;
  }

  double getUsdValue() {
    return getBalanceDouble() * (price_usd??0);
  }
}
