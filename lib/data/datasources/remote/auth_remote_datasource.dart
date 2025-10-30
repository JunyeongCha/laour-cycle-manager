// lib/data/datasources/remote/auth_remote_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart'; // 1. Injectable 패키지 임포트
import 'package:laour_cycle_manager/data/models/user_profile_model.dart';

// 2. @lazySingleton: "이 클래스는 앱 전체에서 단 하나만 존재해야 하고,
//    처음 필요할 때 만들어줘" 라는 설계도 지시 스티커입니다.
@lazySingleton
class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSource(this._firebaseAuth, this._firestore);

  Stream<User?> get currentUser => _firebaseAuth.authStateChanges();

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required double targetGoal,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception("User creation failed.");
      }

      final userProfile = UserProfileModel(
        uid: user.uid,
        email: email,
        name: name,
        targetGoal: targetGoal,
        totalEarnings: 0.0,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userProfile.toJson());
          
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}