
import 'package:epikwallet/base/buildConfig.dart';
import 'package:flutter/foundation.dart';

class Dlog
{
  static bool logOpen= BuildConfig.isDebug;


  static int size=900;

  static p(String tag, String log,{bool printAll = false})
  {
    if(logOpen)
    {
      if(!printAll || (log?.length??0)<size)
      {
        print("$tag: $log");
      }else{
        if(log!=null && log?.length>size)
        {
          int l = (log.length/size).toInt();
          l+= (log.length%size)>0 ? 1:0;
          for(int i = 0; i < l;i++)
          {
            int start = i*size;
            int end = start+size;
            if(end>log.length)
              end=log.length;
            String t = log.substring(start,end);
            print("$tag: $t");
          }
        }
      }
    }
  }
}