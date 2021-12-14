import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:aes_crypt/aes_crypt.dart';
import 'package:epikwallet/utils/Dlog.dart';

// padding模式
enum AesPadding {
  PKCS5, //n*n
  PKCS7, //n*n
  ANSI_X_923, // 00*(n-1) + n
  ISO_10126, // 随机*(n-1) + n
  ISO_IEC_7816_4, // 80 + 00*(n-1)
  ZeroPadding, // 00*n
  NoPadding, // 00*n
}

class AesCryptUtil {
  //AES加密 输出base64
  static Future<String> aesEncode(
      Uint8List source, AesMode mode, Uint8List key, Uint8List iv,
      {AesPadding padding = AesPadding.ZeroPadding}) async {
    AesCrypt crypt = AesCrypt();
    //设置 key密码 和 iv偏移量
    crypt.aesSetKeys(key, iv);
    //加密模式
    crypt.aesSetMode(mode);
    //数据补位 padding
    source = addPadding(source, padding); // AesCrypt 这个AES加密需要自己处理padding
    //加密
    Uint8List data = crypt.aesEncrypt(source);
    // 转base64
    String result = base64.encode(data);
    Dlog.p("AES","aesEncode  result:$result  length=${result.length}");
    return result;
  }

  // AES解密
  static Future<String> aesDecode(
      Uint8List source, AesMode mode, Uint8List key, Uint8List iv,
      {AesPadding padding = AesPadding.ZeroPadding}) async {
    AesCrypt crypt = AesCrypt();
    //设置 key密码 和 iv偏移量
    crypt.aesSetKeys(key, iv);
    //加密模式
    crypt.aesSetMode(mode);
    //解密
    Uint8List data = crypt.aesDecrypt(source);
    // print(data);
    data = removePadding(data, padding); // AesCrypt 这个AES加密需要自己处理padding
    // print(data);
    //数据转字符串
    String result = utf8.decode(data);
    Dlog.p("AES","aesDecode  result:$result  length=${result.length}");
    return result;
  }

  // 数据填充padding 补足16整数倍
  static Uint8List addPadding(Uint8List source, AesPadding aespadding) {
    // print("addPadding start");
    // print(source);
    int padding_count = source.length % 16;
    if (padding_count != 0) {
      padding_count = 16 - padding_count;
      // print("addPadding padding_count=${padding_count}");
      List<int> source_padding = List.from(source);
      for (int i = 0; i < padding_count; i++) {
        switch (aespadding) {
          case AesPadding.PKCS5:
          case AesPadding.PKCS7:
            {
              // 填充补位长度
              source_padding.add(padding_count);
            }
            break;
          case AesPadding.ANSI_X_923:
            {
              if (i < padding_count - 1) {
                source_padding.add(0x00);
              } else {
                source_padding.add(padding_count);
              }
            }
            break;
          case AesPadding.ISO_10126:
            {
              Random random = Random();
              if (i < padding_count - 1) {
                source_padding.add(random.nextInt(0xff));//此处填充随机数
              } else {
                source_padding.add(padding_count);
              }
            }
            break;
          case AesPadding.ISO_IEC_7816_4:
            {
              if (i == 0) {
                source_padding.add(0x80);
              } else {
                source_padding.add(0x00);
              }
            }
            break;
          case AesPadding.ZeroPadding:
          case AesPadding.NoPadding:
            {
              source_padding.add(0x00);
            }
            break;
        }
      }
      Uint8List ret = Uint8List.fromList(source_padding);
      // print(ret);
      // print("addPadding end ");
      return ret;
    }
    // print("addPadding end ");
    return source;
  }

  // 数据移除padding
  static Uint8List removePadding(Uint8List source, AesPadding aespadding) {
    // print("removePadding start");
    // print(source);
    int padding_count = 0;
    switch (aespadding) {
      case AesPadding.PKCS5:
      case AesPadding.PKCS7:
      case AesPadding.ANSI_X_923:
      case AesPadding.ISO_10126:
        {
          padding_count = source[source.length - 1];
        }
        break;
      case AesPadding.ISO_IEC_7816_4:
        {
          for (int i = 1; i < 16; i++) {
            int item = source[source.length - i];
            if (item == 0x00) {
            } else if (item == 0x80) {
              padding_count = i;
            } else {
              break;
            }
          }
        }
        break;
      case AesPadding.ZeroPadding:
      case AesPadding.NoPadding:
        {
          for (int i = 1; i < 16; i++) {
            if (source[source.length - i] != 0x00) {
              padding_count = i - 1;
              break;
            }
          }
        }
        break;
    }
    if (padding_count > 0 && padding_count < source.length) {
      Uint8List ret = source.sublist(0, source.length - padding_count);
      // print(ret);
      // print("removePadding end ");
      return ret;
    }
    // print("removePadding end");
    return source;
  }



  // 加密 原文String -> 生成base64   aes_key、aes_iv16个长度
  static Future<String> aesEncodeBase64CBC(String text,{String aes_key="pigxpigxpigxpigx",String aes_iv="pigxpigxpigxpigx"}) async {
    //加密
    try{
      String result = await AesCryptUtil.aesEncode(
        utf8.encode(text),
        AesMode.cbc,
        utf8.encode(aes_key),
        utf8.encode(aes_iv),
        padding: AesPadding.NoPadding,
      );
      return result;
    }catch(e)
    {
      Dlog.p("AES","aesEncodeBase64CBC error $e");
      print(e);
    }
    return null;
  }

  // 解密 解base64 -> 原文String   aes_key、aes_iv16个长度
  static Future<String> aesDecodeBase64CBC(String text,{String aes_key="pigxpigxpigxpigx",String aes_iv="pigxpigxpigxpigx"}) async {
    //解密
    try{
      String result = await AesCryptUtil.aesDecode(
        base64.decode(text),
        AesMode.cbc,
        utf8.encode(aes_key),
        utf8.encode(aes_iv),
        padding: AesPadding.NoPadding,
      );
      return result;
    }catch(e){
      Dlog.p("AES","aesDecodeBase64CBC error $e");
      print(e);
    }
    return null;
  }
}
