// lib/domain/usecases/sign_out.dart

import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/domain/repositories/auth_repository.dart';

@lazySingleton
class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  Future<void> call() {
    return repository.signOut();
  }
}