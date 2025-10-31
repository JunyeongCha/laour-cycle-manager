// lib/presentation/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:laour_cycle_manager/config/dependency_injection.dart';
import 'package:laour_cycle_manager/domain/entities/user_profile.dart';
import 'package:laour_cycle_manager/presentation/screens/cycle_management/trade_result_screen.dart';
import 'package:laour_cycle_manager/presentation/view_models/dashboard_viewmodel.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<DashboardViewModel>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('대시보드'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/myPage'),
            ),
          ],
        ),
        body: Consumer<DashboardViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = viewModel.userProfile;

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 1. 인사말 및 오늘의 명언
                Text(
                  '안녕하세요, ${user?.name ?? '사용자'}님!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  '"시장은 예측하는 것이 아니라 대응하는 것이다."',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // 2. 목표 달성률 카드
                if (user != null) _buildGoalProgressCard(context, user),
                const SizedBox(height: 24),

                // 3. 오늘의 통합 체크리스트
                Text('✅ 오늘의 할 일', style: Theme.of(context).textTheme.titleLarge),
                const Divider(height: 16),
                if (viewModel.tasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: Text('오늘 해야 할 일이 없습니다!')),
                  )
                else
                  Column(
                    children: viewModel.tasks.map((task) {
                      return CheckboxListTile(
                        title: Text(task.description),
                        value: task.isCompleted,
                        onChanged: (bool? value) {
                          // [핵심 수정] 할 일 종류에 따라 다른 행동 수행
                          if (task.type == TaskType.enterResult) {
                            // '어제 결과 입력' 클릭 시, ViewModel이 미리 계산해 둔
                            // cycle과 guide 정보를 가지고 TradeResultScreen으로 이동합니다.
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => TradeResultScreen(cycle: task.cycle, guide: task.guide),
                            ));
                          } else if (task.type == TaskType.placeOrder) {
                            // '오늘 주문 등록'은 사용자가 직접 체크만 합니다.
                            viewModel.toggleTaskCompletion(task);
                          }
                        },
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 24),

                // 4. 나의 사이클 목록
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('🌀 나의 사이클', style: Theme.of(context).textTheme.titleLarge),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.blue),
                      onPressed: () => context.push('/addCycle'),
                    )
                  ],
                ),
                const Divider(height: 16),
                
                if (viewModel.cycles.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48.0),
                    child: Center(child: Text('진행 중인 사이클이 없습니다.')),
                  )
                else
                  ...viewModel.cycles.map((cycle) => Card(
                        child: ListTile(
                          title: Text(cycle.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('종목: ${cycle.ticker} | ${cycle.divisionCount}분할'),
                          onTap: () => context.push('/cycleDetail', extra: cycle),
                          trailing: const Icon(Icons.arrow_forward_ios),
                        ),
                      )),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGoalProgressCard(BuildContext context, UserProfile user) {
    final double progress = (user.targetGoal > 0) ? (user.totalEarnings / user.targetGoal) : 0.0;
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('💰 목표 달성률', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currencyFormat.format(user.totalEarnings),
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                ),
                Text(currencyFormat.format(user.targetGoal)),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}