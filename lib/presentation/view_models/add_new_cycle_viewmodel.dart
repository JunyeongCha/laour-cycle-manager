// lib/presentation/view_models/add_new_cycle_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/domain/entities/cycle.dart';
import 'package:laour_cycle_manager/domain/entities/user_profile.dart';
import 'package:laour_cycle_manager/domain/usecases/add_new_cycle.dart';
import 'package:laour_cycle_manager/domain/usecases/get_current_user.dart';

@injectable
class AddNewCycleViewModel extends ChangeNotifier {
  final AddNewCycle _addNewCycleUseCase;
  final GetCurrentUser _getCurrentUserUseCase;

  AddNewCycleViewModel(this._addNewCycleUseCase, this._getCurrentUserUseCase);

  // 화면의 상태를 나타내는 변수들
  bool _isLoading = false;
  String? _errorMessage;
  UserProfile? _currentUser;

  // UI에서 상태를 읽기 위한 getter
  bool get isLoading => _isLoading;
  String? get getErrorMessage => _errorMessage;

  // 새 사이클을 생성하는 메인 메소드
  Future<bool> addNewCycle({
    required String name,
    required String ticker,
    required String totalInvestmentAmount,
    required String divisionCount,
    required String targetProfitPercentage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 현재 로그인된 사용자 정보를 가져옵니다.
    _currentUser = await _getCurrentUserUseCase().first;
    if (_currentUser == null) {
      _errorMessage = '로그인 정보가 없습니다. 다시 로그인해주세요.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      // 입력받은 문자열 값들을 숫자(double, int)로 변환합니다.
      final double amount = double.parse(totalInvestmentAmount);
      final int divisions = int.parse(divisionCount);
      final double profitTarget = double.parse(targetProfitPercentage);

      // Domain 계층의 Cycle 엔티티를 생성합니다.
      final newCycle = Cycle(
        // ID는 Firestore에서 자동으로 생성되므로 임시 값을 사용합니다.
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _currentUser!.uid,
        name: name,
        ticker: ticker.toUpperCase(), // 티커는 대문자로 통일
        totalInvestmentAmount: amount,
        divisionCount: divisions,
        targetProfitPercentage: profitTarget,
        status: CycleStatus.inProgress, // 초기 상태는 '진행 중'
        createdAt: DateTime.now(),
      );

      // Usecase를 실행하여 사이클을 Firestore에 저장합니다.
      await _addNewCycleUseCase(newCycle);

      _isLoading = false;
      notifyListeners();
      return true; // 성공 반환

    } catch (e) {
      _errorMessage = '사이클 생성에 실패했습니다. 입력 값을 확인해주세요.';
      _isLoading = false;
      notifyListeners();
      return false; // 실패 반환
    }
  }
}