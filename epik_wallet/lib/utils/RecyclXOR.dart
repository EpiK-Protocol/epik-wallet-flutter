import 'dart:convert';
import 'dart:typed_data';

class RecyclXOR {
  static Uint8List recyclingXOR(Uint8List data, String key, {String iv}) {
    if (data == null || key == null || data.length == 0 || key.length == 0) {
      return null;
    }
    print(data.length);
    print(data);
    Uint8List ret = Uint8List(data.length);
    try {
      Uint8List keylist = utf8.encode(key);
      Uint8List ivlist = iv != null ? utf8.encode(iv) : null;
      int length = data.length;
      for (int i = 0; i < length; i++) {
        int key_index = i % keylist.length;
        int key_item = keylist[key_index];
        if(ivlist!=null&&ivlist.length>0)
        {
          int iv_index = i % ivlist.length;
          int iv_item = ivlist[iv_index];
          key_item=key_item*iv_item;
        }
        ret[i] = data[i] ^ key_item;

        // print("${data[i]} ^ $key_item => ${ret[i]}");
      }
    } catch (e, s) {
      print(s);
      ret = null;
    }
    return ret;
  }

  static String XORCryptoBase64(String content, String key, {String iv}) {
    if (content == null ||
        key == null ||
        content.length == 0 ||
        key.length == 0) return null;
    String ret = null;
    try {
      Uint8List a = recyclingXOR(utf8.encode(content), key,iv: iv);
      if (a != null && a.length > 0) {
        ret = base64.encode(a);
      }
    } catch (e) {
      print(e);
    }
    return ret;
  }

  static String XORDecryptBase64(String content, String key, {String iv}) {
    if (content == null ||
        key == null ||
        content.length == 0 ||
        key.length == 0) return null;
    String ret = null;
    try {
      Uint8List a = base64.decode(content);
      if (a != null) {
        Uint8List codeUnits = recyclingXOR(a, key,iv: iv);
        ret = utf8.decode(codeUnits);
      }
    } catch (e) {
      print(e);
    }
    return ret;
  }
}
