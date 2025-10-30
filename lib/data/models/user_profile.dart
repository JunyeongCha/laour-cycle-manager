// lib/data/models/user_profile.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laour_cycle_manager/domain/entities/user_profile.dart';

// 이 클래스는 Firestore에 있는 사용자 프로필의 데이터 구조를 나타냅니다.
class UserProfileModel {
  final String uid;
  final String email;
  final String? name;
  final double targetGoal;
  final double? secondTargetGoal;
  final double totalEarnings;

  UserProfileModel({
    required this.uid,
    required this.email,
    this.name,
    required this.targetGoal,
    this.secondTargetGoal,
    required this.totalEarnings,
  });

  // Firestore 문서로부터 UserProfileModel을 생성하는 factory 생성자입니다.
  factory UserProfileModel.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return UserProfileModel(
      uid: snap.id,
      email: data['email'],
      name: data['name'],
      targetGoal: (data['targetGoal'] as num).toDouble(),
      secondTargetGoal: (data['secondTargetGoal'] as num?)?.toDouble(),
      totalEarnings: (data['totalEarnings'] as num).toDouble(),
    );
  }

  // UserProfileModel 객체를 Firestore에 저장하기 위한 Map 형태로 변환합니다.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'targetGoal': targetGoal,
      'secondTargetGoal': secondTargetGoal,
      'totalEarnings': totalEarnings,
    };
  }

  // 이 데이터 모델(Model)을 Domain 계층의 순수 객체(Entity)로 변환합니다.
  UserProfile toEntity() {
    return UserProfile(
      uid: uid,
      email: email,
      name: name,
      targetGoal: targetGoal,
      secondTargetGoal: secondTargetGoal,
      totalEarnings: totalEarnings,
    );
  }
}