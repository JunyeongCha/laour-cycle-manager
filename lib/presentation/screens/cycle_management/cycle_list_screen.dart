// lib/presentation/screens/cycle_management/cycle_list_screen.dart

import 'package.flutter/material.dart';
import 'package:go_router/go_router.dart'; // 1. GoRouter 임포트
import 'package:laour_cycle_manager/config/dependency_injection.dart';
import 'package:laour_cycle_manager/presentation/view_models/cycle_list_viewmodel.dart';
import 'package:provider/provider.dart';

class CycleListScreen extends StatelessWidget {
  const CycleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<CycleListViewModel>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('나의 사이클 목록'),
          // [추가] 마이페이지(설정) 화면으로 이동하는 버튼
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // 2. GoRouter를 사용하여 경로 이름으로 안전하게 이동
                context.push('/myPage');
              },
            ),
          ],
        ),
        body: Consumer<CycleListViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.cycles.isEmpty) {
              return const Center(
                child: Text(
                  '아직 생성된 사이클이 없습니다.\n아래 버튼을 눌러 새 사이클을 추가하세요!',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.builder(
              itemCount: viewModel.cycles.length,
              itemBuilder: (context, index) {
                final cycle = viewModel.cycles[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(cycle.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('종목: ${cycle.ticker} | ${cycle.divisionCount}분할'),
                    // [수정] ListTile을 탭하면 사이클 상세 페이지로 이동
                    onTap: () {
                      // 3. GoRouter를 사용하여 '/cycleDetail' 경로로 이동
                      // state.extra를 통해 Cycle 객체를 통째로 전달합니다.
                      context.push('/cycleDetail', extra: cycle);
                    },
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // [수정] GoRouter를 사용하여 새 사이클 추가 화면으로 이동
            context.push('/addCycle');
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}