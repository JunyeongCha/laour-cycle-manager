// lib/domain/usecases/sign_in.dart

import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/domain/repositories/auth_repository.dart';

@lazySingleton
class SignIn {
  final AuthRepository repository;

  SignIn(this.repository);

  Future<void> call({required String email, required String password}) {
    return repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}