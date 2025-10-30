// lib/presentation/screens/cycle_management/trade_result_screen.dart

import 'package:flutter/material.dart';
import 'package:laour_cycle_manager/config/dependency_injection.dart';
import 'package:laour_cycle_manager/domain/entities/cycle.dart';
import 'package:laour_cycle_manager/domain/entities/order_guide.dart';
import 'package:laour_cycle_manager/presentation/view_models/trade_result_viewmodel.dart';
import 'package:provider/provider.dart';

class TradeResultScreen extends StatelessWidget {
  final Cycle cycle;
  final OrderGuide guide;

  const TradeResultScreen({super.key, required this.cycle, required this.guide});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<TradeResultViewModel>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${cycle.name} 결과 입력'),
        ),
        body: Consumer<TradeResultViewModel>(
          builder: (context, viewModel, child) {
            // 로딩 중일 때 화면 전체에 로딩 인디케이터 표시
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 안내 메시지
                  const Text(
                    '어제 걸어둔 주문이 체결되었나요?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '미션: ${guide.ticker} ${guide.price}에 ${guide.quantity?.toStringAsFixed(2)}주 매수',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // '체결됨 O' 버튼
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    onPressed: () async {
                      final success = await viewModel.submitResult(
                        cycleId: cycle.id,
                        wasExecuted: true,
                        price: guide.price!,
                        quantity: guide.quantity!,
                      );
                      if (success && context.mounted) {
                        Navigator.of(context).pop(); // 성공 시 이전 화면으로 돌아가기
                      }
                    },
                    child: const Text(
                      '체결됨 (O)',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // '미체결 X' 버튼
                  OutlinedButton(
                     style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    onPressed: () async {
                       final success = await viewModel.submitResult(
                        cycleId: cycle.id,
                        wasExecuted: false, // 체결되지 않음
                        price: 0, // 의미 없는 값
                        quantity: 0, // 의미 없는 값
                      );
                      if (success && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('미체결 (X)', style: TextStyle(fontSize: 20)),
                  ),
                  
                  // 에러 메시지 표시
                  if (viewModel.getErrorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        viewModel.getErrorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
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