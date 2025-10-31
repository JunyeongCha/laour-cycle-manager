// lib/domain/repositories/user_repository.dart
import 'package:laour_cycle_manager/domain/entities/user_profile.dart';

abstract class UserRepository {
  Future<UserProfile?> getUserProfile(String userId);
  Future<void> updateUserEarnings({required String userId, required double profit});
}