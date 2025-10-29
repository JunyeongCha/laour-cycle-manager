// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_template/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Future<String?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String userId,
    required String dateOfBirth,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? newUser = userCredential.user;

      if (newUser != null) {
        await newUser.updateDisplayName(displayName);
        await newUser.reload();

        await _firestoreService.createUserDocument(
          user: newUser,
          email: email,
          displayName: displayName,
          userId: userId,
          dateOfBirth: dateOfBirth,
        );
        return null;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return '비밀번호가 너무 약합니다.';
      } else if (e.code == 'email-already-in-use') {
        return '이미 사용 중인 이메일입니다.';
      }
      return '회원가입 중 오류가 발생했습니다.';
    } catch (e) {
      return '알 수 없는 오류가 발생했습니다.';
    }
    return '회원가입에 실패했습니다.';
  }

  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException {
      return '이메일 또는 비밀번호가 잘못되었습니다.';
    } catch (e) {
      return '알 수 없는 오류가 발생했습니다.';
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return "로그인 상태를 확인해주세요.";
      }
      
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return '현재 비밀번호가 일치하지 않습니다.';
      }
      return '오류가 발생했습니다: ${e.message}';
    } catch (e) {
      return '알 수 없는 오류가 발생했습니다.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
}