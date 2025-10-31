// lib/presentation/view_models/cycle_detail_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/domain/entities/cycle.dart';
import 'package:laour_cycle_manager/domain/entities/order_guide.dart';
import 'package:laour_cycle_manager/domain/entities/portfolio_state.dart';
import 'package:laour_cycle_manager/domain/usecases/calculate_portfolio.dart';
import 'package:laour_cycle_manager/domain/usecases/complete_cycle.dart';

@injectable
class CycleDetailViewModel extends ChangeNotifier {
  final CalculatePortfolio _calculatePortfolioUseCase;
  final CompleteCycle _completeCycleUseCase; // [추가]

  // [수정] 생성자를 통해 CompleteCycle Usecase도 주입받습니다.
  CycleDetailViewModel(this._calculatePortfolioUseCase, this._completeCycleUseCase);

  bool _isLoading = true;
  String? _errorMessage;
  PortfolioState _portfolioState = PortfolioState.initial();
  OrderGuide _orderGuide = OrderGuide.initial();

  bool get isLoading => _isLoading;
  String? get getErrorMessage => _errorMessage;
  PortfolioState get portfolioState => _portfolioState;
  OrderGuide get orderGuide => _orderGuide;

  Future<void> loadCycleDetails(Cycle cycle) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: 실제 주식 시세 API 연동 필요
      const double currentPrice = 55.0;
      const double lastClosePrice = 54.0;

      _portfolioState = await _calculatePortfolioUseCase(cycle, currentPrice);
      _orderGuide = _determineOrderGuide(cycle, _portfolioState, lastClosePrice);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = "데이터를 불러오는 데 실패했습니다: $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  OrderGuide _determineOrderGuide(Cycle cycle, PortfolioState state, double lastClosePrice) {
    if (state.totalQuantity > 0 && state.sellTargetPrice <= lastClosePrice) {
      return OrderGuide(
        action: OrderActionType.marketSell,
        ticker: cycle.ticker,
        message: '목표 수익률 달성! 전량 시장가 매도하세요.',
      );
    }
    
    if (state.plannedTradeCount >= cycle.divisionCount) {
        return OrderGuide(
            action: OrderActionType.addFunds,
            ticker: cycle.ticker,
            message: '모든 분할 매수가 완료되었습니다. 위기 관리 가이드를 확인하세요.',
        );
    }

    final double quantityToBuy = cycle.amountPerDivision / lastClosePrice;
    
    return OrderGuide(
      action: OrderActionType.locBuy,
      ticker: cycle.ticker,
      message: '아래 내용으로 지정가(LOC) 매수 주문을 넣으세요.',
      price: lastClosePrice,
      quantity: quantityToBuy,
    );
  }

  // [추가된 기능] 전량 매도 및 수익 정산을 실행하는 메소드
  Future<bool> executeProfitSell(Cycle cycle) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // CompleteCycle Usecase를 호출하여 복잡한 로직을 처리합니다.
      await _completeCycleUseCase(
        cycle: cycle,
        portfolioState: _portfolioState,
        userId: cycle.userId,
      );
      _isLoading = false;
      notifyListeners();
      return true; // 성공
    } catch (e) {
      _errorMessage = "수익 정산에 실패했습니다: $e";
      _isLoading = false;
      notifyListeners();
      return false; // 실패
    }
  }
}