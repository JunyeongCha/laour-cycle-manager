// lib/presentation/view_models/auth_gate_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/domain/entities/user_profile.dart';
import 'package:laour_cycle_manager/domain/usecases/get_current_user.dart';

@injectable
class AuthGateViewModel extends ChangeNotifier {
  final GetCurrentUser _getCurrentUserUseCase;

  AuthGateViewModel(this._getCurrentUserUseCase);

  // 현재 사용자 상태를 실시간으로 UI에 전달하는 Stream getter
  Stream<UserProfile?> get userStream => _getCurrentUserUseCase();
}