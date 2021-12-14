import 'package:decimal/decimal.dart';

class DecimalUtils
{
  // addition 加法  a+b
  static double addition(a,b,{double def=0})
  {
    try{
      return (Decimal.parse(a.toString()) + Decimal.parse(b.toString())).toDouble();
    }catch(e)
    {
      print(e);
    }
    return def;
  }

  // subtraction 减法 a-b
  static double subtraction(a,b,{double def=0})
  {
    try{
      return (Decimal.parse(a.toString()) - Decimal.parse(b.toString())).toDouble();
    }catch(e)
    {
      print(e);
    }
    return def;
  }

  // multiplication乘法 a*b
  static double multiplication(a,b,{double def=0})
  {
    try{
      return (Decimal.parse(a.toString()) * Decimal.parse(b.toString())).toDouble();
    }catch(e)
    {
      print(e);
    }
    return def;
  }

  // division 除法 a/b
  static double division(a,b,{double def=0})
  {
    try{
      return (Decimal.parse(a.toString()) / Decimal.parse(b.toString())).toDouble();
    }catch(e)
    {
      print(e);
    }
    return def;
  }

 // remainder 余数  a%b
  static double remainder(a,b,{double def=0})
  {
    try{
      return (Decimal.parse(a.toString()) % Decimal.parse(b.toString())).toDouble();
    }catch(e)
    {
      print(e);
    }
    return def;
  }

}