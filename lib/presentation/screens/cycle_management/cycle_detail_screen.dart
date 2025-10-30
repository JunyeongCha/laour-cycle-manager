// lib/presentation/screens/cycle_management/cycle_detail_screen.dart

import 'package.flutter/material.dart';
import 'package:laour_cycle_manager/config/dependency_injection.dart';
import 'package:laour_cycle_manager/domain/entities/cycle.dart';
import 'package:laour_cycle_manager/presentation/view_models/cycle_detail_viewmodel.dart';
import 'package:provider/provider.dart';

class CycleDetailScreen extends StatelessWidget {
  final Cycle cycle; // 이전 화면(사이클 목록)에서 어떤 사이클을 볼지 전달받습니다.

  const CycleDetailScreen({super.key, required this.cycle});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // ViewModel을 생성하고, 생성되자마자 loadCycleDetails를 호출하여 데이터 로딩을 시작합니다.
      create: (_) => getIt<CycleDetailViewModel>()..loadCycleDetails(cycle),
      child: Scaffold(
        appBar: AppBar(
          title: Text(cycle.name),
        ),
        body: Consumer<CycleDetailViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.getErrorMessage != null) {
              return Center(child: Text(viewModel.getErrorMessage!));
            }

            final state = viewModel.portfolioState;
            final guide = viewModel.orderGuide;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. 오늘의 미션 브리핑 카드
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "🎯 오늘의 미션",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            guide.message,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (guide.price != null && guide.quantity != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "${guide.ticker}: ${guide.price!.toStringAsFixed(2)}에 ${guide.quantity!.toStringAsFixed(2)}주 매수",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. 실시간 현황판
                  Text("📊 실시간 현황판", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  _buildStatusTile("평균 매수 단가", "\$${state.averageBuyPrice.toStringAsFixed(2)}"),
                  _buildStatusTile("총 매수 금액", "₩${state.totalBuyAmount.toStringAsFixed(0)}"), // 원화 표시 예시
                  _buildStatusTile(
                    "현재 수익률",
                    "${state.currentProfitRate.toStringAsFixed(2)}%",
                    valueColor: state.currentProfitRate >= 0 ? Colors.green : Colors.red,
                  ),
                  _buildStatusTile("매도 목표가", "\$${state.sellTargetPrice.toStringAsFixed(2)} (목표 ${cycle.targetProfitPercentage}%)"),
                  const SizedBox(height: 8),
                  
                  // 진행 현황 프로그레스 바
                  Text(
                    "진행 현황 (${state.plannedTradeCount} / ${cycle.divisionCount}회)",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: state.plannedTradeCount / cycle.divisionCount,
                    minHeight: 10,
                  ),
                  
                  // TODO: 여기에 '오늘의 체크리스트', '위기 관리 가이드', '수동 거래' 버튼 등을 추가할 예정입니다.
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 현황판의 각 항목을 만드는 헬퍼 위젯
  Widget _buildStatusTile(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}