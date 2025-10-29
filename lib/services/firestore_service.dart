// lib/services/firestore_service.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // MARK: - User Methods

  Future<void> createUserDocument({
    required User user,
    required String email,
    required String displayName,
    required String userId,
    required String dateOfBirth,
  }) async {
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': email,
      'displayName': displayName,
      'userId': userId,
      'dateOfBirth': dateOfBirth,
      'settings': {
        'themeMode': 'system',
        'seedColor': Colors.blue.value,
        'iconColor': Colors.blue.value,
        'fontScaleFactor': 1.0,
      }
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocument(String userId) {
    return _db.collection('users').doc(userId).get();
  }
  
  Future<void> saveUserSettings(String userId, Map<String, dynamic> settingsData) async {
    await _db.collection('users').doc(userId).update({
      'settings': settingsData,
    });
  }
}