// lib/domain/usecases/sign_up.dart

import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/domain/repositories/auth_repository.dart';

@lazySingleton
class SignUp {
  final AuthRepository repository;

  SignUp(this.repository);

  Future<void> call({
    required String email,
    required String password,
    required String name,
    required double targetGoal,
  }) {
    return repository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
      targetGoal: targetGoal,
    );
  }
}