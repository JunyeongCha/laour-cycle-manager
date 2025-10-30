// lib/presentation/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:laour_cycle_manager/config/dependency_injection.dart';
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
          title: const Text('Laour Cycle Manager'),
        ),
        body: Consumer<DashboardViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 인사말 및 오늘의 명언
                  Text(
                    '안녕하세요, ${viewModel.userName ?? '사용자'}님!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '"시장은 예측하는 것이 아니라 대응하는 것이다."', // TODO: 명언 기능 구현
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 24),

                  // 2. 오늘의 통합 체크리스트
                  Text(
                    '✅ 오늘의 할 일',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(height: 16),
                  
                  // 할 일이 없을 때 메시지 표시
                  if (viewModel.tasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: Text('오늘 해야 할 일이 없습니다!')),
                    ),

                  // 할 일이 있을 때 목록 표시
                  Expanded(
                    child: ListView.builder(
                      itemCount: viewModel.tasks.length,
                      itemBuilder: (context, index) {
                        final task = viewModel.tasks[index];
                        return CheckboxListTile(
                          title: Text(task.description),
                          value: task.isCompleted,
                          onChanged: (bool? value) {
                            // TODO: 체크박스 상태 변경 로직 구현
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}