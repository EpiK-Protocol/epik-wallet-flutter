import 'package:epikwallet/utils/string_utils.dart';

class BountyTaskUser{
  String userid;
  String amount_str;

  double amount;

  BountyTaskUser(this.userid,this.amount_str)
  {
    amount = StringUtils.parseDouble(amount_str, 0);
  }

  String toLineString()
  {
    return "$userid,$amount_str";
  }


  static RegExp regexp = RegExp(r"[^\u4e00-\u9fa5]+,\d+\.?\d*");

  static BountyTaskUser parseInputText(String lineText)
  {
    if(lineText!=null)
    {
      String text = regexp.stringMatch(lineText);
      if(StringUtils.isNotEmpty(text))
      {
        List<String> array = text.split(",");
        if(array!=null && array.length==2)
        {
          String userid = array[0];
          String amount = array[1];
          return BountyTaskUser(userid,amount);
        }
      }
    }
    return null;
  }

  static List<BountyTaskUser> parseLinesData(String linesStr)
  {
    List<BountyTaskUser> ret = [];

    List<String> lines = (linesStr ?? "").split("\n");
    if(lines!=null && lines.length>0)
    {
      for(String line in lines)
      {
        BountyTaskUser  item = parseInputText(line);
        if(item!=null)
        {
          ret.add(item);
        }
      }
    }
    return ret;
  }

  static String makePostData(List<BountyTaskUser> list){

    String ret = "";
    if(list!=null &&list.length>0){
      List<String> liststr = [];
      for(BountyTaskUser item in list)
      {
        liststr.add(item.toLineString());
      }
      ret = liststr.join("\n");
    }
    return ret;
  }

}