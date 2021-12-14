import 'package:epikwallet/utils/JsonUtils.dart';

class MinerCoinbaseList {
  // {"code":{"code":0,"message":"OK"},"coinbased":["f0509794"],"pledged":null}

  ///用户会收到收益的矿机
  List<String> coinbased;

  ///用户只参与抵押的矿机
  List<String> pledged;

  MinerCoinbaseList();

  MinerCoinbaseList.from(Map<String, dynamic> json) {
    try {
      List _coinbased = JsonArray.obj2List(json["coinbased"], def: []);
      coinbased = List.from(_coinbased);

      List _pledged = JsonArray.obj2List(json["pledged"], def: []);
      pledged = List.from(_pledged);
    } catch (e) {
      print(e);
    }
  }

  bool get hasCoinbased {
    if (coinbased != null && coinbased.length > 0) return true;
    return false;
  }

  bool get haspledged {
    if (pledged != null && pledged.length > 0) return true;
    return false;
  }

  bool get hasData {
    return hasCoinbased || haspledged;
  }

  bool containsMinerid(String minerid) {
    bool ret = false;
    if (hasCoinbased) {
      ret = coinbased.contains(minerid);
    }
    if (ret == false && haspledged) {
      ret = pledged.contains(minerid);
    }
    print("containsMinerid $minerid  $ret");
    print("containsMinerid  $coinbased");
    print("containsMinerid  $pledged");
    return ret;
  }
}
