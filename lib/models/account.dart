// lib/models/account.dart

import 'dart:convert';

/// 자동 로그인을 위해 기기에 저장될 사용자의 계정 정보를 담는 클래스입니다.
/// flutter_secure_storage에 JSON 문자열 형태로 저장됩니다.
class Account {
  final String email;
  final String password;

  Account({required this.email, required this.password});

  /// Account 객체를 Map 형태로 변환합니다. JSON 인코딩 시 사용됩니다.
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
    };
  }

  /// Map 형태의 데이터를 Account 객체로 변환합니다. JSON 디코딩 시 사용됩니다.
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      email: map['email'] ?? '',
      password: map['password'] ?? '',
    );
  }

  /// Account 객체 리스트를 JSON 문자열로 인코딩하는 정적 메서드입니다.
  static String encode(List<Account> accounts) => json.encode(
        accounts
            .map<Map<String, dynamic>>((account) => account.toMap())
            .toList(),
      );

  /// JSON 문자열을 Account 객체 리스트로 디코딩하는 정적 메서드입니다.
  static List<Account> decode(String accounts) =>
      (json.decode(accounts) as List<dynamic>)
          .map<Account>((item) => Account.fromMap(item))
          .toList();
}