// lib/domain/usecases/complete_cycle.dart

import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/domain/entities/cycle.dart';
import 'package:laour_cycle_manager/domain/entities/portfolio_state.dart';
import 'package:laour_cycle_manager/domain/repositories/cycle_repository.dart';
import 'package:laour_cycle_manager/domain/repositories/user_repository.dart'; // [추가] UserRepository 설계도

@lazySingleton
class CompleteCycle {
  final CycleRepository _cycleRepository;
  final UserRepository _userRepository; // [추가]

  CompleteCycle(this._cycleRepository, this._userRepository);

  Future<void> call({
    required Cycle cycle,
    required PortfolioState portfolioState,
    required String userId,
  }) async {
    // 1. 수익금 계산
    final double profit = portfolioState.unrealizedProfitOrLoss;

    // 2. Cycle 상태를 'completed'로 업데이트
    final updatedCycle = cycle.copyWith(
      status: CycleStatus.completed,
      completedAt: DateTime.now(),
    );
    await _cycleRepository.updateCycle(updatedCycle); // [수정] updateCycle 메소드 필요

    // 3. UserProfile의 totalEarnings 업데이트
    await _userRepository.updateUserEarnings(userId: userId, profit: profit); // [수정] updateUserEarnings 메소드 필요
  }
}