// lib/presentation/view_models/trade_result_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/domain/usecases/update_trade_result.dart';

@injectable
class TradeResultViewModel extends ChangeNotifier {
  final UpdateTradeResult _updateTradeResultUseCase;

  TradeResultViewModel(this._updateTradeResultUseCase);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get getErrorMessage => _errorMessage;

  // UI에서 O 또는 X 버튼을 눌렀을 때 호출될 메소드
  Future<bool> submitResult({
    required String cycleId,
    required bool wasExecuted,
    required double price,
    required double quantity,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Usecase를 실행하여 결과를 Firestore에 기록합니다.
      await _updateTradeResultUseCase(
        cycleId: cycleId,
        wasExecuted: wasExecuted,
        price: price,
        quantity: quantity,
      );

      _isLoading = false;
      notifyListeners();
      return true; // 성공 반환

    } catch (e) {
      _errorMessage = '결과를 저장하는 데 실패했습니다.';
      _isLoading = false;
      notifyListeners();
      return false; // 실패 반환
    }
  }
}