// lib/presentation/view_models/sign_up_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/data/models/account_model.dart';
import 'package:laour_cycle_manager/domain/usecases/sign_up.dart';

@injectable
class SignUpViewModel extends ChangeNotifier {
  final SignUp _signUpUseCase;
  final _storage = const FlutterSecureStorage(); // SecureStorage 인스턴스

  SignUpViewModel(this._signUpUseCase);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get getErrorMessage => _errorMessage;

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String targetGoal,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final double targetGoalAmount = double.tryParse(targetGoal) ?? 0.0;
      
      await _signUpUseCase(
        email: email,
        password: password,
        name: name,
        targetGoal: targetGoalAmount,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = '회원가입에 실패했습니다. 이미 사용 중인 이메일이거나 비밀번호가 너무 짧습니다.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // UI의 요청에 따라 실제로 로그인 정보를 저장하는 메소드
  Future<void> saveCredentials({required String email, required String password}) async {
    final accountsJson = await _storage.read(key: 'saved_accounts');
    List<Account> savedAccounts = [];
    if (accountsJson != null && accountsJson.isNotEmpty) {
      savedAccounts = Account.decode(accountsJson);
    }
    
    // 중복 체크 후 추가
    final existingAccountIndex = savedAccounts.indexWhere((acc) => acc.email == email);
    if (existingAccountIndex != -1) {
      savedAccounts[existingAccountIndex] = Account(email: email, password: password);
    } else {
      savedAccounts.add(Account(email: email, password: password));
    }
    
    await _storage.write(
      key: 'saved_accounts',
      value: Account.encode(savedAccounts),
    );
  }
}