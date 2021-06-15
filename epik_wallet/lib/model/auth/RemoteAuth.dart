import 'dart:convert';

import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/string_utils.dart';

class RemoteAuth
{
 String type;//":"bls",
 String plain;//":"base64",
 String callback;//":"url"

 RemoteAuth();

 RemoteAuth.fromJson(Map<String,dynamic> json)
 {
   parseJson(json);
 }

 parseJson(Map<String,dynamic> json)
 {
   try {
     type=json["type"];
     plain=json["plain"];
     callback=json["callback"];
   } catch (e, s) {
     print(s);
   }
 }

 bool get hasData{
   return StringUtils.isNotEmpty(type) && StringUtils.isNotEmpty(plain) ;
 }

 bool get hasCallback{
   return StringUtils.isNotEmpty(callback);
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
         if(ra.hasData)
           return ra;
       }catch(e,s){
         print(e);
       }
     }
   }
   return null;
 }

}