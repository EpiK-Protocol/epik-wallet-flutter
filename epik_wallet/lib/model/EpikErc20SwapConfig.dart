import 'package:epikwallet/utils/string_utils.dart';

class EpikErc20SwapConfig {
  String erc20_address; //":"0x943FfcA1116F83983DA4275493d900176E4BfCD3",
  String
      epik_address; //":"f3rxzadet3wfoxecn7hxjhs7ztpugks2nhqxmi6oogkgxxvkdai5ojrpvuerlds4zpnllsvz2pshxg4za2eeiq",
  String erc20_fee; //":"5",
  String epik_fee; //":"1",
  double min_erc20_swap=0; //":"10",
  double max_erc20_swap=0; //":"100000",
  double min_epik_swap=0; //":"10",
  double max_epik_swap=0; //":"100000"

  EpikErc20SwapConfig();

  EpikErc20SwapConfig.fromJson(Map<String ,dynamic>json){
    try {
      erc20_address=json["erc20_address"];
      epik_address=json["epik_address"];
      erc20_fee=json["erc20_fee"];
      epik_fee=json["epik_fee"];
      min_erc20_swap = StringUtils.parseDouble(json["min_erc20_swap"], 0);
      max_erc20_swap = StringUtils.parseDouble(json["max_erc20_swap"], 0);
      min_epik_swap = StringUtils.parseDouble(json["min_epik_swap"], 0);
      max_epik_swap = StringUtils.parseDouble(json["max_epik_swap"], 0);
    } catch (e, s) {
      print(s);
    }
  }
}
