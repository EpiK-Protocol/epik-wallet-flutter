import 'dart:collection';

import 'package:epikwallet/logic/loader/DataLoader.dart';
import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/http/httputils.dart';

class DataLoaderGroup<tp, Dt> extends DataLoader<Dt> {
  Map<tp, DataLoader<Dt>> _dlmap = new Map();

  tp _current_type = null; // 默认
  DataLoader<Dt> _current_dl;

  DataLoaderGroup(HashMap<tp, DataLoader<Dt>> map, tp defType) {
    _dlmap = map;
    _dlmap.forEach((key, value) {
      tp type = key;
      DataLoader<Dt> dl = value;
      DlCallback<Dt> mDlProxyCallback =
          DlCallback<Dt>((dataloader, errCode, msg, page, pageSize, pagedata) {
        if (type == _current_type)
          requestComplete(errCode, msg, page, pagesize, pagedata);
      });
      dl.addCallback(mDlProxyCallback);
    });

    setDlType(defType);
  }

  /** 切换数据源 */
  void setDlType(tp type) {
    _current_type = type;
    _current_dl = _dlmap[_current_type];
  }

  tp getDlType() {
    return _current_type;
  }

  Future<void> requestData(bool readCache, JResponse callback){
    _current_dl.requestData(
        readCache, callback); // callback 是group的, 然后调用group的parseData
  }

  void parseData(HttpJsonRes hjr, bool cached) {
    _current_dl.parseData(
        hjr, cached); // 解析内容交给具体的dl中，通过代理的DlProxyCallback 调用requestComplete
  }

  void requestComplete(
      int errCode, String msg, int page, int pageSize, List<Dt> pagedata) {
    super.requestComplete(errCode, msg, page, pageSize, pagedata);
  }

  bool isRequesting() {
    return _current_dl.isRequesting();
  }

  void setRequesting(bool requesting) {
    _current_dl.setRequesting(requesting);
  }

  Future<void> refreshData(bool readCache) async{
    return _current_dl.refreshData(readCache);
  }

  void loadMoreData() {
    _current_dl.loadMoreData();
  }

  List<Dt> getAllData() {
    return _current_dl.getAllData();
  }

  void addCallback(DlCallback<Dt> callback) {
    super.addCallback(callback);
  }

  void removeCallback(DlCallback<Dt> callback) {
    super.removeCallback(callback);
  }

  void destroy() {
    try {
      _dlmap.forEach((key, value) {
        value.destroy();
      });
      _dlmap.clear();
    } catch (e) {
      Dlog.p("DataLoaderGroup", e);
    }
  }

  int getPage() {
    return _current_dl.getPage();
  }

  int getPagesize() {
    return _current_dl.getPagesize();
  }

  int getTotal() {
    return _current_dl.getTotal();
  }

  bool getHasMore() {
    return _current_dl.getHasMore();
  }

  int getLastRefreshTime() {
    return _current_dl.getLastRefreshTime();
  }

  Object getLastId() {
    return _current_dl.getLastId();
  }
}
