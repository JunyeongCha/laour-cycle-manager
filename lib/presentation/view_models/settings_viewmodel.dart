// lib/presentation/view_models/settings_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/domain/usecases/sign_out.dart';

@injectable
class SettingsViewModel extends ChangeNotifier {
  final SignOut _signOutUseCase;

  SettingsViewModel(this._signOutUseCase);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 로그아웃 기능을 수행하는 메소드
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 주입받은 SignOut Usecase를 실행합니다.
      await _signOutUseCase();
      // 성공/실패 여부와 관계없이 로딩 상태를 종료합니다.
      // AuthGate가 Stream을 통해 상태 변화를 감지하고 자동으로 로그인 화면으로 보내줄 것입니다.
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      // TODO: 로그아웃 실패 시 에러 처리 (예: 스낵바 표시)
    }
  }
}