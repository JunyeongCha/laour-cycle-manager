// lib/presentation/screens/cycle_management/cycle_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:laour_cycle_manager/config/dependency_injection.dart';
import 'package:laour_cycle_manager/domain/entities/cycle.dart';
import 'package:laour_cycle_manager/presentation/screens/cycle_management/manual_trade_screen.dart';
import 'package:laour_cycle_manager/presentation/screens/cycle_management/trade_result_screen.dart';
import 'package:laour_cycle_manager/presentation/view_models/cycle_detail_viewmodel.dart';
import 'package:provider/provider.dart';

class CycleDetailScreen extends StatelessWidget {
  final Cycle cycle;

  const CycleDetailScreen({super.key, required this.cycle});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
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
                  _buildMissionCard(context, guide),
                  const SizedBox(height: 24),

                  // 2. 오늘의 체크리스트
                  Text("✅ 오늘의 할 일", style: Theme.of(context).textTheme.titleLarge),
                  const Divider(height: 16),
                  CheckboxListTile(
                    title: const Text("어제 주문 결과 입력하기"),
                    value: false, // TODO: 실제 완료 여부 상태와 연결 필요
                    onChanged: (value) {
                      // 결과 입력 화면으로 이동
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TradeResultScreen(cycle: cycle, guide: guide),
                        ),
                      );
                    },
                  ),
                  CheckboxListTile(
                    title: const Text("오늘 주문 등록하기"),
                    value: false, // TODO: 실제 완료 여부 상태와 연결 필요
                    onChanged: (value) {
                      // TODO: 체크 상태 변경 로직 구현
                    },
                  ),
                  const SizedBox(height: 24),

                  // 3. 실시간 현황판
                  Text("📊 실시간 현황판", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  _buildStatusTile("평균 매수 단가", "\$${state.averageBuyPrice.toStringAsFixed(2)}"),
                  _buildStatusTile("총 매수 금액", "${NumberFormat.currency(locale: 'ko_KR', symbol: '₩').format(state.totalBuyAmount)}"),
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
                    value: (state.plannedTradeCount / cycle.divisionCount).clamp(0.0, 1.0),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 24),

                  // 4. 기타 기능 버튼들
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('수동 거래 추가'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ManualTradeScreen(cycle: cycle),
                            ),
                          );
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.warning_amber_rounded),
                        label: const Text('위기 관리 가이드'),
                        onPressed: () {
                          // TODO: 위기 관리 가이드 팝업 기능 구현
                        },
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 오늘의 미션 카드를 만드는 헬퍼 위젯
  Widget _buildMissionCard(BuildContext context, dynamic guide) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🎯 오늘의 미션",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              guide.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            if (guide.price != null && guide.quantity != null && guide.quantity > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "${guide.ticker}: ${guide.price!.toStringAsFixed(2)}에 ${guide.quantity!.toStringAsFixed(2)}주 매수",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 현황판의 각 항목을 만드는 헬퍼 위젯
  Widget _buildStatusTile(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
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