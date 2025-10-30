// lib/data/repositories/auth_repository_impl.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart'; // 1. Injectable 패키지 임포트
import 'package:laour_cycle_manager/data/datasources/remote/auth_remote_datasource.dart';
import 'package:laour_cycle_manager/data/models/user_profile_model.dart';
import 'package:laour_cycle_manager/domain/entities/user_profile.dart';
import 'package:laour_cycle_manager/domain/repositories/auth_repository.dart';

// 2. @LazySingleton 스티커를 붙이되, AuthRepository 타입으로 등록되도록 지정합니다.
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this.remoteDataSource, this._firestore);

  @override
  Stream<UserProfile?> get currentUser {
    return remoteDataSource.currentUser.asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      } else {
        final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (userDoc.exists) {
          return UserProfileModel.fromSnapshot(userDoc).toEntity();
        }
        return null;
      }
    });
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return remoteDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required double targetGoal,
  }) {
    return remoteDataSource.signUpWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
      targetGoal: targetGoal,
    );
  }

  @override
  Future<void> signOut() {
    return remoteDataSource.signOut();
  }
}