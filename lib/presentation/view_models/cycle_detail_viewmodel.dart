// lib/presentation/view_models/cycle_detail_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/domain/entities/cycle.dart';
import 'package:laour_cycle_manager/domain/entities/order_guide.dart';
import 'package:laour_cycle_manager/domain/entities/portfolio_state.dart';
import 'package:laour_cycle_manager/domain/usecases/calculate_portfolio.dart';

@injectable
class CycleDetailViewModel extends ChangeNotifier {
  final CalculatePortfolio _calculatePortfolioUseCase;

  CycleDetailViewModel(this._calculatePortfolioUseCase);

  // 화면의 상태를 나타내는 변수들
  bool _isLoading = true;
  String? _errorMessage;
  PortfolioState _portfolioState = PortfolioState.initial();
  OrderGuide _orderGuide = OrderGuide.initial();

  // UI에서 상태를 읽기 위한 getter
  bool get isLoading => _isLoading;
  String? get getErrorMessage => _errorMessage;
  PortfolioState get portfolioState => _portfolioState;
  OrderGuide get orderGuide => _orderGuide;

  // 이 ViewModel이 처음 생성될 때 UI에서 호출할 초기화 메소드
  Future<void> loadCycleDetails(Cycle cycle) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // =================================================================
      // TODO: 여기에 실제 주식 시세 API를 연동하여 실시간 주가를 가져오는 로직이 필요합니다.
      // 지금은 임시로 고정된 값을 사용합니다.
      const double currentPrice = 55.0; // 예: 현재가
      const double lastClosePrice = 54.0; // 예: 전일 종가
      // =================================================================

      // 1. Usecase를 실행하여 현재 포트폴리오 상태를 계산합니다.
      _portfolioState = await _calculatePortfolioUseCase(cycle, currentPrice);

      // 2. 계산된 포트폴리오 상태를 바탕으로 '오늘의 미션'을 결정합니다.
      _orderGuide = _determineOrderGuide(cycle, _portfolioState, lastClosePrice);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = "데이터를 불러오는 데 실패했습니다: $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  // '오늘의 미션'을 결정하는 내부 로직
  OrderGuide _determineOrderGuide(Cycle cycle, PortfolioState state, double lastClosePrice) {
    // 매도 목표가에 도달했는지 확인
    if (state.totalQuantity > 0 && state.sellTargetPrice <= lastClosePrice) {
      return OrderGuide(
        action: OrderActionType.marketSell,
        ticker: cycle.ticker,
        message: '목표 수익률 달성! 전량 시장가 매도하세요.',
      );
    }
    
    // 40회 매수가 끝났는지 확인 (리밸런싱 안내)
    if (state.plannedTradeCount >= cycle.divisionCount) {
        return OrderGuide(
            action: OrderActionType.addFunds,
            ticker: cycle.ticker,
            message: '모든 분할 매수가 완료되었습니다. 위기 관리 가이드를 확인하세요.',
        );
    }

    // 위 조건에 해당하지 않으면, 다음 LOC 매수 주문을 안내합니다.
    final double quantityToBuy = cycle.amountPerDivision / lastClosePrice;
    
    return OrderGuide(
      action: OrderActionType.locBuy,
      ticker: cycle.ticker,
      message: '아래 내용으로 지정가(LOC) 매수 주문을 넣으세요.',
      price: lastClosePrice,
      quantity: quantityToBuy,
    );
  }
}