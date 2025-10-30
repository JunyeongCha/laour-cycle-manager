// lib/domain/usecases/update_trade_result.dart

import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/domain/entities/trade_record.dart';
import 'package:laour_cycle_manager/domain/repositories/cycle_repository.dart';

@lazySingleton
class UpdateTradeResult {
  final CycleRepository repository;

  UpdateTradeResult(this.repository);

  // O/X 버튼 뒤의 로직입니다.
  // 거래가 체결되었다면, 'locBuy' 타입의 새로운 거래 기록을 생성합니다.
  Future<void> call({
    required String cycleId,
    required bool wasExecuted,
    required double price,
    required double quantity,
  }) {
    // 거래가 실제로 일어났을 때만 기록을 생성합니다.
    if (wasExecuted) {
      final tradeRecord = TradeRecord(
        // ID는 Firestore에서 자동으로 생성되므로 임시 값을 사용합니다.
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cycleId: cycleId,
        type: TradeType.locBuy,
        price: price,
        quantity: quantity,
        timestamp: DateTime.now(),
        // 이 거래는 N/40회 진행률에 포함되는 계획된 거래입니다.
        isPlanned: true,
      );
      return repository.addTradeRecord(tradeRecord);
    }
    // 체결되지 않았다면 아무것도 하지 않습니다.
    return Future.value();
  }
}