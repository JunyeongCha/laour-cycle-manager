// lib/presentation/view_models/sign_in_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/data/models/account_model.dart';
import 'package:laour_cycle_manager/domain/usecases/sign_in.dart';

// ViewModel이 반환할 로그인 결과 타입
enum SignInResult { success, successAndAskToSave, failure }

@injectable
class SignInViewModel extends ChangeNotifier {
  final SignIn _signInUseCase;
  final _storage = const FlutterSecureStorage(); // SecureStorage 인스턴스

  SignInViewModel(this._signInUseCase);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get getErrorMessage => _errorMessage;
  
  // 로그인 로직을 포함하여, 저장된 계정인지 확인하는 로직까지 담당합니다.
  Future<SignInResult> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _signInUseCase(email: email, password: password);
      _isLoading = false;
      notifyListeners();

      // 로그인 성공 후, 이 계정이 이미 저장되어 있는지 확인합니다.
      final accountsJson = await _storage.read(key: 'saved_accounts');
      if (accountsJson != null && accountsJson.isNotEmpty) {
        final savedAccounts = Account.decode(accountsJson);
        final isAlreadySaved = savedAccounts.any((acc) => acc.email == email);
        // 이미 저장된 계정이면 그냥 성공을 반환합니다.
        if (isAlreadySaved) {
          return SignInResult.success;
        }
      }
      // 저장되지 않은 새 계정이면, 저장할지 물어보라는 신호를 반환합니다.
      return SignInResult.successAndAskToSave;

    } catch (e) {
      _errorMessage = '로그인에 실패했습니다. 이메일 또는 비밀번호를 확인해주세요.';
      _isLoading = false;
      notifyListeners();
      return SignInResult.failure;
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