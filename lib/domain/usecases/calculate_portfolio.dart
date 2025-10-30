// lib/domain/usecases/calculate_portfolio.dart

import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/domain/entities/cycle.dart';
import 'package:laour_cycle_manager/domain/entities/portfolio_state.dart';
import 'package:laour_cycle_manager/domain/entities/trade_record.dart';
import 'package:laour_cycle_manager/domain/repositories/cycle_repository.dart';

@lazySingleton
class CalculatePortfolio {
  final CycleRepository repository;

  CalculatePortfolio(this.repository);

  // This is the core calculation engine of the app.
  Future<PortfolioState> call(Cycle cycle, double currentPrice) async {
    // 1. Fetch all trade records for this specific cycle.
    final tradeRecords = await repository.getTradeRecords(cycle.id);

    if (tradeRecords.isEmpty) {
      return PortfolioState.initial();
    }

    // 2. Initialize variables for calculation.
    double totalBuyAmount = 0.0;
    double totalQuantity = 0.0;
    int plannedTradeCount = 0;

    // 3. Loop through every trade record to aggregate data.
    for (final record in tradeRecords) {
      if (record.type == TradeType.locBuy || record.type == TradeType.manualBuy) {
        totalBuyAmount += record.totalAmount;
        totalQuantity += record.quantity;
        
        if (record.isPlanned) {
          plannedTradeCount++;
        }
      } else { // For manualSell or profitSell
        if (totalQuantity > 0) {
          double costPerShare = totalBuyAmount / totalQuantity;
          totalBuyAmount -= record.quantity * costPerShare;
          totalQuantity -= record.quantity;
        }
      }
    }
    
    // Prevent division by zero if all shares are sold.
    if (totalQuantity <= 0) {
        return PortfolioState.initial();
    }

    // 4. Calculate the final metrics.
    final double averageBuyPrice = totalBuyAmount / totalQuantity;
    final double totalEvaluationAmount = totalQuantity * currentPrice;
    final double unrealizedProfitOrLoss = totalEvaluationAmount - totalBuyAmount;
    final double currentProfitRate = (unrealizedProfitOrLoss / totalBuyAmount) * 100;
    final double sellTargetPrice = averageBuyPrice * (1 + (cycle.targetProfitPercentage / 100));

    // 5. Return the complete, calculated state.
    return PortfolioState(
      averageBuyPrice: averageBuyPrice,
      totalBuyAmount: totalBuyAmount,
      totalEvaluationAmount: totalEvaluationAmount,
      unrealizedProfitOrLoss: unrealizedProfitOrLoss,
      currentProfitRate: currentProfitRate,
      totalQuantity: totalQuantity,
      plannedTradeCount: plannedTradeCount,
      sellTargetPrice: sellTargetPrice,
    );
  }
}