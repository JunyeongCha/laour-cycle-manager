// lib/domain/usecases/add_manual_trade.dart

import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/domain/entities/trade_record.dart';
import 'package:laour_cycle_manager/domain/repositories/cycle_repository.dart';

@lazySingleton
class AddManualTrade {
  final CycleRepository repository;

  AddManualTrade(this.repository);

  // 이 기능은 UI에서 생성된 TradeRecord 객체를 받아
  // repository에 저장을 위임하는 간단한 역할을 합니다.
  Future<void> call(TradeRecord tradeRecord) {
    return repository.addTradeRecord(tradeRecord);
  }
}