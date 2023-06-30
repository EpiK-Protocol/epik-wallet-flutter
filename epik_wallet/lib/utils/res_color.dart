import 'package:flutter/painting.dart';

class ResColor {
  static const Color black = Color(0xFF000000);
  static const Color black_0 = Color(0x00000000);
  static const Color black_10 = Color(0x19000000);
  static const Color black_20 = Color(0x33000000);
  static const Color black_30 = Color(0x4c000000);
  static const Color black_40 = Color(0x66000000);
  static const Color black_50 = Color(0x7f000000);
  static const Color black_60 = Color(0x99000000);
  static const Color black_70 = Color(0xb2000000);
  static const Color black_80 = Color(0xcc000000);
  static const Color black_90 = Color(0xe6000000);

  static const Color white = Color(0xFFffffff);
  static const Color white_0 = Color(0x00ffffff);
  static const Color white_10 = Color(0x19ffffff);
  static const Color white_20 = Color(0x33ffffff);
  static const Color white_30 = Color(0x4cffffff);
  static const Color white_40 = Color(0x66ffffff);
  static const Color white_50 = Color(0x7fffffff);
  static const Color white_60 = Color(0x99ffffff);
  static const Color white_70 = Color(0xb2ffffff);
  static const Color white_80 = Color(0xccffffff);
  static const Color white_90 = Color(0xe6ffffff);

  static const Color main = Color(0xff10052f);
  static const Color main_1 = Color(0xff1e183c);
  static const Color main_2 = Color(0x7f10052f);
  static const Color progress = Color(0xffF28955);//Color(0xff10052f);

  static const Color b_1 = Color(0xff141414);
  static const Color b_2 = Color(0xff1d1d1d);
  static const Color b_3 = Color(0xff1f1f1f);
  static const Color b_4 = Color(0xff252525);
  static const Color b_5 = Color(0xff333333);


  static const Color o_1 = Color(0xffF7AB00);

  static const Color r_1 = Color(0xffF24F30);
  static const Color g_1 = Color(0xff4ADE2C);
  static const Color blue_1=Color(0xff39A7FF);

  static const Color warning_bg=Color(0xff331F1F);
  static const Color warning_text=Color(0xffF24F30);

  static const LinearGradient lg_1 = LinearGradient(
    colors: [Color(0xffF2C17C), Color(0xffD1851A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lg_1_1 = LinearGradient(
    colors: [Color(0xffF2C17C), Color(0xffD1851A)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient lg_2 = LinearGradient(
    colors: [Color(0xff4CC8D4), Color(0xff4698F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lg_3 = LinearGradient(
    colors: [Color(0xffE6AC5B), Color(0xffCC5252)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lg_4 = LinearGradient(
    colors: [Color(0xffF28955), Color(0x00F28955)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient lg_5 = LinearGradient(
    colors: [Color(0xffF576A4), Color(0xffA870F5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient lg_6 = LinearGradient(
    colors: [Color(0xffF2C17C), Color(0x00F2C17C)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient lg_7 = LinearGradient(
    colors: [Color(0xff555555), Color(0xff444444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lg_8 = LinearGradient(
    colors: [Color(0x00d0a14a),Color(0x10d0a14a), Color(0x42d0a14a)],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );


  static const BoxShadow shadow_main_bar =  BoxShadow(
    color: black_30,//Color(0x28000000),
    offset:Offset(0,-2),
    blurRadius:6,
    spreadRadius: 0,
  );
}
