import 'package:epikwallet/utils/Dlog.dart';

class ModelCache {
  ModelCache() {
    Dlog.p("ModelCache","构造");
  }

  Map _cache_map = {};

  Map get map {
    if (_cache_map == null) _cache_map = {};
    return _cache_map;
  }

  void add(key, data) {
    if (data == null) {
      map[key] = data;
    }
  }
}

var modelCacheMgr = new ModelCacheMgr();

class ModelCacheMgr {
  static const String TAG="ModelCacheMgr";
  static ModelCacheMgr _ModelCacheMgr = ModelCacheMgr._internal();

  factory ModelCacheMgr() {
    return _ModelCacheMgr;
  }

  ModelCacheMgr._internal() {
    // 单例初始化
    Dlog.p(TAG,"初始化");
  }

  Map<String, ModelCache> _map = {};

  Map<String, ModelCache> get map {
    if (_map == null) _map = {};
    return _map;
  }

  void add<K, V>(K key, V data) {
    String cachekey = getCachekey(K, V);
    ModelCache mc = getModelCache(cachekey);
    if (mc == null) {
      mc = ModelCache();
      map[cachekey] = mc;
    }
    mc.map[key] = data;
  }

  ModelCache getModelCache(String cachekey) {
    return map[cachekey];
  }

  String getCachekey(var k, var v) {
    String cachekey = k.toString() + "_" + v.toString();
    // Dlog.p(TAG,cachekey);
    return cachekey;
  }

  V find<K,V>(Type clazz,K key)
  {
    String cachekey = getCachekey(K, clazz);
    ModelCache mc = getModelCache(cachekey);
    if(mc!=null)
    {
      return mc.map[key];
    }
    return null;
  }

  void clear()
  {
    _map.clear();
    _map=null;
  }

  void removeAll(k,v)
  {
    String cachekey = getCachekey(k, v);
    ModelCache mc = getModelCache(cachekey);
    if(mc!=null)
    {
      mc.map.clear();
      map.remove(cachekey);
    }
  }

  @override
  String toString() {
    _map.values.forEach((element) {
      print(element?.map?.length);
    });
    return "ModelCacheMgr size=${_map?.length} keys=${_map?.keys}";
  }
}
