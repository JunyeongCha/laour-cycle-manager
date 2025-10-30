// lib/presentation/view_models/manual_trade_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/domain/entities/trade_record.dart';
import 'package:laour_cycle_manager/domain/usecases/add_manual_trade.dart';

@injectable
class ManualTradeViewModel extends ChangeNotifier {
  final AddManualTrade _addManualTradeUseCase;

  ManualTradeViewModel(this._addManualTradeUseCase);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get getErrorMessage => _errorMessage;

  // UI에서 '저장하기' 버튼을 눌렀을 때 호출될 메소드
  Future<bool> submitManualTrade({
    required String cycleId,
    required TradeType tradeType, // '수동 매수' 또는 '수동 매도'
    required String price,
    required String quantity,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 입력받은 문자열 값들을 숫자로 변환합니다.
      final double priceValue = double.parse(price);
      final double quantityValue = double.parse(quantity);

      // 수동 거래이므로 isPlanned는 항상 false입니다.
      final newRecord = TradeRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // 임시 ID
        cycleId: cycleId,
        type: tradeType,
        price: priceValue,
        quantity: quantityValue,
        timestamp: DateTime.now(),
        isPlanned: false, // 이것이 핵심입니다.
      );

      // Usecase를 실행하여 기록을 저장합니다.
      await _addManualTradeUseCase(newRecord);

      _isLoading = false;
      notifyListeners();
      return true; // 성공 반환

    } catch (e) {
      _errorMessage = '거래 기록 저장에 실패했습니다. 입력 값을 확인해주세요.';
      _isLoading = false;
      notifyListeners();
      return false; // 실패 반환
    }
  }
}