// lib/data/repositories/user_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:laour_cycle_manager/data/models/user_profile_model.dart';
import 'package:laour_cycle_manager/domain/entities/user_profile.dart';
import 'package:laour_cycle_manager/domain/repositories/user_repository.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;

  UserRepositoryImpl(this._firestore);

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserProfileModel.fromSnapshot(doc).toEntity();
    }
    return null;
  }

  @override
  Future<void> updateUserEarnings({required String userId, required double profit}) {
    // FieldValue.increment를 사용하여 안전하게 수익을 누적합니다.
    return _firestore.collection('users').doc(userId).update({
      'totalEarnings': FieldValue.increment(profit),
    });
  }
}