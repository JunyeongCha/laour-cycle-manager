// lib/models/user_profile.dart

/// Firestore의 'users' 컬렉션에 저장될 사용자 프로필 데이터 모델입니다.
class UserProfile {
  final String uid; // Firebase Auth의 사용자 고유 ID
  final String email;
  final String displayName; // 이름 (닉네임)
  final String userId; // 사용자가 직접 설정하는 아이디
  final String dateOfBirth; // 생년월일 (YYYY-MM-DD)
  final int completedItemsCount; // 사용자가 완료(체크)한 총 항목의 개수

class UserProfile {
    final String uid;
    final String email;
    final String? name;
    final double targetGoal; // 1차 목표 금액
    final double? secondTargetGoal; // 2차 목표 금액 (선택)
    final double totalEarnings; // 전체 사이클 누적 수익

    UserProfile({
        required this.uid,
        required this.email,
        this.name,
        this.targetGoal = 0.0, // 기본값 설정
        this.secondTargetGoal,
        this.totalEarnings = 0.0, // 기본값 설정
    });
}

  /// UserProfile 객체를 Firestore에 저장하기 위해 Map<String, dynamic> 형태로 변환하는 메소드
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'userId': userId,
      'dateOfBirth': dateOfBirth,
      'completedItemsCount': completedItemsCount,
      // 참고: isSetupComplete, must_have_options 등은 AuthService에서 별도로 관리됩니다.
    };
  }

  /// Firestore에서 가져온 Map<String, dynamic> 형태의 데이터를 UserProfile 객체로 변환하는 팩토리 생성자
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      userId: map['userId'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      completedItemsCount: map['completedItemsCount'] ?? 0,
    );
  }
}