import 'package:epikwallet/utils/Dlog.dart';
import 'package:epikwallet/utils/http/httputils.dart';
import 'package:flutter/material.dart';

typedef OnRequestComplete<Dt>(DataLoader<Dt> dataloader, int errCode, String msg,
    int page, int pageSize, List<Dt> pagedata);

class DlCallback<Dt>{
  OnRequestComplete onRequestComplete;
  DlCallback(this.onRequestComplete);
}

typedef JResponse(HttpJsonRes hjr, bool cached);

abstract class DataLoader<Dt> {
  List<DlCallback<Dt>> callbackList;
  List<DlCallback<Dt>> callbackList_once;

  List<Dt> data = new List();

  int page = 0;
  int pagesize = 20;
  int total = -1;
  bool hasMore;

  Object lastId;
  bool lastIdMode = false;

  bool requesting = false;

  int lastRefreshTime = 0;

  bool isRequesting() {
    return requesting;
  }

  void setRequesting(bool requesting) {
    Dlog.p("DataLoader", "setRequesting ${getClassName()}  ${requesting}");
    this.requesting = requesting;
  }

  String getClassName() {

    String className;
    try{
       className = this.toString();
      List<String> array = className.split(" ");
      if (array != null && array.length > 0) {
        className = array[array.length-1];
      }
    }catch(e){
    }

    if (className == null) {
      return "DataLoader${this.hashCode}";
    }

    return className;
  }

  /** 请求新数据 */
  Future<void>  refreshData(bool readCache)async {
    setRequesting(true);
    if (lastIdMode) {
      lastId = null;
      hasMore = false;
    } else {
      page = 0;
      total = -1;
      hasMore = false;
    }

    if (data == null)
      data = new List();
    else
      data.clear();



    JResponse _mJResponse = null;
    _mJResponse = (HttpJsonRes hjr, bool cached) {
      if (_mJResponse == mJResponse) {
        setRequesting(false);

        try {
          parseData(hjr, cached);
        } catch (e) {
          Dlog.p("DataLoader", e);
        }
      }
    };

    mJResponse = _mJResponse;
    await requestData(readCache, mJResponse);
    lastRefreshTime = DateTime.now().millisecondsSinceEpoch;
  }

  /** 请求更多数据 */
  void loadMoreData() {
    if (getHasMore()) requestData(false, mJResponse);
  }

  List<Dt> getAllData() {
    if (data == null) data = new List();
    return data;
  }

  JResponse mJResponse;

  /** 请求完成 分发结果 */
  void requestComplete(
      int errCode, String msg, int page, int pageSize, List<Dt> pagedata) {
    try {
      // 一次性回调
      if (callbackList_once != null) {
        try {
          for (DlCallback callback in callbackList_once) {
            try {
              callback.onRequestComplete(this, errCode, msg, page, pagesize, pagedata);
            } catch (e) {
              Dlog.p("DataLoader", e);
            }
          }
        } catch (e) {
          Dlog.p("DataLoader", e);
        }
        try {
          callbackList_once.clear();
        } catch (e) {
          Dlog.p("DataLoader", e);
        }
      }

      // 常规回调
      if (callbackList != null) {
        for (DlCallback callback in callbackList) {
          try {
            callback.onRequestComplete(this, errCode, msg, page, pagesize, pagedata);
          } catch (e) {
            Dlog.p("DataLoader", e);
          }
        }
      }
    } catch (e) {
      Dlog.p("DataLoader", e);
    }
  }

  /** 具体的请求数据方法 */
  Future<void>  requestData(bool readCache, JResponse callback);

  /**
   * 具体解析数据的方法<br>
   * 解析数据后需要调用requestComplete()分发结果
   */
  void parseData(HttpJsonRes hjr, bool cached);

  void addCallback(DlCallback<Dt> callback) {
    if (callbackList == null) callbackList = new List();
    if (!callbackList.contains(callback)) callbackList.add(callback);
  }

  void removeCallback(DlCallback<Dt> callback) {
    try {
      if (callbackList != null) callbackList.remove(callback);
    } catch (e) {
      Dlog.p("DataLoader", e);
    }
  }

  void addOnceCallback(DlCallback<Dt> callback) {
    if (callbackList_once == null) callbackList_once = new List();
    if (!callbackList_once.contains(callback)) callbackList_once.add(callback);
  }

  void destroy() {
    if (callbackList != null) callbackList.clear();
    callbackList = null;
  }

  Object getLastId() {
    return lastId;
  }

  int getPage() {
    return page;
  }

  int getPagesize() {
    return pagesize;
  }

  int getTotal() {
    return total;
  }

  bool getHasMore() {
    return hasMore;
  }

  int getLastRefreshTime() {
    return lastRefreshTime;
  }
}
