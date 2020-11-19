
import "dart:math";

import '../entity/k_entity.dart';

class KLineEntity extends KEntity {
  double open;
  double high;
  double low;
  double close;
  double vol;
  double amount;
  int count;
  int id;

  KLineEntity.fromJson(Map<String, dynamic> json) {
    open = (json['open'] as num)?.toDouble();
    high = (json['high'] as num)?.toDouble();
    low = (json['low'] as num)?.toDouble();
    close = (json['close'] as num)?.toDouble();
    vol = (json['vol'] as num)?.toDouble();
    amount = (json['amount'] as num)?.toDouble();
    count = (json['count'] as num)?.toInt();
    id = (json['id'] as num)?.toInt();
    
    if(low==0)
      low = min(open, close);
    if(high==0)
      high = max(open, close);
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['open'] = this.open;
    data['close'] = this.close;
    data['high'] = this.high;
    data['low'] = this.low;
    data['vol'] = this.vol;
    data['amount'] = this.amount;
    data['count'] = this.count;
    return data;
  }

  @override
  String toString() {
    return 'MarketModel{open: $open, high: $high, low: $low, close: $close, vol: $vol, id: $id}';
  }

  KLineEntity setTimeOffset(int timeOffset)
  {
    id += timeOffset;
    return this;
  }
}
