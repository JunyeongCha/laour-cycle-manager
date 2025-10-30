// lib/domain/usecases/get_current_user.dart

import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/domain/entities/user_profile.dart';
import 'package:laour_cycle_manager/domain/repositories/auth_repository.dart';

@lazySingleton
class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  // This returns a real-time stream. The UI will listen to this stream
  // to automatically navigate between the sign-in screen and the main app.
  Stream<UserProfile?> call() {
    return repository.currentUser;
  }
}