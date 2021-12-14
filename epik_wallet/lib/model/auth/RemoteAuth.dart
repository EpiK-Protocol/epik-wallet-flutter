import 'dart:convert';

import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/string_utils.dart';

class RemoteAuth
{
  static final int code_version = 1;

  //{"v":1,"t":"sign","s":"bls","p":"plaintext","c":"https://callbackurl"}
  int v = 0; //"v":1,
  String t; //"sign" 、 "deal"
  String s; // "bls" 目前只支持bls

  //t=sign时
  String p; //"plaintext",
  String c; // "https://callbackurl",

  //t=deal时 用 epik_wallet_signAndSendMessage签名
  Map<String,dynamic> m; // {"to":"f05","value":"0","method":1,"params":"asdfasdfasdf"}

  // String type;//":"bls",     s
  // String plain;//":"base64", p
  // String callback;//":"url"  c

 RemoteAuth();

 bool get isSign
 {
   return t=="sign";
 }
  bool get isDeal
  {
    return t=="deal";
  }

 RemoteAuth.fromJson(Map<String,dynamic> json)
 {
   parseJson(json);
 }

 parseJson(Map<String,dynamic> json)
 {
   try {
     // type=json["type"];
     // plain=json["plain"];
     // callback=json["callback"];

     v= StringUtils.parseInt(json["v"], 0);//  1
     t = StringUtils.parseString(json["t"], null);//"sign"  "deal"
     s=StringUtils.parseString(json["s"], null);// "bls"

     if(isSign)
     {
       p = StringUtils.parseString(json["p"], null);// "base64文本"
       c = StringUtils.parseString(json["c"], null);// callback地址
     }else if(isDeal)
     {
       m = json["m"];
     }

   } catch (e, s) {
     print(s);
   }
 }

 bool get checkData{

   if(s=="bls")
   {
     if(isSign)
     {
       try {
         base64.decode(p);//base64.decode(ra.plain);
       } catch (e, s) {
         return false;
       }
       return StringUtils.isNotEmpty(p) && StringUtils.isNotEmpty(c);
     }else if(isDeal)
     {
       return m!=null && m.length>0;
     }
   }

   return false;
 }

 bool get hasCallback{
   return StringUtils.isNotEmpty(c);
 }

 static RemoteAuth fromString(jsontext){
   Dlog.p("RemoteAuth","jsontext=$jsontext");
   if(jsontext!=null && jsontext is String)
   {
     String data = jsontext.toString().trim();
     if(data.length>0 && data.startsWith("{") && data.endsWith("}"))
     {
       try{
         Map<String,dynamic> json = jsonDecode(data);
         RemoteAuth ra = RemoteAuth.fromJson(json);
         if(ra.checkData)
           return ra;
       }catch(e,s){
         print(e);
       }
     }
   }
   return null;
 }

}