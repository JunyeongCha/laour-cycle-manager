// lib/domain/entities/user_profile.dart

import 'package:equatable/equatable.dart';

// Equatable을 상속받으면 객체끼리 내용을 쉽게 비교할 수 있어 편리합니다.
class UserProfile extends Equatable {
  final String uid; // 사용자의 고유 ID (Firebase Auth에서 제공)
  final String email; // 사용자의 이메일
  final String? name; // 사용자 이름 (선택)
  final double targetGoal; // 1차 목표 금액
  final double? secondTargetGoal; // 2차 목표 금액 (1차 달성 후 설정 가능)
  final double totalEarnings; // 모든 사이클에서 누적된 총수익

  const UserProfile({
    required this.uid,
    required this.email,
    this.name,
    this.targetGoal = 0.0, // 회원가입 시 기본값
    this.secondTargetGoal,
    this.totalEarnings = 0.0, // 초기값
  });

  @override
  List<Object?> get props => [
        uid,
        email,
        name,
        targetGoal,
        secondTargetGoal,
        totalEarnings,
      ];
}