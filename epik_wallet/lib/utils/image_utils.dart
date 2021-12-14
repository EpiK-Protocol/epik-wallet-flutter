import 'dart:math';

class ImageUtils {
  static List<String> getRandomImageUrlList(int size) {
    List<String> ret = new List<String>();
    if (size <= 0) return ret;
    if (size > urls_test.length) size = urls_test.length;
    for (int i = 0; i < size; i++) {
      try {
        String path = "";
        do {
          path = getRandomImageUrl();
        } while (ret.contains(path));
        ret.add(path);
      } catch (e) {}
    }
    return ret;
  }

  static String getRandomImageUrl() {
    int number = Random().nextInt(urls_test.length - 1);
    return urls_test[number];
  }

  static List<String> urls_test = [
//    "http://i-2.yxdown.com/2014/8/9/4ab8f770-dc64-4caf-8dcb-530812dd135f.gif",
//    "http://fdfs.xmcdn.com/group5/M01/2E/8D/wKgDtVONtOaCCgiQAAHhAAnF2BY165_web_large.jpg",
//    "http://ww1.sinaimg.cn/thumb180/63fb4ad5gw6denp4x9fduj.jpg",
//    "http://b.hiphotos.baidu.com/image/h%3D360/sign=d45d77b8b0b7d0a264c9029bfbee760d/b2de9c82d158ccbf15e8ae301bd8bc3eb1354167.jpg",
//    "http://dimg04.c-ctrip.com/images/hhtravel/713/698/484/9159cabcda424168948cd82fb47f5f8d_C_250_140_Q80.jpg",
//    "http://p1.pstatp.com/large/a78000825b7fd4bc35f",
    "http://p1.pstatp.com/large/pgc-image/bf1eb3eee58e47fbb8a8869ea81ede4c",
    "http://p1.pstatp.com/large/pgc-image/5d5bb19fb41247539d3fbb9bc2e1f84f",
    "http://www.teda.com.cn/public/static/index/uploads/ad/20200506/7c36c302a593b1083814cad210cd09fd.jpg",
    "http://www.teda.com.cn/public/static/index/uploads/ad/20200506/725e1dfe3926d86493cb2fdfa8998011.jpg",
    "http://www.teda.com.cn/ueditor/php/upload/image/20190522/1558499463125523.jpg",
    "http://www.teda.com.cn/ueditor/php/upload/image/20190910/1568084211116943.jpg",
  ];
}
