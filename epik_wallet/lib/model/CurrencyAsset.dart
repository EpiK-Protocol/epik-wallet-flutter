import 'package:epikwallet/utils/string_utils.dart';

class CurrencyAsset {
  String type = "";
  String asset_id = "";
  String chain_id = "";
  String symbol = "";
  String name = "";
  String icon_url = "";
  String balance = "0";
  double price_btc = 0;
  double price_usd = 0;
  double change_btc = 0;
  double change_usd = 0;
  String asset_key = "";
  double confirmations = 0;
  double capitalization = 0;

  double getBalanceDouble() {
    double b = StringUtils.parseDouble(balance.replaceAll(",", ""), 0);
    return b;
  }

  double getUsdValue() {
    return getBalanceDouble() * price_usd;
  }
}
