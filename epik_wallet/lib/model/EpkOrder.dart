import 'package:epikwallet/utils/string_utils.dart';

class EpkOrder {




  int version = 0;
  String from = "";
  String to = "";
  String value = "0";
  double value_d = 0;
  int nonce = 0;
  double gas_limit = 0;
  String gas_price = "0";
  String gas_FeeCap="0";
  String gas_Premium="0";
  int method = 0;
  String params = "";
  int height;
  String time;
  int time_ts=0;//时间戳 秒
  DateTime time_dt;

  Map<String,dynamic> cidmap=null;

  //retrievalfund  storageminer vesting votefund
  String actorName="";
  //Transfer Withdraw Vote  ConfirmUpdateWorkerKey Pledge Rescind  WithdrawBalance  AddPledge
  String MethodName = "";

  // 0 是ok 已完成  其他都是错误失败
  int exitCode=null;
  double gas_Used = 0;

  EpkOrder.fromJsonTepk(Map<String, dynamic> jsonobj) {
    // parseTestNet(jsonobj);
    parseMainNet(jsonobj);
  }

  // Height: 195007,
  // Time: "2020-12-28T04:04:27Z"
  // Message: {
  //   Version: 0,
  //   To: "t04",
  //   From: "t3v2m2rkfoaqcqavhazvuplnqjpn4tgfgrej5r7sjrv27sa2ulftepflbcjakzk3pw3fysrdznz6kw6l4aamja",
  //   Nonce: 0,
  //   Value: "0",
  //   GasPrice: "0",
  //   GasLimit: 10000000,
  //   Method: 2,
  //   Params: "hVgxA66ZqKiuBAUAVODNaPW2CXt5MxTRInsfyTGuvyBqiyzI8qwiSBWVbfbZcSiPLc+Vb1gxA66ZqKiuBAUAVODNaPW2CXt5MxTRInsfyTGuvyBqiyzI8qwiSBWVbfbZcSiPLc+VbwFYJgAkCAESIGrQGoPrwFHUHD3dJiPb7wNPgTXj9l5W/Bgd0mlzZYwYgA=="
  // }
  // parseTestNet(Map<String, dynamic> jsonobj)
  // {
  //   try {
  //     height = jsonobj["Height"];
  //     time = jsonobj["Time"]; //"2020-12-28T04:04:27Z"
  //     time_dt = DateTime.tryParse(time);
  //     Map<String, dynamic> json = jsonobj["Message"];
  //     version = json["Version"] ?? 0;
  //     from = json["From"] ?? "";
  //     to = json["To"] ?? "";
  //     value = json["Value"] ?? "0";
  //     double v = StringUtils.parseDouble(value, 0);
  //     value_d = v / 1000000000000000000;
  //     nonce = json["Nonce"] ?? 0;
  //     gas_limit = StringUtils.parseDouble(json["GasLimit"], 0);
  //     gas_price = json["GasPrice"] ?? "0";
  //     method = json["Method"].toString();
  //     params = json["Params"] ?? "";
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // {
  // "Timestamp": 1617005840,

  // "Message": {
      // "Version": 0,
      // "To": "f3rivtflppymnpcmqn66a4wb6gx3323xcybw7bop72zj5qbi2hyr7hxznxgocxbj4kwqij2vr55kijc6ls7jva",
      // "From": "f3rxzadet3wfoxecn7hxjhs7ztpugks2nhqxmi6oogkgxxvkdai5ojrpvuerlds4zpnllsvz2pshxg4za2eeiq",
      // "Nonce": 21348,
      // "Value": "123450000000000000",
      // "GasLimit": 476268,
      // "GasFeeCap": "100",
      // "GasPremium": "0",
      // "Method": 0,
      // "Params": null,
      // "CID": {
          // "/": "bafy2bzacedjrysucjmo2s4dcrtwdnuful5thsqa4hufrl2dc76pqmfbadcrck"
          // }
  // },

  // "ActorName": "epk/1/account",
  // "Receipt": {
  // "ExitCode": 0,
  // "Return": null,
  // "GasUsed": 468468
  // }
  // }
  parseMainNet(Map<String, dynamic> jsonobj)
  {
    try {

      time_ts = jsonobj["Timestamp"];
      time_dt = DateTime.fromMillisecondsSinceEpoch(time_ts*1000);

      Map<String, dynamic> json = jsonobj["Message"];
      version = json["Version"] ?? 0;
      to = json["To"] ?? "";
      from = json["From"] ?? "";
      nonce = json["Nonce"] ?? 0;
      value = json["Value"] ?? "0";
      value = StringUtils.bigNumDownsizing(value);
      value_d = StringUtils.parseDouble(value, 0);
      gas_limit = StringUtils.parseDouble(json["GasLimit"], 0);
      // gas_price = json["GasPrice"] ?? "0";
      gas_FeeCap = json["GasFeeCap"];
      gas_Premium = json["GasPremium"];
      method = json["Method"];
      params = json["Params"] ?? "";
      cidmap=json["CID"];

      actorName=jsonobj["ActorName"];
      MethodName=jsonobj["MethodName"];

      Map<String, dynamic> j_Receipt = jsonobj["Receipt"];
      if(j_Receipt!=null)
      {
        exitCode = j_Receipt["ExitCode"];
        gas_Used = StringUtils.parseDouble(j_Receipt["GasUsed"], 0);
      }else
        {
          exitCode==null;
          gas_Used==0;
        }
    } catch (e) {
      print(e);
    }
  }

  String get cid{
    String ret="";
    if(cidmap!=null)
    {
      ret = cidmap["/"] ?? "";
    }
    return ret;
  }

  bool isWithdraw = true;

  checkSelf(String selfaddress)
  {
    isWithdraw = from?.toLowerCase()==selfaddress?.toLowerCase();
  }

  String get numDirection
  {
    if(value_d==0)
      return "";
    if(isWithdraw && from==to)
      return "";
    if(isWithdraw)
      return "-";
    else
      return "+";
  }

  String getCodeText(){
    switch(exitCode){
      case 0:return"ok";
      case 1:return"SysErrSenderInvalid";
      case 2:return"SysErrSenderInvalid";
      case 3:return"SysErrInvalidMethod";
      case 4:return"SysErrReserved";
      case 5:return"SysErrInvalidReceiver";
      case 6:return"SysErrInsufficientFunds";
      case 7:return"SysErrOutOfGas";
      case 8:return"SysErrForbidden";
      case 9:return"SysErrorIllegalActor";
      case 10:return"SysErrorIllegalArgument";
      default:return"Error";
    }
  }

  String getCodeTextFilter()
  {
    if(exitCode==null)
      return "Pending";
    if(exitCode==0)
      return "";
    return "Error";
  }
}
